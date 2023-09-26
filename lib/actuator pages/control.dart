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
  const ControlPage({Key? key, required this.name}) : super(key: key);

  final String name;

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
          bluetoothMessageHandler.requestTemperature();
          bluetoothMessageHandler.requestModulatingInversion();
          if (!NavDrawController.isSelectedPage(widget)) {
            timer.cancel();
          }
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

    return Scaffold(
        appBar: appBar(title: getTitle(), context: context),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActuatorIndicator.widget(large: false),
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
                Expanded(child: AutoManualButton.widget),
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
              title:
                  Text(style: Style.normalText, StringConsts.actuators.status),
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
            ),
            // Temperature
            TextTile(
              title: Text(
                  style: Style.normalText, StringConsts.actuators.temperature),
              text: Text(
                  style: Style.normalText,
                  Actuator.connectedActuator.settings.getTemperature
                      .toString()),
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
            ),
            // Modulation input
            TextTile(
              title: Text(
                  style: Style.normalText,
                  StringConsts.actuators.receivedModulationInput),
              text: Text(
                  style: Style.normalText,
                  Actuator.connectedActuator.modulation),
            ),
            // Disclaimer
            const Center(
              child: Text(
                  "*Hold the Auto/Manual Button for 5 seconds to change the mode*"),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                  textAlign: TextAlign.center,
                  "**If you are experiencing problems disconnect and reconnect, if the problems persist use the /Report a Bug page\\ "
                  "and explain the problem you are having in as much detail as possible**"),
            )
          ],
        )));
  }
}
