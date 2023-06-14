package com.example.actuatorapp2;

import android.Manifest;
import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothServerSocket;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.SystemClock;
import android.util.Log;

import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

class BLDevice {
    public BluetoothDevice device;
    public short rssi;

    BLDevice(BluetoothDevice device, short rssi) {
        this.device = device;
        this.rssi = rssi;
    }
}

public class BluetoothController {
    public static final int CONNECTING = 0;
    public static final int FAILED = 1;
    public static final int CONNECTED = 2;
    public static final int MESSAGE_STATE_CHANGE = 1;
    public static final int MESSAGE_READ = 2;
    public static final int MESSAGE_WRITE = 3;
    public static final int MESSAGE_DEVICE_NAME = 4;
    public static final int MESSAGE_LOST_CONNECTION = 6;
    static final String VerifyCode = "m156";
    static final int STATE_NONE = 0;
    static final int STATE_LISTEN = 1;
    static final int STATE_CONNECTING = 2;
    static final int STATE_CONNECTED = 3;
    static final int STATE_RECONNECTING = 4;
    static final int STATE_EXCEPTION = 5;
    // Name for the SDP record when creating server socket
    private static final String NAME_SECURE = "BluetoothChatSecure";
    private static final String NAME_INSECURE = "BluetoothChatInsecure";
    // UUID for bluetooth server and client connections
    private static final UUID UUID_SECURE =
            UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
    private static final UUID UUID_INSECURE =
            UUID.fromString("8ce255c0-200a-11e0-ac64-0800200c9a66");
    private static final String[] notRequests = new String[]{
            "m5",
            "m6",
            "m7",
            "m44",
            "m45",
            "m48",
            "a",
            "l",
            "w",
            "m11",
            "m111",
            "m9",
            "m40",
            "m46",
            "m47",
            "m200",
            "@",
            "~",
            "#",
            "%",
            "!",
    };
    private static final String[] areRequests = new String[]{
            "m57" // Feature request
    };
    private static final Set<String> notRequestsSet = new HashSet<>(Arrays.asList(notRequests));
    private static final Set<String> areRequestsSet = new HashSet<>(Arrays.asList(areRequests));
    public static String DEVICE_NAME = "device_name";
    private static MainActivity mainActivity;
    final String HEXF_FILE_NAME = "actuatorHexs.txt";
    final int timeOutDuration = 15000;
    public Runnable runnable;
    BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

    @SuppressLint("HandlerLeak")
    private final Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MESSAGE_STATE_CHANGE:
                    switch (msg.arg1) {
                        case STATE_CONNECTED:
                            String mConnectedDeviceName = msg.getData().getString(DEVICE_NAME);

                            keepAliveSignal();
                            break;
                        case STATE_CONNECTING:
                        case STATE_LISTEN:
                        case STATE_NONE:
                            break;
                    }
                    break;
                case MESSAGE_WRITE:
                    break;

                // Receive message from actuator
                case MESSAGE_READ:
                    byte[] readBuf = (byte[]) msg.obj;
                    String readMessage = new String(readBuf, 0, msg.arg1);

                    flutterChannel.invokeMethod("bluetoothCommandResponse", processReadMessage(readMessage));

                    break;
                case MESSAGE_DEVICE_NAME:
                    // save the connected device's name
                    String mConnectedDeviceName = msg.getData().getString(DEVICE_NAME);
                    // final ArrayList<Actuator> singleActuator =  new ArrayList<>();
                    // singleActuator.add(actuator);
                    new Handler().postDelayed(new Runnable() {
                        @Override
                        public void run() {
//                                BluetoothMessageHandler.requestFeatures(singleActuator);
                        }
                    }, 250);
                    new Handler().postDelayed(new Runnable() {
                        @Override
                        public void run() {
//                                BluetoothMessageHandler.requestFeatures(singleActuator);
                        }
                    }, 750);
                    new Handler().postDelayed(new Runnable() {
                        @Override
                        public void run() {
//                                mActuatorSingleton.onActuatorConnected(actuator);
                        }
                    }, 1250);

