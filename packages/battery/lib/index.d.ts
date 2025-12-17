interface BatteryInfoInterface {
    level: number;
    isCharging: boolean;
    isLowPower: boolean;
}
export declare class Battery {
    /**
     * 获取当前电池信息
     * @returns Promise<BatteryInfoInterface> 电池信息
     */
    static getBatteryInfo(): Promise<BatteryInfoInterface>;
    /**
     * 监听电池状态变化
     * @param callback 回调函数
     * @returns 取消监听的函数
     */
    static addBatteryListener(callback: (info: BatteryInfoInterface) => void): () => void;
}
export type { BatteryInfoInterface };
//# sourceMappingURL=index.d.ts.map