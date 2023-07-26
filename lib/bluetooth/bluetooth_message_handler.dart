// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../actuator/actuator.dart';
import '../actuator/actuator_settings.dart';
import '../date_time.dart';
import 'bluetooth_manager.dart';

class BluetoothMessageHandler {
  // non m- requests
  static const String codeRequestAngle = "a"; // Angle
  static const String codeRequestLEDS = "l"; // LEDS is TODO
  static const String codeRequestTemperature = "w"; // Temperature

  // bootloader requests
  static const String codeEnterBootloader = "m200";
  static const String codeExitBootloader = "%";
  static const String codeGetBootloaderStatus = "@";
  static const String codeSendManualFirmwareEnter = "!";

  // m- commands - in order
  static const String codeRequestFirmwareVersion = "m4";
  static const String codeOpenActuator = "m5";
  static const String codeStopActuator = "m6";
  static const String codeCloseActuator = "m7";
  static const String codeSetAutoManual = "m9";
  static const String codeRequestWorkingTime = "m10";
  static const String codeWriteToFlash = "m11";
  static const String codeSetWorkingTime = "m12";
  static const String codeSetMaximumDuty = "m14";
  static const String codeSetTorqueLimit = "m15";
  static const String codeSetValveOrientation = "m16";
  static const String codeRequestMaximumDuty = "m20";
  static const String codeRequestTorqueLimit = "m21";
  static const String codeRequestValveOrientation = "m22";
  static const String codeRequestNumberOfFullCycles = "m23";
  static const String codeRequestWorkingAngle = "m26";
  static const String codeSetWorkingAngle = "m27";
  static const String codeRequestFailsafeMode = "m28";
  static const String codeSetFailsafeMode = "m29";
  static const String codeRequestFailsafeAngle = "m30";
  static const String codeSetFailsafeAngle = "m31";
  static const String codeRequestAnalogSignalMode = "m32";
  static const String codeSetAnalogSignalMode = "m33";
  static const String codeRequestReverseActing = "m34";
  static const String codeSetReverseActing = "m35";
  static const String codeRequestNumberOfStarts = "m36";
  static const String codeRequestIndicationMode = "m38";
  static const String codeSetIndicationMode = "m39";
  static const String codeSetDefaultSettings = "m40";
  static const String codeSetClosedAngleAddition = "m41";
  static const String codeRequestClosedAngleAddition = "m42";
  static const String codeRequestBatteryVoltage = "m43";
  static const String codeCalibrateOpenActuator = "m44";
  static const String codeCalibrateCloseActuator = "m45";
  static const String codeDoubleTapOpenActuator = "m46";
  static const String codeDoubleTapCloseActuator = "m47";
  static const String codeCalibrateStopActuator = "m48";
  static const String codeRequestPIDP = "m49";
  static const String codeSetPIDP = "m50";
  static const String codeRequestPIDI = "m51";
  static const String codeSetPIDI = "m52";
  static const String codeRequestLossOfSignalMode = "m53";
  static const String codeSetLossOfSignalMode = "m54";
  static const String codeRequestLossOfSignalAngle = "m55";
  static const String codeSetLossOfSignalAngle = "m56";
  static const String codeRequestFeatures = "m57";
  static const String codeRequestFeaturePasswordDigits = "m58";
  static const String codeRequestPositionMode = "m63";
  static const String codeSetBacklash = "m65";
  static const String codeRequestBacklash = "m66";
  static const String codeRequestStartInManual = "m67";
  static const String codeSetStartInManual = "m68";
  static const String codeRequestOffGridTimeUntilFirstOpen = "m69";
  static const String codeSetOffGridTimeUntilFirstOpen = "m70";
  static const String codeRequestOffGridTimeBetweenCycles = "m71";
  static const String codeSetOffGridTimeBetweenCycles = "m72";
  static const String codeRequestOffGridOpenTime = "m73";
  static const String codeSetOffGridTimerOpenTime = "m74";
  static const String codeRequestOffGridTimerEnabled = "m75";
  static const String codeRequestWiggleEnabled = "m77";
  static const String codeSetWiggleEnabled = "m78";
  static const String codeRequestWiggleTimeBetween = "m79";
  static const String codeSetWiggleTimeBetween = "m80";
  static const String codeRequestWiggleAngle = "m81";
  static const String codeSetWiggleAngle = "m82";
  static const String codeRequestTorqueLimitBackoffAngle = "m83";
  static const String codeSetTorqueLimitBackoffAngle = "m84";
  static const String codeRequestTorqueLimitDelayBeforeRetry = "m85";
  static const String codeSetTorqueLimitDelayBeforeRetry = "m86";
  static const String codeRequestControlSystemPIDP = "m87";
  static const String codeSetControlSystemPIDP = "m88";
  static const String codeRequestControlSystemPIDI = "m89";
  static const String codeSetControlSystemPIDI = "m90";
  static const String codeRequestControlSystemTargetFraction = "m91";
  static const String codeSetControlSystemTargetFraction = "m92";
  static const String codeRequestControlSystemEnabled = "m93";
  static const String codeSetControlSystemEnabled = "m94";
  static const String codeRequestInputSignalVoltage = "m95";
  static const String codeRequestControlSystemReverse = "m96";
  static const String codeSetControlSystemReverse = "m97";
  static const String codeRequestSleepEnabled = "m102";
  static const String codeSetSleepEnabled = "m103";
  static const String codeRequestMagnetTest = "m107";
  static const String codeSetMagnetTest = "m108";
  static const String codeRequestButtonsEnabled = "m109";
  static const String codeSetButtonsEnabled = "m110";
  static const String codeSetResetBoard = "m111";
  static const String codeRequestNumberOfTests = "m115";
  static const String codeSetNumberOfTests = "m116";
  static const String codeRequestMinimumBatteryVoltage = "m117";
  static const String codeSetMinimumBatteryVoltage = "m118";
  static const String codeRequestTestingEnabled = "m120";
  static const String codeSetAnalogDeadbandBackwards = "m122";
  static const String codeRequestAnalogDeadbandForwards = "m123";
  static const String codeSetAnalogDeadbandForwards = "m124";
  static const String codeRequestAnalogDeadbandBackwards = "m125";
  static const String codeRequestAutoManual = "m128";
  static const String codeResetLogData = "m154";
  static const String codeRequestLoggingData = "m155";
  static const String codeVerify = "m156";
  static const String codeLock = "m169";
  static const String codeUnlock = "m170";
  static const String codeRequestLocked = "m171";
  static const String codeSetFailsafeDelay = "m202";
  static const String codeRequestFailsafeDelay = "m203";
  static const String codeModulatingInversion = "m1222";
  static const String codeRequestModulatingInversion = "m1223";

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  Future<void> processResponse(List<String> messages) async {
    for (String message in messages) {
      switch (message[0]) {
        case codeRequestAngle: // a
          Actuator.connectedActuator.settings.angle =
              (double.parse(message.substring(1)) % 360);
          Actuator.connectedActuator.settings.rawAngle =
              double.parse(message.substring(1));
          break;
        case codeRequestLEDS: // l
          Actuator.connectedActuator.settings.leds =
              int.parse(message.substring(1));
          break;
        case codeRequestTemperature: // w
          Actuator.connectedActuator.settings.temperature = double.parse(message.substring(1)); // 20 == 2.0
          break;
        case codeGetBootloaderStatus: // @
          Actuator.connectedActuator.settings.firmwareVersion = double.parse(message.substring(1));
          Actuator.connectedActuator.inBootLoader = true;
          if (kDebugMode) {
            print("bootloader: ${Actuator.connectedActuator.inBootLoader}");
          }
          break;
        case codeSendManualFirmwareEnter: // !
          break;
      }
      switch (message.split(",")[0].substring(1)) {
        case codeRequestWorkingTime: // m10
          Actuator.connectedActuator.workingTime =
              double.parse(message.split(",")[1]);
          break;
        case codeWriteToFlash: // flash finished : 362
          if (kDebugMode) {
            print("STOP WRITE TO FLASH");
          }
          Actuator.connectedActuator.writingToFlash = false;
          break;
        case codeRequestMaximumDuty: // m20
          Actuator.connectedActuator.settings.maximumDuty =
              int.parse(message.split(",")[1]);
          break;
        case codeRequestTorqueLimit: // m21
          Actuator.connectedActuator.settings.torqueLimitNm =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestValveOrientation: // m22
          Actuator.connectedActuator.settings.valveOrientation =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestNumberOfFullCycles: // 23
          Actuator.connectedActuator.settings.numberOfFullCycles =
              int.parse(message.split(",")[1]);
          break;
        case codeRequestWorkingAngle: // 26
          Actuator.connectedActuator.settings.workingAngle = double.parse(message.split(",")[1]);
          getOpenAngle();
          break;
        case codeRequestFailsafeMode: // 28
          Actuator.connectedActuator.settings.failsafeMode =
              int.parse(message.split(",")[1]);
          break;
        case codeRequestFailsafeAngle: // 30
          Actuator.connectedActuator.settings.failsafeAngle =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestAnalogSignalMode: // 32
          Actuator.connectedActuator.analogSignalMode =
              int.parse(message.split(",")[1]);
          break;
        case codeRequestReverseActing: //34
          Actuator.connectedActuator.settings.reverseActing =
              int.parse(message.split(",")[1]) == 1;
          // maybe add receivedReverseActing like from bluetoothHandler 431:55
          break;
        case codeRequestNumberOfStarts: // 36
          Actuator.connectedActuator.settings.numberOfStarts =
              int.parse(message.split(",")[1]);
          break;
        case codeRequestIndicationMode: // 38
          Actuator.connectedActuator.settings.indicationMode =
              int.parse(message.split(",")[1]);
          break;
        case codeRequestClosedAngleAddition: // 42
          Actuator.connectedActuator.settings.closedAngle = double.parse(message.split(",")[1]);
          Actuator.connectedActuator.settings.calibratedClosedAngle = double.parse(message.split(",")[1]);
          break;
        case codeRequestBatteryVoltage: // 43
          Actuator.connectedActuator.settings.batteryVoltage =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestPIDP: // 49
          Actuator.connectedActuator.settings.PIDP =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestPIDI: // 51
          Actuator.connectedActuator.settings.PIDI =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestLossOfSignalMode: // 53
          Actuator.connectedActuator.settings.lossOfSignalMode =
              int.parse(message.split(",")[1]);
          break;
        case codeRequestLossOfSignalAngle: // 55
          Actuator.connectedActuator.settings.lossOfSignalAngle =
              double.parse(message.split(",")[1]);
          break;
        case "57":
          List<String> parts = message.substring(1).split(",");
          if (parts.length < 3) {
            return;
          }

          int index = int.parse(parts[1]);
          int value = int.parse(parts[2]);

          if (value == 0) {
            Actuator.connectedActuator.settings.setFeaturesDisabled(index);
          } else if (value == 1) {
            Actuator.connectedActuator.settings.setFeaturesEnabled(index);
          }
          break;
        case codeRequestFeaturePasswordDigits: // 58
          // feature password digits
          break;
        case codeRequestPositionMode: // 63
          Actuator.connectedActuator.settings.positionMode =
              int.parse(message.split(",")[1]);
          break;
        case codeRequestBacklash: // 66
          Actuator.connectedActuator.settings.backlash =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestStartInManual: // 67
          Actuator.connectedActuator.settings.startInManualMode =
              int.parse(message.split(",")[1]) == 1;
          break;
        case codeRequestOffGridTimeUntilFirstOpen: // 69
          Actuator.connectedActuator.settings.offGridTimeUntilFirstOpen =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestOffGridTimeBetweenCycles: // 71
          Actuator.connectedActuator.settings.offGridTimeBetweenCycles =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestOffGridOpenTime: // 73
          Actuator.connectedActuator.settings.offGridOpenTime =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestOffGridTimerEnabled: // 75
          Actuator.connectedActuator.settings.offGridTimerEnabled =
              double.parse(message.split(",")[1]) == 1;
          break;
        case codeRequestWiggleEnabled: // 77
          Actuator.connectedActuator.settings.wiggleEnabled =
              double.parse(message.split(",")[1]) == 1;
          break;
        case codeRequestWiggleTimeBetween: // 79
          // Actuator.connectedActuator.wiggleTime = double.parse(message.split(",")[1]);
          break;
        case codeRequestWiggleAngle: // 81
          Actuator.connectedActuator.settings.wiggleAngle =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestTorqueLimitBackoffAngle: // 83
          Actuator.connectedActuator.settings.torqueLimitBackoffAngle =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestTorqueLimitDelayBeforeRetry: // 85
          Actuator.connectedActuator.settings.torqueLimitDelayBeforeRetry = Delay.fromSecs(double.parse(message.split(",")[1]));
          break;
        case codeRequestControlSystemPIDP: // 87
          // Actuator.connectedActuator.PIDP = double.parse(message.split(",")[1]);
          break;
        case codeRequestControlSystemPIDI: // 89
          // Actuator.connectedActuator.PIDI
          break;
        case codeRequestControlSystemTargetFraction: // 91
          break;
        case codeRequestControlSystemEnabled: // 93
          break;
        case codeRequestInputSignalVoltage:
          break;
        case "98": // unused???? : 658
          break;
        case "100": // unused : 664
          break;
        case codeRequestSleepEnabled:
          break;
        case codeRequestMagnetTest: // 107
          Actuator.connectedActuator.settings.magnetTestMode =
              int.parse(message.split(",")[1]) == 1;
          break;
        case codeRequestButtonsEnabled: // 109
          Actuator.connectedActuator.settings.buttonsEnabled =
              int.parse(message.split(",")[1]) == 1;
          break;
        case codeRequestNumberOfTests: // 115
          Actuator.connectedActuator.settings.numberOfTests =
              int.parse(message.split(",")[1]);
          break;
        case codeRequestMinimumBatteryVoltage: // 117
          Actuator.connectedActuator.settings.minimumBatteryVoltageTest =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestTestingEnabled: // 120
          Actuator.connectedActuator.settings.testingEnabled =
              int.parse(message.split(",")[1]) == 1;
          break;
        case codeRequestAnalogDeadbandBackwards: // 125
          Actuator.connectedActuator.deadbandBackwards =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestAnalogDeadbandForwards: // 123
          Actuator.connectedActuator.deadbandForwards =
              double.parse(message.split(",")[1]);
          break;
        case codeRequestModulatingInversion: // 1223
          Actuator.connectedActuator.settings.modulatingInversion =
              int.parse(message.split(",")[1]) == 1;
          break;
        case codeRequestAutoManual: // set auto manual : 734
          print(message.split(","));
          Actuator.connectedActuator.settings.autoManual =
              int.parse(message.split(",")[1]);
          break;
        case "154": // unused???? : 740
          break;
        case "155": // logging information : 743
          break;
        case "1551": // valve profile : 767
          break;
        case "1552": // pid information : 774
          break;
        case codeVerify:
          break;
        case codeLock:
          break;
        case codeUnlock:
          break;
        case codeRequestLocked:
          Actuator.connectedActuator.isLocked =
              int.parse(message.split(",")[1]) == 1;
          break;
        case codeRequestFailsafeDelay: // 203
          Actuator.connectedActuator.failsafeDelay =
              Delay.fromSecs(double.parse(message.split(",")[1]));
          break;
      }
    }
  }

