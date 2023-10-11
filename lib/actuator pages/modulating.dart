import 'dart:async';

import 'package:flutter/material.dart';

import '../actuator/actuator.dart';
import '../app_bar.dart';
import '../asset_manager.dart';
import '../bluetooth/bluetooth_message_handler.dart';
import '../nav_drawer.dart';
import '../string_consts.dart';
import 'list_tiles.dart';

class ModulatingPage extends StatefulWidget {
  const ModulatingPage({Key? key}) : super(key: key);

  final String name = StringConsts.modulating;

  @override
  State<ModulatingPage> createState() => _ModulatingPageState();
}

class _ModulatingPageState extends State<ModulatingPage> {
  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();

  bool loading = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    bluetoothMessageHandler.requestLossOfSignalMode();
    bluetoothMessageHandler.requestLossOfSignalAngle();
    bluetoothMessageHandler.requestAnalogSignalMode();
    bluetoothMessageHandler.requestAnalogDeadbandForwards();
    bluetoothMessageHandler.requestAnalogDeadbandBackwards();
    bluetoothMessageHandler.requestModulatingInversion();

    timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (mounted) {
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
            child: Stack(
          children: [
            Column(
              children: [
                Style.sizedHeight,
                Row(children: [
                  Style.sizedWidth,
                  Expanded(
                      child: Button(
                          child: Text(
                              style: Style.normalText,
                              StringConsts.actuators.writeToFlash),
                          onPressed: () {
                            setState(() {
                              Actuator.writeToFlash(context, bluetoothMessageHandler);
                            });
                          })),
                  Style.sizedWidth
                ]),
                DropDownTile(
                    title: Text(
                        style: Style.normalText,
                        StringConsts.actuators.lossOfSignalMode),
                    items: Actuator.lossOfSignalModes,
                    value: Actuator.lossOfSignalModes.elementAt(
                        Actuator.connectedActuator.settings.lossOfSignalMode),
                    onChanged: (String? lossOfSignalMode) {
                      if (lossOfSignalMode != null) {
                        setState(() {
                          Actuator.connectedActuator.settings.lossOfSignalMode =
                              Actuator.lossOfSignalModes.indexOf(lossOfSignalMode);
                        });

                        bluetoothMessageHandler.setLossOfSignalMode(Actuator.connectedActuator.settings.lossOfSignalMode);

                        return Actuator.lossOfSignalModes.elementAt(
                            Actuator.connectedActuator.settings.lossOfSignalMode);
                      }
                    }),
                TextInputTile(
                  title: Text(style: Style.normalText, StringConsts.actuators.lossOfSignalAngle),
                  initialValue: Actuator
                      .connectedActuator.settings.lossOfSignalAngle
                      .toString(),
                  onSaved: (String? value) {
                    Actuator.connectedActuator.settings.lossOfSignalAngle =
                        value != null
                            ? double.parse(value)
                            : Actuator.connectedActuator.settings.lossOfSignalAngle;

                    bluetoothMessageHandler.setLossOfSignalAngle(Actuator.connectedActuator.settings.lossOfSignalAngle);
                  },
                ),
                DropDownTile(
                    title: Text(
                        style: Style.normalText,
                        StringConsts.actuators.analogSignalMode),
                    items: Actuator.analogSignalModes,
                    value: Actuator.analogSignalModes
                        .elementAt(Actuator.connectedActuator.analogSignalMode),
                    onChanged: (String? analogSignalMode) {
                      if (analogSignalMode != null) {
                        setState(() {
                          Actuator.connectedActuator.analogSignalMode =
                              Actuator.analogSignalModes.indexOf(analogSignalMode);
                        });

                        bluetoothMessageHandler.setAnalogSignalMode(Actuator.connectedActuator.analogSignalMode);

                        return Actuator.analogSignalModes
                            .elementAt(Actuator.connectedActuator.analogSignalMode);
                      }
                    }),
                TextInputTile(
                  title: Text(
                    style: Style.normalText,
                    StringConsts.actuators.deadbandForwards),
                  initialValue: Actuator.connectedActuator.deadbandForwards.toString(),
                  onSaved: (String? value) {
                    setState(() {
                      if (value != null) {
                        Actuator.connectedActuator.deadbandForwards = double.parse(value);
                        bluetoothMessageHandler.setAnalogDeadbandForwards(Actuator.connectedActuator.deadbandForwards);
                      }
                    });
                  },
                ),
                TextInputTile(
                  title: Text(
                    style: Style.normalText,
                    StringConsts.actuators.deadbandBackwards),
                  initialValue: Actuator.connectedActuator.deadbandBackwards.toString(),
                  onSaved: (String? value) {
                    setState(() {
                      if (value != null) {
                        Actuator.connectedActuator.deadbandBackwards = double.parse(value);
                        bluetoothMessageHandler.setAnalogDeadbandBackwards(Actuator.connectedActuator.deadbandBackwards);
                      }
                    });
                  },
                ),
                SwitchTile(
                    title: Text(
                      style: Style.normalText,
                      StringConsts.actuators.invertSignal,
                    ),
                    initValue: Actuator.connectedActuator.invertSignal,
                    callback: (bool value) {
                      Actuator.connectedActuator.invertSignal = value;
                      bluetoothMessageHandler.setModulatingInversion(Actuator.connectedActuator.invertSignal);
                    }),
          ],
        ),
                loading ? AssetManager.loading : Container()
              ],
            )));
  }
}
