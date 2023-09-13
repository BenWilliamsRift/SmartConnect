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

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();

  void requestAll() {
    bluetoothMessageHandler.requestAngle();
    bluetoothMessageHandler.requestAutoManual();
    bluetoothMessageHandler.requestClosedAngleAddition();
    bluetoothMessageHandler.requestWorkingAngle();
    Actuator.connectedActuator.settings.openAngle =
        Actuator.connectedActuator.settings.closedAngle +
            Actuator.connectedActuator.settings.workingAngle;
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
          bluetoothMessageHandler.requestClosedAngleAddition();
          bluetoothMessageHandler.requestWorkingAngle();
          Actuator.connectedActuator.settings.openAngle =
              Actuator.connectedActuator.settings.closedAngle +
                  Actuator.connectedActuator.settings.workingAngle;
          getTorqueBand();
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

  bool autoManualReleased = false;
  Color? autoManualColor;

  void getTorqueBand() {
    Actuator.connectedActuator.updateTorqueBand();
  }

  @override
  Widget build(BuildContext context) {
    Style.update();

    return Scaffold(
      appBar: appBar(title: getTitle(), context: context),
      drawer: const NavDrawer(),
      body: ListView(
        shrinkWrap: true,
        children: [
          Style.sizedHeight,
          Column(children: [
            Style.sizedHeight,
            Row(children: [
              Style.sizedWidth,
              const SizedBox(
                  width: 30, height: 30, child: ActuatorConnectedIndicator())
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ActuatorIndicator.widget(large: true)],
            )
          ]),
          Style.sizedHeight,
          Row(children: [
            Style.sizedWidth,
            Expanded(
                child: GestureDetector(
              onDoubleTap: () {
                setState(() {
                  bluetoothMessageHandler.doubleTapOpenActuator();
                });
              },
              child: IconButtonTile(
                  icon: Icon(Icons.rotate_left_outlined,
                      color: ColorManager.actuatorIcon),
                  backgroundColor: ColorManager.rotateLeftOutlinedButton,
                  onPressed: () {
                    setState(() {
                      bluetoothMessageHandler.calibrateOpenActuator();
                    });
                  },
                  onReleased: () {
                    setState(() {
                      bluetoothMessageHandler.calibrateStopActuator();
                    });
                  }),
            )),
            Style.sizedWidth,
            Expanded(
                child: GestureDetector(
              onDoubleTap: () {
                setState(() {
                  bluetoothMessageHandler.doubleTapCloseActuator();
                });
              },
              child: IconButtonTile(
                icon: Icon(Icons.rotate_right_outlined,
                    color: ColorManager.actuatorIcon),
                backgroundColor: ColorManager.rotateRightOutlinedButton,
                onPressed: () {
                  setState(() {
                    bluetoothMessageHandler.calibrateCloseActuator();
                  });
                },
                onReleased: () {
                  setState(() {
                    bluetoothMessageHandler.calibrateStopActuator();
                  });
                },
              ),
            )),
            Style.sizedWidth,
            Expanded(child: AutoManualButton.widget)
          ]),
          Style.sizedWidth,
          Row(children: [
            Style.sizedWidth,
            Expanded(
                child: Button(
              onPressed: () {
                bluetoothMessageHandler.setClosedAngleAddition(
                    Actuator.connectedActuator.settings.angle);
              },
              child: Text(
                  style: Style.normalText, StringConsts.actuators.setCloseHere),
            )),
            Style.sizedWidth,
            Expanded(
                child: Button(
              onPressed: () {
                Actuator.writeToFlash(context, bluetoothMessageHandler);
              },
              child: Text(
                  style: Style.normalText, StringConsts.actuators.writeToFlash),
            )),
            Style.sizedWidth,
            Expanded(
                child: Button(
              onPressed: () {
                bluetoothMessageHandler
                    .setOpenAngle(Actuator.connectedActuator.settings.angle);
              },
              child: Text(
                  style: Style.normalText, StringConsts.actuators.setOpenHere),
            )),
            Style.sizedWidth,
          ]),
          // angle
          TextTile(
            title:
                Text(style: Style.normalText, StringConsts.actuators.rawAngle),
            text: Text(
              Actuator.connectedActuator.settings.getRawAngle,
              style: Style.normalText,
            ),
          ),
          // open angle
          TextInputTile(
            title: Text(
                style: Style.normalText,
                StringConsts.actuators.calibrationOpenAngle),
            initialValue: Actuator.connectedActuator.settings.getOpenAngle,
            onSaved: (String? newValue) {
              // set open angle
              if (newValue != null) {
                double openAngle = double.parse(newValue);

                Actuator.connectedActuator.settings.setOpenAngle(openAngle);

                // confirmation message
                confirmationMessage(
                    context: context,
                    text: StringConsts.actuators.moveClosedAngle(
                        Actuator.connectedActuator.settings.getWorkingAngle),
                    yesAction: () {
                      // Move closed angle
                      setState(() {
                        Actuator.connectedActuator.settings.setClosedAngle(
                            openAngle -
                                Actuator
                                    .connectedActuator.settings.workingAngle);
                      });
                    });
              }

              return Actuator.connectedActuator.settings.getOpenAngle;
            },
          ),
          // closed angle
          TextInputTile(
            title: Text(
              style: Style.normalText,
              // closed angle
              StringConsts.actuators.calibrationCloseAngle,
            ),
            initialValue: Actuator.connectedActuator.settings.getClosedAngle,
            onSaved: (String? newValue) {
              // set closed angle
              if (newValue != null) {
                double closedAngle = double.parse(newValue);

                Actuator.connectedActuator.settings.setClosedAngle(closedAngle);

                confirmationMessage(
                    context: context,
                    text: StringConsts.actuators.moveOpenAngle(
                        Actuator.connectedActuator.settings.getWorkingAngle),
                    yesAction: () {
                      // Move open angle
                      setState(() {
                        Actuator.connectedActuator.settings.setOpenAngle(
                            closedAngle +
                                Actuator
                                    .connectedActuator.settings.workingAngle);
                      });
                    });
              }
            },
          ),
          // working angle
          TextInputTile(
            title: Text(
                style: Style.normalText, StringConsts.actuators.workingAngle),
            initialValue: Actuator.connectedActuator.settings.getWorkingAngle,
            onSaved: (String? newValue) {
              // set working angle
              if (newValue != null) {
                double workingAngle = double.parse(newValue);

                Actuator.connectedActuator.settings
                    .setWorkingAngle(workingAngle);

                confirmationMessage(
                    context: context,
                    text: StringConsts.actuators.moveOpenAngle(
                        Actuator.connectedActuator.settings.getWorkingAngle),
                    yesAction: () {
                      setState(() {
                        Actuator.connectedActuator.settings.setOpenAngle(
                            Actuator.connectedActuator.settings.closedAngle +
                                Actuator
                                    .connectedActuator.settings.workingAngle);
                      });
                    });
              }
            },
          ),
          // torque band
          TextTile(
              title: Text(
                  style: Style.normalText, StringConsts.actuators.torqueBand),
              text: Text(
                  style: Style.normalText,
                  Actuator.connectedActuator.getTorqueBand)),
        ],
      ),
    );
  }
}