  late BluetoothManager bluetoothManager;

  BluetoothMessageHandler({BluetoothManager? bluetoothHandler}) {
    bluetoothManager = bluetoothHandler ?? BluetoothManager();
  }

  static String boolToString(bool value) {
    return value ? "1" : "0";
  }

  void setAngle(double angle) {}

  void getOpenAngle() {
    requestClosedAngleAddition();
    requestWorkingAngle();
    requestReverseActing();

    bool reverseActing = Actuator.connectedActuator.settings.reverseActing;
    Future.delayed(const Duration(seconds: 1), () {
      if (reverseActing) {
        double workingAngle = Actuator.connectedActuator.settings.workingAngle;
        double closedAddition =
            Actuator.connectedActuator.settings.calibratedClosedAngle;
        Actuator.connectedActuator.settings.openAngle =
            closedAddition + workingAngle;
      }
    });

    Actuator.connectedActuator.settings.openAngle =
        Actuator.connectedActuator.settings.closedAngle +
            Actuator.connectedActuator.settings.workingAngle;
  }

  void writeToFlash() {
    Actuator.connectedActuator.writingToFlash = true;

    stopActuator();
    bluetoothManager.sendMessage(code: codeWriteToFlash);
  }

  void getInformation() {
    requestAngle();
    requestLEDS();
    requestTemperature();
    requestAutoManual();
    getBootloaderStatus();
    requestFirmwareVersion();
    requestWorkingTime();
    requestWorkingAngle();
    requestMaximumDuty();
    requestAnalogDeadbandBackwards();
    requestAnalogDeadbandForwards();
    requestAnalogSignalMode();
    requestBacklash();
    requestBatteryVoltage();
    requestButtonsEnabled();
    requestClosedAngleAddition();
    requestControlSystemEnabled();
    requestControlSystemPIDI();
    requestControlSystemPIDP();
    requestControlSystemReverse();
    requestControlSystemTargetFraction();
    requestFailsafeAngle();
    requestFailsafeDelay();
    requestFailsafeMode();
    requestFeaturePasswordDigits();
  }

