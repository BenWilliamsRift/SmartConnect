import 'actuator/actuator.dart';
import 'settings.dart';

class StringConsts {
  static const String appTitle = "Smart Connect";
  static String appVersionTitle = "App Version ";
  static String appVersion = "0.1";

  static const String control = "Control";
  static const String basicSettings = "Basic Settings";
  static const String calibration = "Calibration";
  static const String features = "Features";
  static const String updateFirmware = "Update firmware";
  static const String failsafe = "Failsafe";
  static const String modulating = "Modulating";
  static const String speedControl = "Speed Control";
  static const String wiggle = "Wiggle";
  static const String logOut = "Log out";
  static const String connectToActuator = "Connect to an Actuator";
  static const String appSettings = "App Settings";
  static const String contactUs = "Report a Bug";
  static const String faq = "FAQ";
  static const String torqueLimit = "Torque Limit";
  static const String none = "None";

  static LoginText login = LoginText();
  static ActuatorsStrings actuators = ActuatorsStrings();
  static SettingsStrings settings = SettingsStrings();
  static NetworkText network = NetworkText();
  static ContactUsStrings contact = ContactUsStrings();
  static Bluetooth bluetooth = Bluetooth();
  static Help help = Help();
  static Statistics statistics = Statistics();
  static FirstTime firstTime = FirstTime();

  static const String search = "Search";

  static const String hoursMinutesSeconds = "( Hours : Minutes : Seconds )";

  static const String timePickerTitle = "Choose A Time";

  static const String confirm = "Confirm";
  static const String cancel = "Cancel";

  static const String months = "Months";
  static const String weeks = "Weeks";
  static const String days = "Days";
  static const String hours = "Hours";
  static const String minutes = "Minutes";
  static const String seconds = "Seconds";

  static const String loading = "Loading...";

  static const String pullDownToRefresh = "Pull down to refresh";
  static const String refresh = "Refresh";
}

class Statistics {
  final String title = "Statistics";
}

class Help {
  final String bulletPoint = "\u2022";
  final String actuatorScan = "Click for help finding actuators";
  final String pullDown = "Pull down to refresh";

  final String title = "Help";
  final String isItPowered =
      "Are the LEDs turned on at the top of the actuator?";
  final String setAppPermissions =
      "Does the app have the correct permissions enabled?";
  final String isBluetoothEnabled = "Is Bluetooth enabled?";
  final String openSettings = "Open permission settings";
  final String enableBluetooth = "Enable Bluetooth";
  final String deviceWontConnect = "Device won't connect?";

  String get isActuatorPluggedIn => "$bulletPoint Is the actuator plugged in?";

  String get isTheBatteryCharged => "$bulletPoint Is the battery charged?";

  String get reLogin => "$bulletPoint Log out then login again";

  String get closeTheAppAndOpenIt =>
      "$bulletPoint Close the app and then re-open the app.";
  final String somethingElse = "Something not listed?";
  final String contactUs = "Contact us here.";
  final String exampleActuatorName = "Example Actuator";
  final String exampleActuatorAddress = "Example Address";
}

class Bluetooth {
  final String editAlias = "Edit alias";
  final String readyToConnect = "Ready To Connect";
  final String connecting = "Connecting...";
  final String connected = "Connected";
  final String connectedSuccessfully = "Connected successfully";
  final String connectingTo = "Connecting to ";
  final String scanFinished = "Bluetooth scan finished";
  final String attemptingConnection = "Attempting to connect to ";
  final String failedConnection = "Failed to connect to ";
  final String fixConnections = "How to fix connections";
  final String timedOut = "Timed Out";
  final String retryConnection = "Failed. Retry";
  final String unconnected = "Unconnected";
  final String disconnected = "Disconnected";
  final String notConnected = "Not connected";
  final String successfullyTurnedOn = "Bluetooth was successfully turned on";
  final String unsuccessfullyTurnedOn =
      "Bluetooth could not be turned on automatically, please turn it on manually";

  String disconnect() =>
      "Disconnect from ${Actuator.connectedActuator.boardNumber ?? 'device'}";
}

