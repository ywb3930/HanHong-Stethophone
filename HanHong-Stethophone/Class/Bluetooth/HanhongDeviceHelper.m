//
//  HanhongDeviceTool.m
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/29.
//
#import "HanhongDeviceHelper.h"
  
const int audiosize_per_second = 2 * 11025;
const int audiosample_per_second = 11025;

typedef NS_ENUM(NSInteger, RECORD_STATE)
{
    RecordStop = 0,
    RecordIng = 1,
    RecordPause = 2,
};

typedef NS_ENUM(NSInteger, PLAY_STATE)
{
    PlayStop = 0,
    PlayIng = 1,
    PlayPause = 2,
};
 
@implementation HanhongDeviceHelper 
{
    NSLock *cmd_lock;
    HanhongDevice *hanhongDevice;
    
    NSMutableArray *record_buffer;
    NSMutableArray *play_buffer;
    NSData *play_data;
    
    int recordDuration;  //录音时长
    int configRecordDuration;  //设置的录音时长
    
    float configPlayStartTime;
    float configPlayEndTime;
    float playStartTime;
    float playEndTime;
    float playTime;
    
    BOOL configPlayRepeat;
    BOOL playRepeat;
    
    int recordSecond;
     
    RECORD_TYPE recordType;
    RECORD_TYPE configRecordType;
    
    RECORD_MODE recordMode;
    RECORD_MODE configRecordMode;
    
    RECORD_STATE recordState; //录音状态
    
    PLAY_MODE playMode;
    PLAY_MODE configPlayMode;
    
    BOOL realtime_cmd_enabled;
    dispatch_block_t realtime_cmd;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        cmd_lock = [NSLock new];
        record_buffer = [NSMutableArray array];
        play_buffer = [NSMutableArray array];
        play_data = NULL;
        
        configPlayStartTime = 0;
        configPlayEndTime= 0;
        configPlayRepeat = false;
        
        hanhongDevice = [HanhongDevice new];
        hanhongDevice.deviceEventDelegate = self;
        hanhongDevice.searchDelegate = self;
        
        configRecordDuration = 15; //默认时长
    
        recordState = RecordStop;
        
        realtime_cmd = NULL;
    }
    
    return self;
}


-(BOOL)SetRecordDuration:(int)duration
{
    if (duration >= 5 && duration <= 120) {
        configRecordDuration = duration;
        return true;
    }
    
    return false;
}
     
-(void)DelayExcuteRealtimeCmd
{
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), realtime_cmd);
}

-(void)CancelRealtimeCmd
{
    if (realtime_cmd) {
        dispatch_block_cancel(realtime_cmd);
        realtime_cmd = nil;
    }
}

-(void)StartRecord:(RECORD_TYPE)record_type record_mode:(RECORD_MODE)record_mode
{
    [cmd_lock lock];
    
    realtime_cmd_enabled = false;
    [self CancelRealtimeCmd];
    
    [hanhongDevice RealtimeStop];
     
    configRecordMode = record_mode;
    configRecordType = record_type;
        
    realtime_cmd = dispatch_block_create(0, ^{
         
        [self->cmd_lock lock];
        
        if (self->realtime_cmd_enabled) {
            
            if (([self->hanhongDevice ConnectState] == DEVICE_CONNECTED)  && ([self->hanhongDevice GetType] == STETHOSCOPE)) {
                self->recordType = self->configRecordType;
                self->recordMode = self->configRecordMode;
                
                if (![self->hanhongDevice RealtimeStartRecord:self->recordType]) {
                    [self DelayExcuteRealtimeCmd];
                    NSLog(@"RealtimeStartRecod failed, busy delay retry");
                } else {
                    NSLog(@"RealtimeStartRecod success");
                }
            } else {
                NSLog(@"RealtimeStartRecod failed, device not ready or not stethoscope");
            }
        }
        [self->cmd_lock unlock];
    });
    
    realtime_cmd_enabled = true;
    [self DelayExcuteRealtimeCmd];
    
    [cmd_lock unlock];
}
-(NSData *)GetRecordData
{
    if (recordState == RecordStop) {
        if (recordSecond > 0) {
           
            //去掉整数时间以外的数据
            int seconds = (int)(record_buffer.count * 400 / audiosize_per_second);
            int size = seconds * audiosize_per_second;

            NSMutableData *audio_data = [NSMutableData dataWithLength:size]; //包含音频头文件

            if (size > 0) {

                int pos = 0;
                int len = 0;
                for (int i = 0; i < record_buffer.count - 1; i++) {
                    pos = i * 400;
                    len = 400;
                    [audio_data replaceBytesInRange:NSMakeRange(pos, len) withBytes:[[record_buffer objectAtIndex:i] bytes]];
                }

                int last_i = (int)record_buffer.count - 1;

                pos = last_i * 400;
                len = size - pos;
                [audio_data replaceBytesInRange:NSMakeRange(pos, len) withBytes:[[record_buffer objectAtIndex:last_i] bytes]];
            }
            
            NSData *ret_data = [NSData dataWithData:audio_data];
            
            audio_data = nil;
            
            return [NSData dataWithData:ret_data];
        }
    }
    
    return NULL;
}

