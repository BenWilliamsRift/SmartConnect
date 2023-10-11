import 'dart:math';

import 'package:actuatorapp2/person_data.dart';
import 'package:actuatorapp2/web_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'actuator pages/list_tiles.dart';
import 'nav_drawer.dart';
import 'preference_manager.dart';
import 'string_consts.dart';

// TODO Could try just having a list of settings and then using the data type
// that they are construct a widget with a builder, so new settings could be created easily

class Settings {
  static bool devSettingsEnabled = false;
  static bool emulateConnectedActuator = false;

  static bool pidAccessUnlocked = true;
  static bool testingAccessUnlocked = true;

  static const int newtonMeter = 0;
  static const int footPound = 1;
  static const int inchPound = 2;
  static const List<String> torqueUnits = [
    "Newton Meters (nM)",
    "Foot Pound (ft-lb)",
    "Inch Pound (in-lb)"
  ];

  static const int celsius = 0;
  static const int fahrenheit = 1;
  static const List<String> temperatureUnits = [
    "Celsius (\u2103)",
    "Fahrenheit (\u2109)"
  ];

  static int selectedAngleMarker = 0;
  static const List<String> angleMarkers = [
    "0",
    "30",
    "45",
    "60",
    "90",
    "120",
    "180"
  ];

  static int get angleMarker =>
      int.parse(angleMarkers.elementAt(selectedAngleMarker));

  static const int hoursMinutesSeconds = 0;
  static const int monthsWeekDays = 1;
  static const int seconds = 2;
  static const int minutes = 3;
  static const int hours = 4;
  static const int days = 5;
  static const int weeks = 6;
  static const int months = 7;
  static const int monthsWeekDaysHoursMinutesSeconds = 8;

  static List<String> timeUnits = [
    "Hours : Minutes : Seconds",
    "Months (28 days) : Weeks : Days",
    "Seconds",
    "Minutes",
    "Hours",
    "Days",
    "Weeks",
    "Months (28 days)",
    "M(28 days) : W : D : H : M : S"
  ];

  static bool isDarkMode = false;

  static bool twelveHourTime = false;

  static bool saveLoginDetails = true;

  static int scrollSensitivity = 25;

  static int selectedTemperatureUnits = celsius;
  static int selectedTorqueUnits = newtonMeter;
  static int selectedTimeUnits = hoursMinutesSeconds;

  // TODO: implement time picker scrolling view instead of content
  static bool scrollContent = false;

  static bool showAngleShadow = false;

  static int passwordMinLength = 6;

  static int convertTemperatureUnits(
      {required double temp, int source = celsius}) {
    assert(source == celsius || source == fahrenheit);

    if (source == celsius) {
      if (selectedTemperatureUnits == fahrenheit) {
        return ((temp * 9 / 5) + 32).round();
      }

      return temp.round();
    } else if (source == fahrenheit) {
      if (selectedTorqueUnits == celsius) {
        return ((temp - 32) * 5 / 9).round();
      }

      return temp.round();
    }

    // Should never get called
    return temp.round();
  }

  static String getTemperatureUnits() {
    if (selectedTemperatureUnits == fahrenheit) {
      // fahrenheit unit
      return "\u2109";
    }

    // celsius unit
    return "\u2103";
  }

  // by default converts a number from newton meters into either foot pounds or inch pounds
  // but by changing the source the input can convert to any of the three from any of the three
  // Source is the original format, wanted is the the wanted format
  static double convertTorqueUnits(
      {required double torque, int source = newtonMeter, int wanted = -1}) {
    double roundDouble(double value, int places) {
      num mod = pow(10.0, places);
      return ((value * mod).round().toDouble() / mod);
    }

    assert(source == newtonMeter || source == footPound || source == inchPound);

    if (wanted == -1) {
      wanted == selectedTorqueUnits;
    }

    if (source == newtonMeter) {
      if (wanted == footPound) {
        // foot pound
        return roundDouble(torque / 1.356, 2);
      } else if (wanted == inchPound) {
        // inch pound
        return roundDouble(torque * 8.851, 2);
      }

      // newton meters
      return roundDouble(torque, 2);
    } else if (source == inchPound) {
      if (wanted == footPound) {
        // foot pound
        return roundDouble(torque / 12, 2);
      } else if (wanted == newtonMeter) {
        // newton meters
        return roundDouble(torque * 0.112984825, 2);
      }

      // inch pounds
      return roundDouble(torque, 2);
    } else if (source == footPound) {
      if (wanted == inchPound) {
        // inch pound
        return roundDouble(torque * 12, 2);
      } else if (wanted == newtonMeter) {
        // newton meters
        return roundDouble(torque * 1.3558179483, 2);
      }

      return roundDouble(torque, 2);
    }

    // should never get returned here
    return roundDouble(torque, 2);
  }

