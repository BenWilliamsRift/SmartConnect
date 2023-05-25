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

  void setFeature(int index, bool value) {
    switch (index) {
      case 0:
        Actuator.connectedActuator.torqueLimit = value;
        break;
      case 1:
        Actuator.connectedActuator.isNm60 = value;
        break;
      case 2:
        Actuator.connectedActuator.isNm80 = value;
        break;
      case 3:
        Actuator.connectedActuator.isNm100 = value;
        break;
      case 4:
        Actuator.connectedActuator.twoWireControl = value;
        break;
      case 5:
        Actuator.connectedActuator.failsafe = value;
        break;
      case 6:
        Actuator.connectedActuator.modulating = value;
        break;
      case 7:
        Actuator.connectedActuator.speedControl = value;
        break;
      case 8:
        Actuator.connectedActuator.multiTurn = value;
        break;
      case 9:
        Actuator.connectedActuator.offGridTimer = value;
        break;
      case 10:
        Actuator.connectedActuator.wiggle = value;
        break;
      case 11:
        Actuator.connectedActuator.controlSystem = value;
        break;
      case 12:
        Actuator.connectedActuator.valveProfile = value;
        break;
      case 13:
        Actuator.connectedActuator.analogDeadband = value;
        break;
    }
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
    List<String> line = splitPasswords(passwords, boardNumber, 0, " ");

    if (line.length < ActuatorConstants.numberOfFeatures) return;

    try {
      for (int i = 0; i < ActuatorConstants.numberOfFeatures; i++) {
        // Set all Passwords
        Actuator.connectedActuator.settings
            .setFeaturePassword(i, line.elementAt(i + 1));

        // lock features if they are not enabled on the website
        // change features in the app if they are enabled
        // save if the feature was turned off and keep it turned off even if they have the feature
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
    // get features
    bluetoothMessageHandler.requestFeatures();

    List<String> passwords =
        Actuator.connectedActuator.settings.featuresPasswords;
    for (int i = 0; i < ActuatorConstants.numberOfFeatures - 1; i++) {
      String password = passwords.elementAt(i);
      // String password = Actuator.connectedActuator.settings.featuresPasswords[i];

      SwitchTile featureSwitch = switches.elementAt(i);
      bool didComplete = true;
      if (!featureSwitch.initValue) {
        switch (password.toLowerCase()) {
          case "none":
          // Hide feature
            setFeature(i, false);
            break;
          case "disable":
          // Show feature but disable switch
            setFeature(i, false);
            break;
          default:
            didComplete = false;
        }
      }
      if (!didComplete) {
        setFeature(i, true);
      }
      // if (password.toLowerCase() == "none" || password.toLowerCase() == "disable" && !featureSwitch.initValue) {
      // //     uses a callback set for each switch
      //     featureSwitch.setValue!(false);
      //   } else {
      //     featureSwitch.setValue!(true);
      //     // TODO Add different features
      //   }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Style.update();

    // Must be kept in this order
    // order is like this because the data that is received isn't structured so it is just assumed that all the right data is received and that the order of switches is the same
    // Hidden some features because it is never used
    switches = [
      SwitchTile(
        visible: true,
        touchInputDisabled: false,
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
        setValue: () {
          return Actuator.connectedActuator.torqueLimit;
        },
      ), // torque_limit_feature
      SwitchTile(
        visible: true,
        touchInputDisabled: false,
        title: Text(style: Style.normalText, StringConsts.actuators.nm60),
        initValue: Actuator.connectedActuator.isNm60 ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.isNm60 == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.isNm60 ?? false
                  ? Actuator.connectedActuator.isNm60 = value
                  : null;
        },
        setValue: () {
          return Actuator.connectedActuator.isNm60;
        },
      ), // nm60_feature
      SwitchTile(
        visible: true,
        touchInputDisabled: false,
        title: Text(style: Style.normalText, StringConsts.actuators.nm80),
        initValue: Actuator.connectedActuator.isNm80 ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.isNm80 == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.isNm80 ?? false
                  ? Actuator.connectedActuator.isNm80 = value
                  : null;
        },
        setValue: () {
          return Actuator.connectedActuator.isNm80;
        },
      ), // nm80_feature
      SwitchTile(
        visible: true,
        touchInputDisabled: false,
        title: Text(style: Style.normalText, StringConsts.actuators.nm100),
        initValue: Actuator.connectedActuator.isNm100 ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.isNm100 == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.isNm100 ?? false
                  ? Actuator.connectedActuator.isNm100 = value
                  : null;
        },
        setValue: () {
          return Actuator.connectedActuator.isNm100;
        },
      ), // nm100_feature
      SwitchTile(
        visible: false,
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
        setValue: () {
          return Actuator.connectedActuator.twoWireControl;
        },
      ), // twowire_feature
      SwitchTile(
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.failsafe,
        ),
        initValue: Actuator.connectedActuator.failsafe ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.failsafe == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.failsafe ?? false
                  ? Actuator.connectedActuator.failsafe = value
                  : null;
        },
        setValue: () {
          return Actuator.connectedActuator.failsafe;
        },
      ), // failsafe_feature
      SwitchTile(
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.modulating,
        ),
        touchInputDisabled: false,
        initValue: Actuator.connectedActuator.modulating ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.modulating == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.modulating ?? false
                  ? Actuator.connectedActuator.modulating = value
                  : null;
        },
        setValue: () {
          return Actuator.connectedActuator.modulating;
        },
      ), // modulating_feature
      SwitchTile(
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.speedControl,
        ),
        touchInputDisabled: false,
        initValue: Actuator.connectedActuator.speedControl ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.speedControl == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.speedControl ?? false
                  ? Actuator.connectedActuator.speedControl = value
                  : null;
        },
        setValue: () {
          return Actuator.connectedActuator.speedControl;
        },
      ), // speed_control_feature
      SwitchTile(
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.multiTurn,
        ),
        touchInputDisabled: false,
        initValue: Actuator.connectedActuator.multiTurn ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.multiTurn == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.multiTurn ?? false
                  ? Actuator.connectedActuator.multiTurn = value
                  : null;
        },
        setValue: () {
          return Actuator.connectedActuator.multiTurn;
        },
      ), // multi_turn_feature
      SwitchTile(
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.offGridTimer,
        ),
        touchInputDisabled: false,
        initValue: Actuator.connectedActuator.offGridTimer ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.offGridTimer == null
              ? Actuator.connectedActuator.offGridTimer
              : Actuator.connectedActuator.offGridTimer ?? false
                  ? Actuator.connectedActuator.offGridTimer = value
                  : null;
        },
        setValue: () {
          return Actuator.connectedActuator.offGridTimer;
        },
      ), // off_grid_feature
      SwitchTile(
        title: Text(
          style: Style.normalText,
          StringConsts.actuators.wiggle,
        ),
        touchInputDisabled: false,
        initValue: Actuator.connectedActuator.wiggle ?? false,
        callback: (bool value) {
          Actuator.connectedActuator.wiggle == null
              ? StringConsts.bluetooth.notConnected
              : Actuator.connectedActuator.wiggle ?? false
                  ? Actuator.connectedActuator.wiggle = value
                  : null;
        },
        setValue: () {
          return Actuator.connectedActuator.wiggle;
        },
      ), // wiggle_feature
      SwitchTile(
        visible: false,
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
        setValue: () {
          return Actuator.connectedActuator.controlSystem;
        },
      ), // control_systems_feature
      SwitchTile(
        visible: false,
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
        setValue: () {
          return Actuator.connectedActuator.valveProfile;
        },
      ), // valve_profile_feature
      SwitchTile(
        visible: false,
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
        setValue: () {
          return Actuator.connectedActuator.analogDeadband;
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
