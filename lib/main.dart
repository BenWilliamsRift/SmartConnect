import 'package:actuatorapp2/nav_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'String_consts.dart';
import 'actuator/actuator.dart';
import 'bluetooth/bluetooth_manager.dart';
import 'color_manager.dart';
import 'login_controller.dart';
import 'preference_manager.dart';
import 'settings.dart';
import 'theme_manager.dart';

void showSnackBar(BuildContext context, String text, int? duration, SnackBarAction? action) {
  SnackBar snackBar = SnackBar(
    content: Text(text, style: TextStyle(color: ColorManager.snackBar)),
    duration: Duration(seconds: duration ?? 3),
    action: action,
  );

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void routeToPage(BuildContext context, Widget page, {bool removeStack = false}) {
  NavDrawController.selectedPage = StringConsts.none;

  if (removeStack) {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (context) => page));
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
    PreferenceManager.loadSettingsPrefs();

    // Only allow the app to be in portrait up position
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

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
