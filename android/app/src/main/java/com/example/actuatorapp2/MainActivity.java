package com.example.actuatorapp2;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;

import java.io.IOException;
import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

@RequiresApi(api = Build.VERSION_CODES.M)
public class MainActivity extends FlutterActivity {

    static final String BLUETOOTH_CHANNEL = "bluetooth";
    String actuatorPassword = "";
    BluetoothController bluetoothController = new BluetoothController(this);

    void sendActuatorPassword(String message) {
        actuatorPassword = message;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @RequiresApi(api = Build.VERSION_CODES.S)
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        switch (requestCode) {
            case 0:
                if (grantResults.length > 0 && grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(getActivity(), new String[]{Manifest.permission.BLUETOOTH_SCAN}, 0);
                }
                break;
            case 1:
            case 2:
            case 3:
            case 4:
                break;
        }
    }

    public boolean parseBool(String source) {
        return source.equals("true");
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), BLUETOOTH_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    bluetoothController.createMethodChannel(flutterEngine);

                    switch (call.method) {
                        case "scan":
                            // Check if the device supports Bluetooth
                            if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
                                Log.i("SCAN:ERROR", "Bluetooth not supported by device");
                                finish();
                                return;
                            }

                            // Start Bluetooth scanning
                            bluetoothController.startScan(this);
                            result.success(bluetoothController.getDevices());
                            break;
                        case "isScanning":
                            // Check if the device supports Bluetooth
                            if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
                                Log.i("SCAN:ERROR", "Bluetooth not supported by device");
                                finish();
                                return;
                            }

                            result.success(bluetoothController.isScanning());
                            break;
                        case "getDevices":
                            // Check if the device supports Bluetooth
                            if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
                                Log.i("SCAN:ERROR", "Bluetooth not supported by device");
                                finish();
                                return;
                            }

                            result.success(bluetoothController.getDevices());
                            break;
                        case "getBonded":
                            // Retrieve bonded devices
                            result.success(bluetoothController.getBondedDevices());
                            break;
                        case "connect":
                            // Check if the device supports Bluetooth
                            if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
                                Log.i("SCAN:ERROR", "Bluetooth not supported by device");
                                finish();
                                return;
                            }

                            // Connect to a Bluetooth device
                            Map<String, String> params = call.arguments();
                            assert params != null;
                            String address = params.get("address");
                            String secure = params.get("secure");

                            try {
                                bluetoothController.connectToDevice(bluetoothController.getDeviceFromAddress(address), parseBool(Objects.requireNonNull(secure)));
                            } catch (IOException e) {
                                e.printStackTrace();
                                result.success("error");
                                return;
                            }

                            result.success(bluetoothController.getConnectionStatus());
                            break;
                        case "getBoardNumber":
                            // Retrieve board number
                            Log.i("JAVA", "--Board number requested--");
                            result.success(String.valueOf(Actuator.boardNumber));
                            break;
                        case "keepAlive":
                            // Check if the device supports Bluetooth
                            if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
                                Log.i("SCAN:ERROR", "Bluetooth not supported by device");
                                finish();
                                return;
                            }

                            // Keep the Bluetooth connection alive
                            bluetoothController.keepAlive();
                            result.success(actuatorPassword);
                            break;
                        case "sendBluetoothMessage":
                            // Send a Bluetooth message
                            String code = call.argument("code");
                            String param = call.argument("param");
                            String message = param != null ? code + "," + param : code;
                            bluetoothController.send(message);
                            break;
                        case "write":
                            // Write data to the Bluetooth device
                            byte[] bytes = call.argument("bytes");
                            bluetoothController.write(bytes);
                            break;
                        case "isConnected":
                            // Check if connected to a Bluetooth device
                            result.success(bluetoothController.isConnected());
                            break;
                        case "isConnecting":
                            // Check if currently connecting to a Bluetooth device
                            result.success(bluetoothController.isConnecting());
                            break;
                        case "getConnectionStatus":
                            // Get the current connection status
                            result.success(bluetoothController.getConnectionStatus());
                            break;
                        case "updateActuatorPassword":
                            // Update the actuator password
                            String password = call.argument("password");
                            Actuator.insertActuatorPasswords(password);
                            break;
                        case "disconnect":
                            // Disconnect from the Bluetooth device
                            bluetoothController.disconnect();
                            break;
                        case "setAlias":
                            // Set the Bluetooth device alias
                            String alias = call.argument("alias");
                            bluetoothController.setAlias(alias);
                            break;
                    }
                });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        bluetoothController.stopScan();
        bluetoothController.unregisterReceivers(this);
    }
}
