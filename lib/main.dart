import 'package:actuatorapp2/actuator%20pages/list_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'actuator/actuator.dart';
import 'bluetooth/bluetooth_manager.dart';
import 'color_manager.dart';
import 'login_controller.dart';
import 'preference_manager.dart';
import 'settings.dart';
import 'theme_manager.dart';

void showSnackBar(
    BuildContext context, String text, int? duration, SnackBarAction? action) {
  SnackBar snackBar = SnackBar(
    content: Container(
      decoration: BoxDecoration(
          color: ColorManager.snackBarBackground,
          border: Border.all(width: 2.0, color: ColorManager.snackBarBorder),
          borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(color: ColorManager.snackBar))),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 3),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 3),
    dismissDirection: DismissDirection.none,
  );

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void routeToPage(BuildContext context, Widget page,
    {bool removeStack = false}) {
  if (removeStack) {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute<void>(builder: (context) => page));
  } else {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (context) => page));
  }
}

void showAlert(
    {required BuildContext context,
    required Widget content,
    Text? title,
    required List<Widget> actions}) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: title,
          content: content,
          actions: actions,
        );
      });
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void dispose() {
    super.dispose();

    BluetoothManager().disconnect();
  }

  @override
  Widget build(BuildContext context) {
    Style.update();

    PreferenceManager.loadSettingsPrefs();

    // Only allow the app to be in portrait up position
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return NotificationListener<ConnectedNotification>(
      onNotification: (notification) {
        setState(() {
          Actuator.connectedDeviceAddress = Actuator.connectingDeviceAddress;
          Actuator.connectingDeviceAddress = null;
        });
        return true;
      },
      child: NotificationListener<ThemeNotification>(
        // Change the theme
        onNotification: (notification) {
          setState(() {});
          return true;
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          themeMode: Settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const LoginPage(),
        ),
      ),
    );
  }
}
