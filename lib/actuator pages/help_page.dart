import 'package:actuatorapp2/app_bar.dart';
import 'package:actuatorapp2/asset_manager.dart';
import 'package:flutter/material.dart';

import '../String_consts.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(title: StringConsts.help.title),
        body: ListView(
            children: [
              // Make sure actuator has power
              GridTile(
                header: const Text("Make sure it has power"),
                child: AssetManager.logo,
              )
              // Make sure the left led is flashing blue
              // Make sure the app has all the correct permissions
              // Pull down in the connect page to scan for devices
              // Click a device to connect to
              //  if the connection fails logout then login again
              // if it keeps failing then close the app and reopen it
              // if that doesn't work then check you are authorized to connect to that actuator
              // once your connected you can view and control the actuator through each page in the side menu
            ]
        )
    );
  }
}
