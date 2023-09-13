import 'package:flutter/material.dart';

import 'actuator/actuator.dart';
import 'actuator pages/basic_settings.dart';
import 'actuator pages/calibration.dart';
import 'actuator pages/connect.dart';
import 'actuator pages/control.dart';
import 'actuator pages/failsafe.dart';
import 'actuator pages/features.dart';
import 'actuator pages/modulating.dart';
import 'actuator pages/speed_control.dart';
import 'actuator pages/torque_limit.dart';
import 'actuator pages/update_firmware.dart';
import 'actuator pages/wiggle.dart';
import 'asset_manager.dart';
import 'bluetooth/bluetooth_manager.dart';
import 'color_manager.dart';
import 'contact_us.dart';
import 'login_controller.dart';
import 'main.dart';
import 'person_data.dart';
import 'rift_icons.dart';
import 'settings.dart';
import 'statistics.dart';
import 'string_consts.dart';

class NavDrawController {
  static String selectedPage = StringConsts.none;

  static bool isSelectedPage(var page) {
    if (page.runtimeType == List<String>) {
      return page.contains(selectedPage);
    }

    return page.name == selectedPage;
  }
}

class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    Card drawerHeader = Card(
        margin: EdgeInsets.zero,
        shape: Border(bottom: BorderSide(color: ColorManager.companyYellow)),
        color: ColorManager.navDrawHead,
        child: ListTile(
          leading: AssetManager.logo,
          title: Text(
              PersonData.currentEmail ?? "You shouldn't be seeing this.",
              style: TextStyle(color: ColorManager.navDrawHeadText)),
        ));

    TextStyle titleStyle = TextStyle(
      color: ColorManager.navDrawText,
      fontSize: 18,
    );

    Divider div = Divider(thickness: 3, color: ColorManager.navDrawDiv);

    final bool isConnected = BluetoothManager.isActuatorConnected ||
        Settings.emulateConnectedActuator;

    final drawerItems = ListView(
      children: [
        drawerHeader,
        Divider(height: 1, thickness: 3, color: ColorManager.navDrawDiv),
        //  with actuator connected

        (isConnected)
            ? Card(
            color: NavDrawController.selectedPage ==
                        StringConsts.actuators.control
                    ? ColorManager.colorAccent
                    : ColorManager.navDrawBackground,
                child: ListTile(
                  title: Text(
                    StringConsts.actuators.control,
                    style: titleStyle,
                  ),
                  leading: const Icon(Icons.control_camera),
                  onTap: (() {
                    routeToPage(
                        context, const ControlPage(name: StringConsts.control));
                    NavDrawController.selectedPage =
                        StringConsts.actuators.control;
                  }),
                ))
            : Container(),
        (isConnected)
            ? Card(
            color:
                    NavDrawController.selectedPage == StringConsts.basicSettings
                        ? ColorManager.colorAccent
                        : ColorManager.navDrawBackground,
                child: ListTile(
                  title: Text(
                    StringConsts.basicSettings,
                    style: titleStyle,
                  ),
                  leading: const Icon(Icons.settings_outlined),
                  onTap: (() {
                    routeToPage(
                        context,
                        const BasicSettingsPage(
                            name: StringConsts.basicSettings));
                    NavDrawController.selectedPage = StringConsts.basicSettings;
                  }),
                ))
            : Container(),
        (isConnected)
            ? Card(
            color:
                    NavDrawController.selectedPage == StringConsts.calibration
                        ? ColorManager.colorAccent
                        : ColorManager.navDrawBackground,
                child: ListTile(
                  title: Text(
                    StringConsts.calibration,
                    style: titleStyle,
                  ),
                  leading: const Icon(Icons.sync),
                  onTap: (() {
                    routeToPage(context,
                        const CalibrationPage(name: StringConsts.calibration));
                    NavDrawController.selectedPage = StringConsts.calibration;
                  }),
                ))
            : Container(),
        (isConnected)
            ? Card(
            color: NavDrawController.selectedPage == StringConsts.features
                    ? ColorManager.colorAccent
                    : ColorManager.navDrawBackground,
                child: ListTile(
                  title: Text(
                    StringConsts.features,
                    style: titleStyle,
                  ),
                  leading: const Icon(Icons.list_alt),
                  onTap: (() {
                    routeToPage(context,
                        const FeaturesPage(name: StringConsts.features));
                    NavDrawController.selectedPage = StringConsts.features;
                  }),
                ))
            : Container(),
        (isConnected)
            ? Card(
            color: NavDrawController.selectedPage ==
                        StringConsts.updateFirmware
                    ? ColorManager.colorAccent
                    : ColorManager.navDrawBackground,
                child: ListTile(
                  title: Text(
                    StringConsts.updateFirmware,
                    style: titleStyle,
                  ),
                  leading: const Icon(Icons.update),
                  onTap: (() {
                    routeToPage(
                        context,
                        const UpdateFirmwarePage(
                            name: StringConsts.updateFirmware));
                    NavDrawController.selectedPage =
                        StringConsts.updateFirmware;
                  }),
                ))
            : Container(),
        (isConnected && (Actuator.connectedActuator.failsafe) ||
                (Actuator.connectedActuator.modulating) ||
                (Actuator.connectedActuator.speedControl) ||
                (Actuator.connectedActuator.wiggle) ||
                (Settings.devSettingsEnabled))
            ? Row(children: [
                Expanded(flex: 3, child: div),
                Expanded(
                    flex: 2,
                    child: Text(StringConsts.actuators.features,
                        textAlign: TextAlign.center)),
                Expanded(flex: 3, child: div)
              ])
            : Container(),
        ((isConnected && (Actuator.connectedActuator.torqueLimit)) ||
                Settings.devSettingsEnabled)
            ? Card(
            color:
                    NavDrawController.selectedPage == StringConsts.torqueLimit
                        ? ColorManager.colorAccent
                        : ColorManager.navDrawBackground,
            child: ListTile(
              title: Text(
                StringConsts.torqueLimit,
                style: titleStyle
              ),
              leading: const Icon(RiftIcons.torqueLimit),
              onTap: (() {
                routeToPage(context,
                        const TorqueLimitPage(name: StringConsts.torqueLimit));
                    NavDrawController.selectedPage = StringConsts.torqueLimit;
                  }),
            )
        ) : Container(),
        ((isConnected && (Actuator.connectedActuator.failsafe)) ||
                Settings.devSettingsEnabled)
            ? Card(
            color: NavDrawController.selectedPage == StringConsts.failsafe
                    ? ColorManager.colorAccent
                    : ColorManager.navDrawBackground,
                child: ListTile(
                  title: Text(
                    StringConsts.failsafe,
                    style: titleStyle,
                  ),
                  leading: const Icon(RiftIcons.failsafe),
                  onTap: (() {
                    routeToPage(context,
                        const FailsafePage(name: StringConsts.failsafe));
                    NavDrawController.selectedPage = StringConsts.failsafe;
                  }),
                ))
            : Container(),
        ((isConnected && (Actuator.connectedActuator.modulating)) ||
                Settings.devSettingsEnabled)
            ? Card(
            color: NavDrawController.selectedPage == StringConsts.modulating
                    ? ColorManager.colorAccent
                    : ColorManager.navDrawBackground,
                child: ListTile(
                  title: Text(
                    StringConsts.modulating,
                    style: titleStyle,
                  ),
                  leading: const Icon(RiftIcons.modulation),
                  onTap: (() {
                    routeToPage(context,
                        const ModulatingPage(name: StringConsts.modulating));
                    NavDrawController.selectedPage = StringConsts.modulating;
                  }),
                ))
            : Container(),
        ((isConnected && (Actuator.connectedActuator.speedControl)) ||
                Settings.devSettingsEnabled)
            ? Card(
            color:
                    NavDrawController.selectedPage == StringConsts.speedControl
                        ? ColorManager.colorAccent
                        : ColorManager.navDrawBackground,
                child: ListTile(
                  title: Text(
                    StringConsts.speedControl,
                    style: titleStyle,
                  ),
                  leading: const Icon(RiftIcons.speedControl),
                  onTap: (() {
                    routeToPage(
                        context,
                        const SpeedControlPage(
                            name: StringConsts.speedControl));
                    NavDrawController.selectedPage = StringConsts.speedControl;
                  }),
                ))
            : Container(),
        ((isConnected && (Actuator.connectedActuator.wiggle)) ||
                Settings.devSettingsEnabled)
            ? Card(
            color: NavDrawController.selectedPage == StringConsts.wiggle
                    ? ColorManager.colorAccent
                    : ColorManager.navDrawBackground,
                child: ListTile(
                  title: Text(
                    StringConsts.wiggle,
                    style: titleStyle,
                  ),
                  leading: const Icon(RiftIcons.modulation),
                  onTap: (() {
                    routeToPage(
                        context, const WigglePage(name: StringConsts.wiggle));
                    NavDrawController.selectedPage = StringConsts.wiggle;
                  }),
                ))
            : Container(),
        (isConnected) ? div : Container(),
        (isConnected)
            ? Card(
            color: NavDrawController.selectedPage ==
                        StringConsts.statistics.title
                    ? ColorManager.colorAccent
                    : ColorManager.navDrawBackground,
                child: ListTile(
                    title:
                        Text(StringConsts.statistics.title, style: titleStyle),
                    leading: const Icon(Icons.list_outlined),
                    onTap: (() {
                      routeToPage(context, const StatisticsPage());
                      NavDrawController.selectedPage =
                          StringConsts.statistics.title;
                    })))
            : Container(),
        (isConnected) ? div : Container(),
        //  without actuator connected
        Card(
          color:
              NavDrawController.selectedPage == StringConsts.connectToActuator
                  ? ColorManager.colorAccent
                  : ColorManager.navDrawBackground,
          child: ListTile(
            title: Text(
              StringConsts.connectToActuator,
              style: titleStyle,
            ),
            leading: const Icon(Icons.bluetooth),
            onTap: (() {
              routeToPage(
                  context,
                  const ConnectToActuatorPage(
                      name: StringConsts.connectToActuator));
              NavDrawController.selectedPage = StringConsts.connectToActuator;
            }),
          ),
        ),
        Card(
            color: NavDrawController.selectedPage == StringConsts.appSettings
                ? ColorManager.colorAccent
                : ColorManager.navDrawBackground,
            child: ListTile(
              title: Text(
                StringConsts.appSettings,
                style: titleStyle,
              ),
              leading: const Icon(Icons.settings_applications),
              onTap: (() {
                routeToPage(context, const SettingsPage());
                NavDrawController.selectedPage = StringConsts.appSettings;
              }),
            )),
        Card(
            color: NavDrawController.selectedPage == StringConsts.contactUs
                ? ColorManager.colorAccent
                : ColorManager.navDrawBackground,
            child: ListTile(
              title: Text(StringConsts.contactUs, style: titleStyle),
              leading: const Icon(Icons.contact_support),
              onTap: (() {
                routeToPage(context, const ContactUsPage());
                NavDrawController.selectedPage = StringConsts.contactUs;
              }),
            )),
        Card(
            child: ListTile(
          title: Text(
            StringConsts.logOut,
            style: titleStyle,
          ),
          leading: const Icon(Icons.logout_outlined),
          onTap: (() {
            showAlert(
                context: context,
                content: Text(StringConsts.login.confirmLogout),
                actions: [
                  TextButton(
                    onPressed: (() {
                      Navigator.of(context).pop();
                    }),
                    child: const Text(StringConsts.cancel),
                  ),
                  TextButton(
                    onPressed: (() {
                      routeToPage(context, const LoginPage(),
                          removeStack: true);
                      NavDrawController.selectedPage =
                          StringConsts.connectToActuator;
                    }),
                    child: const Text(StringConsts.confirm),
                  ),
                ]);
          }),
        )),
      ],
    );

    return Drawer(
      child: drawerItems,
    );
  }
}