  static String getTorqueUnits() {
    if (selectedTorqueUnits == footPound) {
      // Foot Pound
      return "ft-lb";
    } else if (selectedTorqueUnits == inchPound) {
      // Inch Pound
      return "in-lb";
    }

    // newton meters
    return "Nm";
  }

  static final _devEmails = ["ben@rifttechnology.com"];

  static bool isDevEmail() {
    return _devEmails.contains(PersonData.currentEmail);
  }

  static void checkIsDev() {
    devSettingsEnabled = isDevEmail();
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key, this.login = false, this.firstTime = false})
      : super(key: key);

  final bool login;
  final bool firstTime;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void writeSettingsToPrefs(String key, dynamic value) {
    if (value.runtimeType == bool) {
      prefs.setBool(key, value);
    } else if (value.runtimeType == int) {
      prefs.setInt(key, value);
    }
  }

  Widget get getDevWidgets => Column(mainAxisSize: MainAxisSize.min, children: [
        ElevatedButton(
            onPressed: () {
              setState(() {
                Settings.devSettingsEnabled = false;
              });
            },
            child: Text(StringConsts.settings.disableAccess)),
        SwitchTile(
            title: const Text("Emulate Connection to Actuator"),
            subtitle: const Text("Unlocks all features of the app"),
            initValue: Settings.emulateConnectedActuator,
            callback: (bool value) {
              setState(
                () {
                  Settings.emulateConnectedActuator = value;
                },
              );
            }),
      ]);

  Widget get getAdvancedWidgets => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextInputTile(
            onSaved: (String? newValue) {
              setState(() {
                checkAccessCode(newValue ?? "");
              });
            },
            keyboardType: TextInputType.text,
            initialValue: "",
            title: Text(StringConsts.settings.accessCodes),
          ),
          Settings.pidAccessUnlocked
              ? Card(
                  child: ListTile(
                  title: Text(
                    StringConsts.settings.pidAccessUnlocked,
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // show confirmation to disable access
                      });
                    },
                    child: Text(StringConsts.settings.disableAccess),
                  ),
                ))
              : Container(),
          Settings.testingAccessUnlocked
              ? Card(
                  child: ListTile(
                  title: Text(
                    StringConsts.settings.testingUnlocked,
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // show confirmation to disable access
                      });
                    },
                    child: Text(StringConsts.settings.disableAccess),
                  ),
                ))
              : Container(),
        ],
      );

  bool advancedSettingsOpen = false;
  bool devSettingsOpen = false;

  void checkAccessCode(String key) {
    //TODO
    switch (key.toLowerCase()) {
      // custom codes
      case "dev settings":
        Settings.devSettingsEnabled = !Settings.devSettingsEnabled;
        break;

      default:
        WebController().checkAccessCodeRequest(key).then((value) {
          if (kDebugMode) {
            print("Value: $value");
          }

          switch (value) {
            case "pid":
              // set pid unlocked
              break;
            case "testing":
              // set testing unlocked
              break;
            default:
            // invalid code
          }

          return value;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget sizedBox = const SizedBox(height: 8);

    ThemeNotification themeNotifier = ThemeNotification();
    return Scaffold(
      appBar: AppBar(
        title: Text(StringConsts.settings.title),
      ),
      drawer: (widget.login || widget.firstTime) ? null : const NavDrawer(),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Center(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Text(
                      "${StringConsts.settings.appVersion} ${StringConsts.appVersion}")),
            ),
          ),
          ListView(
            children: [
              sizedBox,
              SwitchTile(
                title: Text(StringConsts.settings.isDarkMode),
                initValue: Settings.isDarkMode,
                callback: (bool value) {
                  setState(() {
                    Settings.isDarkMode = value;
                    writeSettingsToPrefs(
                        "${PreferenceManager.settingsPrefix}-${PreferenceManager.isDarkModeSuffix}",
                        Settings.isDarkMode);
                  });
                  themeNotifier.updateTheme(context);
                },
              ),
              SwitchTile(
                title: Text(StringConsts.settings.showAngleShadow),
                initValue: Settings.showAngleShadow,
                callback: (bool value) {
                  setState(() {
                    Settings.showAngleShadow = value;
                    writeSettingsToPrefs(
                        "${PreferenceManager.settingsPrefix}-${PreferenceManager.showAngleShadowSuffix}",
                        Settings.showAngleShadow);
                  });
                  themeNotifier.updateTheme(context);
                },
              ),
              DropDownTile(
                  items: Settings.angleMarkers,
                  value: Settings.angleMarkers
                      .elementAt(Settings.selectedAngleMarker),
                  onChanged: (String? marker) {
                    setState(() {
                      Settings.selectedAngleMarker =
                          Settings.angleMarkers.indexOf(marker!);
                      writeSettingsToPrefs(
                          "${PreferenceManager.settingsPrefix}-${PreferenceManager.angleMarkersSuffix}",
                          Settings.selectedAngleMarker);
                    });

                    return Settings.selectedAngleMarker.toString();
                  },
                  title: Text(StringConsts.settings.angleMarkers)),
              DropDownTile(
                  items: Settings.temperatureUnits,
                  value: Settings.temperatureUnits
                      .elementAt(Settings.selectedTemperatureUnits),
                  onChanged: (String? unit) {
                    setState(() {
                      Settings.selectedTemperatureUnits =
                          Settings.temperatureUnits.indexOf(unit!);
                      writeSettingsToPrefs(
                          "${PreferenceManager.settingsPrefix}-${PreferenceManager.temperatureUnitsSuffix}",
                          Settings.selectedTemperatureUnits);
                    });

                    return Settings.selectedTemperatureUnits.toString();
                  },
                  title: Text(StringConsts.settings.temperature)),
              DropDownTile(
                  items: Settings.torqueUnits,
                  value: Settings.torqueUnits
                      .elementAt(Settings.selectedTorqueUnits),
                  onChanged: (String? unit) {
                    setState(() {
                      Settings.selectedTorqueUnits =
                          Settings.torqueUnits.indexOf(unit!);
                      writeSettingsToPrefs(
                          "${PreferenceManager.settingsPrefix}-${PreferenceManager.torqueUnitsSuffix}",
                          Settings.selectedTorqueUnits);
                    });

                    return Settings.selectedTorqueUnits.toString();
                  },
                  title: Text(StringConsts.settings.torqueUnits)),
              DropDownTile(
                  items: Settings.timeUnits,
                  value:
                  Settings.timeUnits.elementAt(Settings.selectedTimeUnits),
                  onChanged: (String? unit) {
                    setState(() {
                      Settings.selectedTimeUnits =
                          Settings.timeUnits.indexOf(unit!);
                      writeSettingsToPrefs(
                          "${PreferenceManager.settingsPrefix}-${PreferenceManager.timeUnitsSuffix}",
                          Settings.selectedTimeUnits);
                    });

                    return Settings.selectedTimeUnits.toString();
                  },
                  title: Text(StringConsts.settings.timeUnits)),
              SwitchTile(
                title: Text(StringConsts.settings.saveLoginDetails),
                subtitle: Text(StringConsts.settings.saveLoginDetailsSub,
                    style: Style.subtitle),
                visible: !widget.login,
                initValue: Settings.saveLoginDetails,
                callback: ((bool value) {
                  setState(() {
                    Settings.saveLoginDetails = value;
                    writeSettingsToPrefs(
                        "${PreferenceManager.settingsPrefix}-${PreferenceManager.saveLoginDetailsSuffix}",
                        Settings.saveLoginDetails);
                  });
                }),
              ),
              // Advanced settings
              sizedBox,
              GestureDetector(
                  onTap: () {
                    // open advanced settings
                    setState(() {
                      advancedSettingsOpen = !advancedSettingsOpen;
                    });
                  },
                  child: Row(children: [
                    const Expanded(child: Divider(indent: 1, endIndent: 1)),
                    Center(child: Text(StringConsts.settings.advancedSettings)),
                    Center(
                        child: Icon(advancedSettingsOpen
                            ? Icons.arrow_drop_up_sharp
                            : Icons.arrow_drop_down_sharp)),
                    const Expanded(child: Divider(indent: 1, endIndent: 1)),
                  ])),
              advancedSettingsOpen ? getAdvancedWidgets : Container(),
              // Dev Settings
              sizedBox,
              Settings.devSettingsEnabled
                  ? GestureDetector(
                      onTap: () {
                        // open advanced settings
                        setState(() {
                          devSettingsOpen = !devSettingsOpen;
                        });
                      },
                      child: Row(children: [
                        const Expanded(child: Divider(indent: 1, endIndent: 1)),
                        Center(child: Text(StringConsts.settings.devSettings)),
                        Center(
                            child: Icon(devSettingsOpen
                                ? Icons.arrow_drop_up_sharp
                                : Icons.arrow_drop_down_sharp)),
                        const Expanded(child: Divider(indent: 1, endIndent: 1)),
                      ]))
                  : Container(),
              Settings.devSettingsEnabled && devSettingsOpen
                  ? getDevWidgets
                  : Container(),
              sizedBox,
              sizedBox,
              sizedBox,
            ],
          ),
        ],
      ),
    );
  }
}

class ThemeNotification extends Notification {
  updateTheme(BuildContext context) {
    dispatch(context);
  }
}
