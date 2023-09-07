// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:actuatorapp2/settings.dart';
import 'package:flutter/material.dart';

import '../actuator/actuator.dart';
import '../app_bar.dart';
import '../asset_manager.dart';
import '../bluetooth/bluetooth_message_handler.dart';
import '../color_manager.dart';
import '../nav_drawer.dart';
import '../string_consts.dart';
import 'list_tiles.dart';

bool isLocked = false;

class BasicSettingsPage extends StatefulWidget {
  const BasicSettingsPage({Key? key}) : super(key: key);

  @override
  State<BasicSettingsPage> createState() => _BasicSettingsPageState();
}

class _BasicSettingsPageState extends State<BasicSettingsPage> {
  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();

  void requestAll() {
    bluetoothMessageHandler.requestFirmwareVersion();
    bluetoothMessageHandler.requestValveOrientation();
    bluetoothMessageHandler.requestBacklash();
    bluetoothMessageHandler.requestButtonsEnabled();
    bluetoothMessageHandler.requestNumberOfFullCycles();
    bluetoothMessageHandler.requestNumberOfStarts();
    bluetoothMessageHandler.requestSleepEnabled();
    bluetoothMessageHandler.requestMagnetTest();
    bluetoothMessageHandler.requestStartInManual();
    bluetoothMessageHandler.requestIndicationMode();
    bluetoothMessageHandler.requestReverseActing();
    bluetoothMessageHandler.requestLocked();
  }

  late Timer timer;

