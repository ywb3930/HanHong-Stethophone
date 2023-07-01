//
//  HHBlueToothManager.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/28.
//

#import "HHBlueToothManager.h"

@interface HHBlueToothManager()

@property (assign, nonatomic) NSInteger             last_second;
@property (retain, nonatomic) NSString              *btDeviceMode;;

@end

@implementation HHBlueToothManager

static HanhongDeviceHelper             *_hanhongDevice;

+(instancetype)shareManager{
    static HHBlueToothManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HHBlueToothManager alloc] init];
        [manager initDevice];
    });
    
    return manager;
}

- (void)on_device_helper_event:(DEVICE_HELPER_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2{
    //收数据
    //NSLog(@"DEVICE_HELPER_EVENT = %li", event);
    if (self.delegate && [self.delegate respondsToSelector:@selector(on_device_helper_event:args1:args2:)]) {
        [self.delegate on_device_helper_event:event args1:args1 args2:args2];
    }
}

- (NSString *)getProductionDate{
    return [_hanhongDevice GetProductionDate];
}

- (NSString *)getBootloaderVersion{
    return [_hanhongDevice GetBootloaderVersion];
}

- (NSString *)getSerialNumber{
    return [_hanhongDevice GetSerialNumber];
}

- (NSString *)getFirmwareVersion{
    return [_hanhongDevice GetFirmwareVersion];
}

- (NSString *)getDeviceMessage{
    return  [_hanhongDevice GetModelName];
}

- (NSInteger)getModeSeq{
    return [_hanhongDevice GetModeSeq];;
}

- (NSInteger)getDefaultVolume{
    return [_hanhongDevice GetDefaultVolume];
}

- (NSInteger)getAutoOffTime{
    return [_hanhongDevice GetAutoOffTime];
}

- (Boolean)getAdvStartState{
    return [_hanhongDevice GetAdvStartState];
}

- (CONNECT_STATE)getConnectState{
    return [_hanhongDevice ConnectState];
}

- (NSInteger)getDeviceType{
    return [_hanhongDevice GetType];
}

- (double)getBatteryState{
    return [_hanhongDevice GetBatteryState];
}

- (void)setBatteryType:(BOOL)normal{
    return [_hanhongDevice SetBatteryType:normal];
}

- (void)disconnect{
    return [_hanhongDevice Disconnect];
}

- (void)abortSearch{
    return [_hanhongDevice AbortSearch];
}

- (NSData *)getRecordFile{
    return [_hanhongDevice GetRecordFile];;
}

- (void)startRecord:(RECORD_TYPE)record_type record_mode:(RECORD_MODE)record_mode{
   [_hanhongDevice StartRecord:record_type record_mode:record_mode];
}

- (void)stop{
    [_hanhongDevice Stop];
}

- (void)initDevice{
    _hanhongDevice = [[HanhongDeviceHelper alloc] init];
    _hanhongDevice.deviceHelperEventDelegate = self;
}

- (void)actionSearchBluetoothList{
    [_hanhongDevice Search:ALL_MODEL];
}

- (void)actionConnectToBluetoothMacAddress:(NSString *)macAddress{
    [_hanhongDevice Connect:macAddress];
}

- (void)setAdvStartState:(Boolean)state{
    [_hanhongDevice SetAdvStartState:state];
}

- (void)setModeSeq:(int)value{
    [_hanhongDevice SetModeSeq:value];
}

- (void)setDefaultVolume:(int)value{
    [_hanhongDevice SetDefaultVolume:value];
}

- (void)setAutoOffTime:(int)value{
    [_hanhongDevice SetAutoOffTime:value];
}

- (void)setRecordDuration:(int)duration{
    [_hanhongDevice SetRecordDuration:duration];
}

@end
