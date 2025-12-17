"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Battery = void 0;
const react_native_1 = require("react-native");
// 获取原生模块
const BatteryModule = react_native_1.NativeModules.BatteryModule;
// 检查模块是否存在
if (!BatteryModule) {
    console.error('电池模块未找到。请确保已正确链接原生模块。' +
        '对于Android，请检查MainApplication.kt中是否添加了BatteryPackage。' +
        '对于iOS，请检查是否运行了pod install。');
}
// 创建事件发射器
const batteryEventEmitter = BatteryModule ? new react_native_1.NativeEventEmitter(BatteryModule) : null;
// 电池信息类
class Battery {
    /**
     * 获取当前电池信息
     * @returns Promise<BatteryInfoInterface> 电池信息
     */
    static async getBatteryInfo() {
        try {
            return await BatteryModule.getBatteryInfo();
        }
        catch (error) {
            console.error('Failed to get battery info:', error);
            return {
                level: -1,
                isCharging: false,
                isLowPower: false
            };
        }
    }
    /**
     * 监听电池状态变化
     * @param callback 回调函数
     * @returns 取消监听的函数
     */
    static addBatteryListener(callback) {
        if (!BatteryModule) {
            console.error('电池模块未找到，无法监听电池状态变化');
            // 返回一个空函数作为取消监听的函数
            return () => { };
        }
        BatteryModule.startMonitoringBattery();
        const subscription = batteryEventEmitter.addListener('BatteryStatus', callback);
        return () => {
            subscription.remove();
            BatteryModule.stopMonitoringBattery();
        };
    }
}
exports.Battery = Battery;
//# sourceMappingURL=index.js.map