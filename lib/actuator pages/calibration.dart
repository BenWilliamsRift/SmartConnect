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
  const CalibrationPage({Key? key}) : super(key: key);

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

  late TextEditingController openAngleController;
  late TextEditingController closedAngleController;
  late TextEditingController workingAngleController;
  late TextEditingController angleController;

  @override
  void initState() {
    super.initState();

    openAngleController = TextEditingController(
        text: Actuator.connectedActuator.settings.getOpenAngle);
    closedAngleController = TextEditingController(
        text: Actuator.connectedActuator.settings.getClosedAngle);
    workingAngleController = TextEditingController(
        text: Actuator.connectedActuator.settings.getWorkingAngle);
    angleController = TextEditingController(
        text: Actuator.connectedActuator.settings.getAngle);

    // initial requests
    requestAll();
  }

  bool autoManualReleased = false;
  Color? autoManualColor;

  @override
  Widget build(BuildContext context) {
    Style.update();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          bluetoothMessageHandler.requestAngle();
          bluetoothMessageHandler.requestClosedAngleAddition();
          bluetoothMessageHandler.requestWorkingAngle();
          Actuator.connectedActuator.settings.openAngle =
              Actuator.connectedActuator.settings.closedAngle +
                  Actuator.connectedActuator.settings.workingAngle;
          openAngleController.text =
              Actuator.connectedActuator.settings.getOpenAngle;
          closedAngleController.text =
              Actuator.connectedActuator.settings.getClosedAngle;
          workingAngleController.text =
              Actuator.connectedActuator.settings.getWorkingAngle;
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
          Column(children: [
            Style.sizedHeight,
            Row(children: [
              Style.sizedWidth,
              // cant be const otherwise they wont be rebuilt
              const SizedBox(
                  width: 30, height: 30, child: ActuatorConnectedIndicator())
            ]),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActuatorIndicator(radius: 120),
              ],
            )
          ]),
          Style.sizedHeight,
          Row(children: [
            Style.sizedWidth,
            Expanded(
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
                    })),
            Style.sizedWidth,
            Expanded(
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
            )),
            Style.sizedWidth,
            const Expanded(child: AutoManualButton())
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
          TextInputTile(
            title:
                Text(style: Style.normalText, StringConsts.actuators.rawAngle),
            onSaved: (String? newValue) {
              setState(() {
                // set angle
                bluetoothMessageHandler.setAngle(double.parse(newValue ??
                    Actuator.connectedActuator.settings.angle.toString()));
              });
            },
            controller: angleController,
          ),
          // open angle
          TextInputTile(
            title: Text(
                style: Style.normalText,
                StringConsts.actuators.calibrationOpenAngle),
            onSaved: (String? newValue) {
              // set open angle
              if (newValue != null) {
                double openAngle = double.parse(newValue);

                Actuator.connectedActuator.settings.setOpenAngle(openAngle);
                openAngleController.text =
                    Actuator.connectedActuator.settings.getOpenAngle;

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
                        closedAngleController.text =
                            Actuator.connectedActuator.settings.getClosedAngle;
                      });
                    });
              }

              return Actuator.connectedActuator.settings.getOpenAngle;
            },
            controller: openAngleController,
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

                  Actuator.connectedActuator.settings
                      .setClosedAngle(closedAngle);
                  closedAngleController.text = workingAngleController.text =
                      Actuator.connectedActuator.settings.getClosedAngle;

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
                          openAngleController.text =
                              Actuator.connectedActuator.settings.getOpenAngle;
                        });
                      });
                }
              },
              controller: closedAngleController),
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
                  workingAngleController.text =
                      Actuator.connectedActuator.settings.getWorkingAngle;

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
                          openAngleController.text =
                              Actuator.connectedActuator.settings.getOpenAngle;
                        });
                      });
                }
              },
              controller: workingAngleController),
          // torque band
          TextTile(
              title: Text(
                  style: Style.normalText, StringConsts.actuators.torqueBand),
              text: Text(
                  style: Style.normalText,
                  Actuator.connectedActuator.settings.torqueBand.toString())),
        ],
      )),
    );
  }
}