  Duration getEstimatedTimeForFirmware() {
    // failed the last page
    return const Duration(minutes: 1, seconds: 30);

    // 3Mbits per second // bluetooth 2.0 + EDR
    // 375,000 bytes per second
    // the file contains 165160 characters
    // which is 82,580 number of bytes
    // so it should take less than a second
    // using 721Kbits per second, the slowest data rate // bluetooth 1.2
    // 90,125 bytes per second
    // it should take around a second to transfer
  }

  void requestAngle() {
    bluetoothManager.sendMessage(code: codeRequestAngle);
  }

  void requestLEDS() {
    bluetoothManager.sendMessage(code: codeRequestLEDS);
  }

  void requestTemperature() {
    bluetoothManager.sendMessage(code: codeRequestTemperature);
  }

  void exitBootloader() {
    bluetoothManager.sendMessage(code: codeExitBootloader);
  }

  void getBootloaderStatus() {
    bluetoothManager.sendMessage(code: codeGetBootloaderStatus);
  }

  void sendManualFirmwareEnter() {
    bluetoothManager.sendMessage(code: codeSendManualFirmwareEnter);
  }

  void requestFirmwareVersion() {
    bluetoothManager.sendMessage(code: codeRequestFirmwareVersion);
  }

  void openActuator() {
    bluetoothManager.sendMessage(code: codeOpenActuator);
  }

