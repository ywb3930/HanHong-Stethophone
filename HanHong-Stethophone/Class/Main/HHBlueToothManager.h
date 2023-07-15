//
//  HHBlueToothManager.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/28.
//

#import <Foundation/Foundation.h>
#import "HanhongDeviceHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHBlueToothManager : NSObject<HanhongDeviceHelperDelegate>


+ (instancetype)shareManager;


- (NSString *)getDeviceMessage;//获取设备信息
- (NSInteger)getModeSeq;//开机默认模式
- (NSInteger)getDefaultVolume;//开机默认音量
- (NSInteger)getAutoOffTime;//自动关机时间
- (Boolean)getAdvStartState;//听诊器蓝牙默认状态
- (CONNECT_STATE)getConnectState;//获取设备的连接状态
- (NSInteger)getDeviceType;//获取设备类型
- (void)startRecord:(RECORD_TYPE)record_type record_mode:(RECORD_MODE)record_mode;
- (Boolean)isRecording;//2
- (NSArray *)getRecordFile;//获取录音文件
- (NSArray *)getRecordData;
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
- (void)setPlayFile:(NSData *)file_data;//播放  file_data：文件数据
- (void)startPlay:(PLAY_MODE)play_mode;//play_mode 用第一个
- (void)setPlayTimeRange:(float)start_time end_time:(float)end_time;
- (void)writePlayBuffer:(NSData *)data;

- (void)actionSearchBluetoothList;//查找蓝牙列表
- (void)connent:(NSString *)macAddress;//根据Mac地址连接蓝牙
-(CBCentralManager *)getCentralManager;
-(CBPeripheral *)currentPeripheral;

@end

NS_ASSUME_NONNULL_END
