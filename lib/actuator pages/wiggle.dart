import 'dart:async';

import 'package:flutter/material.dart';

import '../actuator/actuator.dart';
import '../app_bar.dart';
import '../asset_manager.dart';
import '../bluetooth/bluetooth_message_handler.dart';
import '../date_time.dart';
import '../nav_drawer.dart';
import '../string_consts.dart';
import 'list_tiles.dart';

class WigglePage extends StatefulWidget {
  const WigglePage({Key? key}) : super(key: key);

  @override
  State<WigglePage> createState() => _WigglePageState();
}

class _WigglePageState extends State<WigglePage> {
  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();

  bool loading = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    bluetoothMessageHandler.requestWiggleEnabled();
    bluetoothMessageHandler.requestWiggleAngle();
    bluetoothMessageHandler.requestWiggleTimeBetween();

    timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
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
    });
  }

  @override
  void dispose() {
    super.dispose();

    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(title: getTitle()),
        drawer: const NavDrawer(),
        body: SingleChildScrollView(
            child: Stack(
              children: [
                Column(children: [
          Row(children: [
                Style.sizedWidth,
                Expanded(
                    child: Button(
                        child: Text(
                            style: Style.normalText,
                            StringConsts.actuators.writeToFlash),
                        onPressed: () {
                          Actuator.writeToFlash(context, bluetoothMessageHandler);
                        })),
                Style.sizedWidth
          ]),
          SwitchTile(
              title: Text(
                    style: Style.normalText,
                    StringConsts.actuators.wiggle,
                  ),
                  initValue: Actuator.connectedActuator.wiggle,
                  callback: (bool value) {
                    Actuator.connectedActuator.wiggle = value;
                    bluetoothMessageHandler
                        .setWiggleEnabled(Actuator.connectedActuator.wiggle);
                  }),
          TextInputTile(
                title: Text(style: Style.normalText, StringConsts.actuators.wiggleAngle),
                initialValue:
                    Actuator.connectedActuator.settings.wiggleAngle.toString(),
                onSaved: (String? value) {
                  Actuator.connectedActuator.settings.wiggleAngle = value != null ? double.parse(value) : Actuator.connectedActuator.settings.wiggleAngle;
                  bluetoothMessageHandler.setWiggleAngle(Actuator.connectedActuator.settings.wiggleAngle);
                },
          ),
          TimePickerTile(
                  title: Text(style: Style.normalText, StringConsts.actuators.timeBetweenWiggles),
                  timeText: Text(Actuator.connectedActuator.settings.timeBetweenWiggles.toString()),
                  time: Actuator.connectedActuator.settings.timeBetweenWiggles,
                  callback: (time) {
                    setState(() {
                      Actuator.connectedActuator.settings.timeBetweenWiggles = Delay.copyFrom(time);
                      bluetoothMessageHandler.setWiggleTimeBetween(Actuator.connectedActuator.settings.timeBetweenWiggles);
                    });
                  }
          )
        ]),
                loading ? AssetManager.loading : Container()
              ],
            )));
  }
}