-(NSData *)GetRecordFile
{
    NSData *audio_data = [self GetRecordData];
    
    if (audio_data == NULL) {
        return NULL;
    }
  
    NSMutableData *audio_file = [NSMutableData dataWithLength:audio_data.length + 44]; //包含音频头44字节
    
    [audio_file replaceBytesInRange:NSMakeRange(44, audio_data.length) withBytes:audio_data.bytes];
     
    [hanhongDevice GenerateWavFileHeader:(int)audio_data.length wav_file_header_buffer:audio_file];
    
    NSData *ret_data = [NSData dataWithData:audio_file];
    
    audio_file = nil;
    
    return [NSData dataWithData:ret_data];
}

-(void)SetPlayData:(NSData *)data
{
    [self->cmd_lock lock];
    
    play_data = [data copy];
    
    configPlayStartTime = 0;
    configPlayEndTime = (float)play_data.length / audiosize_per_second;
    
    [self->cmd_lock unlock];
}

-(void)SetPlayFile:(NSData *)file_data
{
    [self->cmd_lock lock];
    
    play_data = [file_data subdataWithRange:NSMakeRange(44, file_data.length - 44)]; //直接去掉头44字节（前提是我们自己录音的标准wav文件）
    
    configPlayStartTime = 0;
    configPlayEndTime = (float)play_data.length / audiosize_per_second;
    
    [self->cmd_lock unlock];
}

-(void)SetPlayTimeRange:(float)start_time end_time:(float)end_time
{
    if (!play_data)
        return;
    
    if (start_time < 0 || end_time < 0 || start_time >= end_time) {
        return;
    }
    
    [self->cmd_lock lock];
    
    float data_time = (float)self->play_data.length / audiosize_per_second;
 
    if (start_time > data_time) {
        configPlayStartTime = 0;
    } else {
        configPlayStartTime = start_time;
    }
    
    if (end_time > data_time) {
        configPlayEndTime = data_time;
    } else {
        configPlayEndTime = end_time;
    }
     
    [self->cmd_lock unlock];
}

-(void)SetPlayRepeat:(BOOL)state
{
    [self->cmd_lock lock];
    configPlayRepeat = state;
    [self->cmd_lock unlock];
}

