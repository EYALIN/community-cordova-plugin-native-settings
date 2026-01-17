package com.ionicframework.plugins.nativesettings;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import android.content.Intent;
import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import java.util.HashMap;
import java.util.Map;

public class NativeSettings extends CordovaPlugin {
    private static final Map<String, String> settingsMap = new HashMap<>();
    
    static {
        // Initialize settings map
        settingsMap.put("accessibility", Settings.ACTION_ACCESSIBILITY_SETTINGS);
        settingsMap.put("account", Settings.ACTION_ADD_ACCOUNT);
        settingsMap.put("airplane_mode", Settings.ACTION_AIRPLANE_MODE_SETTINGS);
        settingsMap.put("apn", Settings.ACTION_APN_SETTINGS);
        settingsMap.put("application_details", Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        settingsMap.put("application_development", Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS);
        settingsMap.put("application", Settings.ACTION_APPLICATION_SETTINGS);
        settingsMap.put("bluetooth", Settings.ACTION_BLUETOOTH_SETTINGS);
        // Android settings map - expanded
        settingsMap.put("battery_optimization", Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS);
        settingsMap.put("captioning", Settings.ACTION_CAPTIONING_SETTINGS);
        settingsMap.put("cast", Settings.ACTION_CAST_SETTINGS);
        settingsMap.put("data_roaming", Settings.ACTION_DATA_ROAMING_SETTINGS);
        settingsMap.put("date", Settings.ACTION_DATE_SETTINGS);
        settingsMap.put("about", Settings.ACTION_DEVICE_INFO_SETTINGS);
        settingsMap.put("display", Settings.ACTION_DISPLAY_SETTINGS);
        settingsMap.put("dream", Settings.ACTION_DREAM_SETTINGS);
        settingsMap.put("home", Settings.ACTION_HOME_SETTINGS);
        settingsMap.put("keyboard", Settings.ACTION_INPUT_METHOD_SETTINGS);
        settingsMap.put("keyboard_subtype", Settings.ACTION_INPUT_METHOD_SUBTYPE_SETTINGS);
        settingsMap.put("storage", Settings.ACTION_INTERNAL_STORAGE_SETTINGS);
        settingsMap.put("locale", Settings.ACTION_LOCALE_SETTINGS);
        settingsMap.put("location", Settings.ACTION_LOCATION_SOURCE_SETTINGS);
        settingsMap.put("manage_all_applications", Settings.ACTION_MANAGE_ALL_APPLICATIONS_SETTINGS);
        settingsMap.put("manage_applications", Settings.ACTION_MANAGE_APPLICATIONS_SETTINGS);
        settingsMap.put("memory_card", Settings.ACTION_MEMORY_CARD_SETTINGS);
        settingsMap.put("network", Settings.ACTION_NETWORK_OPERATOR_SETTINGS);
        settingsMap.put("nfcsharing", Settings.ACTION_NFCSHARING_SETTINGS);
        settingsMap.put("nfc_payment", Settings.ACTION_NFC_PAYMENT_SETTINGS);
        settingsMap.put("nfc_settings", Settings.ACTION_NFC_SETTINGS);
        settingsMap.put("print", Settings.ACTION_PRINT_SETTINGS);
        settingsMap.put("privacy", Settings.ACTION_PRIVACY_SETTINGS);
        settingsMap.put("quick_launch", Settings.ACTION_QUICK_LAUNCH_SETTINGS);
        settingsMap.put("search", Settings.ACTION_SEARCH_SETTINGS);
        settingsMap.put("security", Settings.ACTION_SECURITY_SETTINGS);
        settingsMap.put("settings", Settings.ACTION_SETTINGS);
        settingsMap.put("show_regulatory_info", Settings.ACTION_SHOW_REGULATORY_INFO);
        settingsMap.put("sound", Settings.ACTION_SOUND_SETTINGS);
        settingsMap.put("sync", Settings.ACTION_SYNC_SETTINGS);
        settingsMap.put("usage", Settings.ACTION_USAGE_ACCESS_SETTINGS);
        settingsMap.put("user_dictionary", Settings.ACTION_USER_DICTIONARY_SETTINGS);
        settingsMap.put("voice_input", Settings.ACTION_VOICE_INPUT_SETTINGS);
        settingsMap.put("wifi_ip", Settings.ACTION_WIFI_IP_SETTINGS);
        settingsMap.put("wifi", Settings.ACTION_WIFI_SETTINGS);
        settingsMap.put("wireless", Settings.ACTION_WIRELESS_SETTINGS);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("open")) {
            return openSettings(args, callbackContext);
        } else if (action.equals("isAvailable")) {
            return checkAvailability(args, callbackContext);
        }
        return false;
    }

    private boolean openSettings(JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (args == null || args.length() == 0) {
            callbackContext.error("Setting name is required");
            return false;
        }

        String settingName = args.getString(0);
        boolean newTask = args.length() > 1 && args.getBoolean(1);
        
        Intent intent = getSettingsIntent(settingName);
        if (intent == null) {
            callbackContext.error("Invalid setting: " + settingName);
            return false;
        }

        try {
            if (newTask) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            }
            this.cordova.getActivity().startActivity(intent);
            callbackContext.success();
            return true;
        } catch (Exception e) {
            callbackContext.error("Failed to open settings: " + e.getMessage());
            return false;
        }
    }

    private boolean checkAvailability(JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (args == null || args.length() == 0) {
            callbackContext.error("Setting name is required");
            return false;
        }

        String settingName = args.getString(0);
        Intent intent = getSettingsIntent(settingName);
        
        callbackContext.success(intent != null ? 1 : 0);
        return true;
    }

    private Intent getSettingsIntent(String setting) {
        Context context = this.cordova.getActivity().getApplicationContext();
        Uri packageUri = Uri.parse("package:" + context.getPackageName());
        
        String action = settingsMap.get(setting);
        if (action != null) {
            if (action.equals(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)) {
                return new Intent(action, packageUri);
            }
            return new Intent(action);
        }

        // Special cases
        switch (setting) {
            case "notification_id":
                return getNotificationSettingsIntent(context);
            case "store":
                return new Intent(Intent.ACTION_VIEW,
                        Uri.parse("market://details?id=" + context.getPackageName()));
            // Add more special cases...
        }

        return null;
    }

    private Intent getNotificationSettingsIntent(Context context) {
        Intent intent = new Intent();
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N_MR1) {
            intent.setAction(Settings.ACTION_APP_NOTIFICATION_SETTINGS);
            intent.putExtra(Settings.EXTRA_APP_PACKAGE, context.getPackageName());
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            intent.setAction("android.settings.APP_NOTIFICATION_SETTINGS");
            intent.putExtra("app_package", context.getPackageName());
            intent.putExtra("app_uid", context.getApplicationInfo().uid);
        } else {
            intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
            intent.addCategory(Intent.CATEGORY_DEFAULT);
            intent.setData(Uri.parse("package:" + context.getPackageName()));
        }
        return intent;
    }
}