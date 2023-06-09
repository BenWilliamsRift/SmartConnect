// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../actuator/actuator.dart';
import '../asset_manager.dart';
import '../main.dart';
import '../preference_manager.dart';
import '../string_consts.dart';
import '../web_controller.dart';
import 'bluetooth_message_handler.dart';

class Device {
  BluetoothManager bluetoothManager;
  String name;
  String alias;
  String address;

  // large the closer
  // -26 (a few inches) to -100 (40–50 m distance)
  String rssi;

  getRssi() => int.parse(rssi);

  Device(this.name, this.address, this.alias, this.rssi, this.bluetoothManager);

  get getStrength {
    return Icons.signal_wifi_4_bar;
  }

  @override
  String toString() {
    return "name: $name, address: $address";
  }

  void setAlias(String value) {
    if (value != alias) {
      bluetoothManager.setAlias(value);
    }
  }
}

class BluetoothManager {
  static String? passwords;

  static MethodChannel androidPlatform = const MethodChannel("bluetooth");

  static List<List<dynamic>> devicesCopy = [];

  List<Device> devices = [];
  List<String> deviceAddresses = [];

  static const int connecting = 0;
  static const int failed = 1;
  static const int connected = 2;
  late int connectionStatus = connecting;

  static int timeOutDelay = 15; // In seconds

  String? connectingDeviceAddress;
  String? connectedDeviceAddress;

  static late MethodChannel bluetoothResponse;

  static bool bluetoothResponseInitialized = false;

  static void initBluetoothResponse() async {
    if (!bluetoothResponseInitialized) {
      bluetoothResponseInitialized = true;
      bluetoothResponse = const MethodChannel("bluetooth-response");
      bluetoothResponse.setMethodCallHandler((call) async {
        switch (call.method) {
          case "bluetoothCommandResponse":
            await BluetoothMessageHandler().processResponse(call.arguments.split("\n"));
            break;
        }
      });
    }
  }

  BluetoothManager() {
    initBluetoothResponse();

    if (devicesCopy.isNotEmpty) {
      devices = devicesCopy[0] as List<Device>;
      deviceAddresses = devicesCopy[1] as List<String>;
    }
  }

  static Future<String> getBoardNumber() async {
    return await androidPlatform.invokeMethod("getBoardNumber");
  }

  String getName() {
    // TODO getName
    return "";
  }

  static bool isActuatorConnected = false;

  Future<bool> isConnected() async {
    ColorNotifier colorNotifier = ColorNotifier();
    bool connected = await androidPlatform.invokeMethod("isConnected");
    colorNotifier.updateColor(connected ? Colors.green : Colors.red);
    return connected;
  }

  Future<bool> isConnecting() async {
    return await androidPlatform.invokeMethod("isConnecting");
  }

  void refresh() async {
    tempDevices = await androidPlatform.invokeMethod("getDevices");
    getDevices();
  }

  void getDevices() async {
    for (LinkedHashMap device in tempDevices) {
      if (!deviceAddresses.contains(device["address"])) {
        if (device["name"]?.startsWith("RIFT") ?? false) {
          if (kDebugMode) {
            print(device["rssi"].toString());
          }
          devices.add(Device(device["name"].toString(), device["address"].toString(), device["alias"].toString(), device["rssi"].toString(), this));
          deviceAddresses.add(device["address"].toString());
        }
      }
    }

    devicesCopy = [devices, deviceAddresses];
  }

  void keepAlive() {
    androidPlatform.invokeMethod("keepAlive");
  }

  var tempDevices = [];

  bool isScanning = false;

  Future<void> scan() async {
    // returns a list of hashmaps
    tempDevices = await androidPlatform.invokeMethod("scan");

    isScanning = true;

    Future.delayed(const Duration(seconds: 12), () {
      isScanning = false;
    });

    getDevices();
  }

  void isTimedOut(BuildContext context, bool timedOut) {
    if (timedOut && connectionStatus != connected) {
      showSnackBar(context, StringConsts.bluetooth.timedOut, null, null);
    }
  }