-(void)StartPlay:(PLAY_MODE)play_mode
{
    if (play_data == NULL) {
        return;
    }
    
    [cmd_lock lock];
    
    realtime_cmd_enabled = false;
    [self CancelRealtimeCmd];
    
    [hanhongDevice RealtimeStop];
    
    configPlayMode = play_mode;
      
    realtime_cmd = dispatch_block_create(0, ^{
        
        [self->cmd_lock lock];
        
        if (self->realtime_cmd_enabled) {
            
            if ([self->hanhongDevice ConnectState] == DEVICE_CONNECTED) {
                self->playMode = self->configPlayMode;
                if (![self->hanhongDevice RealtimeStartPlay:(self->playMode == PlayingWithSettingData) ? false : true]) {
                    [self DelayExcuteRealtimeCmd];
                    NSLog(@"RealtimeStartPlay failed, busy delay retry");
                } else {
                      
                    if (self->playMode == PlayingWithSettingData) {
                        
                        //Prepare play data
                        self->playStartTime = self->configPlayStartTime;
                        self->playEndTime = self->configPlayEndTime;
                        self->playRepeat = self->configPlayRepeat;
                        
                        int start = (int) (self->playStartTime * audiosize_per_second);
                        int count = (int) ((self->playEndTime - self->playStartTime) * audiosize_per_second);
                        
                        if (start + count > self->play_data.length) {
                            count = (int)self->play_data.length - start;
                        }
                        
                        [self->play_buffer removeAllObjects];
                        
                        int packets = (count + 399) / 400;
                        
                        for (int i = 0; i < packets; i++) {
                            int ptr = start + i * 400;
                            int length = ((int)self->play_data.length - ptr) >= 400 ? 400 : (int)self->play_data.length - ptr;
                            NSData *packet = [NSData dataWithBytes:(self->play_data.bytes + ptr) length:length];
                            [self->play_buffer addObject:packet];
                        }
                    } else {
                        self->playStartTime = 0; //从0计时
                    }
                        
                    NSLog(@"RealtimeStartPlay success");
                }
            } else {
                NSLog(@"RealtimeStartPlay failed, device not ready");
            }
                
        }
        [self->cmd_lock unlock];
    });
    
    realtime_cmd_enabled = true;
    [self DelayExcuteRealtimeCmd];
    
    [cmd_lock unlock];
}

//异步的，真正结束时候会触发 DeviceHelperRecordEnd
-(void)Stop
{
    [cmd_lock lock];
    
    [self CancelRealtimeCmd];
    
    [hanhongDevice RealtimeStop];
    
    [cmd_lock unlock];
}

-(BOOL)IsRecordWithButton
{
    
    if ((recordType == RECORD_IMMEDIATELY) ||
        (recordType == RECORD_FULL_IMMEDIATELY) ||
        (recordType == RECORD_HEART_IMMEDIATELY) ||
        (recordType == RECORD_LUNG_IMMEDIATELY)) {
        return false;
    }
    
    return true;
}

-(BOOL)IsStopByButtonRecordOff
{
    if ((recordMode == RecordingWithRecordDurationMaximum) || (recordMode == RecordingNoLimited1)) {
        return true;
    }
    
    return false;
}

-(BOOL)IsRecordingWithRecordDuration
{
    if ((recordMode == RecordingWithRecordDurationMaximum) || (recordMode == RecordingUntilRecordDuration))
    {
        return true;
    }
    
    return false;
}

-(void)EventCallback:(DEVICE_HELPER_EVENT)event args1:(NSObject*)args1 args2:(NSObject*)args2
{
    if (self.deviceHelperEventDelegate) {
        [self.deviceHelperEventDelegate on_device_helper_event:event args1:args1 args2:args2];
    }
}

