import 'dart:core';

import 'package:actuatorapp2/bluetooth/bluetooth_message_handler.dart';

import '../date_time.dart';
import '../settings.dart';

class ActuatorConstants {
  static int numberOfFeatures = 14;
  static int featureTorqueLimit = 0;
  static int feature60Nm = 1;
  static int feature80Nm = 2;
  static int feature100Nm = 3;
  static int featureTwoWireControl = 4;
  static int featureFailsafe = 5;
  static int featureModulating = 6;
  static int featureSpeedControl = 7;
  static int featureMultiTurn = 8;
  static int featureOffGridTimer = 9;
  static int featureWiggle = 10;
  static int featureControlSystem = 11;
  static int featureValveProfile = 12;
  static int featureAnalogDeadband = 13;
}

class ActuatorSettings {
  ActuatorSettings(
    this.firmwareVersion,
    this.valveOrientation,
    this.backlash,
    this.buttonsEnabled,
    this.numberOfFullCycles,
    this.numberOfStarts,
    this.sleepWhenNotPowered,
    this.magnetTestMode,
    this.startInManualMode,
    this.indicationMode,
    this.reverseActing
    );

  final String angleSymbol = "\u00B0";

  double angle = 0.0;
  double rawAngle = 0.0;
  String get getAngle => "${angle.truncateToDouble()}$angleSymbol";
  String get getRawAngle => "$rawAngle$angleSymbol";
  int leds = 0;
  double temperature = 0.0;
  String get getTemperature => "${Settings.convertTemperatureUnits(temp: temperature).round().toString().padRight(2, "0")}${Settings.getTemperatureUnits()}";
  double batteryVoltage = 0.0;
  // V for units
  String get getBatteryVoltage => "${batteryVoltage}V";
  int positionMode = 0;
  double receivedModulationInput = 0.0;
  String loggingPassword = "";

  // basic settings

  late int boardNumber;
  late double firmwareVersion;
  late double valveOrientation;
  late int numberOfFullCycles;
  late int numberOfStarts;
  int autoManual = 0;
  late double peakCurrent;
  late double peakTemperature;
  get getPeakTemperature => Settings.convertTemperatureUnits(temp: peakTemperature);
  late double voltageAllTimeLow;
  late int powerOns;
  late double lastCycleEnergy;
  late int lastChargeTime;
  late bool reverseActing;
  late int indicationMode;
  late int torqueProfile;
  int maximumDuty = 0;

  // ignore: non_constant_identifier_names
  late double PIDP;

  // ignore: non_constant_identifier_names
  late double PIDI;
  late bool startInManualMode;
  double backlash = 0;
  late bool sleepWhenNotPowered;
  late bool buttonsEnabled;
  late bool locked;

  BluetoothMessageHandler messageHandler = BluetoothMessageHandler();

  // calibration Settings
  double closedAngle = 0;

  String get getClosedAngle => "${closedAngle.truncateToDouble()}$angleSymbol";

  void setClosedAngle(double angle) {
    closedAngle = angle;
    messageHandler.setClosedAngleAddition(angle);
  }

  double openAngle = 0;

  String get getOpenAngle => "${openAngle.truncateToDouble()}$angleSymbol";

  void setOpenAngle(double angle) {
    openAngle = angle;
    messageHandler.setOpenAngle(angle);
  }

  double workingAngle = 0.0;

  String get getWorkingAngle =>
      "${workingAngle.truncateToDouble()}$angleSymbol";

  void setWorkingAngle(double angle) {
    workingAngle = angle;
    messageHandler.setWorkingAngle(angle);
  }

  double calibratedClosedAngle = 0.0;
  double torqueBand = 0;

  String get getTorqueBand =>
      "${Settings.convertTorqueUnits(torque: torqueBand)}${Settings.getTorqueUnits()}";

  // torque limit
  double torqueLimitNm = 0.0;

  void setTorqueLimitNm(String? value) {
    if (value != null) {
      torqueLimitNm = Settings.convertTorqueUnits(
          torque: double.parse(value),
          source: Settings.selectedTorqueUnits,
          wanted: Settings.newtonMeter);
    }
  }
  double torqueLimitBackoffAngle = 0.0;
  bool retryAfterTorqueLimit = false;
  Delay torqueLimitDelayBeforeRetry = Delay();
  // failsafe

  int failsafeMode = 0;
  double failsafeAngle = 0.0;

  // modulating

  int lossOfSignalMode = 0;
  double lossOfSignalAngle = 0.0;
  int modulatingAnalogSignalMode = 0;
  double analogDeadbandForwards = 0.0;
  double analogDeadbandBackwards = 0.0;
  bool modulatingInversion = false;

  // speed control

  double workingTimeInSeconds = 0.0;

  // off grid timer

  bool offGridTimerEnabled = false;
  double offGridTimeUntilFirstOpen = 0.0;
  double offGridOpenTime = 0.0;
  double offGridTimeBetweenCycles = 0.0;

  // wiggle

  bool wiggleEnabled = false;
  double wiggleAngle = 0.0;
  Delay timeBetweenWiggles = Delay();

  // process control

  late int processControlAnalogSignalMode;
  late bool processControlEnabled;
  late double processControlPValue;
  late double processControlIValue;
  late double processControlDesiredInputVoltage;
  late bool processControlReverseControl;


  // valve profile

  // testing
  late int numberOfTests;
  late double minimumBatteryVoltageTest;
  late bool testingEnabled;

  // features
  List<int> featuresArray = List.filled(16, 0);
  List<String> featuresPasswords =
      List.filled(ActuatorConstants.numberOfFeatures, "None");
  late String featuresPasswordDigits;

  late bool magnetTestMode;

  // Bootloader
  bool inBootLoader = false;
  int failsafeDelay = 0;
  late bool parityEnabled;

  // General
  late String timeSerialised;

  void setFeaturePassword(int index, String password) {
    featuresPasswords[index] = password;
  }

  void setModulatingInversion(int value) {
    if (value == 1) modulatingInversion = true;
    if (value == 0) modulatingInversion = false;
  }
}
