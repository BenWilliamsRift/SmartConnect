package com.example.actuatorapp2;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

/**
 * hosts all bluetooth connectivity and discovery
 **/

@RequiresApi(api = Build.VERSION_CODES.M)
public class MainActivity extends FlutterActivity {

    static final String BLUETOOTH_CHANNEL = "bluetooth";
    public static int amountOfAsyncTasks = 0;
    //    static ActuatorsSavingCallback actuatorsSavingCallback;
    final ActuatorSingleton actuatorSingleton = ActuatorSingleton.getInstance();
    String actuatorPassword = "";
    BluetoothController bluetoothController = new BluetoothController(this);

    void sendActuatorPassword(String message) {
        actuatorPassword = message;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState, @Nullable PersistableBundle persistentState) {
        super.onCreate(savedInstanceState, persistentState);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        switch (requestCode) {
            case 0:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // Granted
                } else {
                    ActivityCompat.requestPermissions(getActivity(), new String[]{Manifest.permission.BLUETOOTH_SCAN}, 0);
                }
            case 1:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // Granted
                } else {
                    // Not Granted
                }
            case 2:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // Granted
                } else {
                    // Not Granted
                }
            case 3:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // Granted
                } else {
                    // Not Granted
                }
            case 4:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // Granted
                } else {
                    // Not Granted
                }
        }
    }

    public boolean parseBool(String source) throws RuntimeException {
        if (source.equals("false")) {
            return false;
        } else if (source.equals("true")) {
            return true;
        } else {
            throw new RuntimeException("Invalid source string: " + source);
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

        super.configureFlutterEngine(flutterEngine);

        // All Bluetooth backend
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), BLUETOOTH_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            bluetoothController.createMethodChannel(flutterEngine);

                            // Bluetooth Scan
                            if (call.method.equals("scan")) {
                                // check if the device the app is running on has Bluetooth available
                                if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
                                    Log.i("SCAN:ERROR", "Bluetooth not supported by device");
                                    finish();
                                }

                                boolean success = bluetoothController.startScan(this);



                                result.success(bluetoothController.getDevices());
                            }

                            if (call.method.equals("isScanning")) {
                                // check if the device the app is running on has Bluetooth available
                                if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
                                    Log.i("SCAN:ERROR", "Bluetooth not supported by device");
                                    finish();
                                }

                                result.success(bluetoothController.isScanning());
                            }

                            if (call.method.equals("getDevices")) {
                                // check if the device the app is running on has Bluetooth available
                                if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
                                    Log.i("SCAN:ERROR", "Bluetooth not supported by device");
                                    finish();
                                }

                                result.success(bluetoothController.getDevices());
                            }

                            if (call.method.equals("connect")) {
                                // Check if the device the app is running on has Bluetooth available
                                if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
                                    Log.i("SCAN:ERROR", "Bluetooth not supported by device");
                                    finish();
                                }

                                Map<String, String> params = new HashMap<String, String>();
                                params.put("address", call.argument("address"));
                                params.put("secure", call.argument("secure"));

                                try {
                                    bluetoothController.connectToDevice(bluetoothController.getDeviceFromAddress(params.get("address")), parseBool(Objects.requireNonNull(params.get("secure"))));
                                } catch (IOException e) {
                                    e.printStackTrace();
                                    result.success("error");
                                }

                                result.success(bluetoothController.getConnectionStatus());
                            }

                            if (call.method.equals("getBoardNumber")) {
                                Log.i("JAVA", "--Board number requested--");
                                result.success(String.valueOf(Actuator.boardNumber));
                            }

                            if (call.method.equals("keepAlive")) {
                                // Check if the device the app is running on has Bluetooth available
                                if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
                                    Log.i("SCAN:ERROR", "Bluetooth not supported by device");
                                    finish();
                                }

                                bluetoothController.keepAlive();

                                result.success(actuatorPassword);
                            }

                            if (call.method.equals("sendBluetoothMessage")) {
                                if (call.argument("param") == null) {
                                    bluetoothController.send(call.argument("code"));
                                } else {
                                    bluetoothController.send(call.argument("code") + "," + Objects.requireNonNull(call.argument("param")));
                                }
                            }

                            if (call.method.equals("write")) {
                                Log.i("Bytes", Objects.requireNonNull(call.argument("bytes")).getClass().getName());
                                bluetoothController.write(call.argument("bytes"));
                            }

                            if (call.method.equals("isConnected")) {
                                result.success(bluetoothController.isConnected());
                            }

                            if (call.method.equals("isConnecting")) {
                                result.success(bluetoothController.isConnecting());
                            }

                            if (call.method.equals("getConnectionStatus")) {
                                result.success(bluetoothController.getConnectionStatus());
                            }

                            if (call.method.equals("updateActuatorPassword")) {
                                Actuator.insertActuatorPasswords(call.argument("password"));
                            }

                            if (call.method.equals("disconnect")) {
                                bluetoothController.disconnect();
                            }

                            if (call.method.equals("setAlias")) {
                                bluetoothController.setAlias(call.argument("alias"));
                            }
                        }
                    );
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        bluetoothController.stopScan();
        bluetoothController.unregisterReceivers(this);
    }
}