  void stopActuator() {
    bluetoothManager.sendMessage(code: codeStopActuator);
  }

  void closeActuator() {
    bluetoothManager.sendMessage(code:  codeCloseActuator );
  }

  void setAutoManual() {
    bluetoothManager.sendMessage(code: codeSetAutoManual);
  }

  void requestAutoManual() {
    bluetoothManager.sendMessage(code: codeRequestAutoManual);
  }

  void requestWorkingTime() {
    bluetoothManager.sendMessage(code: codeRequestWorkingTime);
  }

  void setWorkingTime(double time) {
    bluetoothManager.sendMessage(code: codeSetWorkingTime, value: time.toString());
  }

  void setMaximumDuty(String duty) {
    bluetoothManager.sendMessage(code: codeSetMaximumDuty, value: duty);
  }

  void setTorqueLimit(String torque) {
    bluetoothManager.sendMessage(code: codeSetTorqueLimit, value: torque);
  }

  void setValveOrientation(double valveOrientation) {
    bluetoothManager.sendMessage(code: codeSetValveOrientation, value: valveOrientation.toString());
  }

  void requestMaximumDuty() {
    bluetoothManager.sendMessage(code: codeRequestMaximumDuty);
  }

  void requestTorqueLimit() {
    bluetoothManager.sendMessage(code: codeRequestTorqueLimit);
  }