class NetworkText {
  final String failedToUpdateFeaturePassword =
      "Failed to update feature passwords";
  final String finishedSyncingData = "Finished syncing data";
  final String failedToGetFeaturePassword = "Unable to get passwords";
  final String failedToGetLoginData = "Unable to get login data";
}

class LoginText {
  final String title = "Login";
  final String complete = "Login complete";
  final String nameField = "Name*";
  final String showPassword = "Show password";
  final String hidePassword = "Hide password";
  final String formErrors = "Please fix the errors in red before submitting.";
  final String enterPassword = "Please enter a password";
  final String passwordsDoNotMatch = "Passwords do not match";
  final String noMoreThan = "Password can not be more than 8 characters";
  final String retypePassword = "Retype password";
  final String password = "Password";
  final String passwordRequired = "A password is required";
  final String yourEmailAddress = "Your email address";
  final String email = "Email";
  final String emailRequired = "Email is required";
  final String emailNotCorrect = "Email is not correct";
  final String fieldSubmit = "Log In";
  final String requiredField = "* indicates required field";
  final String usernameOrPasswordWrong = "Username or password wrong";
  final String usernameOrPasswordWrongOrNetworkError =
      "Unable to log you in due to an unknown error. Please try again";
  final String registerAccount = "Create a new account";
  final String passwordNotLongEnough =
      "Password needs to be at least ${Settings.passwordMinLength} characters";
  final String passwordNotComplexEnough =
      "Password needs to contain at least one special character";
  final String failedToOpenRegisterPage = "Failed to open register page";
  final String copyRegisterUrl = "Copy link";
  final String confirmLogout = "Are you sure you want to log out";
}

class ActuatorsStrings {
  final Values values = Values();

  final String title = "Actuator: ";

  final String errorValidatingActuators =
      "Error validating actuator, try logging ing again";

  final String noConnectedActuator = "No Connected Actuator";

  String moveClosedAngle(String value) {
    return "Do you want to move the closed angle, to maintain a working angle of: $value?";
  }

  // TODO only use this while the old bootloader system is in place
  // remove once the update process is streamlined
  final String bootloaderDoYouKnowWhatYourDoing =
      "Are you sure you want to do this?";

  String moveOpenAngle(String value) {
    return "Do you want to move the open angle, to maintain a working angle of: $value?";
  }

  final String features = "Features";
  final String status = "Status";
  final String angle = "Angle";
  final String temperature = "Temperature";
  final String batteryVoltage = "Battery Voltage";
  final String receivedModulationInput = "Received Modulation Input";

  final String open = "Open";
  final String close = "Close";
  final String autoOrManual = "Auto/Manual";

  final String startingAutoManual = "Starting Auto Manual";
  final String stoppingAutoManual = "Stopping Auto Manual";
  final String failedToChangeAutoManual = "Failed To Change Auto Manual";

  final String softResetBoard = "Soft Reset Board";
  final String stop = "STOP";
  final String revertToDefaultValues = "Revert To Default Values";

  final String writeToFlash = "Save Settings";
  final String settingsSaved = "Settings Saved";
  final String confirmWriteToFlash =
      "Are you sure you want to save these settings";
  final String firmwareVersion = "Firmware Version";
  final String valveOrientation = "Valve Orientation";
  final String backlash = "Backlash";
  final String buttonsEnabled = "Buttons Enabled";
  final String numberOfFullCycles = "Number Of Full Cycles";
  final String numberOfStarts = "Number Of Starts";
  final String sleepWhenNotPowered = "Sleep When Not Powered";
  final String magnetTestMode = "Magnet Test Mode";
  final String factoryBuildTest = "( factory build test )";
  final String startInManualMode = "Start In Manual Mode";
  final String indicationMode = "Indication Mode";
  final String reverseActing = "Reverse Acting";
  final String pidP = "PID P Value";
  final String pidI = "PID I Value";

  String confirmLock(bool locked) =>
      "Type '${locked ? 'UNLOCK' : 'LOCK'}' to confirm";

  final String lock = "Lock";
  final String unlock = "Unlock";
  final String failedToUpdateFeatures = "Failed to update features";
  final String featureUpdated = "Features updated successfully";

