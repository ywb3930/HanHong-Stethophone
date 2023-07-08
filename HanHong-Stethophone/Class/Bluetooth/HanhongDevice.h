//
//  HanhongDevice.h
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/19.
//

#ifndef HanhongDevice_h
#define HanhongDevice_h
  
#import <Foundation/Foundation.h>
#import "BluetoothHelper.h"


typedef NS_ENUM(NSInteger, DEVICE_EVENT) {
    
    ConnectionBeginEvent = 0,
    AdapterNotValidEvent = 1,
    ConnectingEvent = 2,
    ConnectFailEvent = 3,
    ConnectedEvent = 4,
    TestDevErrorEvent = 5,
    StandbyEvent = 6,
    BusyEvent = 7,
    BootloaderEvent = 8,
    ModelNotSupportEvent = 9,
    VersionNotSupportEvent = 10,
    UserLoginErrorEvent = 11,
    ReadyEvent = 12,
    TransferErrorEvent = 13,
    DisconnectedEvent = 14,
    ConnectionEndEvent = 15,


    RealtimePlayBeginEvent = 19,
    RealtimePlayStartEvent = 20,
    RealtimePlaySyncEvent = 21,
    RealtimePlayInstableEvent = 22,
    RealtimePlayBufferEmptyEvent = 23,
    RealtimePlayBufferSyncEvent = 24,
    RealtimePlayStopEvent = 25,
    RealtimePlayEndEvent = 26,

    RealtimeRecordBeginEvent = 27,
    RealtimeRecordStartEvent = 28,
    RealtimeRecordResetEvent = 29,
    RealtimeRecordSyncEvent = 30,
    RealtimeRecordInstableEvent = 31,
    RealtimeRecordLostEvent = 32,
    RealtimeRecordOnEvent = 33,
    RealtimeRecordOffEvent = 34,
    RealtimeRecordStopEvent = 35,
    RealtimeRecordEndEvent = 36,
    
    LogEvent = 100,
};

typedef NS_ENUM(NSInteger, DEVICE_TYPE)
{
    UNKNOW_TYPE,
    STETHOSCOPE,
    EARPHONE
};

typedef NS_ENUM(NSInteger, DEVICE_MODEL)
{
    UNKNOW_MODEL,
    ALL_MODEL,
    POPULAR3,
    POP3
};

typedef NS_ENUM(NSInteger, RECORD_TYPE)
{
    RECORD_IMMEDIATELY,  //不带按键事件

    RECORD_FULL_IMMEDIATELY,
    RECORD_HEART_IMMEDIATELY,
    RECORD_LUNG_IMMEDIATELY,
    RECORD_WITH_BUTTON,  //带按键事件

    RECORD_FULL_WITH_BUTTON,
    RECORD_HEART_WITH_BUTTON,
    RECORD_LUNG_WITH_BUTTON,
};

extern NSString *const POPULAR3_btName;
extern NSString *const POP3_btName;

typedef NS_ENUM(NSInteger, CONNECT_STATE){
    DEVICE_NOT_CONNECT,  //未连接
    DEVICE_CONNECTED,  //已连接
    DEVICE_CONNECTING,  //连接中
};

@protocol DeviceEventDelegate <NSObject>

-(void)on_device_event:(DEVICE_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2;

@end

@interface HanhongDevice : NSObject{
    
    
    
}
   
@property (weak, nonatomic) id<SearchDelegate> searchDelegate;
 
-(BOOL)Search:(DEVICE_MODEL)model;
-(void)AbortSearch;
 
@property (weak, nonatomic) id<DeviceEventDelegate> deviceEventDelegate;
 
-(void)SetConnectRetryMax:(int)value;
-(BOOL)Connect:(NSString *)device;
-(CONNECT_STATE)ConnectState;
-(void)Disconnect;

-(BOOL)ConnectRunning;
-(BOOL)Connected;
-(BOOL)Ready;
-(BOOL)RealtimePlayRunning;
-(BOOL)RealtimeRecordRunning;
-(BOOL)Running;

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
-(NSString *)GetMac;
 

-(BOOL)RealtimeStartPlay:(BOOL)enable_realtimeplay_delay_limit;
-(void)RealtimePlayBufferWrite:(NSData *)pcm_data_pack;
-(void)RealtimePlayBufferClear;
-(long)RealtimePlayBufferLength;

-(BOOL)RealtimeStartRecord:(RECORD_TYPE)type;

-(void)RealtimeStop;
 
-(void)GenerateWavFileHeader:(int)pcm_data_size wav_file_header_buffer:(NSMutableData *)wav_file_header_buffer;


@end

#endif /* HanhongDevice_h */