                    break;
                case MESSAGE_LOST_CONNECTION:
                    disconnect(); // Lost connection, remove our actuator from the disconnected list and make sure we've stopped all threads.
                    break;
            }
        }
    };

    String latestCommand;

    String processReadMessage(String message) {
        if (message.startsWith(String.valueOf(latestCommand.charAt(0)))) {
            return latestCommand + ":" + message;
        }
        return "null:" + message;
    }

    long timeOutSystemTime = 0;
    Actuator actuator;
    List<BluetoothDevice> devices = new ArrayList<>();
    List<BLDevice> devicesRssi = new ArrayList<>();
    Thread timeoutThread;
    BroadcastReceiver scanReceiver;
    boolean connectedToDevice = false;
    private int CONNECTION_STATUS;
    private int state = STATE_NONE;
    private long flashingBoard = 0; // Used to prevent bluetooth request being sent while board is in a critical mode
    private long flashTimeoutMs = 2000;
    private AcceptThread secureAcceptThread;
    private AcceptThread inSecureAcceptThread;
    private ConnectThread connectThread;
    private ConnectedThread connectedThread;
    MethodChannel flutterChannel = null;
    private boolean receivedReverseActing;
    private boolean receivedClosedAngle;
    static private BluetoothDevice connectedDevice;

    BluetoothController(MainActivity mainActivity) {
        BluetoothController.mainActivity = mainActivity;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    static void sendActuatorPassword(String password) {
        mainActivity.sendActuatorPassword(password);
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    public static String getActuatorPassword() {
        return mainActivity.actuatorPassword;
    }
//    public CallbackInterface m155Callback, m1551Callback, m1552Callback;

    private static byte[] hexStringToByteArray(String s) {
        s = s.replaceAll("\\s", "");
        int len = s.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4) + Character.digit(s.charAt(i + 1), 16));
        }

        return data;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    public static void updateConnectionStatus(int status) {
        mainActivity.sendActuatorPassword(String.valueOf(status));
    }

    void createMethodChannel(FlutterEngine flutterEngine) {
        if (flutterChannel == null) {
            flutterChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "bluetooth-response");
        }
    }

    public BluetoothDevice getDeviceFromAddress(String address) {
        for (BluetoothDevice device : devices) {
            if (device.getAddress().equals(address)) {
                return device;
            }
        }

        return null;
    }

    public synchronized void start() {
        // Cancel any thread attempting to make a connection
        if (connectThread != null) {
            connectThread.cancel();
            connectThread = null;
        }
        // Cancel any thread currently running a connection
        if (connectedThread != null) {
            connectedThread.cancel();
            connectedThread = null;
        }

        setState(STATE_LISTEN);

        // Start the thread to listen on a BluetoothServerSocket
        if (secureAcceptThread == null) {
            secureAcceptThread = new AcceptThread(true);
            secureAcceptThread.start();
        }
        if (inSecureAcceptThread == null) {
            inSecureAcceptThread = new AcceptThread(false);
            inSecureAcceptThread.start();
        }
    }

    public void write(byte[] out) {
        // Create temporary object
        ConnectedThread r;
        // Synchronize a copy of the ConnectedThread
        synchronized (this) {
            if (state != STATE_CONNECTED) return;
            r = connectedThread;
        }
        // Perform the write unsynchronized
        r.write(out);
    }

    private synchronized void setState(int _state) {
        state = _state;

        handler.obtainMessage(MESSAGE_STATE_CHANGE, state, -1).sendToTarget();
    }

    // Three dots allow one, or many or an array of strings to be passed
    boolean hasPermissions(Context context, String... permissions) {
        if (context != null && permissions != null) {
            for (String permission : permissions) {
                if (ActivityCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                    return false;
                }
            }
        }
        return true;
    }

    @SuppressLint("MissingPermission")
    @RequiresApi(api = Build.VERSION_CODES.M)
    public boolean startScan(MainActivity mainActivity) {
        // Clear devices to prevent duplicate devices for another scan
        devices.clear();

        // Ask for all of the different permissions
        // This section should always be the first thing called so permissions are accepted here then don't need to be checked anywhere else

        if (!mainActivity.getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
            Log.i("BlueController", "Bluetooth not supported");
            return false;
        }

        String[] PERMISSIONS;
        int PERMISSION_ALL = 1;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PERMISSIONS = new String[]{
                    Manifest.permission.BLUETOOTH_ADMIN,
                    Manifest.permission.BLUETOOTH_CONNECT,
                    Manifest.permission.BLUETOOTH_SCAN,
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                    Manifest.permission.ACCESS_FINE_LOCATION
            };
            if (!hasPermissions(mainActivity.getApplicationContext(), PERMISSIONS)) {
                ActivityCompat.requestPermissions(mainActivity.getActivity(), PERMISSIONS, PERMISSION_ALL);
            }
        } else {
            PERMISSIONS = new String[]{
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                    Manifest.permission.BLUETOOTH,
                    Manifest.permission.BLUETOOTH_ADMIN,
            };

            if (!hasPermissions(mainActivity.getApplicationContext(), PERMISSIONS)) {
                ActivityCompat.requestPermissions(mainActivity.getActivity(), PERMISSIONS, PERMISSION_ALL);
            }
        }


        // enable Bluetooth
        if (!bluetoothAdapter.isEnabled()) {
            bluetoothAdapter.enable();
        }

        // Discovery is expensive and should be stopped before attempting another scan
        if (bluetoothAdapter.isDiscovering()) {
            stopScan();
        }

        // When a device is found this section is run and adds the device to a list
        scanReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String action = intent.getAction();

                if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                    // Device found
                    BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);

                    short rssi = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE);
                    devicesRssi.add(new BLDevice(device, rssi));

                    // handle new device
                    devices.add(device);

                } else if (BluetoothDevice.ACTION_ACL_CONNECTED.equals(action)) {
                    // Device is now connected
                    connectedToDevice = true;
                }
            }
        };
        IntentFilter intentFilter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
        mainActivity.registerReceiver(scanReceiver, intentFilter);

        // start the discovery service
        return bluetoothAdapter.startDiscovery();
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @SuppressLint("MissingPermission")
    List<HashMap<String, String>> getDevices() {
        List<HashMap<String, String>> tempDevices = new ArrayList<>();

        // get bonded devices
        Set<BluetoothDevice> bondedDevices = getBondedDevices();

        for (BluetoothDevice device : bondedDevices) {
            HashMap<String, String> deviceInfo = new HashMap<>();

            deviceInfo.put("name", device.getName());
            System.out.println(device.getName());
            deviceInfo.put("address", device.getAddress());
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                deviceInfo.put("alias", device.getAlias());
            } else {
                deviceInfo.put("alias", device.getName());
            }
            deviceInfo.put("rssi", "0");
        }

        // add device information to a hashmap to be sent to the flutter engine
        for (BLDevice BLDevice : devicesRssi) {
            HashMap<String, String> deviceInfo = new HashMap<>();
            deviceInfo.put("name", BLDevice.device.getName());
            deviceInfo.put("address", BLDevice.device.getAddress());
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                deviceInfo.put("alias", BLDevice.device.getAlias());
            } else {
                deviceInfo.put("alias", BLDevice.device.getName());
            }
            deviceInfo.put("rssi", String.valueOf(BLDevice.rssi));

            tempDevices.add(deviceInfo);
        }

        return tempDevices;
    }

    @SuppressLint("MissingPermission")
    public void stopScan() {
        bluetoothAdapter.cancelDiscovery();
    }

    @SuppressLint("MissingPermission")
    public boolean isScanning() {
        return bluetoothAdapter.isDiscovering();
    }

    @SuppressLint("MissingPermission")
    public boolean isConnected() {
        return state == STATE_CONNECTED;
    }

    @SuppressLint("MissingPermission")
    public boolean isConnecting() {
        return state == STATE_CONNECTING;
    }

    @SuppressLint("MissingPermission")
    public void connectToDevice(BluetoothDevice device, boolean secure) throws IOException {

        if (!bluetoothAdapter.isEnabled()) {
            bluetoothAdapter.enable();
        }

        stopScan();

        if (state == STATE_CONNECTED) {
            disconnect();
        }

        // Cancel any thread attempting to make a connection
        if (state == STATE_CONNECTING) {
            if (connectThread != null) {
                connectThread.cancel();
                connectThread = null;
            }
        }

        // Cancel any thread currently running a connection
        if (connectedThread != null) {
            connectedThread.cancel();
            connectedThread = null;
        }

        // Start the thread to connect with a given device
        connectThread = new ConnectThread(device, secure);
        connectThread.start();
        setState(STATE_CONNECTING);
        setConnectionStatus(CONNECTING);
        // timeout code
        timeoutThread = null;
        // x3 to the duration if the user has to pair to the device
        final int timeOutLength = (device.getBondState() == BluetoothDevice.BOND_BONDED) ? timeOutDuration : timeOutDuration * 3;
        timeOutSystemTime = System.currentTimeMillis() + timeOutLength; // time we should time out
        timeoutThread = new Thread(new Runnable() {
            @Override
            public void run() {
                while (state == STATE_CONNECTING) {
                    try {
                        if (timeOutSystemTime < System.currentTimeMillis()) {
                            connectThread.cancel();
                            connectionTimedOut();
                            return;
                        }
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        });
        timeoutThread.start();
    }

    public Set<BluetoothDevice> getBondedDevices() {
        if (ActivityCompat.checkSelfPermission(mainActivity.getApplicationContext(), Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
            Set<BluetoothDevice> devices = bluetoothAdapter.getBondedDevices();
            System.out.println(devices);
            return devices;
        }

        return Collections.emptySet();
    }

    private boolean getParity(int n) {
        boolean parity = false;
        while (n != 0) {
            parity = !parity;
            n = n & (n - 1);
        }
        return parity;
    }

    public void keepAlive() {
        keepAliveSignal();
    }

    private void keepAliveSignal() {
        runnable = new Runnable() {
            @RequiresApi(api = Build.VERSION_CODES.M)
            @Override
            public void run() {
                try {
                    verifyActuator();
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (runnable == this) {
                        handler.postDelayed(this, 1000);
                    }
                }
            }
        };

        handler.postDelayed(runnable, 0);
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    void setAlias(String alias) {
        if (ActivityCompat.checkSelfPermission(mainActivity.getApplicationContext(), Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
            return;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            connectedDevice.setAlias(alias);
        } else {
            // write name to file??
            // Tel user they can only do that on newer devices
        }
    }

    private boolean isNumeric(String s) {
        return s != null && s.matches("[-+]?\\d*\\.?\\d+");
    }

    void loggingFunc(String[] loggingInfo) {
        Actuator.setLoggingPassword(loggingInfo[1]);
        Actuator.setNumberOfFullCycles(Integer.parseInt(loggingInfo[2]));
        Actuator.setNumberOfStarts(Integer.parseInt(loggingInfo[3]));
        Actuator.setPeakCurrent(Double.parseDouble(loggingInfo[4]));
        Actuator.setPeakTemperature(Double.parseDouble(loggingInfo[5]));
        Actuator.setVoltageAllTimeLow(Double.parseDouble(loggingInfo[6]));
        Actuator.setPowerOns(Integer.parseInt(loggingInfo[7]));
        Actuator.setLastCycleEnergy(Double.parseDouble(loggingInfo[8]));
        Actuator.setLastChargeTime(Integer.parseInt(loggingInfo[9]));
    }

    public void disconnect() {
        stop();
        runnable = null;
    }

    public synchronized void stop() {
        if (connectThread != null) {
            connectThread.cancel();
            connectThread = null;
        }

        if (connectedThread != null) {
            connectedThread.cancel();
            connectedThread = null;
        }

        if (secureAcceptThread != null) {
            secureAcceptThread.cancel();
            secureAcceptThread = null;
        }

        if (inSecureAcceptThread != null) {
            inSecureAcceptThread.cancel();
            inSecureAcceptThread = null;
        }

        setState(STATE_NONE);
    }

    @SuppressLint("MissingPermission")
    public synchronized void connected(BluetoothSocket socket, BluetoothDevice device, final String socketType) {
        // Cancel the thread that completed the connection
        if (connectThread != null) {
            connectThread.cancel();
            connectThread = null;
        }

        // Cancel any thread currently running a connection
        if (connectedThread != null) {
            connectedThread.cancel();
            connectedThread = null;
        }

        // Cancel the accept thread because we only want to connect to one device
        connectedThread = new ConnectedThread(socket, socketType);
        connectedThread.start();

        // Send the name of the connected device back to the UI activity
        Message msg = handler.obtainMessage(MESSAGE_DEVICE_NAME);
        Bundle bundle = new Bundle();
        bundle.putString(DEVICE_NAME, device.getName());
        msg.setData(bundle);
        handler.sendMessage(msg);

        setState(STATE_CONNECTED);
    }

    // TODO
    private void connectionTimedOut() {
        // Send a failure message back to the activity
    }

    public void send(String message) {
        message += "\n"; // End command

        // Prevent interrupts to actuators while in critical state

        if (isMessageRequest(message))
            new BluetoothAwait(message);

        if (SystemClock.elapsedRealtime() - flashingBoard < flashTimeoutMs) {
            return;
        } else if (message.compareTo("m111\n") == 0 || message.compareTo("m11\n") == 0) {
            flashingBoard = SystemClock.elapsedRealtime();
        }

//        Log.i("MESSAGE SENT", message);

        latestCommand = message;

        try {
            write(message.getBytes());
        } catch (Exception e) {
            // Probably a broken pipe, we've lost connection with the device, remove it from the list and disconnect threads
            disconnect();
        }
    }

    void writeBootloader(Actuator actuator, MainActivity activity) {
        // Start transfer key
        SystemClock.sleep(100);

        byte[] hexBuffer = new byte[40000];
        try {
            InputStream inputStream = activity.getAssets().open(HEXF_FILE_NAME);
            int value;
            while ((value = inputStream.read(hexBuffer, 0, 40000)) != -1) {
                byte[] array = hexStringToByteArray(new String(hexBuffer).substring(0, value));

                if (Actuator.parity) {
                    send("!");
                    send(String.valueOf(((getParity(value) ? 1 : 0))));
                }

            }
        } catch (Exception e) {
            Log.e("error", e.getMessage());
        }
    }

    // Determine if a message being sent is a getter or a setter
    private boolean isMessageRequest(String Message) {
        Message = Message.replaceAll("\\n", "");
        char c = Message.charAt(0);

        // Some requests have commas, and some non-requests don't have commas. Filter these ones out through the sets.
        if (notRequestsSet.contains(Message))
            return false;
        else if (c == 'm') {
            if (Message.contains(",")) {
                String[] split = Message.split(",");
                return areRequestsSet.contains(split[0]);
            }
        }
        return true;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    private void verifyActuator() {
        String secret = getActuatorPassword();
        String message = (VerifyCode + secret);
        send(message);
    }

    public int getConnectionStatus() {
        return CONNECTION_STATUS;
    }

    public void setConnectionStatus(int status) {
        CONNECTION_STATUS = status;
    }

    private void connectionFailed() {
        // Send a failure message back to the activity
        setConnectionStatus(FAILED);
    }

    // TODO
    private void connectionLost() {
        // Send a failure message back to the activity
    }

    void unregisterReceivers(MainActivity mainActivity) {
        mainActivity.unregisterReceiver(scanReceiver);
    }

    private class AcceptThread extends Thread {
        // The local server socket
        private final BluetoothServerSocket bluetoothServerSocket;
        private final String socketType;

        @SuppressLint("MissingPermission")
        AcceptThread(boolean secure) {
            BluetoothServerSocket tmp = null;
            socketType = secure ? "Secure" : "Insecure";

            try {
                if (secure) {
                    tmp = bluetoothAdapter.listenUsingRfcommWithServiceRecord(NAME_SECURE, UUID_SECURE);
                } else {
                    tmp = bluetoothAdapter.listenUsingRfcommWithServiceRecord(NAME_INSECURE, UUID_INSECURE);
                }
            } catch (Exception e) {
                Log.e("BTA:AcceptThread", "Socket Type" + socketType + "listen() failed", e);
            }
            bluetoothServerSocket = tmp;
        }

        public void run() {
            setName("AcceptThread" + socketType);

            BluetoothSocket socket = null;

            // Listen to the server socket if we're not connected
            while (state != STATE_CONNECTED) {
                try {
                    if (bluetoothServerSocket != null) {
                        socket = bluetoothServerSocket.accept();
                    } else {
                        break;
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                    break;
                }
            }

            // If a connection was accepted
            if (socket != null) {
                synchronized (BluetoothController.this) {
                    switch (state) {
                        case STATE_LISTEN:
                        case STATE_CONNECTING:
                            // Situation normal. Start the connected thread
                            connected(socket, socket.getRemoteDevice(), socketType);
                            break;
                        case STATE_NONE:
                        case STATE_CONNECTED:
                            // Either not ready or already connected. Terminate new socket
                            try {
                                socket.close();
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            break;
                    }
                }
            }
        }

        public void cancel() {
            try {
                bluetoothServerSocket.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private class ConnectThread extends Thread {
        private final BluetoothSocket socket;
        private final BluetoothDevice device;
        private final String socketType;

        @SuppressLint("MissingPermission")
        ConnectThread(BluetoothDevice BtDevice, boolean secure) {
            device = BtDevice;
            BluetoothSocket tmp = null;
            socketType = secure ? "secure" : "Insecure";
            BluetoothController.connectedDevice = device;

            // Get a BluetoothSocket for a connection with the
            // given BluetoothDevice
            try {
                if (secure) {
                    tmp = device.createRfcommSocketToServiceRecord(UUID_SECURE);
                } else {
                    tmp = device.createInsecureRfcommSocketToServiceRecord(UUID_INSECURE);
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
            socket = tmp;

            Actuator.updateBoardNumber(device.getName());
        }

        @RequiresApi(api = Build.VERSION_CODES.M)
        @SuppressLint("MissingPermission")
        public void run() {
            setName("ConnectThread" + socketType);

            bluetoothAdapter.cancelDiscovery();

            // Make a connection to the BluetoothSocket
            try {
                socket.connect();

                actuator = new Actuator(device, mainActivity);

                // start the keep alive
                runnable = new Runnable() {
                    @Override
                    public void run() {
                        try {
                            verifyActuator();
                        } catch (Exception e) {
                            Log.e("KeepAlive", e.getMessage());
                        } finally {
                            if (runnable == this) {
                                handler.postDelayed(this, 1000);
                            }
                        }
                    }
                };

                runnable.run();

                Log.e("ConnectThread", "-- attempting start --");
                BluetoothController.updateConnectionStatus(BluetoothController.CONNECTING);
            } catch (IOException e) {
                BluetoothController.updateConnectionStatus(BluetoothController.FAILED);
                Log.e("ConnectThread", "-- socket failed --");
                e.printStackTrace();
                try {
                    Log.e("ConnectThread", "-- attempting close --");
                    socket.close();
                } catch (IOException e2) {
                    Log.e("ConnectThread", "-- close failed --");
                    e2.printStackTrace();
                }

                e.printStackTrace();

                if (System.currentTimeMillis() > timeOutSystemTime) {
                    connectionTimedOut();
                } else {
                    connectionFailed();
                }

                BluetoothController.updateConnectionStatus(BluetoothController.CONNECTED);
                return;
            }

            // Reset connectThread because we're done
            synchronized (BluetoothController.this) {
                connectThread = null;
            }

            // Start the connected thread
            connected(socket, device, socketType);
        }

        public void cancel() {
            try {
                socket.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private class ConnectedThread extends Thread {
        private final BluetoothSocket socket;
        private final InputStream inStream;
        private final OutputStream outStream;

        ConnectedThread(BluetoothSocket s, String socketType) {
            socket = s;
            InputStream tmpIn = null;
            OutputStream tmpOut = null;
            try {
                tmpIn = socket.getInputStream();
                tmpOut = socket.getOutputStream();
            } catch (IOException e) {
                e.printStackTrace();
            }

            inStream = tmpIn;
            outStream = tmpOut;
        }

        @RequiresApi(api = Build.VERSION_CODES.M)
        public void run() {
            setState(STATE_CONNECTED);

            int num_buffers = 4;
            byte[][] buffer = {new byte[1024], new byte[1024], new byte[1024], new byte[1024]};

            int bytes;
            int buffer_to_use = 0;

            setConnectionStatus(CONNECTED);

            // Keep listening to the InputStream while connected
            while (connectedThread != null) {
                int available = 0;

                try {
                    available = inStream.available();
                } catch (IOException e) {
                    e.printStackTrace();
                }

                if (available > 0) {
                    try {
                        // Read from inputStream
                        bytes = inStream.read(buffer[buffer_to_use]);

                        handler.obtainMessage(MESSAGE_READ, bytes, -1, buffer[buffer_to_use])
                                .sendToTarget();
                        buffer_to_use++;
                        if (buffer_to_use >= num_buffers) {
                            buffer_to_use = 0;
                        }
                    } catch (IOException e) {
                        Log.e("ConnectedThread:Run", "Disconnected", e);
                        connectionLost();
                        // Start the service over to restart listening mode
                        BluetoothController.this.start();
                        break;
                    }
                } else {
                    SystemClock.sleep(100);
                }
            }
        }

        public void write(byte[] buffer) {
            try {
                outStream.write(buffer);
                try {
                    Thread.sleep(10);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                handler.obtainMessage(MESSAGE_WRITE, -1, -1, buffer)
                        .sendToTarget();
            } catch (IOException e) {
                Log.e("ConnectedThread:Write", "Exception writing", e);

                Message msg = handler.obtainMessage(MESSAGE_LOST_CONNECTION);
                // device connection was lost
                // send to flutter engine
                handler.sendMessage(msg);

                setState(STATE_EXCEPTION);
            }
        }

        public void cancel() {
            try {
                socket.close();
            } catch (IOException e) {
                Log.e("ConnectedThread:Close", "close() of connect socket failed", e);
            }
        }
    }
}
