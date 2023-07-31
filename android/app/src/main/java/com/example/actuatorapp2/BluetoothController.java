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
import android.os.Looper;
import android.os.Message;
import android.os.SystemClock;
import android.util.Log;

import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

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
    //    static final int STATE_RECONNECTING = 4;
    static final int STATE_EXCEPTION = 5;
    // Name for the SDP record when creating server socket
    private static final String NAME_SECURE = "BluetoothChatSecure";
    private static final String NAME_INSECURE = "BluetoothChatInsecure";
    // UUID for bluetooth server and client connections
    private static final UUID UUID_SECURE =
            UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
    private static final UUID UUID_INSECURE =
            UUID.fromString("8ce255c0-200a-11e0-ac64-0800200c9a66");
    public static String DEVICE_NAME = "device_name";
    private static MainActivity mainActivity;
    final int timeOutDuration = 15000;
    public Runnable runnable;
    BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

    private final Handler handler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MESSAGE_STATE_CHANGE:
                    switch (msg.arg1) {
                        case STATE_CONNECTED:
                            keepAliveSignal();
                            break;
                        case STATE_CONNECTING:
                        case STATE_LISTEN:
                        case STATE_NONE:
                            break;
                    }
                    break;
                case MESSAGE_WRITE:
                case MESSAGE_DEVICE_NAME:
                    break;
                // Receive message from actuator
                case MESSAGE_READ:
                    byte[] readBuf = (byte[]) msg.obj;
                    String readMessage = new String(readBuf, 0, msg.arg1);

                    flutterChannel.invokeMethod("bluetoothCommandResponse", processReadMessage(readMessage));
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
    List<BluetoothDevice> devices = new ArrayList<>();
    List<BLDevice> devicesRssi = new ArrayList<>();
    Thread timeoutThread;
    BroadcastReceiver scanReceiver;
    boolean connectedToDevice = false;
    private int CONNECTION_STATUS;
    private int state = STATE_NONE;
    private long flashingBoard = 0; // Used to prevent bluetooth request being sent while board is in a critical mode
    private AcceptThread secureAcceptThread;
    private AcceptThread inSecureAcceptThread;
    private ConnectThread connectThread;
    private ConnectedThread connectedThread;
    MethodChannel flutterChannel = null;
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
    boolean doesNotHavePermission(Context context, String... permissions) {
        if (context != null && permissions != null) {
            for (String permission : permissions) {
                if (ActivityCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                    return true;
                }
            }
        }
        return false;
    }

    @SuppressLint("MissingPermission")
    @RequiresApi(api = Build.VERSION_CODES.M)
    public void startScan(MainActivity mainActivity) {
        // Clear devices to prevent duplicate devices for another scan
        devices.clear();

        // Ask for all of the different permissions
        // This section should always be the first thing called so permissions are accepted here then don't need to be checked anywhere else

        if (!mainActivity.getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
            Log.i("BlueController", "Bluetooth not supported");
            return;
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
        } else {
            PERMISSIONS = new String[]{
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                    Manifest.permission.BLUETOOTH,
                    Manifest.permission.BLUETOOTH_ADMIN,
            };

        }
        if (doesNotHavePermission(mainActivity.getApplicationContext(), PERMISSIONS)) {
            ActivityCompat.requestPermissions(mainActivity.getActivity(), PERMISSIONS, PERMISSION_ALL);
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
        bluetoothAdapter.startDiscovery();
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @SuppressLint("MissingPermission")
    List<HashMap<String, String>> getDevices() {

        // List<HashMap<String, String>> tempDevices = new ArrayList<>(getBondedDevices());

        List<HashMap<String, String>> tempDevices = new ArrayList<>();

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

    private ScheduledExecutorService executorService;
    private ScheduledFuture<?> timeoutFuture;


    @SuppressLint("MissingPermission")
    public void connectToDevice(BluetoothDevice device, boolean secure) throws IOException {

        if (device == null) {
            return;
        }

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
        timeOutSystemTime = System.currentTimeMillis() + timeOutLength;
        executorService = Executors.newSingleThreadScheduledExecutor();
        timeoutFuture = executorService.scheduleAtFixedRate(() -> {
            if (timeOutSystemTime < System.currentTimeMillis()) {
                connectThread.cancel();
                connectionTimedOut();
                cancelTimeoutThread();
            }
        }, 0, 1, TimeUnit.SECONDS);

    }

    private void cancelTimeoutThread() {
        if (timeoutFuture != null && !timeoutFuture.isCancelled()) {
            timeoutFuture.cancel(true);
        }
        if (executorService != null) {
            executorService.shutdown();
        }
    }


    @SuppressLint("MissingPermission")
    public List<HashMap<String, String>> getBondedDevices() {
        Set<BluetoothDevice> bondedDevices = bluetoothAdapter.getBondedDevices();

        Log.i("bonded", String.valueOf(bondedDevices.size()));

        List<HashMap<String, String>> devices = new ArrayList<>();

        for (BluetoothDevice device : bondedDevices) {
            HashMap<String, String> deviceInfo = new HashMap<>();

            deviceInfo.put("name", device.getName());
            deviceInfo.put("address", device.getAddress());
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                deviceInfo.put("alias", device.getAlias());
            } else {
                deviceInfo.put("alias", device.getName());
            }
            deviceInfo.put("rssi", "0");

            devices.add(deviceInfo);
        }
        return devices;
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
        }
    }

    public void disconnect() {
        stop();
        runnable = null;
        cancelTimeoutThread();
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
    public synchronized void connected(BluetoothSocket socket, BluetoothDevice device) {
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
        connectedThread = new ConnectedThread(socket);
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

        long flashTimeoutMs = 2000;
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
                            connected(socket, socket.getRemoteDevice());
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

            Log.i("Device Address", device.getAddress());

            // Make a connection to the BluetoothSocket
            try {
                socket.connect();

                Log.e("ConnectThread", "-- attempting start --");
                BluetoothController.updateConnectionStatus(BluetoothController.CONNECTING);
            } catch (IOException e) {
                BluetoothController.updateConnectionStatus(BluetoothController.FAILED);
                Log.e("ConnectThread", "-- socket failed --");
                e.printStackTrace();
                try {
                    Log.e("ConnectThread", "-- attempting close --");
                    e.printStackTrace();
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
            connected(socket, device);
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

        ConnectedThread(BluetoothSocket s) {
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

                        handler.obtainMessage(MESSAGE_READ, bytes, -1, buffer[buffer_to_use]).sendToTarget();
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
                handler.obtainMessage(MESSAGE_WRITE, -1, -1, buffer).sendToTarget();
            } catch (IOException e) {
                Log.e("ConnectedThread:Write", "Exception writing", e);

                Message msg = handler.obtainMessage(MESSAGE_LOST_CONNECTION);
                // device connection was lost

                handler.sendMessage(msg);

                setState(STATE_EXCEPTION);
            }
        }

        public void cancel() {
            try {
                inStream.close();
                outStream.close();
                socket.close();
            } catch (IOException e) {
                Log.e("ConnectedThread:Close", "close() of connect socket failed", e);
            }
        }
    }
}