  @override
  void initState() {
    super.initState();
    requestAll();

    timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (mounted) {
        setState(() {
          bluetoothMessageHandler.requestPIDP();
          bluetoothMessageHandler.requestPIDI();
        });

        if (Actuator.connectedActuator.writingToFlash) {
          if (!loading) {
            setState(() {
              loading = true;
            });
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                loading = false;
                Actuator.connectedActuator.writingToFlash = false;
              });
            });
          }
        }
      }
    });

    bluetoothMessageHandler.requestLocked();
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Style.update();

    TextEditingController lockTextController = TextEditingController();

    return Scaffold(
        appBar: appBar(title: getTitle(), context: context),
        drawer: const NavDrawer(),
        body: Stack(
          children: [
            SingleChildScrollView(
                child: Column(children: [
                  AbsorbPointer(
                    absorbing: isLocked || loading,
                    child: Column(
                      children: [
                        Style.sizedHeight,
                    Row(
                      children: [
                        Style.sizedWidth,
                        Expanded(
                            child: Button(
                          onPressed: () {
                            setState(() {
                              Actuator.writeToFlash(
                                  context, bluetoothMessageHandler);
                            });
                          },
                          child: Text(
                              style: Style.normalText,
                              StringConsts.actuators.writeToFlash),
                        )),
                        Style.sizedWidth
                      ],
                    ),
                    Style.sizedHeight,
                    TextTile(
                        title: Text(
                            style: Style.normalText,
                            StringConsts.actuators.firmwareVersion),
                        text: Text(
                            style: Style.normalText,
                            Actuator.connectedActuator.settings.firmwareVersion
                                .toString())),

                    // pid access code
                    Settings.pidAccessUnlocked
                        ? TextInputTile(
                            onSaved: (String? value) {
                              setState(() {});
                            },
                            title: Text(StringConsts.actuators.pidP))
                        : Container(),
                    Settings.pidAccessUnlocked
                        ? TextInputTile(
                            onSaved: (String? value) {
                              setState(() {});
                            },
                            title: Text(StringConsts.actuators.pidI))
                        : Container(),

                    DropDownTile(
                        title: Text(
                            style: Style.normalText,
                            StringConsts.actuators.valveOrientation),
                        items: Actuator.valveOrientations,
                        value: Actuator.valveOrientations.elementAt(
                            Actuator.valveOrientationAngles.indexOf(Actuator
                                .connectedActuator.settings.valveOrientation)),
                        onChanged: (String? valveOrientation) {
                          if (valveOrientation != null) {
                            setState(() {
                              Actuator.connectedActuator.settings
                                      .valveOrientation =
                                  Actuator.valveOrientationAngles.elementAt(
                                      Actuator.valveOrientations
                                          .indexOf(valveOrientation));
                              bluetoothMessageHandler.setValveOrientation(
                                  Actuator.connectedActuator.settings
                                      .valveOrientation);
                            });

                            return Actuator.valveOrientations.elementAt(
                                Actuator.valveOrientationAngles.indexOf(Actuator
                                    .connectedActuator
                                    .settings
                                    .valveOrientation));
                          }
                        }),
                    TextInputTile(
                        title: Text(
                            style: Style.normalText,
                            StringConsts.actuators.backlash),
                        initialValue: Actuator
                            .connectedActuator.settings.backlash
                            .toString(),
                        onSaved: (String? value) {
                          Actuator.connectedActuator.settings.backlash =
                              value != null
                                  ? double.parse(value)
                                  : Actuator
                                      .connectedActuator.settings.backlash;
                          bluetoothMessageHandler.setBacklash(
                              Actuator.connectedActuator.settings.backlash);
                        }),
                    SwitchTile(
                        title: Text(
                          style: Style.normalText,
                          StringConsts.actuators.buttonsEnabled,
                        ),
                        initValue:
                            Actuator.connectedActuator.settings.buttonsEnabled,
                        callback: (bool value) {
                          Actuator.connectedActuator.settings.buttonsEnabled =
                              value;
                          bluetoothMessageHandler.setButtonsEnabled(value);
                        }),
                    TextTile(
                        title: Text(
                            style: Style.normalText,
                            StringConsts.actuators.numberOfFullCycles),
                        text: Text(
                            style: Style.normalText,
                            Actuator
                                .connectedActuator.settings.numberOfFullCycles
                                .toString()),
                        update: () {
                          bluetoothMessageHandler.requestNumberOfFullCycles();
                        }),
                    TextTile(
                        title: Text(
                            style: Style.normalText,
                            StringConsts.actuators.numberOfStarts),
                        text: Text(
                            style: Style.normalText,
                            Actuator.connectedActuator.settings.numberOfStarts
                                .toString()),
                        update: () {
                          bluetoothMessageHandler.requestNumberOfStarts();
                        }),
                    SwitchTile(
                        title: Text(
                          style: Style.normalText,
                          StringConsts.actuators.sleepWhenNotPowered,
                        ),
                        initValue: Actuator
                            .connectedActuator.settings.sleepWhenNotPowered,
                        callback: (bool value) {
                          Actuator.connectedActuator.settings
                              .sleepWhenNotPowered = value;
                          bluetoothMessageHandler.setSleepEnabled(value);
                        }),
                    SwitchTile(
                        title: Text(
                          style: Style.normalText,
                          StringConsts.actuators.magnetTestMode,
                        ),
                        initValue:
                            Actuator.connectedActuator.settings.magnetTestMode,
                        callback: (bool value) {
                          Actuator.connectedActuator.settings.magnetTestMode =
                              value;
                          bluetoothMessageHandler.setMagnetTest(value);
                        }),
                    SwitchTile(
                        title: Text(
                          style: Style.normalText,
                          StringConsts.actuators.startInManualMode,
                        ),
                        initValue: Actuator
                            .connectedActuator.settings.startInManualMode,
                        callback: (bool value) {
                          Actuator.connectedActuator.settings
                              .startInManualMode = value;
                          bluetoothMessageHandler.setStartInManual(value);
                        }),
                    DropDownTile(
                        title: Text(
                            style: Style.normalText,
                            StringConsts.actuators.indicationMode),
                        items: Actuator.indicationModes,
                        value: Actuator.indicationModes.elementAt(
                            Actuator.connectedActuator.settings.indicationMode),
                        onChanged: (String? indicationMode) {
                          if (indicationMode != null) {
                            setState(() {
                              Actuator.connectedActuator.settings
                                      .indicationMode =
                                  Actuator.indicationModes
                                      .indexOf(indicationMode);
                              bluetoothMessageHandler.setIndicationMode(Actuator
                                  .connectedActuator.settings.indicationMode);
                            });

                            return Actuator.indicationModes.elementAt(Actuator
                                .connectedActuator.settings.indicationMode);
                          }
                        }),
                    SwitchTile(
                        title: Text(
                          style: Style.normalText,
                          StringConsts.actuators.reverseActing,
                        ),
                        initValue:
                            Actuator.connectedActuator.settings.reverseActing,
                        callback: (bool value) {
                          Actuator.connectedActuator.settings.reverseActing =
                              value;
                          bluetoothMessageHandler.setReverseActing(value);
                        }),
                    Style.sizedHeight,
                    Divider(
                      indent: Style.padding,
                      endIndent: Style.padding,
                      color: ColorManager.colorAccent,
                      thickness: 2,
                    ),
                    Style.sizedHeight,
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: Card(
                          child: ListTile(
                              title: Text(
                                  style: Style.normalText,
                                  StringConsts.actuators.lock),
                              trailing: Button(
                                  onPressed: () {
                                    setState(() {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(StringConsts.actuators
                                                  .confirmLock(Actuator
                                                      .connectedActuator
                                                      .isLocked)),
                                              content: TextFormField(
                                                  controller:
                                                      lockTextController,
                                                  onSaved: (String? value) {
                                                    lockTextController.text =
                                                        value!;
                                                  }),
                                              actions: [
                                                TextButton(
                                                  onPressed: (() {
                                                    Navigator.of(context).pop();
                                                  }),
                                                  child: const Text(
                                                      StringConsts.cancel),
                                                ),
                                                TextButton(
                                                  onPressed: (() {
                                                    setState(() {
                                                      Navigator.of(context)
                                                          .pop();
                                                      if (Actuator
                                                              .connectedActuator
                                                              .isLocked &&
                                                          lockTextController
                                                                  .text
                                                                  .toUpperCase() ==
                                                              "UNLOCK") {
                                                        bluetoothMessageHandler
                                                            .unlock();
                                                        isLocked = false;
                                                      } else if (!Actuator
                                                              .connectedActuator
                                                              .isLocked &&
                                                          lockTextController
                                                                  .text
                                                                  .toUpperCase() ==
                                                              "LOCK") {
                                                        bluetoothMessageHandler
                                                            .lock();
                                                        isLocked = true;
                                                      }
                                                    });
                                                  }),
                                                  child: const Text(
                                                      StringConsts.confirm),
                                                ),
                                              ],
                                            );
                                          });
                                    });
                                  },
                                  child: Text(
                                      style: Style.smallText,
                                      Actuator.connectedActuator.isLocked ==
                                              null
                                          ? StringConsts.bluetooth.notConnected
                                          : Actuator.connectedActuator.isLocked
                                              ? StringConsts.actuators.unlock
                                                  .toUpperCase()
                                              : StringConsts.actuators.lock
                                                  .toUpperCase())))))
                ],
              ),
            ])),
            loading ? Center(child: AssetManager.loading) : Container(),
          ],
        ));
  }
}