-(void)on_device_event:(DEVICE_EVENT)event args1:(NSObject*)args1 args2:(NSObject*)args2
{
    if (event == ReadyEvent) {
        
        [self EventCallback:DeviceConnected args1:NULL args2:NULL];
        
    } else if (event == RealtimeRecordBeginEvent) {
        
        [cmd_lock lock];
        
        recordDuration = configRecordDuration;
        recordSecond = 0;
        [record_buffer removeAllObjects];
        
        [cmd_lock unlock];
        
        [self EventCallback:DeviceHelperRecordReady args1:NULL args2:NULL];
        
        if (![self IsRecordWithButton]) {
            recordState = RecordIng;
            [self EventCallback:DeviceHelperRecordBegin args1:NULL args2:NULL];
        }
        
    } else if (event == RealtimeRecordOnEvent) {
             
        recordState = RecordIng;
        [self EventCallback:DeviceHelperRecordBegin args1:NULL args2:NULL];
      
    } else if (event == RealtimeRecordOffEvent) {
        
        if ([self IsStopByButtonRecordOff]) {
            [hanhongDevice RealtimeStop];
        } else {
            recordState = RecordPause;
            [self EventCallback:DeviceHelperRecordPause args1:NULL args2:NULL];
        }
        
    } else if (event == RealtimeRecordSyncEvent) {
       
        NSData *data = (NSData *)args1;
        BOOL data_used = false;
        
        if (recordState == RecordIng) {
           
            if ([self IsRecordingWithRecordDuration]) {
                
                if (record_buffer.count * 400 / audiosize_per_second < recordDuration) {
                    
                    data_used = true;
                    
                    [record_buffer addObject:data];
                    
                    [self EventCallback:DeviceHelperRecordingData args1:args1 args2:NULL];
                    
                    if (record_buffer.count * 400 / audiosize_per_second >= recordDuration) {
                        
                        [hanhongDevice RealtimeStop];
                        
                        recordSecond = recordDuration;
                        [self EventCallback:DeviceHelperRecordingTime args1:[NSNumber numberWithInt:recordSecond] args2:NULL];
                        
                    } else {
                        
                        //每一秒通知应用一次
                        int second = (int)(record_buffer.count * 400 / audiosize_per_second);
                        if ((second >= recordSecond + 1) || (record_buffer.count == 1)) {
                            recordSecond = second;
                            
                            [self EventCallback:DeviceHelperRecordingTime args1:[NSNumber numberWithInt:recordSecond] args2:NULL];
                            
                        }
                    }
                }
                
            } else {  //无录音时长限制
                
                data_used = true;
                
                [record_buffer addObject:data];
                
                [self EventCallback:DeviceHelperRecordingData args1:args1 args2:NULL];
                
                //每一秒通知应用一次
                int second = (int)(record_buffer.count * 400 / audiosize_per_second);
                if ((second >= recordSecond + 1) || (record_buffer.count == 1)) {
                    recordSecond = second;
                    
                    [self EventCallback:DeviceHelperRecordingTime args1:[NSNumber numberWithInt:recordSecond] args2:NULL];
                    
                }
            }
        }
        
        if (!data_used) { 
            data = nil;
        }
        
    } else if (event == RealtimeRecordEndEvent) {
        
        recordState = RecordStop;
        
        [self EventCallback:DeviceHelperRecordEnd args1:NULL args2:NULL];
         
    } else if (event == RealtimePlayBeginEvent) {
        
        float time;
        
        [cmd_lock lock];
        
        if (playMode == PlayingWithSettingData) {
            playTime = playStartTime;
            
            //Write data to play buffer
            for (NSData *packet in self->play_buffer) {
                [self->hanhongDevice RealtimePlayBufferWrite:packet];
            }
        } else {
            playTime = 0;
        }
        
        time = playTime;
        
        [cmd_lock unlock];
        
        [self EventCallback:DeviceHelperPlayBegin args1:NULL args2:NULL];
        
        [self EventCallback:DeviceHelperPlayingTime args1:@(time) args2:NULL];
         
    } else if (event == RealtimePlayBufferEmptyEvent) {
         
        BOOL repeat;
        
        [cmd_lock lock];
        
        playRepeat = configPlayRepeat;
        repeat = (playMode == PlayingWithSettingData) && playRepeat;
          
        if (repeat) {
            
            for (NSData *packet in play_buffer) {
                [hanhongDevice RealtimePlayBufferWrite:packet];
            }
            
            playTime = playStartTime;
             
        } else {
            [hanhongDevice RealtimeStop];
        }
        
        [cmd_lock unlock];
        
        if (repeat) {
            [self EventCallback:DeviceHelperPlayingTime args1:@(playTime) args2:NULL];
        }
        
    } else if (event == RealtimePlayBufferSyncEvent) {
        
        int sync_sample_count = [(NSNumber *)args1 intValue];
        playTime += (float) sync_sample_count / audiosample_per_second;
        
        [self EventCallback:DeviceHelperPlayingTime args1:@(self->playTime) args2:NULL];
        
    } else if (event == RealtimePlayEndEvent) {
        
        if (playMode == PlayingWithSettingData) {
            [self EventCallback:DeviceHelperPlayingTime args1:@(self->playEndTime) args2:NULL];
        }
        
        [self EventCallback:DeviceHelperPlayEnd args1:NULL args2:NULL];
        
    } else if (event == DisconnectedEvent) {
        
        if (recordState == RecordIng) {
            recordState = RecordPause;
            [self EventCallback:DeviceHelperRecordPause args1:NULL args2:NULL];
        }
        
        [self EventCallback:DeviceDisconnected args1:NULL args2:NULL];
        
    } else if (event == ReadyEvent) {
        
        [self EventCallback:DeviceConnected args1:NULL args2:NULL];
        
        if (recordState == RecordPause) {
            
            if (![self IsRecordWithButton]) {
                recordState = RecordIng;
            }
            
        }
    } else if (event == ConnectingEvent) {
        
        [self EventCallback:DeviceConnecting args1:NULL args2:NULL];
        
    }
}
 
