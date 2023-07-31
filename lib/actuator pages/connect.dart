import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../actuator/actuator.dart';
import '../app_bar.dart';
import '../bluetooth/bluetooth_manager.dart';
import '../color_manager.dart';
import '../main.dart';
import '../nav_drawer.dart';
import '../string_consts.dart';
import 'help_page.dart';
import 'list_tiles.dart';

class ConnectToActuatorPage extends StatefulWidget {
  const ConnectToActuatorPage({Key? key}) : super(key: key);

  @override
  State<ConnectToActuatorPage> createState() => _ConnectToActuatorPageState();
}

List<Widget> deviceWidgets = [];

class _ConnectToActuatorPageState extends State<ConnectToActuatorPage>
    with SingleTickerProviderStateMixin {
  BluetoothManager bluetoothManager = BluetoothManager();

  Timer? updateTimer;

  @override
  void initState() {
    super.initState();
    getPermissions();

    // get paired devices
    // bluetoothManager.getPairedDevices();

    // start scan here
    _refreshList();

    aliasFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    updateTimer?.cancel();
    aliasFocusNode.dispose();
    enabled = false;
  }

  List<Widget> unconnected = [];

  Future<void> _refreshList() async {
    bluetoothManager.scan();
    if (mounted) {
      setState(() {});
    }

    final timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {});
      }
      bluetoothManager.refresh();
    });

    return Future.delayed(Duration(seconds: BluetoothManager.timeOutDelay), () {
      if (mounted) {
        setState(() {
          showSnackBar(
              context, StringConsts.bluetooth.scanFinished, null, null);
          bluetoothManager.refresh();
          timer.cancel();
          bluetoothManager.getIsScanning();
        });
      }
    });
  }

  bool aliasEditorEnabled = false;
  late FocusNode aliasFocusNode;

  void saveAlias(Device device, TextEditingController controller) {
    setState(() {
      if (kDebugMode) {
        print("Alias Saved");
      }
      device.setAlias(controller.text);
      aliasEditorEnabled = false;
    });
  }

  bool getDevices() {
    setState(() {
      bluetoothManager.scan();
    });
    return true;
  }

  // Sort the devices in order of connected > connecting > unconnected
  // Could also filter out non actuators - this could also be done in the android side
  // Could also sort based on rssi value
  List<Widget> sortedDevices() {
    List<Device> connectedDevices = [];
    List<Device> connectingDevices = [];
    List<Device> unconnectedDevices = [];
    List<Device> devices = [];

    // Might have to move to separate thread
    // Change to a different algorithm
    // Sorts each device into different categories then joins them at the end
    while ((connectedDevices.length + connectingDevices.length + unconnectedDevices.length) != bluetoothManager.devices.length) {
      for (Device device in bluetoothManager.devices) {
        if (!connectedDevices.contains(device) ||
            !connectingDevices.contains(device) ||
            !unconnectedDevices.contains(device)) {
          if (device.address == Actuator.connectedDeviceAddress) {
            connectedDevices.add(device);
          } else if (device.address == Actuator.connectingDeviceAddress) {
            connectingDevices.add(device);
          } else {
            unconnectedDevices.add(device);
          }
        }
      }
    }

    void disconnect() {
      bluetoothManager.disconnect();
      showSnackBar(context, StringConsts.bluetooth.disconnected, null, null);
    }

    devices.addAll(connectedDevices);
    devices.addAll(connectingDevices);
    devices.addAll(unconnectedDevices);

    List<Widget> widgetDevices = [];

    for (Device device in devices) {

      widgetDevices.add(GestureDetector(
        onHorizontalDragStart: (details) {
          setState(() {
            disconnect();
          });
        },
        child: Card(
            child: ListTile(
                tileColor: Actuator.connectedDeviceAddress == device.address
                    ? ColorManager.companyYellow
                    : null,
                onTap: () {
                  setState(() {
                    showSnackBar(
                        context,
                        "${StringConsts.bluetooth.attemptingConnection}${device.name}",
                        null,
                        null);

                    bluetoothManager.connectingDeviceAddress = device.address;
                    Actuator.connectingDeviceAddress = device.address;

                    // Start update timer to update state
                    updateTimer =
                        Timer.periodic(const Duration(seconds: 1), (timer) {
                      setState(() {
                        if (Actuator.connectedDeviceAddress != null &&
                            Actuator.connectingDeviceAddress == null) {
                          Future.delayed(const Duration(seconds: 10), () {
                            setState(() {
                              timer.cancel();
                            });
                          });
                        }
                      });
                    });

                    try {
                      // Start connection attempt
                      bluetoothManager.connect(device.address, context);
                      Future.delayed(Duration(seconds: BluetoothManager.timeOutDelay), () {
                        if (Actuator.connectedDeviceAddress == null) {
                          setState(() {});
                        }
                      });
                    } catch (e) {
                      if (kDebugMode) {
                        print(e.toString());
                      }
                      showSnackBar(
                          context,
                          "${StringConsts.bluetooth.failedConnection}${device.name}",
                          null,
                          null);
                      setState(() {
                        bluetoothManager.connectingDeviceAddress = null;
                        Actuator.connectingDeviceAddress = null;
                      });
                      updateTimer?.cancel();
                    }
                  });
                },
                title: Text(device.alias),
                subtitle: Text(device.name),
                trailing: (Actuator.connectedDeviceAddress == device.address)
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            disconnect();
                            Actuator.connectingDeviceAddress = null;
                            Actuator.connectedDeviceAddress = null;
                            bluetoothManager.connectingDeviceAddress = null;
                            bluetoothManager.connectedDeviceAddress = null;
                          });

                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {});
                          });
                        },
                        icon: Icon(Icons.cancel, color: ColorManager.close),
                      )
                    : (Actuator.connectingDeviceAddress == device.address)
                        ? const CircularProgressIndicator()
                        : null)),
      ));
      if (widgetDevices.length == connectedDevices.length) {
        widgetDevices.add(Row(children: [
          Expanded(
              child: Divider(
                  color: ColorManager.colorPrimaryLight,
                  indent: 2,
                  endIndent: 2)),
          Text(StringConsts.bluetooth.unconnected.toUpperCase(),
              style: TextStyle(color: ColorManager.colorPrimary)),
          Expanded(
              child: Divider(
                  color: ColorManager.colorPrimary, indent: 2, endIndent: 2)),
        ]));
      }
    }

    deviceWidgets = widgetDevices;

    return widgetDevices;
  }

  void getPermissions() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      if (await Permission.bluetooth.status.isGranted &&
          await Permission.bluetoothScan.status.isGranted &&
          await Permission.bluetoothConnect.isGranted) {
      } else {
        Map<Permission, PermissionStatus> status =
            await [Permission.bluetooth].request();

        if (kDebugMode) {
          print("status bluetooth: $status");
        }

        if (await Permission.bluetooth.isPermanentlyDenied) {
          openAppSettings();
        }

        Map<Permission, PermissionStatus> statusScan =
            await [Permission.bluetoothScan].request();

        if (kDebugMode) {
          print("status scan $statusScan");
        }

        Map<Permission, PermissionStatus> statusConnect =
            await [Permission.bluetoothConnect].request();

        if (kDebugMode) {
          print("status scan $statusConnect");
        }
      }
    } else {
      Map<Permission, PermissionStatus> status =
          await [Permission.location].request();

      if (kDebugMode) {
        print("status location: $status");
      }

      if (await Permission.location.isPermanentlyDenied) {
        openAppSettings();
      }
    }

    // todo get bluetooth permissions
    // move all permissions to here
  }

  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (enabled) {
          setState(() {});
        }
      }
    });

    return Scaffold(
      appBar: appBar(title: StringConsts.connectToActuator, context: context),
      drawer: const NavDrawer(),
      body: GestureDetector(
        onTap: () {
          setState(() {
            FocusScope.of(context).requestFocus(FocusNode());
          });
        },
        child: Column(
          children: [
            Style.sizedHeight,
            Row(children: [
              Expanded(flex: 1, child: Style.sizedWidth),
              Expanded(
                  flex: 20,
                  child: DropdownButton<String>(
                      value: Actuator.connectionSortMode,
                      items: Actuator.connectionSortModes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? sortMode) {
                        setState(() {
                          Actuator.connectionSortMode =
                              sortMode ?? Actuator.connectionSortMode;
                        });
                      })),
              Expanded(flex: 1, child: Style.sizedWidth),
            ]),
            Style.sizedHeight,
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshList,
                child: ListView(children: [
                  (bluetoothManager.devices.isEmpty &&
                          !bluetoothManager.isScanning)
                      ? Card(
                          child: ListTile(
                              onTap: () {
                                routeToPage(context, const HelpPage());
                              },
                              title: Text(StringConsts.help.actuatorScan),
                              subtitle: Text(StringConsts.help.pullDown)))
                      : Container(),
                  for (Widget widget in sortedDevices()) widget
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
