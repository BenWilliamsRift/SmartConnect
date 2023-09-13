import 'dart:async';

import 'package:flutter/material.dart';

import '../actuator/actuator.dart';
import '../app_bar.dart';
import '../asset_manager.dart';
import '../bluetooth/bluetooth_message_handler.dart';
import '../main.dart';
import '../nav_drawer.dart';
import '../string_consts.dart';
import '../web_controller.dart';
import 'list_tiles.dart';

class FeaturesPage extends StatefulWidget {
  const FeaturesPage({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  State<FeaturesPage> createState() => _FeaturesPageState();
}

class _FeaturesPageState extends State<FeaturesPage> {
  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();
  WebController webController = WebController();

  String? response;

  @override
  void initState() {
    super.initState();

    Actuator.connectedActuator.settings.featurePasswordsIntoActuator(false);

    showLoading = true;
    updateFeatures();
  }

  List<SwitchTile> switches = [];

  bool showLoading = false;

  void updateFeatures() async {
    Actuator.connectedActuator.settings.updateFeatures();

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showLoading = false;
        showSnackBar(
            context, StringConsts.actuators.featureUpdated, null, null);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    Style.update();

    // Must be kept in this order
    // order is like this because the data that is received isn't structured so it is just assumed that all the right data is received and that the order of switches is the same
    // Hidden some features because it is never used
    switches = [
      SwitchTile(
        isLocked: !Actuator.connectedActuator.torqueLimit,
        visible: true,
        title:
        Text(style: Style.normalText, StringConsts.actuators.torqueLimit),
        initValue: Actuator.connectedActuator.torqueLimit,
        callback: (bool value) {
          Actuator.connectedActuator.torqueLimit = value;
        },
        setValue: () {
          return Actuator.connectedActuator.torqueLimit;
        },
      ), // torque_limit_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.isNm60,
        visible: true,
        title: Text(style: Style.normalText, StringConsts.actuators.nm60),
        initValue: Actuator.connectedActuator.isNm60,
        callback: (bool value) {
          Actuator.connectedActuator.isNm60 = value;
        },
        setValue: () {
          return Actuator.connectedActuator.isNm60;
        },
      ), // nm60_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.isNm80,
        visible: true,
        title: Text(style: Style.normalText, StringConsts.actuators.nm80),
        initValue: Actuator.connectedActuator.isNm80,
        callback: (bool value) {
          Actuator.connectedActuator.isNm80 = value;
        },
        setValue: () {
          return Actuator.connectedActuator.isNm80;
        },
      ), // nm80_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.isNm100,
        visible: true,
        title: Text(style: Style.normalText, StringConsts.actuators.nm100),
        initValue: Actuator.connectedActuator.isNm100,
        callback: (bool value) {
          Actuator.connectedActuator.isNm100 = value;
        },
        setValue: () {
          return Actuator.connectedActuator.isNm100;
        },
      ), // nm100_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.twoWireControl,
        visible: false,
        title: Text(
            style: Style.normalText, StringConsts.actuators.twoWireControl),
        initValue: Actuator.connectedActuator.twoWireControl,
        callback: (bool value) {
          Actuator.connectedActuator.twoWireControl = value;
        },
        setValue: () {
          return Actuator.connectedActuator.twoWireControl;
        },
      ), // twowire_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.failsafe,
        visible: true,
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.failsafe,
        ),
        initValue: Actuator.connectedActuator.failsafe,
        callback: (bool value) {
          Actuator.connectedActuator.failsafe = value;
        },
        setValue: () {
          return Actuator.connectedActuator.failsafe;
        },
      ), // failsafe_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.modulating,
        visible: true,
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.modulating,
        ),
        initValue: Actuator.connectedActuator.modulating,
        callback: (bool value) {
          Actuator.connectedActuator.modulating = value;
        },
        setValue: () {
          return Actuator.connectedActuator.modulating;
        },
      ), // modulating_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.speedControl,
        visible: true,
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.speedControl,
        ),
        initValue: Actuator.connectedActuator.speedControl,
        callback: (bool value) {
          Actuator.connectedActuator.speedControl = value;
        },
        setValue: () {
          return Actuator.connectedActuator.speedControl;
        },
      ), // speed_control_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.multiTurn,
        visible: true,
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.multiTurn,
        ),
        initValue: Actuator.connectedActuator.multiTurn,
        callback: (bool value) {
          Actuator.connectedActuator.multiTurn = value;
        },
        setValue: () {
          return Actuator.connectedActuator.multiTurn;
        },
      ), // multi_turn_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.offGridTimer,
        visible: true,
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.offGridTimer,
        ),
        initValue: Actuator.connectedActuator.offGridTimer,
        callback: (bool value) {
          Actuator.connectedActuator.offGridTimer = value;
        },
        setValue: () {
          return Actuator.connectedActuator.offGridTimer;
        },
      ), // off_grid_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.wiggle,
        visible: true,
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.wiggle,
        ),
        initValue: Actuator.connectedActuator.wiggle,
        callback: (bool value) {
          Actuator.connectedActuator.wiggle = value;
        },
        setValue: () {
          return Actuator.connectedActuator.wiggle;
        },
      ), // wiggle_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.controlSystem,
        visible: false,
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.controlSystem,
        ),
        initValue: Actuator.connectedActuator.controlSystem,
        callback: (bool value) {
          Actuator.connectedActuator.controlSystem = value;
        },
        setValue: () {
          return Actuator.connectedActuator.controlSystem;
        },
      ), // control_systems_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.valveProfile,
        visible: false,
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.valveProfile,
        ),
        initValue: Actuator.connectedActuator.valveProfile,
        callback: (bool value) {
          Actuator.connectedActuator.valveProfile = value;
        },
        setValue: () {
          return Actuator.connectedActuator.valveProfile;
        },
      ), // valve_profile_feature
      SwitchTile(
        isLocked: !Actuator.connectedActuator.analogDeadband,
        visible: false,
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.analogDeadband,
        ),
        initValue: Actuator.connectedActuator.analogDeadband,
        callback: (bool value) {
          Actuator.connectedActuator.analogDeadband = value;
        },
        setValue: () {
          return Actuator.connectedActuator.analogDeadband;
        },
      ), // analog_deadband_feature
    ];

    return Scaffold(
        appBar: appBar(title: getTitle(), context: context),
        drawer: const NavDrawer(),
        body: Stack(
          children: [
            SingleChildScrollView(
                child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Row(children: [
                    Expanded(flex: 1, child: Style.sizedWidth),
                    Expanded(
                            flex: 3,
                            child: Button(
                                child: Text(
                                    style: Style.normalText,
                                    StringConsts.actuators.syncFromInternet),
                                onPressed: () {
                                  setState(() {
                                    showLoading = true;
                                    updateFeatures();
                                  });
                                })),
                        Expanded(flex: 1, child: Style.sizedWidth)
                      ]),
                    ),
                    for (Widget featureSwitch in switches) featureSwitch
                  ],
                )),
            (showLoading) ? Center(child: AssetManager.loading) : Container()
          ],
        ));
  }
}
