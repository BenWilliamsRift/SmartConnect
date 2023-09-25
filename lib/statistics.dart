import 'dart:async';

import 'package:flutter/material.dart';

import 'actuator/actuator.dart';
import 'actuator pages/list_tiles.dart';
import 'app_bar.dart';
import 'bluetooth/bluetooth_manager.dart';
import 'bluetooth/bluetooth_message_handler.dart';
import 'color_manager.dart';
import 'main.dart';
import 'nav_drawer.dart';
import 'string_consts.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();

  void getInformation() {
    bluetoothMessageHandler.getInformation();
  }

  late bool isConnected;

  bool snackBarShown = false;

  late Timer timer;

  @override
  void initState() {
    super.initState();

    getInformation();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        bluetoothMessageHandler.requestTemperature();
        bluetoothMessageHandler.requestBatteryVoltage();
        if (!NavDrawController.isSelectedPage(widget)) {
          timer.cancel();
        }
      });
    });

    snackBarShown = false;
  }

  String get getBoardNumber => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.boardNumber.toString() : StringConsts.bluetooth.notConnected;
  String get getFirmware => BluetoothManager.isActuatorConnected
      ? Actuator.connectedActuator.settings.firmwareVersion.toString()
      : StringConsts.bluetooth.notConnected;

  String get getType => BluetoothManager.isActuatorConnected
      ? Actuator.connectedActuator.type == ""
          ? StringConsts.loading
          : Actuator.connectedActuator.type
      : StringConsts.bluetooth.notConnected;

  String get getAngle => BluetoothManager.isActuatorConnected
      ? Actuator.connectedActuator.settings.getAngle
      : StringConsts.bluetooth.notConnected;
  String get getLocked => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.isLocked.toString() : StringConsts.bluetooth.notConnected;
  String get getOpenAngle => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.getOpenAngle : StringConsts.bluetooth.notConnected;
  String get getClosedAngle => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.getClosedAngle : StringConsts.bluetooth.notConnected;
  String get getLEDS => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.leds.toString().padRight(5, "0") : StringConsts.bluetooth.notConnected;
  String get getTemp => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.getTemperature.toString() : StringConsts.bluetooth.notConnected;
  String get getAutoManual => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.autoManual.toString() : StringConsts.bluetooth.notConnected;
  String get getBootLoader => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.inBootLoader.toString() : StringConsts.bluetooth.notConnected;
  String get getWorkingTime => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.workingTime.toString() : StringConsts.bluetooth.notConnected;
  String get getWorkingAngle =>BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.getWorkingAngle : StringConsts.bluetooth.notConnected;
  String get getMaximumDuty => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.maximumDuty.toString() : StringConsts.bluetooth.notConnected;
  String get getDeadBandBackwards => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.analogDeadbandBackwards.toString() : StringConsts.bluetooth.notConnected;
  String get getDeadBandForwards => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.analogDeadbandForwards.toString() : StringConsts.bluetooth.notConnected;
  String get getAnalogSignal => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.analogSignalMode.toString() : StringConsts.bluetooth.notConnected;
  String get getBacklash => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.backlash.toString() : StringConsts.bluetooth.notConnected;
  String get getBatteryVoltage => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.getBatteryVoltage.toString() : StringConsts.bluetooth.notConnected;
  String get getButtonsEnabled => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.buttonsEnabled.toString() : StringConsts.bluetooth.notConnected;
  String get getFailsafeAngle => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.failsafeAngle.toString() : StringConsts.bluetooth.notConnected;
  String get getFailsafeDelay => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.failsafeDelay.toString() : StringConsts.bluetooth.notConnected;
  String get getFailsafeMode => BluetoothManager.isActuatorConnected ? Actuator.connectedActuator.settings.failsafeMode.toString() : StringConsts.bluetooth.notConnected;

  Stopwatch stopwatch = Stopwatch();

  @override
  Widget build(BuildContext context) {
    if (!stopwatch.isRunning) {
      stopwatch.start();
    }

    if (stopwatch.elapsed.inSeconds >= 15) {
      getInformation();
      stopwatch.stop();
      stopwatch.reset();
      stopwatch.start();
    }

    if (!snackBarShown) {
      snackBarShown = true;
      Future.delayed(const Duration(seconds: 1), () {
        showSnackBar(
            context,
            StringConsts.pullDownToRefresh,
            4,
            SnackBarAction(
                label: StringConsts.refresh,
                onPressed: () {
                  getInformation();
                }));
      });
    }

    Divider div = Divider(color: ColorManager.colorAccent, thickness: 1, indent: 15, endIndent: 15);

    return Scaffold(
      appBar: appBar(title: StringConsts.statistics.title, context: context),
      drawer: const NavDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            getInformation();
          });
        },
        child: ListView(
          children: [
            TextTile(
                compact: true,
                title:
                    Text(style: Style.normalText, StringConsts.appVersionTitle),
                text: Text(style: Style.normalText, StringConsts.appVersion)),
            div,
            TextTile(
                compact: true,
                title: Text(
                    style: Style.normalText,
                    StringConsts.actuators.values.boardNumber),
                text: Text(style: Style.normalText, getBoardNumber)),
            div,
            TextTile(
                compact: true,
                title: Text(
                    style: Style.normalText,
                    StringConsts.actuators.values.firmwareVersion),
                text: Text(style: Style.normalText, getFirmware)),
            div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.type), text: Text(style: Style.normalText, getType)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.angle), text: Text(style: Style.normalText, getAngle)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.locked), text: Text(style: Style.normalText, getLocked)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.openAngle), text: Text(style: Style.normalText, getOpenAngle)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.closedAngle), text: Text(style: Style.normalText, getClosedAngle)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.lEDS), text: Text(style: Style.normalText, getLEDS)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.temperature), text: Text(style: Style.normalText, getTemp)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.autoManual), text: Text(style: Style.normalText, getAutoManual)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.bootloaderStatus), text: Text(style: Style.normalText, getBootLoader)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.workingTime), text: Text(style: Style.normalText, getWorkingTime)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.workingAngle), text: Text(style: Style.normalText, getWorkingAngle)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.maximumDuty), text: Text(style: Style.normalText, getMaximumDuty)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.analogDeadbandBackwards), text: Text(style: Style.normalText, getDeadBandBackwards)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.analogDeadbandForwards), text: Text(style: Style.normalText, getDeadBandForwards)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.analogSignalMode), text: Text(style: Style.normalText, getAnalogSignal)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.backlash), text: Text(style: Style.normalText, getBacklash)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.batteryVoltage), text: Text(style: Style.normalText, getBatteryVoltage)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.buttonsEnabled), text: Text(style: Style.normalText, getButtonsEnabled)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.closedAngleAddition), text: Text(style: Style.normalText, getClosedAngle)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.failsafeAngle), text: Text(style: Style.normalText, getFailsafeAngle)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.failsafeDelay), text: Text(style: Style.normalText, getFailsafeDelay)), div,
            TextTile(compact: true, title: Text(style: Style.normalText, StringConsts.actuators.values.failsafeMode), text: Text(style: Style.normalText, getFailsafeMode)), div,
          ],
        ),
      ),
    );
  }
}
