import 'package:actuatorapp2/app_bar.dart';
import 'package:actuatorapp2/bluetooth/bluetooth_manager.dart';
import 'package:actuatorapp2/color_manager.dart';
import 'package:actuatorapp2/nav_drawer.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../String_consts.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final EdgeInsets padding = const EdgeInsets.all(10);
  final String bulletPoint = "\u2022";

  int selectedTile = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(title: StringConsts.help.title),
        drawer: const NavDrawer(),
        body: ListView(children: [
          const SizedBox(height: 10),
          // Make sure actuator has power
          Card(
            child: ExpansionTile(
              iconColor: ColorManager.companyYellow,
              collapsedIconColor: ColorManager.companyYellow,
              title: Text(StringConsts.help.isItPowered),
              children: [
                ExpansionTile(
                    title: const Text("Is the Actuator powered"),
                    collapsedIconColor: ColorManager.companyYellow,
                    iconColor: ColorManager.companyYellow,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: padding,
                          child: Text("$bulletPoint Is the battery charged?"),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                            padding: padding,
                            child: Text(
                                "$bulletPoint Is the actuator plugged in?")),
                      )
                    ]),
              ],
            ),
          ),
          // Make sure the app has all the correct permissions
          Card(
              child: ExpansionTile(
                  iconColor: ColorManager.companyYellow,
                  collapsedIconColor: ColorManager.companyYellow,
                  title: Text(StringConsts.help.setAppPermissions),
                  children: [
                // show how to set permissions

                //  add button to open permissions
                Padding(
                  padding: padding,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                          onPressed: () => openAppSettings(),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      ColorManager.blue2.withOpacity(0.1)),
                              foregroundColor: MaterialStateColor.resolveWith(
                                  (states) => ColorManager.companyYellow)),
                          child: Text(StringConsts.help.openSettings))),
                )
              ])),
          Card(
              child: ExpansionTile(
                  iconColor: ColorManager.companyYellow,
                  collapsedIconColor: ColorManager.companyYellow,
                  title: Text(StringConsts.help.isBluetoothEnabled),
                  children: [
                Padding(
                  padding: padding,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                          onPressed: () =>
                              BluetoothManager().enableBluetooth(context),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) => ColorManager.blue2),
                              foregroundColor: MaterialStateColor.resolveWith(
                                  (states) => ColorManager.companyYellow)),
                          child: Text(StringConsts.help.enableBluetooth))),
                )
              ]))

          // Click a device to connect to
          //  if the connection fails logout then login again
          // if it keeps failing then close the app and reopen it
          // if that doesn't work then check you are authorized to connect to that actuator
          // once your connected you can view and control the actuator through each page in the side menu
        ]));
  }
}
