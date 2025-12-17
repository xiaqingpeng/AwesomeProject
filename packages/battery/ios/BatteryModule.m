#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(BatteryModule, RCTEventEmitter)

RCT_EXTERN_METHOD(getBatteryInfo:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startMonitoringBattery)

RCT_EXTERN_METHOD(stopMonitoringBattery)

@end