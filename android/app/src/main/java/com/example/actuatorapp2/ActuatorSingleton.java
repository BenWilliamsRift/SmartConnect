package com.example.actuatorapp2;

import java.util.ArrayList;

public class ActuatorSingleton {

    // this holds actuator information
    // used to be held in main activity, now is in here

    private static ActuatorSingleton ourInstance;

    ArrayList<Actuator> connectedActuators = new ArrayList<Actuator>();
    ArrayList<Actuator> connectingActuators = new ArrayList<Actuator>();
    ArrayList<Actuator> unconnectedActuators = new ArrayList<Actuator>();
    ArrayList<Actuator> activeActuators = new ArrayList<Actuator>();

    ArrayList<Integer> connectedBoardNumbers = new ArrayList<Integer>();
    ArrayList<Integer> connectingBoardNumbers = new ArrayList<Integer>();
    ArrayList<Integer> unconnectedBoardNumbers = new ArrayList<Integer>();
    ArrayList<Integer> activeBoardNumbers = new ArrayList<Integer>();

//    ArrayList<CallbackInterface> onConnectCallbacks = new ArrayList<CallbackInterface>();
//    ArrayList<CallbackInterface> onDisconnectCallbacks = new ArrayList<CallbackInterface>();

    public static ActuatorSingleton getInstance() {
        if (ourInstance == null) {
            ourInstance = new ActuatorSingleton();
        }
        return ourInstance;
    }

    public void addNewActuator(Actuator actuator) {
        addNewActuator(actuator, CONNECTION_STATUS.NOT_CONNECTED);
    }

    public void addNewActuator(Actuator actuator, int connectStatus) {
//        if (getEveryActuators(Actuator.class).contains(actuator)) {
//            return; // not new
//        }

        switch (connectStatus) {
            case CONNECTION_STATUS.NOT_CONNECTED:
//                addActuatorUnconnected(actuator);
                break;
            case CONNECTION_STATUS.CONNECTING:
//                addActuatorConnecting(actuator);
                break;
            case CONNECTION_STATUS.CONNECTED:
//                addActuatorConnected(actuator);
                break;
        }
    }

    public static class CONNECTION_STATUS {
        public final static int NOT_CONNECTED = 1;
        public final static int CONNECTING = 2;
        public final static int CONNECTED = 4;
    }

//    public Actuator createNewActuator(BluetoothDevice bluetoothDevice, MainActivity mainActivity, Context context) {
//        Actuator Actuator = new Actuator(bluetoothDevice, mainActivity, context);
//    }
}
