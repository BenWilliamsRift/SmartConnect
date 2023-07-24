import 'dart:async';

import 'package:flutter/material.dart';

import '../actuator/actuator.dart';
import '../app_bar.dart';
import '../asset_manager.dart';
import '../bluetooth/bluetooth_message_handler.dart';
import '../color_manager.dart';
import '../nav_drawer.dart';
import '../string_consts.dart';
import 'list_tiles.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({Key? key}) : super(key: key);

  @override
  State<ControlPage> createState() => _ControlPageState();
}

//ControlFragment ln:292
class _ControlPageState extends State<ControlPage> {
  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();

  void requestAll() {
    bluetoothMessageHandler.requestAngle();
    bluetoothMessageHandler.requestTemperature();
    bluetoothMessageHandler.requestBatteryVoltage();
    bluetoothMessageHandler.requestAutoManual();
  }

  late Timer timer;

  @override
  void initState() {
    super.initState();
    // initial requests
    requestAll();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          bluetoothMessageHandler.requestBatteryVoltage();
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Style.update();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          bluetoothMessageHandler.requestBatteryVoltage();
        });
      }
    });

    return Scaffold(
        appBar: appBar(title: getTitle()),
        drawer: const NavDrawer(),
        body: SingleChildScrollView(
            child: Column(
              children: [
                Style.sizedHeight,
                Row(children: [
                  Style.sizedWidth,
                  const SizedBox(
                      width: 30, height: 30, child: ActuatorConnectedIndicator())
                ]),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActuatorIndicator(radius: 100),
                  ],
                ),
                Style.sizedHeight,
                Row(
                  children: [
                    Style.sizedWidth,
                    Expanded(
                        child: HoldButton(
                          onPressed: () {
                            setState(() {
                              bluetoothMessageHandler.openActuator();
                            });
                          },
                          onDoubleTap: () {
                            bluetoothMessageHandler.doubleTapOpenActuator();
                          },
                          onReleased: () {
                            setState(() {
                              bluetoothMessageHandler.stopActuator();
                            });
                          },
                          backgroundColor: ColorManager.actuatorOpenButton,
                          child: Text(
                              style: Style.normalText, StringConsts.actuators.open),
                        )),
                    Style.sizedWidth,
                    Expanded(
                        child: HoldButton(
                            onPressed: () {
                              setState(() {
                                bluetoothMessageHandler.closeActuator();
                              });
                            },
                            onDoubleTap: () {
                              bluetoothMessageHandler.doubleTapCloseActuator();
                            },
                            onReleased: () {
                              setState(() {
                                bluetoothMessageHandler.stopActuator();
                              });
                            },
                            backgroundColor: ColorManager.actuatorCloseButton,
                            child: Text(
                                style: Style.normalText,
                                StringConsts.actuators.close))),
                    Style.sizedWidth,
                    const Expanded(child: AutoManualButton()),
                    Style.sizedWidth,
                  ],
                ),
                Row(
                  children: [
                    Style.sizedWidth,
                    Expanded(
                        child: Button(
                          onPressed: () {
                            bluetoothMessageHandler.setResetBoard();
                          },
                          backgroundColor: Style.darkBlue,
                          child: Text(
                              style: Style.normalText,
                              StringConsts.actuators.softResetBoard),
                        )),
                    Style.sizedWidth,
                    Expanded(
                        child: Button(
                          onPressed: () {
                            bluetoothMessageHandler.stopActuator();
                          },
                          backgroundColor: Style.darkBlue,
                          child: Text(
                              style: Style.normalText, StringConsts.actuators.stop),
                        )),
                    Style.sizedWidth,
                    Expanded(
                        child: Button(
                          onPressed: () {
                            bluetoothMessageHandler.setDefaultSettings();
                          },
                          backgroundColor: Style.darkBlue,
                          child: Text(
                              style: Style.normalText,
                              StringConsts.actuators.revertToDefaultValues),
                        )),
                    Style.sizedWidth,
                  ],
                ),
                Divider(indent: Style.padding, endIndent: Style.padding),
                // Status
                TextTile(
                  title: Text(
                      style: Style.normalText, StringConsts.actuators.status),
                  text: Text(
                      style: Style.normalText,
                      Actuator.connectedActuator.status ??
                          StringConsts.bluetooth.notConnected),
                ),
                // Angle
                TextTile(
                  title:
                  Text(style: Style.normalText, StringConsts.actuators.angle),
                  text: Text(
                      style: Style.normalText,
                      Actuator.connectedActuator.settings.getAngle),
                  update: () {
                    // bluetoothMessageHandler.requestAngle();
                  },
                ),
                // Temperature
                TextTile(
                    title: Text(
                        style: Style.normalText,
                        StringConsts.actuators.temperature),
                    text: Text(
                        style: Style.normalText,
                        Actuator.connectedActuator.settings.getTemperature
                            .toString()),
                    update: () {
                      bluetoothMessageHandler.requestTemperature();
                    }
                ),
                // Battery volt
                TextTile(
                    title: Text(
                        style: Style.normalText,
                        StringConsts.actuators.batteryVoltage),
                    text: Text(
                        style: Style.normalText,
                        Actuator.connectedActuator.settings.getBatteryVoltage
                            .toString()),
                    update: () {
                      bluetoothMessageHandler.requestBatteryVoltage();
                    }
                ),
                // Modulation input
                TextTile(
                  title: Text(
                      style: Style.normalText,
                      StringConsts.actuators.receivedModulationInput),
                  text: Text(
                      style: Style.normalText,
                      Actuator.connectedActuator.modulation),
                  update: () {
                    bluetoothMessageHandler.requestModulatingInversion();
                  },
                ),
              ],
            )));
  }
}