  void requestValveOrientation() {
    bluetoothManager.sendMessage(code: codeRequestValveOrientation);
  }

  void requestNumberOfFullCycles() {
    bluetoothManager.sendMessage(code: codeRequestNumberOfFullCycles);
  }

  void requestWorkingAngle() {
    bluetoothManager.sendMessage(code: codeRequestWorkingAngle);
  }

  void setWorkingAngle(double angle) {
    bluetoothManager.sendMessage(code: codeSetWorkingAngle, value: angle.toString());
  }

  void setOpenAngle(double angle) {
    double newValue = (angle - Actuator.connectedActuator.settings.closedAngle).abs();
    bluetoothManager.sendMessage(code: codeSetWorkingAngle, value: newValue.toString());
  }

  void requestFailsafeMode() {
    bluetoothManager.sendMessage(code: codeRequestFailsafeMode);
  }

  void setFailsafeMode(String failSafeMode) {
    bluetoothManager.sendMessage(code: codeSetFailsafeMode, value: failSafeMode);
  }

  void requestFailsafeAngle() {
    bluetoothManager.sendMessage(code: codeRequestFailsafeAngle);
  }

  void setFailsafeAngle(double failSafeAngle) {
    bluetoothManager.sendMessage(code: codeSetFailsafeAngle, value: failSafeAngle.toString());
  }

