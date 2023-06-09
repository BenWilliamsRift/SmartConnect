import 'dart:async';

import 'package:flutter/material.dart';

import '../asset_manager.dart';
import '../actuator/actuator.dart';
import '../app_bar.dart';
import '../bluetooth/bluetooth_message_handler.dart';
import '../date_time.dart';
import 'list_tiles.dart';
import '../nav_drawer.dart';
import '../string_consts.dart';

class FailsafePage extends StatefulWidget {
  const FailsafePage({Key? key}) : super(key: key);

  @override
  State<FailsafePage> createState() => _FailsafePageState();
}

class _FailsafePageState extends State<FailsafePage> {
  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!Actuator.connectedActuator.writingToFlash) {
        setState(() {
          bluetoothMessageHandler.requestFailsafeMode();
          bluetoothMessageHandler.requestFailsafeDelay();
          bluetoothMessageHandler.requestFailsafeAngle();
        });
      } else {
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

    Style.update();
    return Scaffold(
        appBar: appBar(title: getTitle()),
        drawer: const NavDrawer(),
        body: Stack(
          children: [
            SingleChildScrollView(
                child: Column(
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
                            Actuator.writeToFlash(context, bluetoothMessageHandler);
                          })),
                  Style.sizedWidth
                ]),
                DropDownTile(
                    title: Text(
                        style: Style.normalText,
                        StringConsts.actuators.failsafeMode),
                    items: Actuator.failsafeModes,
                    value: Actuator.failsafeModes.elementAt(
                        Actuator.connectedActuator.settings.failsafeMode),
                    onChanged: (String? failsafeMode) {
                      if (failsafeMode != null) {
                        setState(() {
                          Actuator.connectedActuator.settings.failsafeMode =
                              Actuator.failsafeModes.indexOf(failsafeMode);
                          bluetoothMessageHandler.setFailsafeMode(failsafeMode);
                        });

                        return Actuator.failsafeModes.elementAt(
                            Actuator.connectedActuator.settings.failsafeMode);
                      }
                    }),
                TimePickerTile(
                    title: Text(style: Style.normalText, StringConsts.actuators.failsafeDelay),
                    timeText:
                        Text(Actuator.connectedActuator.failsafeDelay.toString()),
                    time: Actuator.connectedActuator.failsafeDelay,
                    callback: (time) {
                      setState(() {
                        Actuator.connectedActuator.failsafeDelay = Delay.copyFrom(time);
                        bluetoothMessageHandler.setFailsafeDelay(Actuator.connectedActuator.failsafeDelay);
                      });
                    }),
                TextInputTile(
                    initialValue: Actuator.connectedActuator.settings.failsafeAngle
                        .toString(),
                    title: Text(style: Style.normalText, StringConsts.actuators.failsafeAngle),
                    onSaved: (String? value) {
                      Actuator.connectedActuator.settings.failsafeAngle = value != null ? double.parse(value): Actuator.connectedActuator.settings.failsafeAngle;
                      bluetoothMessageHandler.setFailsafeAngle(Actuator.connectedActuator.settings.failsafeAngle);
                    })
              ],
            )),
            (Actuator.connectedActuator.writingToFlash) ? AssetManager.loading : Container()
          ],
        ));
  }
}
