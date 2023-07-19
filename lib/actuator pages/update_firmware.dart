import 'dart:async';

import 'package:actuatorapp2/asset_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../actuator/actuator.dart';
import '../app_bar.dart';
import '../bluetooth/bluetooth_message_handler.dart';
import '../nav_drawer.dart';
import '../string_consts.dart';
import 'list_tiles.dart';

class UpdateFirmwarePage extends StatefulWidget {
  const UpdateFirmwarePage({Key? key}) : super(key: key);

  @override
  State<UpdateFirmwarePage> createState() => _UpdateFirmwarePageState();
}

class _UpdateFirmwarePageState extends State<UpdateFirmwarePage> {
  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();

  late Timer updateInfoTimer;

  bool hasShownAlert = false;
  bool showLoading = false;

  @override
  void initState() {
    super.initState();
    bluetoothMessageHandler.requestFirmwareVersion();

    updateInfoTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        bluetoothMessageHandler.getBootloaderStatus();
      });
    });

    hasShownAlert = false;
  }

  @override
  void dispose() {
    super.dispose();

    updateInfoTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Style.update();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          bluetoothMessageHandler.getBootloaderStatus();
          bluetoothMessageHandler.requestFirmwareVersion();
        });
      }
    });

    return Scaffold(
        appBar: appBar(title: getTitle()),
        drawer: const NavDrawer(),
        body: Stack(
          children: [
            showLoading ? Center(child: AssetManager.loading) : Container(),
            SingleChildScrollView(
                child: Column(
              children: [
                TextTile(
                    title: Text(
                        style: Style.normalText, StringConsts.appVersionTitle),
                    text:
                        Text(style: Style.normalText, StringConsts.appVersion)),
                TextTile(
                    title: Text(
                        style: Style.normalText,
                        StringConsts.actuators.firmwareVersion),
                    text: Text(
                        style: Style.normalText,
                        Actuator.connectedActuator.settings.firmwareVersion
                            .toString()),
                    update: () {
                      bluetoothMessageHandler.requestFirmwareVersion();
                    }),
                Row(children: [
                  Style.sizedWidth,
                  Expanded(
                      child: Button(
                          child: Text(Actuator.connectedActuator.inBootLoader
                              ? StringConsts.actuators.exitBootloader
                              : StringConsts.actuators.enterBootloader),
                          onPressed: () {
                            setState(() {
                              if (kDebugMode) {
                                print(Actuator.connectedActuator.inBootLoader);
                              }

                              // if (hasShownAlert) {
                              //   if (Actuator.connectedActuator.inBootLoader) {
                              //     bluetoothMessageHandler.exitBootloader();
                              //     Actuator.connectedActuator.inBootLoader =
                              //         false;
                              //   } else {
                              //     bluetoothMessageHandler.enterBootloader();
                              //     Actuator.connectedActuator.inBootLoader =
                              //         true;
                              //   }
                              // } else {
                              hasShownAlert = true;
                              confirmationMessage(
                                  context: context,
                                  text: StringConsts.actuators
                                      .bootloaderDoYouKnowWhatYourDoing,
                                  yesAction: () {
                                    // let the user continue
                                    bluetoothMessageHandler.enterBootloader();
                                    Actuator.connectedActuator.inBootLoader =
                                        true;
                                  },
                                  noAction: () {
                                      Navigator.pop(context);
                                    });
                              // }
                            });
                          })),
                  Style.sizedWidth,
                ]),
                Actuator.connectedActuator.inBootLoader
                    ? Row(children: [
                        Style.sizedWidth,
                        Expanded(
                            child: Button(
                                child:
                                    Text(StringConsts.actuators.uploadFirmware),
                                onPressed: () {
                                  setState(() {
                                    if (!showLoading) {
                                      bluetoothMessageHandler.updateFirmware();

                                      showLoading = true;
                                      Future.delayed(
                                          bluetoothMessageHandler
                                              .getEstimatedTimeForFirmware(),
                                          () {
                                        setState(() {
                                          showLoading = false;
                                        });
                                      });
                                    }
                                  });
                                })),
                        Style.sizedWidth,
                      ])
                    : Container(),
                Text(
                    textAlign: TextAlign.center,
                    Actuator.connectedActuator.inBootLoader
                        ? "${StringConsts.actuators.inBootLoader[0]}${Actuator.connectedActuator.settings.firmwareVersion.toString()}${StringConsts.actuators.inBootLoader[1]}"
                        : StringConsts.actuators.notInBootLoader,
                    style: Style.subtitle),
              ],
            )),
          ],
        ));
  }
}
