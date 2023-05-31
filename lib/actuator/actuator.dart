import 'dart:async';

import 'package:flutter/material.dart';

import '../String_consts.dart';
import '../bluetooth/bluetooth_manager.dart';
import '../bluetooth/bluetooth_message_handler.dart';
import '../date_time.dart';
import '../main.dart';
import 'actuator_settings.dart';

class Actuator {
  static String? connectingDeviceAddress = "";
  static String? connectedDeviceAddress = "";

  static Actuator connectedActuator = Actuator(
    firmwareVersion: 0,
    backlash: 0.0,
    buttonsEnabled: false,
    indicationMode: 0,
    magnetTestMode: false,
    numberOfFullCycles: 0,
    numberOfStarts: 0,
    reverseActing: false,
    sleepWhenNotPowered: false,
    startInManualMode: false,
    valveOrientation: 0,
  );

  static late String passwords;

  static void writeToFlash(BuildContext context, BluetoothMessageHandler bluetoothMessageHandler) {
    showAlert(
        context: context,
        content: Text(StringConsts.actuators.confirmWriteToFlash),
        actions: [
          TextButton(
            onPressed: (() {
              Navigator.of(context).pop();
            }),
            child: const Text(StringConsts.cancel),
          ),
          TextButton(
            onPressed: (() {
              Navigator.of(context).pop();
              showSnackBar(context, StringConsts.actuators.settingsSaved, null, null);
              bluetoothMessageHandler.writeToFlash();
              // Update any open page listening for the ActuatorNotification
              ActuatorNotification().updateWriteToFlash(context);
            }),
            child: const Text(StringConsts.confirm),
          ),
        ]);
  }

  Actuator({
    required double firmwareVersion,
    required double valveOrientation,
    required double backlash,
    required bool buttonsEnabled,
    required int numberOfFullCycles,
    required int numberOfStarts,
    required bool sleepWhenNotPowered,
    required bool magnetTestMode,
    required bool startInManualMode,
    required int indicationMode,
    required bool reverseActing,
  }) {
    bluetoothManager = BluetoothManager();
    settings = ActuatorSettings(
        firmwareVersion,
        valveOrientation,
        backlash,
        buttonsEnabled,
        numberOfFullCycles,
        numberOfStarts,
        sleepWhenNotPowered,
        magnetTestMode,
        startInManualMode,
        indicationMode,
        reverseActing);
  }

  late ActuatorSettings settings;

  late BluetoothManager bluetoothManager;

  bool connectedToBoard = false;
  bool bootloaderFlashing = false;
  bool writingToFlash = false;

  // We require response of m58 before sending multiple features
  bool featureReady = true;
  bool needFlash = false;

  int? boardNumber;

  late String? type;

  static const String typeSmall = "small";
  static const String typeEcoSmall = "ecosmall";
  static const String typeMedium = "medium";
  static const String typeEcoMedium = "ecomedium";
  static const String typeLarge = "large";
  static const String typeSubsea = "subsea";

  Future<bool> isConnected() async {
    return await bluetoothManager.isConnected();
  }

  bool connect() {
    // TODO connect methods
    return false;
  }

  Future<bool> isConnecting() async {
    return await bluetoothManager.isConnecting();
  }

  void disconnect() {
    bluetoothManager.disconnect();
  }

  bool isSmallActuator() {
    return bluetoothManager.getName().startsWith("SACO2") ||
        bluetoothManager.getName().startsWith("PF") ||
        type == typeSmall;
  }

  static List<String> indicationModes = [
    "Normal Two Way",
    "L Port 90",
    "L Port 180",
    "T Port 90 Diverting",
    "T Port 90 Mixing",
  ];

  static List<String> valveOrientations = [
    "Square",
    "Diamond shaped",
  ];

  static List<double> valveOrientationAngles = [
    -45.0,
    0.0
  ];

  static List<String> failsafeModes = [
    "Off",
    "Open",
    "Close",
    "Specific angle",
  ];

  static List<String> modulatingModes = [
    "Low Signal",
    "Stay Put",
    "High Signal",
    "Specific Angle",
    "Continue Move"
  ];

  static List<String> analogSignalModes = [
    "Off",
    "0 to 10V",
    "4 to 20mA",
    "0 to 20mA",
    "10V Switch Open",
    "10V Switch Close",
    "Low Battery Switch"
  ];

  static List<String> lossOfSignalModes = [
    "Low Signal",
    "Stay Put",
    "High Signal",
    "Specific Angle",
    "Continue Move"
  ];

  // If of sort modes is changed at all go to actuator_pages > ConnectionPage > sortedDevices
  static List<String> connectionSortModes = [
    "Connection Strength",
    "Board No. \u2191",
    "Board No. \u2193",
    "Flash Date \u2191",
    "Flash Date \u2193",
  ];

  static String connectionSortMode = connectionSortModes[0];

  // temporary values
  String? status;
  bool twoWireControl = false;
  bool inBootLoader = false;
  bool failsafe = false;
  bool modulating = false;
  bool speedControl = false;
  bool multiTurn = false;
  bool offGridTimer = false;
  bool wiggle = false;
  bool isLocked = false;

  bool torqueLimit = false;
  bool isNm60 = false;
  bool isNm80 = false;
  bool isNm100 = false;
  bool controlSystem = false;
  bool valveProfile = false;
  bool analogDeadband = false;

  late Delay failsafeDelay = Delay();

  int analogSignalMode = 0;
  bool invertSignal = false;
  double deadbandForwards = 0.0;
  double deadbandBackwards = 0.0;

  String modulation = "MODULATION OFF";

  String macAddress = "00:00:00:00:00:00";

  double workingTime = 0.0;

  static int monthsMax = 12;
  static int monthsMin = 0;
  static int weeksMax = 4;
  static int weeksMin = 0;
  static int daysMax = 28;
  static int daysMin = 0;
  static int hourMax = 24;
  static int hourMin = 0;
  static int minuteMax = 60;
  static int minuteMin = 0;
  static int secondMax = 60;
  static int secondMin = 0;
}

class ActuatorNotification extends Notification {
  updateWriteToFlash(BuildContext context) {
    dispatch(context);
  }
}
