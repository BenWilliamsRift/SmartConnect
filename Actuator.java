package com.example.actuatorapp2;

import android.os.Build;
import android.util.Log;

import androidx.annotation.RequiresApi;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class Actuator {
    public static int boardNumber;
    public static String actuatorPassword;

    Actuator() {
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
                        actuatorPassword = password.getString("android_verification");
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
    }
}
