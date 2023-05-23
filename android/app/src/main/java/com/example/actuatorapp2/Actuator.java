package com.example.actuatorapp2;

import android.bluetooth.BluetoothDevice;
import android.os.Build;
import android.util.Log;

import androidx.annotation.RequiresApi;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class Actuator {
    public static double firmwareVersion;
    public static boolean isInBootloader;
    public static int LEDStatus;
    public static double temperature;
    public static double angle;
    public static boolean parity;
    public static double workingTime;
    public static int maximumDuty;
    public static double torqueLimitNm;
    public static int boardNumber;
    public static String loggingPassword;
    public static int numberOfFullCycles;
    public static double peakCurrent;
    public static double peakTemperature;
    public static double voltageAllTimeLow;
    public static int powerOns;
    public static double lastCycleEnergy;
    public static int lastChargeTime;
    public static double valveOrientation;
    public static int numberOfCycles;
    public static double workingAngle;
    public static int failsafeMode;
    public static double failsafeAngle;
    public static int modulatingAnalogSignalMode;
    public static boolean reverseActing;
    public static int numberOfStarts;
    public static int indicationMode;
    public static double calibratedClosedAngle;
    public static double batteryVoltage;
    public static double PIDP;
    public static double PIDI;
    public static int lossOfSignalMode;
    public static double lossOfSignalAngle;
    public static int featureDisabled;
    public static int featureEnabled;
    public static String featurePasswordDigits;
    public static int positionMode;
    public static double backlash;
    public static boolean startInManualMode;
    public static int offGridTimeUntilFirstOpen;
    public static int offGridTimeBetweenCycles;
    public static int offGridOpenTime;
    public static boolean offGridTimerEnabled;
    public static boolean wiggleEnabled;
    public static double timeBetweenWiggles;
    public static double wiggleAngle;
    public static double torqueLimitBackOffAngle;
    public static double torqueLimitDelayBeforeRetry;
    public static double processControlPValue;
    public static double processControlIValue;
    public static double processControlDesiredInputVoltage;
    public static boolean processControlEnabled;
    public static double receivedModulationInput;
    public static boolean sleepWhenNotPowered;
    public static boolean magnetTestMode;
    public static boolean buttonsEnabled;
    public static int numberOfTests;
    public static double minimumBatteryVoltage;
    public static boolean testingEnabled;
    public static double analogDeadbandBackwards;
    public static double analogDeadbandForwards;
    public static int modulatingInversion;
    public static int autoManual;
    public static boolean locked;
    public static int failsafeDelay;
    public static String actuatorPassword;

    Actuator(BluetoothDevice device, MainActivity mainActivity) {

    }

    public static void setFirmwareVersion(double version) {
        firmwareVersion = version;
    }

    public static void setInBootloader(boolean b) {
        isInBootloader = b;
    }

    public static void setAngle(double a) {
        angle = a;
    }

    public static void setLEDStatus(int leds) {
        LEDStatus = leds;
    }

    public static void setTemperature(double temp) {
        temperature = temp;
    }

    public static void setParityEnabled(boolean b) {
        parity = b;
    }

    public static void setWorkingTimeInSeconds(double time) {
        workingTime = time;
    }

    public static void setMaximumDuty(int maximum) {
        maximumDuty = maximum;
    }

    public static void setTorqueLimitNm(double limit) {
        torqueLimitNm = limit;
    }

    public static void setValveOrientation(double value) {
        valveOrientation = value;
    }

    public static void setNumberOfCycles(int value) {
        numberOfCycles = value;
    }

    public static void setWorkingAngle(double value) {
        workingAngle = value;
    }

    public static void setFailsafeMode(int value) {
        failsafeMode = value;
    }

    public static void setFailsafeAngle(double value) {
        failsafeAngle = value;
    }

    public static void setModulatingAnalogSignalMode(int index) {
        modulatingAnalogSignalMode = index;
    }

    public static void setReverseActing(boolean b) {
        reverseActing = b;
    }

    public static void setNumberOfStarts(int value) {
        numberOfStarts = value;
    }

    public static void setIndicationMode(int value) {
        indicationMode = value;
    }

    public static void setCalibratedClosedAngle(double value) {
        calibratedClosedAngle = value;
    }

    public static void setBatteryVoltage(double value) {
        batteryVoltage = value;
    }

    public static void setPIDP(double value) {
        PIDP = value;
    }

    public static void setPIDI(double value) {
        PIDI = value;
    }

    public static void setLossOfSignalMode(int mode) {
        lossOfSignalMode = mode;
    }

    public static void setLossOfSignalAngle(double value) {
        lossOfSignalAngle = value;
    }

    public static void setFeatureDisabled(int index) {
        featureDisabled = index;
    }

    public static void setFeatureEnabled(int index) {
        featureEnabled = index;
    }

    public static void setFeaturePasswordDigits(String part) {
        featurePasswordDigits = part;
    }

    public static void setPositionMode(int mode) {
        positionMode = mode;
    }

    public static void setBacklash(double value) {
        backlash = value;
    }

    public static void setStartInManualMode(boolean b) {
        startInManualMode = b;
    }

    public static void setOffGridTimeUntilFirstOpen(int value) {
        offGridTimeUntilFirstOpen = value;
    }

    public static void setOffGridTimeBetweenCycles(int value) {
        offGridTimeBetweenCycles = value;
    }

    public static void setOffGridOpenTime(int value) {
        offGridOpenTime = value;
    }

    public static void setOffGridTimerEnabled(boolean b) {
        offGridTimerEnabled = b;
    }

    public static void setWiggleEnabled(boolean b) {
        wiggleEnabled = b;
    }

    public static void setTimeBetweenWiggles(double value) {
        timeBetweenWiggles = value;
    }

    public static void setWiggleAngle(double value) {
        wiggleAngle = value;
    }

    public static void setTorqueLimitBackOffAngle(double value) {
        torqueLimitBackOffAngle = value;
    }

    public static void setTorqueLimitDelayBeforeRetry(double value) {
        torqueLimitDelayBeforeRetry = value;
    }

    public static void setProcessControlPValue(double value) {
        processControlPValue = value;
    }

    public static void setProcessControlIValue(double value) {
        processControlIValue = value;
    }

    public static void setProcessControlDesiredInputVoltage(double value) {
        processControlDesiredInputVoltage = value;
    }

    public static void setProcessControlEnabled(boolean b) {
        processControlEnabled = b;
    }

    public static void setReceivedModulationInput(double value) {
        receivedModulationInput = value;
    }

    public static void setSleepWhenNotPowered(boolean b) {
        sleepWhenNotPowered = b;
    }

    public static void setMagnetTestMode(boolean b) {
        magnetTestMode = b;
    }

    public static void setButtonsEnabled(boolean b) {
        buttonsEnabled = b;
    }

    public static void setNumberOfTests(int value) {
        numberOfTests = value;
    }

    public static void setMinimumBatteryVoltage(double value) {
        minimumBatteryVoltage = value;
    }

    public static void setTestingEnabled(boolean value) {
        testingEnabled = value;
    }

    public static void setAnalogDeadbandBackwards(double value) {
        analogDeadbandBackwards = value;
    }

    public static void setAnalogDeadbandForwards(double value) {
        analogDeadbandForwards = value;
    }

    public static void setModulatingInversion(int value) {
        modulatingInversion = value;
    }

    public static void setAutoManual(int value) {
        autoManual = value;
    }

    public static void setLocked(boolean equals) {
        locked = equals;
    }

    public static void setFailsafeDelay(int parseInt) {
        failsafeDelay = parseInt;
    }

    public static void setLoggingPassword(String password) {
        loggingPassword = password;
    }

    public static void setNumberOfFullCycles(int fullCycles) {
        numberOfFullCycles = fullCycles;
    }

    public static void setPeakCurrent(double peak) {
        peakCurrent = peak;
    }

    public static void setPeakTemperature(double temperature) {
        peakTemperature = temperature;
    }

    public static void setVoltageAllTimeLow(double voltageLow) {
        voltageAllTimeLow = voltageLow;
    }

    public static void setPowerOns(int powerOn) {
        powerOns = powerOn;
    }

    public static void setLastCycleEnergy(double lastCycle) {
        lastCycleEnergy = lastCycle;
    }

    public static void setLastChargeTime(int chargeTime) {
        lastChargeTime = chargeTime;
    }

    // TODO parse passwords
    @RequiresApi(api = Build.VERSION_CODES.M)
    public static void insertActuatorPasswords(String string) {
        string = string.replace("null", "\"\"");

        if (string.length() > 0) {
            try {
                JSONArray passwords = new JSONArray(string);
                for (int i = 0; i < passwords.length(); i++) {
                    JSONObject password = passwords.getJSONObject(i);

                    if (password.getInt("board_number") == 1529) {
                        String msg = password.getString("android_verification");
                        actuatorPassword = msg;
                        BluetoothController.sendActuatorPassword(actuatorPassword);
                    }
                }
            } catch (JSONException e) {
                Log.e("InsertPasswordsError", e.getMessage());
            }
        }
    }

    public static void updateBoardNumber(String name) {
        boardNumber = Integer.parseInt(name.split(" ")[2]);
        Log.i("BoardNumber", String.valueOf(boardNumber));
    }
}
