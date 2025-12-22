import Foundation
import React

@objc(BatteryModule)
class BatteryModule: RCTEventEmitter {
  private var isMonitoring = false
  
  @objc
  func getBatteryInfo(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    // 启用电池监控
    UIDevice.current.isBatteryMonitoringEnabled = true
    
    // 获取电池信息
    let batteryLevel = UIDevice.current.batteryLevel
    let batteryState = UIDevice.current.batteryState
    
    // 检查是否处于低电量模式
    let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    
    // 创建返回对象
    let batteryInfo: [String: Any] = [
      "level": batteryLevel != -1 ? Int(batteryLevel * 100) : -1,
      "isCharging": batteryState == .charging || batteryState == .full,
      "isLowPower": isLowPowerMode
    ]
    
    resolve(batteryInfo)
    
    // 如果不需要持续监控，关闭电池监控
    if !isMonitoring {
      UIDevice.current.isBatteryMonitoringEnabled = false
    }
  }
  
  @objc
  func startMonitoringBattery() {
    if isMonitoring { return }
    
    // 启用电池监控
    UIDevice.current.isBatteryMonitoringEnabled = true
    isMonitoring = true
    
    // 添加电池状态变化通知
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(batteryLevelDidChange),
      name: UIDevice.batteryLevelDidChangeNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(batteryStateDidChange),
      name: UIDevice.batteryStateDidChangeNotification,
      object: nil
    )
    
    // 添加低电量模式变化通知
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(powerModeDidChange),
      name: NSNotification.Name.NSProcessInfoPowerStateDidChange,
      object: nil
    )
  }
  
  @objc
  func stopMonitoringBattery() {
    if !isMonitoring { return }
    
    // 移除所有通知
    NotificationCenter.default.removeObserver(self)
    
    // 关闭电池监控
    UIDevice.current.isBatteryMonitoringEnabled = false
    isMonitoring = false
  }
  
  @objc
  func batteryLevelDidChange(_ notification: Notification) {
    sendBatteryStatus()
  }
  
  @objc
  func batteryStateDidChange(_ notification: Notification) {
    sendBatteryStatus()
  }
  
  @objc
  func powerModeDidChange(_ notification: Notification) {
    sendBatteryStatus()
  }
  
  private func sendBatteryStatus() {
    let batteryLevel = UIDevice.current.batteryLevel
    let batteryState = UIDevice.current.batteryState
    let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    
    let batteryInfo: [String: Any] = [
      "level": batteryLevel != -1 ? Int(batteryLevel * 100) : -1,
      "isCharging": batteryState == .charging || batteryState == .full,
      "isLowPower": isLowPowerMode
    ]
    
    sendEvent(withName: "BatteryStatus", body: batteryInfo)
  }
  
  @objc
  override static func requiresMainQueueSetup() -> Bool {
    return false
  }

  override func supportedEvents() -> [String] {
    return ["BatteryStatus"]
  }
}