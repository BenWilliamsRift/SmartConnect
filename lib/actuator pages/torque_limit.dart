import 'dart:async';

import 'package:flutter/material.dart';

import '../actuator/actuator.dart';
import '../app_bar.dart';
import '../bluetooth/bluetooth_message_handler.dart';
import '../date_time.dart';
import '../nav_drawer.dart';
import '../settings.dart';
import '../string_consts.dart';
import 'list_tiles.dart';

class TorqueLimitPage extends StatefulWidget {
  const TorqueLimitPage({Key? key}) : super(key: key);

  @override
  State<TorqueLimitPage> createState() => _TorqueLimitPageState();
}

class _TorqueLimitPageState extends State<TorqueLimitPage> {
  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();

  bool loading = false;

  late Timer timer;

  @override
  void initState() {
    super.initState();

    bluetoothMessageHandler.requestTorqueLimit();
    bluetoothMessageHandler.requestTorqueLimitBackoffAngle();
    bluetoothMessageHandler.requestTorqueLimitDelayBeforeRetry();

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
    return Scaffold(
      appBar: appBar(title: getTitle(), context: context),
        drawer: const NavDrawer(),
        body: SingleChildScrollView(
            child: Column(children: [
          Style.sizedHeight,
          Row(
            children: [
              Style.sizedWidth,
              Expanded(
                  child: Button(
                onPressed: () {
                    setState(() {
                      Actuator.writeToFlash(context, bluetoothMessageHandler);
                    });
                  },
                  child: Text(
                      style: Style.normalText,
                      StringConsts.actuators.writeToFlash),
                )),
                Style.sizedWidth
              ],
            ),
            TextInputTile(
              title: Text(StringConsts.actuators.torqueLimit),
              initialValue: Settings.convertTorqueUnits(torque: Actuator.connectedActuator.settings.torqueLimitNm).toString(),
              onSaved: (String? value) {
                setState(() {
                  Actuator.connectedActuator.settings.setTorqueLimitNm(value);
                });
              },
            ),
            TextInputTile(
              title: Text(StringConsts.actuators.torqueLimitBackOff),
              initialValue: Actuator.connectedActuator.settings.torqueLimitBackoffAngle.toString(),
              onSaved: (String? value) {
                setState(() {
                  if (value != null) {
                    Actuator.connectedActuator.settings
                        .torqueLimitBackoffAngle = double.parse(value);
                  }
                });
                },
            ),
            SwitchTile(
              title: Text(StringConsts.actuators.retryAfterTorqueLimit),
              initValue: Actuator.connectedActuator.settings.retryAfterTorqueLimit,
              callback: (bool value) {setState(() {
                Actuator.connectedActuator.settings.retryAfterTorqueLimit = value;
              });},
            ),
            TimePickerTile(
              title: Text(StringConsts.actuators.torqueLimitDelayBeforeRetry),
              timeText: Text(Actuator.connectedActuator.settings.torqueLimitDelayBeforeRetry.toString()),
              time: Actuator.connectedActuator.settings.torqueLimitDelayBeforeRetry,
              callback: (time) {
                setState(() {
                  Actuator.connectedActuator.settings.torqueLimitDelayBeforeRetry = Delay.copyFrom(time);
                });
              }
            )
          ]
        )
      )
    );
  }
}