  void requestAnalogSignalMode() {
    bluetoothManager.sendMessage(code: codeRequestAnalogSignalMode);
  }

  void setAnalogSignalMode(int analogSignalMode) {
    bluetoothManager.sendMessage(code: codeSetAnalogSignalMode, value: analogSignalMode.toString());
  }

  void requestReverseActing() {
    bluetoothManager.sendMessage(code: codeRequestReverseActing);
  }

  void setReverseActing(bool value) {
    bluetoothManager.sendMessage(code: codeSetReverseActing, value: boolToString(value));
  }

  void requestNumberOfStarts() {
    bluetoothManager.sendMessage(code: codeRequestNumberOfStarts);
  }

  void requestIndicationMode() {
    bluetoothManager.sendMessage(code: codeRequestIndicationMode);
  }

  void setIndicationMode(int indicationMode) {
    bluetoothManager.sendMessage(code: codeSetIndicationMode, value: indicationMode.toString());
  }

  void setDefaultSettings() {
    bluetoothManager.sendMessage(code: codeSetDefaultSettings);
  }

  void setClosedAngleAddition(double closedAngleAddition) {
    bluetoothManager.sendMessage(code: codeSetClosedAngleAddition, value: closedAngleAddition.toString());
  }

  // Closed angle
  void requestClosedAngleAddition() {
    bluetoothManager.sendMessage(code: codeRequestClosedAngleAddition);
  }

  void requestBatteryVoltage() {
    bluetoothManager.sendMessage(code: codeRequestBatteryVoltage);
  }

  void calibrateOpenActuator() {
    bluetoothManager.sendMessage(code: codeCalibrateOpenActuator);
  }

  void calibrateCloseActuator() {
    bluetoothManager.sendMessage(code: codeCalibrateCloseActuator);
  }

  void doubleTapOpenActuator() {
    bluetoothManager.sendMessage(code: codeDoubleTapOpenActuator);
  }

  void doubleTapCloseActuator() {
    bluetoothManager.sendMessage(code: codeDoubleTapCloseActuator);
  }

  void calibrateStopActuator() {
    bluetoothManager.sendMessage(code: codeCalibrateStopActuator);
  }

  void requestPIDP() {
    bluetoothManager.sendMessage(code: codeRequestPIDP);
  }

  void setPIDP(String PIDP) {
    bluetoothManager.sendMessage(code: codeSetPIDP, value: PIDP);
  }

  void requestPIDI() {
    bluetoothManager.sendMessage(code: codeRequestPIDI);
  }

  void setPIDI(String PIDI) {
    bluetoothManager.sendMessage(code: codeSetPIDI, value: PIDI);
  }

  void requestLossOfSignalMode() {
    bluetoothManager.sendMessage(code: codeRequestLossOfSignalMode);
  }

  void setLossOfSignalMode(int lossOfSignalMode) {
    bluetoothManager.sendMessage(code: codeSetLossOfSignalMode, value: lossOfSignalMode.toString());
  }

  void requestLossOfSignalAngle() {
    bluetoothManager.sendMessage(code: codeRequestLossOfSignalAngle);
  }

  void setLossOfSignalAngle(double lossOfSignalAngle) {
    bluetoothManager.sendMessage(
        code: codeSetLossOfSignalAngle, value: lossOfSignalAngle.toString());
  }

  void requestFeatures() {
    for (int i = 0; i < ActuatorConstants.numberOfFeatures; i++) {
      bluetoothManager.sendMessage(
          code: codeRequestFeatures, value: i.toString());
    }
  }

  void requestFeaturePasswordDigits() {
    bluetoothManager.sendMessage(code: codeRequestFeaturePasswordDigits);
  }

  void requestPositionMode() {
    bluetoothManager.sendMessage(code: codeRequestPositionMode);
  }