  final String setCloseHere = "Set Close Here";
  final String setOpenHere = "Set Open Here";
  final String rawAngle = "Raw Angle";
  final String calibrationOpenAngle = "Open Angle";
  final String calibrationCloseAngle = "Close Angle";
  final String inDegrees = "( In degrees )";
  final String workingAngle = "Working Angle";
  final String torqueBand = "TorqueBand";
  final String torqueLimitBackOff = "Torque Limit Back Off";
  final String retryAfterTorqueLimit = "Retry after torque limit";
  final String torqueLimitDelayBeforeRetry = "Torque limit delay before retry";

  final String syncFromInternet = "Sync All From Internet";
  final String inCelsius = "( In Celsius )";

  final String torqueLimit = "Torque Limit";
  final String nm60 = "Nm60";
  final String nm80 = "Nm80";
  final String nm100 = "Nm100";
  final String twoWireControl = "Two Wire Control";
  final String failsafe = "Failsafe";
  final String modulating = "Modulating";
  final String speedControl = "Speed Control";
  final String multiTurn = "Multi Turn";
  final String offGridTimer = "Off Grid Timer";
  final String wiggle = "Wiggle";
  final String controlSystem = "Control System";
  final String valveProfile = "Valve Profile";
  final String analogDeadband = "Analog Deadband";

  final String enterBootloader = "Enter Bootloader";
  final String exitBootloader = "Exit Bootloader";
  final String uploadFirmware = "Upload Firmware";

  final String notInBootLoader =
      "You are not in the bootloader, enter the bootloader in order to upload your firmware";
  final List<String> inBootLoader = [
    "You are in the bootloader, you can either go back to your current actuator firmware ",
    " or update the firmware."
  ];

  final String failsafeMode = "Failsafe Mode";
  final String failsafeDelay = "Failsafe Delay";
  final String failsafeAngle = "Failsafe Angle";

  final String lossOfSignalMode = "Loss Of Signal Mode";
  final String lossOfSignalAngle = "Loss Of Signal Angle";
  final String analogSignalMode = "Analog Signal Mode";
  final String deadbandForwards = "Deadband Forwards";
  final String deadbandBackwards = "Deadband Backwards";
  final String invertSignal = "Invert Signal";

  final String unconnected = "Unconnected";
  final String connected = "Connected";
  final String connectionStatus = "Connection Status";

  final String workingTimeInSeconds = "Working Time In Seconds";

  final String timeBetweenWiggles = "Time Between Wiggles";

  final String wiggleAngle = "Wiggle Angle";

  final String actuator = "Actuator: ";
  final String connecting = "Connecting to ";
  final String disconnecting = "Disconnecting from ";

  final String failedToConnect = "Failed to connect to ";
  final String successfulConnection = "Successfully to connect to ";

  final String actuatorSettings = "Actuator Settings";
  final String control = "Control";

  final String type = "Type";
  late final List<String> actuatorTypes;

  late final String small = "Small";
  late final String medium = "Medium";
  late final String large = "Large";
  late final String subSea = "Sub-sea";

  ActuatorsStrings() {
    actuatorTypes = [small, medium, large, subSea];
  }
}

class Values {
  final String boardNumber = "Board Number";
  final String angle = "Angle";
  final String locked = "Locked";
  final String lEDS = "LEDS";
  final String temperature = "Temperature";
  final String autoManual = "Auto / Manual";
  final String bootloaderStatus = "Bootloader Status";
  final String firmwareVersion = "Firmware Version";
  final String workingTime = "Working Time";
  final String workingAngle = "Working Angle";
  final String maximumDuty = "Maximum Duty";
  final String analogDeadbandBackwards = "Analog Deadband Backwards";
  final String analogDeadbandForwards = "Analog Deadband Forwards";
  final String analogSignalMode = "Analog Signal Mode";
  final String backlash = "Backlash";
  final String batteryVoltage = "Battery Voltage";
  final String buttonsEnabled = "Buttons Enabled";
  final String closedAngleAddition = "Closed Angle Addition";
  final String controlSystemEnabled = "Control System Enabled";
  final String controlSystemPIDI = "Control System PIDI";
  final String controlSystemPIDP = "Control System PIDP";
  final String controlSystemReverse = "Control System Reverse";
  final String controlSystemTargetFraction = "Control System Target Fraction";
  final String failsafeAngle = "Failsafe Angle";
  final String failsafeDelay = "Failsafe Delay";
  final String failsafeMode = "Failsafe Mode";
  final String featurePasswordDigits = "Feature Password Digits";
  final String openAngle = "Open Angle";
  final String closedAngle = "Closed Angle";
}

