//
//  HHBlueToothManager.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/28.
//

#import "HHBlueToothManager.h"

@interface HHBlueToothManager()

@property (assign, nonatomic) NSInteger             last_second;
@property (retain, nonatomic) NSString              *btDeviceMode;
@property (retain, nonatomic) NSString              *imgMac;;

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
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"event"] = [@(event) stringValue];
    if (args1) {
        userInfo[@"args1"] = args1;
    }
    if (args2) {
        userInfo[@"args2"] = args2;
    }
    if (event == DeviceConnected) {
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [_hanhongDevice Disconnect];
//        });
        
        if ([_hanhongDevice GetModel] == POPULAR3) {
            NSString *deviceFirmwareVersion = [_hanhongDevice GetFirmwareVersion];
            NSRange range = [deviceFirmwareVersion rangeOfString:@"."];
            NSString *firstVersion = [deviceFirmwareVersion substringWithRange:NSMakeRange(0, range.location)];
            
            if ([firstVersion isEqualToString:@"V1"] || [firstVersion isEqualToString:@"V2"] || [firstVersion isEqualToString:@"V3"]) {
                if([[Constant shareManager] checkDeviceIsUpdate:deviceFirmwareVersion])
                {
                    
                    NSString *firstStr = [firstVersion substringFromIndex:1];
                    //[self upUpdateFirmware:firstStr];
                    
                    [[Constant shareManager] upUpdateFirmware:firstStr imgMac:self.imgMac version:deviceFirmwareVersion];
          
                   
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:HHBluetoothMessage object:nil userInfo:userInfo];
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

- (NSArray *)getRecordFile{
    return [_hanhongDevice GetRecordFile];;
}

- (NSArray *)getRecordData{
    return [_hanhongDevice GetRecordData];;
}

- (void)startRecord:(RECORD_TYPE)record_type record_mode:(RECORD_MODE)record_mode{
   [_hanhongDevice StartRecord:record_type record_mode:record_mode];
}

- (Boolean)isRecording{
    return [_hanhongDevice IsRecording];
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

- (void)connent:(NSString *)macAddress{
    self.imgMac = macAddress;
    [_hanhongDevice Connect:macAddress];
}

- (void)setPlayTimeRange:(float)start_time end_time:(float)end_time{
    [_hanhongDevice SetPlayTimeRange:start_time end_time:end_time];
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

-(void)setPlayFile:(NSData *)file_data{
    [_hanhongDevice SetPlayFile:file_data];
}

-(void)startPlay:(PLAY_MODE)play_mode{
    [_hanhongDevice StartPlay:play_mode];
}

- (void)writePlayBuffer:(NSData *)data{
    [_hanhongDevice WritePlayBuffer:data];
}
-(CBCentralManager *)getCentralManager{
    return [_hanhongDevice getCentralManager];
}
-(CBPeripheral *)currentPeripheral{
    return [_hanhongDevice currentPeripheral];
}

@end