  void setBacklash(double backlash) {
    bluetoothManager.sendMessage(code: codeSetBacklash, value: backlash.toString());
  }

  void requestBacklash() {
    bluetoothManager.sendMessage(code: codeRequestBacklash);
  }

  void requestStartInManual() {
    bluetoothManager.sendMessage(code: codeRequestStartInManual);
  }

  void setStartInManual(bool value) {
    bluetoothManager.sendMessage(code: codeSetStartInManual, value: boolToString(value));
  }

  void requestOffGridTimeUntilFirstOpen() {
    bluetoothManager.sendMessage(code: codeRequestOffGridTimeUntilFirstOpen);
  }

  void setOffGridTimeUntilFirstOpen() {
    bluetoothManager.sendMessage(code: codeSetOffGridTimeUntilFirstOpen);
  }

  void requestOffGridTimeBetweenCycles() {
    bluetoothManager.sendMessage(code: codeRequestOffGridTimeBetweenCycles);
  }

  void setOffGridTimeBetweenCycles() {
    bluetoothManager.sendMessage(code: codeSetOffGridTimeBetweenCycles);
  }

  void requestOffGridOpenTime() {
    bluetoothManager.sendMessage(code: codeRequestOffGridOpenTime);
  }

  void setOffGridTimerOpenTime() {
    bluetoothManager.sendMessage(code: codeSetOffGridTimerOpenTime);
  }

  void requestOffGridTimerEnabled() {
    bluetoothManager.sendMessage(code: codeRequestOffGridTimerEnabled);
  }

  void requestWiggleEnabled() {
    bluetoothManager.sendMessage(code: codeRequestWiggleEnabled);
  }

  void setWiggleEnabled(bool value) {
    bluetoothManager.sendMessage(code: codeSetWiggleEnabled, value: boolToString(value));
  }

  void requestWiggleTimeBetween() {
    bluetoothManager.sendMessage(code: codeRequestWiggleTimeBetween);
  }

  void setWiggleTimeBetween(Delay wiggleTime) {
    bluetoothManager.sendMessage(code: codeSetWiggleTimeBetween, value: wiggleTime.totalSeconds);
  }

  void requestWiggleAngle() {
    bluetoothManager.sendMessage(code: codeRequestWiggleAngle);
  }

  void setWiggleAngle(double wiggleAngle) {
    bluetoothManager.sendMessage(code: codeSetWiggleAngle, value: wiggleAngle.toString());
  }

  void requestTorqueLimitBackoffAngle() {
    bluetoothManager.sendMessage(code: codeRequestTorqueLimitBackoffAngle);
  }

  void setTorqueLimitBackoffAngle(String angle) {
    bluetoothManager.sendMessage(code: codeSetTorqueLimitBackoffAngle, value: angle);
  }

  void requestTorqueLimitDelayBeforeRetry() {
    bluetoothManager.sendMessage(code: codeRequestTorqueLimitDelayBeforeRetry);
  }

  void setTorqueLimitDelayBeforeRetry(String delay) {
    bluetoothManager.sendMessage(code: codeSetTorqueLimitDelayBeforeRetry, value: delay);
  }

  void requestControlSystemPIDP() {
    bluetoothManager.sendMessage(code: codeRequestControlSystemPIDP);
  }

  void setControlSystemPIDP(String PIDP) {
    bluetoothManager.sendMessage(code: codeSetControlSystemPIDP, value: PIDP);
  }

  void requestControlSystemPIDI() {
    bluetoothManager.sendMessage(code: codeRequestControlSystemPIDI);
  }

  void setControlSystemPIDI(String PIDI) {
    bluetoothManager.sendMessage(code: codeSetControlSystemPIDI, value: PIDI);
  }

  void requestControlSystemTargetFraction() {
    bluetoothManager.sendMessage(code: codeRequestControlSystemTargetFraction);
  }

  void setControlSystemTargetFraction(String fraction) {
    bluetoothManager.sendMessage(code: codeSetControlSystemTargetFraction, value: fraction);
  }

  void requestControlSystemEnabled() {
    bluetoothManager.sendMessage(code: codeRequestControlSystemEnabled);
  }

  void setControlSystemEnabled(String controlSystem) {
    bluetoothManager.sendMessage(code: codeSetControlSystemEnabled, value: controlSystem);
  }

