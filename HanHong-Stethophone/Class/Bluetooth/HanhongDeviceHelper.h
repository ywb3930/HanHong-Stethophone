//
//  HanhongDeviceHelper.h
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/29.
//

#ifndef HanhongDeviceHelper_h
#define HanhongDeviceHelper_h

#import <Foundation/Foundation.h>
#import "HanhongDevice.h"

typedef NS_ENUM(NSInteger, DEVICE_HELPER_EVENT)
{
    SearchStart = -3,
    SearchFound = -2,  //args1 (NSString *)device_name , args2 (NSString *)device_mac
    SearchEnd = -1,
     
    DeviceConnecting = 0,
    DeviceConnected = 1,
    DeviceDisconnected = 2,
     
    DeviceHelperRecordReady = 9,  //录音就绪
    DeviceHelperRecordBegin = 10, //录音开始
    DeviceHelperRecordingTime = 11,  //录音时间，每接收满1秒产生1次事件 ： args1 NSNumber* 第几秒 （intValue）
    DeviceHelperRecordingData = 12,  //录音数据，每次返回400字节 : args1 NSData*
    DeviceHelperRecordPause = 13, //录音暂停
    DeviceHelperRecordEnd = 14, //录音结束，可以通过接口读取数据
     
    DeviceHelperPlayBegin = 20,    //播放开始
    DeviceHelperPlayingTime = 21,  //当前播放的时间进度： args1 NSNumber * （floatValue）
    DeviceHelperPlayEnd = 22,      //播放结束
    
};
 
typedef NS_ENUM(NSInteger, RECORD_MODE)
{
    RecordingUntilRecordDuration, //录音达到设定的录音时长才会结束，用户调用Api结束录音无效，如果有按键事件则暂停
    RecordingWithRecordDurationMaximum, //录音最多到设定的录音时长，用户调用Api结束或者有按键事件都会结束
    RecordingNoLimited1, //录音无限制，直到用户调用Api结束或按键事件才会结束
    RecordingNoLimited2, //录音无限制，有按键时间则暂停，用户调用Api结束才会结束
};

typedef NS_ENUM(NSInteger, PLAY_MODE)
{
    PlayingWithSettingData,  //播放设定的音频数据，有进度反馈
    PlayingWithRealtimeData,  //播放实时数据
};

@protocol HanhongDeviceHelperDelegate <NSObject>

-(void)on_device_helper_event:(DEVICE_HELPER_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2;

@end


@interface HanhongDeviceHelper : NSObject<DeviceEventDelegate, SearchDelegate>
{
    
}

@property (weak, nonatomic) id<HanhongDeviceHelperDelegate> deviceHelperEventDelegate;
  
//

-(BOOL)Search:(DEVICE_MODEL)model;
-(void)AbortSearch;
   
-(void)SetConnectRetryMax:(int)value;
-(BOOL)Connect:(NSString *)device;
-(CONNECT_STATE)ConnectState;
-(void)Disconnect;
 
-(NSString *)GetModelName;
-(DEVICE_MODEL)GetModel;
-(DEVICE_TYPE)GetType;

-(BOOL)GetAdvStartState;
-(void)SetAdvStartState:(BOOL)state;

-(int)GetAutoOffTime;
-(void)SetAutoOffTime:(int)time;

-(int)GetModeSeq;
-(void)SetModeSeq:(int)seq;

-(int)GetDefaultVolume;
-(void)SetDefaultVolume:(int)volume;

-(void)SetBatteryType:(BOOL) normal;
-(double)GetBatteryState;

-(NSString *)GetUniqueId;
-(NSString *)GetSerialNumber;
-(NSString *)GetProductionDate;
-(NSString *)GetFirmwareVersion;
-(NSString *)GetBootloaderVersion;
 
//
-(BOOL)SetRecordDuration:(int)duration;
-(void)StartRecord:(RECORD_TYPE)record_type record_mode:(RECORD_MODE)record_mode;

-(NSData *)GetRecordData;
-(NSData *)GetRecordFile;

-(void)SetPlayData:(NSData *)data;//
-(void)SetPlayFile:(NSData *)file_data;//播放  file_data：文件数据
-(void)SetPlayTimeRange:(float)start_time end_time:(float)end_time;
-(void)SetPlayRepeat:(BOOL)state;
-(void)StartPlay:(PLAY_MODE)play_mode;//play_mode 用第一个
-(void)WritePlayuffer:(NSData *)data;

-(void)Stop; 




@end


#endif /* HanhongDeviceHelper_h */
