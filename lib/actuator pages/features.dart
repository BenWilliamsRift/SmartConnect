import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../actuator/actuator.dart';
import '../actuator/actuator_settings.dart';
import '../app_bar.dart';
import '../asset_manager.dart';
import '../bluetooth/bluetooth_message_handler.dart';
import '../main.dart';
import '../nav_drawer.dart';
import '../preference_manager.dart';
import '../string_consts.dart';
import '../web_controller.dart';
import 'list_tiles.dart';

class FeaturesPage extends StatefulWidget {
  const FeaturesPage({Key? key}) : super(key: key);

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

    featurePasswordsIntoActuator(false);

    showLoading = true;
    updateFeatures();
  }

  List<SwitchTile> switches = [];

  bool showLoading = false;

  // TODO test features
  void updateFeatures() async {
    response = await webController.getFeaturePasswords();

    if (response == null) {
      // ignore: use_build_context_synchronously
      showSnackBar(
          context, StringConsts.actuators.failedToUpdateFeatures, null, null);
    } else {
      // write passwords to file

      response = response?.replaceAll("<br>", "\n");

      PreferenceManager.writeString(
          PreferenceManager.passwords, response.toString());

      featurePasswordsIntoActuator(true);
    }

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showLoading = false;
        showSnackBar(
            context, StringConsts.actuators.featureUpdated, null, null);
      });
    });
  }

  List<String> splitPasswords(
      String source, String boardNumber, int index, String separator) {
    List<String> passwords = source.split("\n");

    // return the line that has the board number in
    return passwords.firstWhere(
        (element) => element.split(separator).elementAt(0) == boardNumber,
        orElse: () {
      if (kDebugMode) {
        print("Actuator not found");
      }
      return "";
    }).split(separator);
  }

  void featurePasswordsIntoActuator(bool shouldOpenPasswords) {
    String? passwords =
        PreferenceManager.getString(PreferenceManager.passwords);

    if (passwords == null) return;

    String boardNumber = Actuator.connectedActuator.boardNumber.toString();
    if (kDebugMode) {
      print(boardNumber);
    }
    List<String> line = splitPasswords(passwords, boardNumber, 0, " ");

    if (line.length < ActuatorConstants.numberOfFeatures) return;

    try {
      for (int i = 0; i < ActuatorConstants.numberOfFeatures; i++) {
        // Set all Passwords
        Actuator.connectedActuator.settings
            .setFeaturePassword(i, line.elementAt(i + 1));
      }
    } on Exception {
      // log error
      if (kDebugMode) {
        print("Error");
      }
    }

    if (shouldOpenPasswords) {
      updatePasswords();
    }

  }

  void updatePasswords() {
    List<String> passwords =
          Actuator.connectedActuator.settings.featuresPasswords;
      for (int i = 0; i < ActuatorConstants.numberOfFeatures - 1; i++) {
        String password = passwords.elementAt(i);


        SwitchTile featureSwitch = switches.elementAt(i);
        bool didComplete = true;
        if (!featureSwitch.initValue) {
          switch (password.toLowerCase()) {
            case "none":
              // Hide feature
              featureSwitch.setValue!(false);
              break;
            case "disable":
              // Show feature but disable switch
              featureSwitch.setValue!(false);
              break;
            default:
              didComplete = false;
          }
        }
        if (!didComplete) {
          featureSwitch.setValue!(true);
        }
      // if (password.toLowerCase() == "none" || password.toLowerCase() == "disable" && !featureSwitch.initValue) {
      // //     uses a callback set for each switch
      //     featureSwitch.setValue!(false);
      //   } else {
      //     featureSwitch.setValue!(true);
      //     // TODO Add different features
      //   }
      }
  }

  @override
  Widget build(BuildContext context) {
    Style.update();

    // Must be kept in this order
    // order is like this because the data that is received isn't structured so it is just assumed that all the right data is received and that the order of switches is the same
    switches = [
      SwitchTile(
        visible: true,
        touchInputDisabled: true,
        title:
            Text(style: Style.normalText, StringConsts.actuators.torqueLimit),
        initValue: Actuator.connectedActuator.torqueLimit ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.torqueLimit == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.torqueLimit ?? false
                  ? Actuator.connectedActuator.torqueLimit = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.torqueLimit = value;
        },
      ), // torque_limit_feature
      SwitchTile(
        visible: true,
        touchInputDisabled: true,
        title: Text(style: Style.normalText, StringConsts.actuators.nm60),
        initValue: Actuator.connectedActuator.isNm60 ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.isNm60 == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.isNm60 ?? false
                  ? Actuator.connectedActuator.isNm60 = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.isNm60 = value;
        },
      ), // nm60_feature
      SwitchTile(
        visible: true,
        touchInputDisabled: true,
        title: Text(style: Style.normalText, StringConsts.actuators.nm80),
        initValue: Actuator.connectedActuator.isNm80 ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.isNm80 == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.isNm80 ?? false
                  ? Actuator.connectedActuator.isNm80 = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.isNm80 = value;
        },
      ), // nm80_feature
      SwitchTile(
        visible: true,
        touchInputDisabled: true,
        title: Text(style: Style.normalText, StringConsts.actuators.nm100),
        initValue: Actuator.connectedActuator.isNm100 ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.isNm100 == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.isNm100 ?? false
                  ? Actuator.connectedActuator.isNm100 = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.isNm100 = value;
        },
      ), // nm100_feature
      SwitchTile(
        title: Text(
            style: Style.normalText, StringConsts.actuators.twoWireControl),
        touchInputDisabled: true,
        initValue: Actuator.connectedActuator.twoWireControl ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.twoWireControl == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.twoWireControl ?? false
                  ? Actuator.connectedActuator.twoWireControl = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.twoWireControl = value;
        },
      ), // twowire_feature
      SwitchTile(
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.failsafe,
        ),
        touchInputDisabled: true,
        initValue: Actuator.connectedActuator.failsafe ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.failsafe == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.failsafe ?? false
                  ? Actuator.connectedActuator.failsafe = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.failsafe = value;
        },
      ), // failsafe_feature
      SwitchTile(
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.modulating,
        ),
        touchInputDisabled: true,
        initValue: Actuator.connectedActuator.modulating ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.modulating == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.modulating ?? false
                  ? Actuator.connectedActuator.modulating = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.modulating = value;
        },
      ), // modulating_feature
      SwitchTile(
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.speedControl,
        ),
        touchInputDisabled: true,
        initValue: Actuator.connectedActuator.speedControl ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.speedControl == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.speedControl ?? false
                  ? Actuator.connectedActuator.speedControl = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.speedControl = value;
        },
      ), // speed_control_feature
      SwitchTile(
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.multiTurn,
        ),
        touchInputDisabled: true,
        initValue: Actuator.connectedActuator.multiTurn ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.multiTurn == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.multiTurn ?? false
                  ? Actuator.connectedActuator.multiTurn = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.multiTurn = value;
        },
      ), // multi_turn_feature
      SwitchTile(
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.offGridTimer,
        ),
        touchInputDisabled: true,
        initValue: Actuator.connectedActuator.offGridTimer ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.offGridTimer == null
              ? Actuator.connectedActuator.offGridTimer
              : Actuator.connectedActuator.offGridTimer ?? false
                  ? Actuator.connectedActuator.offGridTimer = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.offGridTimer = value;
        },
      ), // off_grid_feature
      SwitchTile(
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.wiggle,
        ),
        touchInputDisabled: true,
        initValue: Actuator.connectedActuator.wiggle ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.wiggle == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.wiggle ?? false
                  ? Actuator.connectedActuator.wiggle = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.wiggle = value;
        },
      ), // wiggle_feature
      SwitchTile(
        visible: true,
        touchInputDisabled: true,
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.controlSystem,
        ),
        initValue: Actuator.connectedActuator.controlSystem ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.controlSystem == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.controlSystem ?? false
                  ? Actuator.connectedActuator.controlSystem = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.controlSystem = value;
        },
      ), // control_systems_feature
      SwitchTile(
        visible: true,
        touchInputDisabled: true,
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.valveProfile,
        ),
        initValue: Actuator.connectedActuator.valveProfile ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.valveProfile == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.valveProfile ?? false
                  ? Actuator.connectedActuator.valveProfile = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.valveProfile = value;
        },
      ), // valve_profile_feature
      SwitchTile(
        visible: true,
        touchInputDisabled: true,
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.analogDeadband,
        ),
        initValue: Actuator.connectedActuator.analogDeadband ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.analogDeadband == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.analogDeadband ?? false
                  ? Actuator.connectedActuator.analogDeadband = value
                  : null;
        },
        setValue: (bool value) {
          Actuator.connectedActuator.analogDeadband = value;
        },
      ), // analog_deadband_feature
    ];

    return Scaffold(
        appBar: appBar(title: getTitle()),
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