  Future<void> connect(String address, BuildContext context) async {
    int result = 0;
    result = await androidPlatform.invokeMethod(
        "connect", {"address": address.toString(), "secure": "true"});

    bool timedOut = false;

    // Test this
    // Still connecting
    while (connectionStatus == connecting && timedOut == false) {
      if (result == connecting) {
        connectionStatus = connecting;
        // Start timeout counter
        Future.delayed(Duration(seconds: timeOutDelay), () {
          if (Actuator.connectedDeviceAddress != null) {
            timedOut = true;
            isTimedOut(context, timedOut);
            result = failed;
            Actuator.connectingDeviceAddress = null;
          }
        });

        // Every 3 seconds check if the connection status had changed
        await Future.delayed(const Duration(seconds: 3), () async {
          result = await androidPlatform.invokeMethod("getConnectionStatus");
        });
      }
      // Failed connection
      else if (result == failed) {
        // throw  a Exception("Error connecting");
        connectionStatus = failed;
        showSnackBar(context,
            "${StringConsts.bluetooth.failedConnection}$address", null, null);
        Actuator.connectingDeviceAddress = null;
        Actuator.connectedDeviceAddress = null;
        connectingDeviceAddress = null;
        connectedDeviceAddress = null;
      }
      // Successful connection
      else if (result == connected) {
        _startKeepAlive();
        showSnackBar(
            context, StringConsts.bluetooth.connectedSuccessfully, null, null);
        connectionStatus = connected;
        connectedDeviceAddress = connectingDeviceAddress;
        // Stop the progress indicator
        connectingDeviceAddress = null;
        ConnectedNotification connectedNotification = ConnectedNotification();
        connectedNotification.stopProgressBar(context);

        Actuator.connectedActuator = Actuator(
            firmwareVersion: 1.22,
            valveOrientation: 0.0,
            backlash: 0,
            buttonsEnabled: true,
            numberOfFullCycles: 0,
            numberOfStarts: 36,
            sleepWhenNotPowered: true,
            magnetTestMode: false,
            startInManualMode: false,
            indicationMode: 0,
            reverseActing: false);
      }
    }

    if (connectionStatus == connected) {
      BluetoothMessageHandler messageHandler = BluetoothMessageHandler();
      // messageHandler.requestAngle();
      String boardNumber = await getBoardNumber();
      Actuator.connectedActuator.boardNumber = int.parse(boardNumber);

      // Should process the string down to just a few letters and numbers

      // Example Line of passwords
      // \":\"243\",\"android_verification\":\"\",\"Type\":\"medium\",\"note\":null},{\"

      // Board Number: 20319, Password: sX4vt1eX
      String? password = Actuator.passwords
          .split("board_number")
          .firstWhere((line) => line.contains(boardNumber.toString()),
              orElse: () => "")
          .replaceAll("\n", "")
          .split('"')[6];

      String? type = Actuator.passwords
          .split("board_number")
          .firstWhere((line) => line.contains(boardNumber.toString()),
              orElse: () => "")
          .replaceAll("\n", "")
          .split('Type":"')[1]
          .split('","')[0];

      Actuator.connectedActuator.type = type;

      if (password != null) {
        messageHandler.verify(password);
      } else {
        showSnackBar(context, StringConsts.actuators.errorValidatingActuators,
            null, null);
      }

      // routeToPage(context, const ControlPage());
      isActuatorConnected = true;
      messageHandler.getInformation();
      String? response = await WebController().getFeaturePasswords();

      Actuator.connectedActuator.status = StringConsts.actuators.connected;

      if (response == null) {
        showSnackBar(
            context, StringConsts.actuators.failedToUpdateFeatures, null, null);
      } else {
        // write passwords to file

        response = response.replaceAll("<br>", "\n");

        PreferenceManager.writeString(
            PreferenceManager.passwords, response.toString());
      }

      Future.delayed(const Duration(seconds: 1), () {
        messageHandler.requestAutoManual();
        WebController().getFeaturePasswords();
        messageHandler.getInformation();
      });
    }
  }

  void _startKeepAlive() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      updateActuatorPassword();
      keepAlive();
    });
  }

  void updateActuatorPassword() {
    androidPlatform.invokeMethod(
        "updateActuatorPassword", {"password": Actuator.passwords});
  }

  Future<void> disconnect() async {
    if (Actuator.connectedDeviceAddress != null) {
      isActuatorConnected = false;
      Actuator.connectedDeviceAddress = null;
      Actuator.connectingDeviceAddress = null;
      androidPlatform.invokeMethod("disconnect");
    }
  }

  // TODO test
  void writeBootloader(BuildContext context) async {
    // Start transfer key
    // send 35 to the actuator
    // 35 is the ASCII code for #
    sendMessage(code: '#');

    sleep(const Duration(milliseconds: 100));

    Uint8List hexBufferData = Uint8List(40000);
    int offset = 0;
    try {
       ByteData fileData = await DefaultAssetBundle.of(context).load(AssetManager.hexFileName);
       Uint8List fileBytes = fileData.buffer.asUint8List();
        int length = fileBytes.length;
        int chunkSize = 40000;
        while (offset < length) {
          int end = offset + chunkSize < length ? offset + chunkSize : length;
          hexBufferData.setRange(0, end - offset, fileBytes.sublist(offset, end));
          List<int> array = hexStringToByteArray(utf8.decode(hexBufferData.sublist(0, end - offset)));
          sendMessage(code: String.fromCharCodes(array));

          if (Actuator.connectedActuator.settings.parityEnabled) {
            sendMessage(code: "!");
            sendMessage(code: (getParity(end - offset) ? 1 : 0).toString());
        }
        offset += chunkSize;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  List<int> hexStringToByteArray(String hexString) {
    List<int> bytes = [];
    for (int i = 0; i < hexString.length; i += 2) {
      String hex = hexString.substring(i, i + 2);
      int byte = int.parse(hex, radix: 16);
      bytes.add(byte);
    }
  return bytes;
}

  bool getParity(int n){
    bool parity = false;
    while(n != 0) {
      parity = !parity;
      n = n & (n - 1);
    }
    return parity;
  }

  Future<void> getIsScanning() async {
    isScanning = await androidPlatform.invokeMethod("isScanning");
  }

  void sendMessage({required String code, String? value}) async {
    if (!Actuator.connectedActuator.writingToFlash) {
      if (value != null) {
        androidPlatform.invokeMethod("sendBluetoothMessage", {"code": code, "param": value});
      } else {
        androidPlatform.invokeMethod("sendBluetoothMessage", {"code": code});
      }
    }
  }

  void setAlias(String alias) {
    androidPlatform.invokeMethod("setAlias", {"alias": alias});
  }
}

class ConnectedNotification extends Notification {
  stopProgressBar(BuildContext context) {
    dispatch(context);
  }
}
