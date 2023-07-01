//
//  HHBlueToothManager.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/28.
//

#import <Foundation/Foundation.h>
#import "HanhongDeviceHelper.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HHBlueToothManagerDelegate <NSObject>

- (void)on_device_helper_event:(DEVICE_HELPER_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2;

@end

@interface HHBlueToothManager : NSObject<HanhongDeviceHelperDelegate>

@property (weak, nonatomic) id<HHBlueToothManagerDelegate> delegate;

+ (instancetype)shareManager;


- (NSString *)getDeviceMessage;//获取设备信息
- (NSInteger)getModeSeq;//开机默认模式
- (NSInteger)getDefaultVolume;//开机默认音量
- (NSInteger)getAutoOffTime;//自动关机时间
- (Boolean)getAdvStartState;//听诊器蓝牙默认状态
- (CONNECT_STATE)getConnectState;//获取设备的连接状态
- (NSInteger)getDeviceType;//获取设备类型
- (void)startRecord:(RECORD_TYPE)record_type record_mode:(RECORD_MODE)record_mode; //2
- (NSData *)getRecordFile;//获取录音文件
- (NSString *)getSerialNumber;
- (NSString *)getFirmwareVersion;
- (NSString *)getBootloaderVersion;
- (NSString *)getProductionDate;
- (double)getBatteryState;

- (void)setBatteryType:(BOOL) normal;
- (void)setAdvStartState:(Boolean)state;//设置听诊器蓝牙默认状态
- (void)setModeSeq:(int)value;//设置开机默认模式
- (void)setDefaultVolume:(int)value;//设置开机默认音量
- (void)setAutoOffTime:(int)value;//设置自动关机时间
- (void)disconnect;//断开连接
- (void)setRecordDuration:(int)duration;//设置录音时长
- (void)stop;
- (void)abortSearch;

- (void)actionSearchBluetoothList;//查找蓝牙列表
- (void)actionConnectToBluetoothMacAddress:(NSString *)macAddress;//根据Mac地址连接蓝牙

@end

NS_ASSUME_NONNULL_END
