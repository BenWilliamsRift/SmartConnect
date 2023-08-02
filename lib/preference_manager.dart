import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';

class PreferenceManager {
  static const String passwords = "passwords";

  static const String settingsPrefix = "settings";
  static const String isDarkModeSuffix = "isDarkMode";
  static const String twelveHourTimeSuffix = "twelveHourTime";
  static const String saveLoginDetailsSuffix = "saveLoginDetails";
  static const String temperatureUnitsSuffix = "temperatureUnits";
  static const String torqueUnitsSuffix = "torqueUnits";
  static const String timeUnitsSuffix = "timeUnits";

  static const String loginPrefix = "login";
  static const String loginTimeSuffix = "time";
  static const String loginDetailsSuffix = "username";

  static const String actuatorPrefix = "actuator";
  static const String passwordsSuffix = "Passwords";

  static const String firstTimeSeen = "firstTimeSeen";

  static SharedPreferences? prefs;

  static void loadSettingsPrefs() async {
    prefs ??= await SharedPreferences.getInstance();
    bool? isDarkMode = prefs?.getBool(
            "${PreferenceManager.settingsPrefix}-${PreferenceManager.isDarkModeSuffix}") ??
        false;
    bool? twelveHourTime = prefs?.getBool(
            "${PreferenceManager.settingsPrefix}-${PreferenceManager.twelveHourTimeSuffix}") ??
        false;
    bool? saveLoginDetails = prefs?.getBool(
            "${PreferenceManager.settingsPrefix}-${PreferenceManager.saveLoginDetailsSuffix}") ??
        false;
    int? temperatureUnits = prefs?.getInt(
            "${PreferenceManager.settingsPrefix}-${PreferenceManager.temperatureUnitsSuffix}") ??
        0;
    int? torqueUnits = prefs?.getInt(
            "${PreferenceManager.settingsPrefix}-${PreferenceManager.torqueUnitsSuffix}") ??
        0;
    int? timeUnits = prefs?.getInt(
            "${PreferenceManager.settingsPrefix}-${PreferenceManager.timeUnitsSuffix}") ??
        0;

    Settings.isDarkMode = isDarkMode;
    Settings.twelveHourTime = twelveHourTime;
    Settings.saveLoginDetails = saveLoginDetails;
    Settings.selectedTemperatureUnits = temperatureUnits;
    Settings.selectedTorqueUnits = torqueUnits;
    Settings.selectedTimeUnits = timeUnits;
  }

  static void writeString(String key, String msg) {
    prefs?.setString(key, msg);
  }

  static String? getString(String key) {
    return prefs?.getString(key);
  }

  static void removeString(String key) {
    prefs?.remove(key);
  }

  static bool? getBool(String key) {
    return prefs?.getBool(key);
  }

  static void setBool(String key, bool value) {
    prefs?.setBool(key, value);
  }
}
