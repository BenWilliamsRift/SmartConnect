package com.example.actuatorapp2;

// Used to match incoming request to the related outgoing request, if the request is not received, then we can resend it.

import android.os.SystemClock;

import java.util.ArrayList;

public class BluetoothAwait {

    static ArrayList<BluetoothAwait> bluetoothAwaits = new ArrayList<>();
    public String message;
    private int bluetoothTimeout = 500; // ms to get a bluetooth response before resending the request.
    private long lastSend = 0;


    BluetoothAwait(String message) {
        this.message = message.replaceAll("\\n", "");

        lastSend = SystemClock.elapsedRealtime();

//        if (existsInList(Actuator, this.message) != null)
//            return;

        getBluetoothAwaits().add(this);
    }

    synchronized static void MessageReceived(String Message, Actuator actuator) {
        Message = Message.replaceAll("\\n", "");
        BluetoothAwait bluetoothAwait = existsInList(actuator, Message);

        if (bluetoothAwait == null)
            return;

        if (getBluetoothAwaits().size() < 2) {
            return;
        }
        getBluetoothAwaits().remove(bluetoothAwait);
        bluetoothAwait = null; // Remove references for garbage collection

    }

    private synchronized static BluetoothAwait existsInList(Actuator actuatorObject, String bluetoothMessage) {

        bluetoothMessage = bluetoothMessage.replaceAll("\\n", "");
        String[] bluetoothMessageSplit = bluetoothMessage.split(",");
        if (bluetoothMessage.contains("SACO")) {
            bluetoothMessageSplit[0] = "m4";
        }
        String bluetoothCommand = bluetoothMessageSplit[0];

        try {
            for (BluetoothAwait bluetoothAwait : getBluetoothAwaits()) {
//                if (bluetoothAwait == null || bluetoothAwait.actuator == null)
//                    continue;

//                if (!bluetoothAwait.actuator.equals(actuatorObject))
//                    continue;

                if (bluetoothCommand.compareTo("m57") == 0) // Feature request
                {
                    String featureRequest = bluetoothMessageSplit[0] + "," + bluetoothMessageSplit[1];
                    if (bluetoothAwait.message.compareTo(featureRequest) == 0)
                        return bluetoothAwait;
                }
                if (bluetoothAwait.message.compareTo(bluetoothCommand) == 0)
                    return bluetoothAwait;
            }
        } catch (Exception ignored) {
            return null;
        }
        return null;
    }

    synchronized static int amountOfAwaitsForActuator(Actuator actuator) {
        int amo = 0;

        for (BluetoothAwait await : getBluetoothAwaits()) {
//            if(await.actuator == actuator){
//                amo++;
//            }
        }
        return amo;
    }

    public synchronized static ArrayList<BluetoothAwait> getBluetoothAwaits() {
        return bluetoothAwaits;
    }

    public boolean isTimeoutExceeded() {
        return (SystemClock.elapsedRealtime() - lastSend > bluetoothTimeout);
    }

    synchronized public void repeatRequest() {
        lastSend = SystemClock.elapsedRealtime();
//        if(amountOfAwaitsForActuator(actuator) > 1) {
//            getBluetoothAwaits().remove(this);
//        }
//        BluetoothMessageHandler.sendMessage(message, actuator);

    }
}