class SettingsStrings {
  final String title = "Settings";

  final String advancedSettings = "Advanced Settings";
  final String accessCodes = "Access Codes";

  final String specialBorders = "Special borders";
  final String visualDensity = "Visual density";
  final String isDarkMode = "Dark mode";
  final String twelveHourTime = "12 Hour time";
  final String saveLoginDetails = "Save login details";
  final String saveLoginDetailsSub =
      "Lets you close the app and stay logged in";
  final String temperature = "Temperature";
  final String torqueUnits = "Torque Units";
  final String timeUnits = "Time units";

  final String appVersion = "App Version";
}

class ContactUsStrings {
  final String generalEnquiry = "General Enquiry";
  final String bugReport = "Report a bug";
  final String salesEnquiry = "Sales Enquiry";

  final String useSameEmailAsLogin = "Use same email as login email?";

  late final List<String> types;

  final String generalEnquirySummaryHint = "Write a summary of the enquiry.";
  final String generalEnquirySummaryLabel = "Summary";
  final String generalEnquirySummaryHelp =
      "Write a short description of what the enquiry is about.";

  final String generalEnquiryHint = "Write the full enquiry here.";
  final String generalEnquiryLabel = "Enquiry";
  final String generalEnquiryHelp = "Write as much detail about your enquiry.";

  final String bugApp = "App";
  final String bugAppHint = "Describe the bug you found in the app.";
  final String bugAppLabel = "Report";
  final String bugAppHelp =
      "Write as much detail about what you were doing with the app when you discovered the bug.";

  final String bugAppSummaryHint = "Write a summary of the bug.";
  final String bugAppSummaryLabel = "Summary";
  final String bugAppSummaryHelp =
      "Write a short description of what the bug is about.";

  final String bugActuator = "Actuator";
  final String bugActuatorHint = "Describe the bug you found with the actuator";
  final String bugActuatorLabel = "Report";
  final String bugActuatorHelp =
      "Write as much detail about what you were doing with the actuator when you discovered the bug.";

  final String bugActuatorSummaryHint = "Write a summary of the bug.";
  final String bugActuatorSummaryLabel = "Summary";
  final String bugActuatorSummaryHelp =
      "Write a short description of what the bug is about.";

  final String bugRiftDevWebsite = "Rift Dev Website";
  final String bugRiftDevWebsiteHint =
      "Describe the bug you found with in the website";
  final String bugRiftDevWebsiteLabel = "Report";
  final String bugRiftDevWebsiteHelp =
      "Write as much detail about what you were doing in the website when you discovered the bug.";

  final String bugRiftDevWebsiteSummaryHint = "Write a summary of the bug.";
  final String bugRiftDevWebsiteSummaryLabel = "Summary";
  final String bugRiftDevWebsiteSummaryHelp =
      "Write a short description of what the bug is about.";

  final String salesSummaryHint = "Write a summary of your sales enquiry here.";
  final String salesSummaryLabel = "Summary";
  final String salesSummaryHelp =
      "Write a short description of what your sales enquiry is about.";

  final String salesHint = "Write the full sales enquiry here.";
  final String salesLabel = "Enquiry";
  final String salesHelp = "Write as much detail about your sales enquiry.";

  late final List<String> bugTypes;

  final String send = "Send";
  final String faq = "FAQ";

  ContactUsStrings() {
    types = [
      generalEnquiry,
      bugReport,
      salesEnquiry,
    ];

    bugTypes = [bugApp, bugActuator, bugRiftDevWebsite];
  }
}

class FirstTime {
  final String title = "First Time";
  final String checkOutSettings = "Check out the settings page";
  final String takeATour = "Do you want to take a tour?";
  final String takeTheTour = "Take the Tour";
  final String noThanks = "No, thanks";
  final String pullDown = "Pull down to refresh the list";
  final String clickToConnect = "Click this to connect to a device";
  final String clickForMoreHelp =
      "Click this if you need help with something else";
  final String clickToNavigate = "Click this to navigate to different pages";
}