  void requestInputSignalVoltage() {
    bluetoothManager.sendMessage(code: codeRequestInputSignalVoltage);
  }

  void requestControlSystemReverse() {
    bluetoothManager.sendMessage(code: codeRequestControlSystemReverse);
  }

  void setControlSystemReverse(String controlSystem) {
    bluetoothManager.sendMessage(code: codeSetControlSystemReverse, value: controlSystem);
  }

  void requestSleepEnabled() {
    bluetoothManager.sendMessage(code: codeRequestSleepEnabled);
  }

  void setSleepEnabled(bool value) {
    bluetoothManager.sendMessage(code: codeSetSleepEnabled, value: boolToString(value));
  }

  void requestMagnetTest() {
    bluetoothManager.sendMessage(code: codeRequestMagnetTest);
  }

  void setMagnetTest(bool value) {
    bluetoothManager.sendMessage(code: codeSetMagnetTest, value: boolToString(value));
  }

  void requestButtonsEnabled() {
    bluetoothManager.sendMessage(code: codeRequestButtonsEnabled);
  }

  void setButtonsEnabled(bool enabled) {
    bluetoothManager.sendMessage(code: codeSetButtonsEnabled, value: enabled ? "1": "0");
  }

  void setResetBoard() {
    bluetoothManager.sendMessage(code: codeSetResetBoard);
  }

  void requestNumberOfTests() {
    bluetoothManager.sendMessage(code: codeRequestNumberOfTests);
  }

  void setNumberOfTests(String numOfTests) {
    bluetoothManager.sendMessage(code: codeSetNumberOfTests, value: numOfTests);
  }

  void requestMinimumBatteryVoltage() {
    bluetoothManager.sendMessage(code: codeRequestMinimumBatteryVoltage);
  }

  void setMinimumBatteryVoltage(String minBatVolt) {
    bluetoothManager.sendMessage(code: codeSetMinimumBatteryVoltage, value: minBatVolt);
  }

  void requestTestingEnabled() {
    bluetoothManager.sendMessage(code: codeRequestTestingEnabled);
  }

  void setAnalogDeadbandBackwards(double deadband) {
    bluetoothManager.sendMessage(code: codeSetAnalogDeadbandBackwards, value: deadband.toString());
  }

  void requestAnalogDeadbandForwards() {
    bluetoothManager.sendMessage(code: codeRequestAnalogDeadbandForwards);
  }

  void setAnalogDeadbandForwards(double deadband) {
    bluetoothManager.sendMessage(code: codeSetAnalogDeadbandForwards, value: deadband.toString());
  }

  void requestAnalogDeadbandBackwards() {
    bluetoothManager.sendMessage(code: codeRequestAnalogDeadbandBackwards);
  }

  void verify(String verify) {
    bluetoothManager.sendMessage(code: codeVerify, value: verify);
  }

  void lock() {
    Actuator.connectedActuator.isLocked = true;
    bluetoothManager.sendMessage(code: codeLock);
  }

  void unlock() {
    Actuator.connectedActuator.isLocked = false;
    bluetoothManager.sendMessage(code: codeUnlock);
  }

  void requestLocked() {
    bluetoothManager.sendMessage(code: codeRequestLocked);
  }

  void enterBootloader() {
    bluetoothManager.sendMessage(code: codeEnterBootloader);
    if (kDebugMode) {
      print("Entered bootloader");
    }
  }

  void updateFirmware() {
    bluetoothManager.writeBootloader();
  }

  void setFailsafeDelay(Delay time) {
    bluetoothManager.sendMessage(
        code: codeSetFailsafeDelay,
        value: (time.totalSeconds.floor()).toString());
  }

  void requestFailsafeDelay() {
    bluetoothManager.sendMessage(code: codeRequestFailsafeDelay);
  }

  void requestModulatingInversion() {
    bluetoothManager.sendMessage(code: codeRequestModulatingInversion);
  }

  void setModulatingInversion(bool enabled) {
    bluetoothManager.sendMessage(
        code: codeModulatingInversion, value: boolToString(enabled));
  }

  void requestLoggingData() {
    bluetoothManager.sendMessage(code: codeRequestLoggingData);
  }

  void resetLoggingData() {
    bluetoothManager.sendMessage(code: codeResetLogData);
  }
}
