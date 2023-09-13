// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../actuator/actuator.dart';
import '../asset_manager.dart';
import '../main.dart';
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
            await BluetoothMessageHandler()
                .processResponse(call.arguments.split("\n"));
            break;
        }
      });
    }
  }

  BluetoothManager({bool test = false}) {
    if (!test) {
      initBluetoothResponse();
    }

    if (devicesCopy.isNotEmpty) {
      devices = devicesCopy[0] as List<Device>;
      deviceAddresses = devicesCopy[1] as List<String>;
    }
  }

  static Future<String> getBoardNumber() async {
    return await androidPlatform.invokeMethod("getBoardNumber");
  }

  String getName() {
    return Actuator.connectedActuator.name;
  }

  void getPairedDevices() {
    androidPlatform.invokeMethod("getBonded").then((temp) {
      for (LinkedHashMap device in temp) {
        if (kDebugMode) {
          print(device["name"]?.startsWith("RIFT") ?? false);
        }
        if (!deviceAddresses.contains(device["address"])) {
          if (device["name"]?.startsWith("RIFT") ?? false) {
            if (kDebugMode) {
              print(device["rssi"].toString());
            }
            devices.add(Device(
                device["name"].toString(),
                device["address"].toString(),
                device["alias"].toString(),
                device["rssi"].toString(),
                this));
            deviceAddresses.add(device["address"].toString());
          }
        }
      }
    });
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
          devices.add(Device(
              device["name"].toString(),
              device["address"].toString(),
              device["alias"].toString(),
              device["rssi"].toString(),
              this));
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

  void enableBluetooth(BuildContext context) async {
    await androidPlatform.invokeMethod("enableBluetooth").then((value) {
      if (value) {
        showSnackBar(
            context, StringConsts.bluetooth.successfullyTurnedOn, null, null);
      }
    });
  }

  Future<void> scan() async {
    // returns a list of hashmaps
    tempDevices = await androidPlatform.invokeMethod("scan");

    isScanning = true;

    Future.delayed(const Duration(seconds: 12), () {
      isScanning = false;
    });

    getDevices();
  }

  final int connectionAttemptsLimit = 5;
  int connectionsAttempted = 0;

  Future<void> connect(String address, BuildContext context) async {
    bool timedOut = false;
    await androidPlatform.invokeMethod("connect",
        {"address": address.toString(), "secure": "true"}).then((result) async {
      if (result == connecting) {
        // still connecting need to wait longer and continually check the result
        // only check while timeout time is less than time passed
        Future.delayed(Duration(seconds: timeOutDelay), () {
          // timeout
          timedOut = true;
        });
        connectionStatus = connecting;

        // check connection status
        // start on a different thread
        while (result == connecting && !timedOut) {
          result = await androidPlatform.invokeMethod("getConnectionStatus");
          connectionStatus = result;
        }
      }

      if (result == failed) {
        connectionsAttempted++;

        if (connectionsAttempted <= connectionAttemptsLimit) {
          // retry connection
          disconnect();
          connect(address, context);
        } else {
          // fail connection
          showSnackBar(context,
              "${StringConsts.bluetooth.failedConnection}$address", null, null);
          Actuator.connectingDeviceAddress = null;
          Actuator.connectedDeviceAddress = null;
          connectingDeviceAddress = null;
          connectedDeviceAddress = null;
          connectionStatus = failed;
          disconnect();
        }
      }

      if (result == connected) {
        connectionsAttempted = 0;
        // success
        _startKeepAlive();
        connectionStatus = connected;
        showSnackBar(
            context, StringConsts.bluetooth.connectedSuccessfully, null, null);
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
        Actuator.connectedActuator.settings.updateFeatures();

        Actuator.connectedActuator.status = StringConsts.actuators.connected;

        Future.delayed(const Duration(seconds: 1), () {
          messageHandler.getBootloaderStatus();
          messageHandler.requestAutoManual();
          WebController().getFeaturePasswords();
          messageHandler.getInformation();
        });
      }
    });
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

  void writeBootloader() async {
    // Start transfer key
    Uint8List hash = Uint8List(1);
    hash[0] = 35;
    write(hash);

    // set writing to flash - test
    Actuator.connectedActuator.writingToFlash = true;

    sleep(const Duration(milliseconds: 100));

    String fileData = await AssetManager.getActuatorHex();
    List<int> data = [];
    fileData = fileData.trim();
    for (int i = 0; i < fileData.length; i += 2) {
      // get every 2 characters
      String hex = fileData[i] + fileData[i + 1];

      // convert to bytes
      int byte = hexStringToInt(hex);

      // add to list
      data.add(byte);
    }

    // write list
    write(Uint8List.fromList(data));

    if (Actuator.connectedActuator.settings.parityEnabled) {
      sendMessage(code: "!");
      sendMessage(code: (getParity(0) ? 1 : 0).toString());
      //parity?

      //sleep(Duration(milliseconds: 10));
    }
  }

  void write(Uint8List bytes) {
    androidPlatform.invokeMethod("write", {"bytes": bytes});
  }

  int hexStringToInt(String s) {
    return (int.parse(s[0], radix: 16) << 4) + int.parse(s[1], radix: 16);
  }

  bool getParity(int n) {
    bool parity = false;
    while (n != 0) {
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
        androidPlatform.invokeMethod(
            "sendBluetoothMessage", {"code": code, "param": value});
      } else {
        androidPlatform.invokeMethod("sendBluetoothMessage", {"code": code});
      }
    } else {
      androidPlatform.invokeMethod("sendBluetoothMessage", {"code": code});
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
