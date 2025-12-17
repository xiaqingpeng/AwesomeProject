package com.awesomeproject;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.PowerManager;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

public class BatteryModule extends ReactContextBaseJavaModule {
    private final ReactApplicationContext reactContext;
    private BroadcastReceiver batteryReceiver;
    private boolean isMonitoring = false;

    public BatteryModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @NonNull
    @Override
    public String getName() {
        return "BatteryModule";
    }

    @ReactMethod
    public void getBatteryInfo(Promise promise) {
        try {
            IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
            Intent batteryStatus = reactContext.registerReceiver(null, ifilter);

            WritableMap batteryInfo = Arguments.createMap();

            // 获取电池电量
            int level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
            int scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
            float batteryPct = level * 100 / (float) scale;

            // 获取充电状态
            int status = batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1);
            boolean isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                    status == BatteryManager.BATTERY_STATUS_FULL;

            // 获取低电量模式状态
            PowerManager powerManager = (PowerManager) reactContext.getSystemService(Context.POWER_SERVICE);
            boolean isLowPower = false;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                isLowPower = powerManager.isPowerSaveMode();
            }

            batteryInfo.putDouble("level", Math.round(batteryPct));
            batteryInfo.putBoolean("isCharging", isCharging);
            batteryInfo.putBoolean("isLowPower", isLowPower);

            promise.resolve(batteryInfo);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    @ReactMethod
    public void startMonitoringBattery() {
        if (isMonitoring) return;

        batteryReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (Intent.ACTION_BATTERY_CHANGED.equals(intent.getAction())) {
                    // 获取电池电量
                    int level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
                    int scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
                    float batteryPct = level * 100 / (float) scale;

                    // 获取充电状态
                    int status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1);
                    boolean isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                            status == BatteryManager.BATTERY_STATUS_FULL;

                    // 获取低电量模式状态
                    PowerManager powerManager = (PowerManager) reactContext.getSystemService(Context.POWER_SERVICE);
                    boolean isLowPower = false;
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                        isLowPower = powerManager.isPowerSaveMode();
                    }

                    WritableMap batteryInfo = Arguments.createMap();
                    batteryInfo.putDouble("level", Math.round(batteryPct));
                    batteryInfo.putBoolean("isCharging", isCharging);
                    batteryInfo.putBoolean("isLowPower", isLowPower);

                    sendEvent("BatteryStatus", batteryInfo);
                }
            }
        };

        IntentFilter filter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        reactContext.registerReceiver(batteryReceiver, filter);
        isMonitoring = true;
    }

    @ReactMethod
    public void stopMonitoringBattery() {
        if (batteryReceiver != null && isMonitoring) {
            reactContext.unregisterReceiver(batteryReceiver);
            batteryReceiver = null;
            isMonitoring = false;
        }
    }

    private void sendEvent(String eventName, WritableMap params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }
}