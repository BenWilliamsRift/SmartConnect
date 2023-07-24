import 'dart:async';

import 'package:flutter/material.dart';

import '../actuator/actuator.dart';
import '../app_bar.dart';
import '../asset_manager.dart';
import '../bluetooth/bluetooth_message_handler.dart';
import '../nav_drawer.dart';
import '../string_consts.dart';
import 'list_tiles.dart';

class SpeedControlPage extends StatefulWidget {
  const SpeedControlPage({Key? key}) : super(key: key);

  @override
  State<SpeedControlPage> createState() => _SpeedControlPageState();
}

class _SpeedControlPageState extends State<SpeedControlPage> {
  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();

  bool loading = false;

  late Timer timer;

  @override
  void initState() {
    super.initState();

    bluetoothMessageHandler.requestWorkingTime();

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
  Widget build(BuildContext context) {
    Style.update();

    return Scaffold(
      appBar: appBar(title: getTitle()),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
        children: [
              Style.sizedHeight,
              Row(
                children: [
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
                ],
              ),
              TextInputTile(
                  title: Text(style: Style.normalText, StringConsts.actuators.workingTimeInSeconds),
                  initialValue: Actuator.connectedActuator.workingTime.toString(),
                  onSaved: (String? value) {
                    setState(() {
                      Actuator.connectedActuator.workingTime = value != null
                          ? double.parse(value)
                          : Actuator.connectedActuator.workingTime;

                      bluetoothMessageHandler.setWorkingTime(Actuator.connectedActuator.workingTime);
                    });
                  }),
        ],
      ),
              loading ? AssetManager.loading : Container()
            ],
          )),
    );
  }
}