-(BOOL)Search:(DEVICE_MODEL)model{
    return [hanhongDevice Search:model];
}

-(void)AbortSearch{
    return [hanhongDevice AbortSearch];
}

-(void)onSearchStart{
    [self EventCallback:SearchStart args1:NULL args2:NULL];
}

- (void)onSearchFinished{
    [self EventCallback:SearchEnd args1:NULL args2:NULL];
}

- (void)onSearchFound:(NSString *)device_name device_mac:(NSString *)device_mac{
    [self EventCallback:SearchFound args1:device_name args2:device_mac];
}

-(void)SetConnectRetryMax:(int)value
{
    [hanhongDevice SetConnectRetryMax:value];
}

-(BOOL)Connect:(NSString *)device{
    return [hanhongDevice Connect:device];
}

-(CONNECT_STATE)ConnectState{
    return [hanhongDevice ConnectState];
}

-(void)Disconnect{
    [hanhongDevice Disconnect];
}

-(NSString *)GetModelName{
    return [hanhongDevice GetModelName];
}

-(DEVICE_MODEL)GetModel{
    return [hanhongDevice GetModel];
}

-(DEVICE_TYPE)GetType{
    return [hanhongDevice GetType];
}
 
-(BOOL)GetAdvStartState{
    return [hanhongDevice GetAdvStartState];
}

-(void)SetAdvStartState:(BOOL)state{
    [hanhongDevice SetAdvStartState:state];
}

-(int)GetAutoOffTime{
    return [hanhongDevice GetAutoOffTime];
}

-(void)SetAutoOffTime:(int)time{
    [hanhongDevice SetAutoOffTime:time];
}

-(int)GetModeSeq{
    return [hanhongDevice GetModeSeq];
}

-(void)SetModeSeq:(int)seq {
    [hanhongDevice SetModeSeq:seq];
}

-(int)GetDefaultVolume{
    return [hanhongDevice GetDefaultVolume];
}

-(void)SetDefaultVolume:(int)volume{
    [hanhongDevice SetDefaultVolume:volume];
}

-(void)SetBatteryType:(BOOL) normal{
    [hanhongDevice SetBatteryType:normal];
}

-(double)GetBatteryState{
   return [hanhongDevice GetBatteryState];
}

-(NSString *)GetUniqueId{
    return [hanhongDevice GetUniqueId];
}

-(NSString *)GetSerialNumber{
    return [hanhongDevice GetSerialNumber];
}

-(NSString *)GetProductionDate{
    return [hanhongDevice GetProductionDate];
}

-(NSString *)GetFirmwareVersion{
    return [hanhongDevice GetFirmwareVersion];
}

-(NSString *)GetBootloaderVersion{
    return [hanhongDevice GetBootloaderVersion];
}


@end

