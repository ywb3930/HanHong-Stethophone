//
//  HanhongDevice.m
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/19.
//

#import "HanhongDevice.h"

NSString *const POPULAR3_btName = @"POPULAR-3";
NSString *const POP3_btName = @"POP-3";
 
@implementation HanhongDevice
{
    
    NSLock * mutex;
    BluetoothHelper *bt_helper;
    
    NSString *bluetooth_device;
    NSString *bluetooth_device_new;
    
    BOOL thread_enable;
    
    int connect_fail_retry;
    BOOL connect_enabled;
    BOOL connected;
    BOOL ready;
    
    DEVICE_TYPE device_type;
    DEVICE_MODEL device_model;
    
    BOOL connection_running;
    BOOL realtimeplay_running;
    BOOL realtimerecord_running;
    
    NSString *password;
    NSString *unique_id;
    NSString *serial_number;
    NSString *production_date;
    
    float battery;
    
    NSString *hardware_version;
    
    NSString *bootloader_version;
    NSNumber *bootloader;
    
    NSString *firmware_version;
    NSNumber *firmware;
    
    BOOL adv_start_on;
    BOOL new_adv_start_on;
    
    int auto_off_time;
    int new_auto_off_time;
    
    int mode_seq;
    int new_mode_seq;
    
    int default_volume;
    int new_default_volume;
    
    BOOL battery_type_normal;
    
    NSThread *thread_connect;
    
    NSThread *thread_realtimeplay;
    __block BOOL is_thread_realtimeplay_finished;
    NSCondition *condition_thread_realtimeplay;
    
    NSThread *thread_realtimerecord;
    __block BOOL is_thread_realtimerecord_finished;
    NSCondition *condition_thread_realtimerecord;
    
    int volume;
    int new_volume;
    
    BOOL realtimeplay_enable;
    BOOL realtimeplay_enabled;
    
    BOOL realtimeplay_ready;
    BOOL realtimeplay_delay_limit;
    
    int realtimeplay_delay_max;
    
    NSMutableArray *realtimeplay_data_buffer;
    NSLock *realtimeplay_data_buffer_mutex;
    
    int buffer_sync_times;
    int buffer_sync_time;
    
    RECORD_TYPE realtimerecord_type;
    
    BOOL realtimerecord_enable;
    BOOL realtimerecord_enabled;
    BOOL realtimerecord_ready;
    
}

-(instancetype)init{
    self = [super init];
    if (self) {
         
        mutex = [NSLock new];
        
        bt_helper = [[BluetoothHelper alloc] init];
        
        bluetooth_device = @"";
        bluetooth_device_new =@"";
        
        connect_fail_retry = 3;
        connect_enabled = false;
        connected = false;
        ready = false;
        
        device_type = UNKNOW_TYPE;
        device_model = UNKNOW_MODEL;
        
        connection_running = false;
        realtimeplay_running = false;
        realtimerecord_running = false;
        
        password = @"0000";
        
        unique_id = @"000000000000000000000000";
        
        serial_number = @"00000000000000000";
        
        production_date = @"00000000";
        
        battery = 0;
        
        hardware_version = @"";
        
        bootloader_version = @"";
        bootloader = 0;
        
        firmware_version = @"";
        firmware = 0;
        
        adv_start_on = false;
        new_adv_start_on = false;
        
        auto_off_time = 0;
        new_auto_off_time = 0;
        
        mode_seq = 1;
        new_mode_seq = 1;
        
        default_volume = 1;
        new_default_volume = 1;
        
        battery_type_normal = true;
        
        thread_realtimeplay = NULL;
        condition_thread_realtimeplay = [[NSCondition alloc] init];
        is_thread_realtimeplay_finished = NO;
        
        thread_realtimerecord = NULL;
        condition_thread_realtimerecord = [[NSCondition alloc] init];
        is_thread_realtimerecord_finished = NO;
        
        volume = 6;
        new_volume = 6;
        
        realtimeplay_enable = false;
        realtimeplay_enabled = false;
        
        realtimeplay_ready = false;
        realtimeplay_delay_limit = false;
        
        realtimeplay_delay_max = 11025 / 2 / 200; //about 500ms
        
        realtimeplay_data_buffer = [NSMutableArray array];
        realtimeplay_data_buffer_mutex = [NSLock new];
        
        buffer_sync_times = 12;
        buffer_sync_time = 2;
        
        realtimerecord_type = RECORD_WITH_BUTTON;
        
        realtimerecord_enable = false;
        realtimerecord_enabled = false;
        realtimerecord_ready = false;
        
        //Create connection thread
        thread_enable = true;
        
        thread_connect = [[NSThread alloc] initWithTarget:self selector:@selector(ConnectThread) object:nil];
        [thread_connect start];
    }
    return self;
}


- (void)setSearchDelegate:(id<SearchDelegate>)searchDelegate
{
    bt_helper.searchDelegate = searchDelegate;
}


-(NSString *)GetModelName {
    switch (device_model) {
        case POPULAR3:
            return POPULAR3_btName;
        case POP3:
            return POP3_btName;
        default:
            return @"UNKNOW";
    }
}

-(DEVICE_MODEL)GetModel {
    return device_model;
}

-(DEVICE_TYPE)GetType{
    return device_type;
}

-(BOOL)GetAdvStartState{
    return adv_start_on;
}

-(void)SetAdvStartState:(BOOL)state
{
    new_adv_start_on = state;
}

-(int)GetAutoOffTime{
    return auto_off_time;
}

-(void)SetAutoOffTime:(int)time{
    new_auto_off_time = time;
}

-(int)GetModeSeq{
    return mode_seq;
}

-(void)SetModeSeq:(int)seq{
    new_mode_seq = seq;
}

-(int)GetDefaultVolume{
    return default_volume;
}

-(void)SetDefaultVolume:(int)volume
{
    new_default_volume = volume;
}

-(void)SetBatteryType:(BOOL) normal
{
    battery_type_normal = normal;
}

//获取电池电量，0~100 ，在Running状态下(实时录音、实时播放等等），电池电量不会更新
-(double)GetBatteryState
{
    if (device_model == POPULAR3) {
        
        if (battery_type_normal) {
            if (battery > 3.2) {
                return 100.0;
            } else if (battery <= 2) {
                return 0;
            } else {
                return (double) ((battery - 2) * 100 / (3.2 - 2));
            }
        } else {
            if (battery > 3) {
                return 100.0;
            } else if (battery <= 2) {
                return 0;
            } else {
                return (double) ((battery - 2) * 100 / (3 - 2));
            }
        }
    } else {
        if (battery > 4.15) {
            return 100.0;
        } else if (battery <= 3.4) {
            return 0;
        } else {
            return (double) ((battery - 3.4) * 100 / (4.15 - 3.4));
        }
    }
}

-(NSString *)GetUniqueId{
    return unique_id;
}

-(NSString *)GetSerialNumber{
    return serial_number;
}

-(NSString *)GetProductionDate{
    return production_date;
}

-(NSString *)GetFirmwareVersion{
    return firmware_version;
}

-(NSString *)GetBootloaderVersion{
    return bootloader_version;
}

-(BOOL)ConnectRunning{
    return connection_running;
}

-(BOOL)Connected{
    return connected;
}

-(CONNECT_STATE)ConnectState{
    if (!connect_enabled || [bluetooth_device_new isEqualToString:@""]) {
        return DEVICE_NOT_CONNECT;
    } else if (![self Ready]) {
        return DEVICE_CONNECTING;
    } else {
        return DEVICE_CONNECTED;
    }
}

//返回设备就绪状态
-(BOOL)Ready{
    return ready;
}

-(BOOL)RealtimePlayRunning
{
    return realtimeplay_running;
}

-(BOOL)RealtimeRecordRunning
{
    return realtimerecord_running;
}

-(BOOL)Running{
    return (connection_running ? (realtimerecord_enabled || realtimerecord_running || realtimeplay_enabled || realtimeplay_running) : false);
}

-(BOOL)Search:(DEVICE_MODEL)model
{
    if (model == ALL_MODEL) {
        return [bt_helper Search:@[@"POPULAR-3", @"POP-3"]];
    } else {
        if (model == POPULAR3) {
            return [bt_helper Search:@[@"POPULAR-3"]];
        } else if (model == POP3) {
            return [bt_helper Search:@[@"POP-3"]];
        } else {
            return false;
        }
    }
}

-(void)AbortSearch{
    [bt_helper AbortSearch];
}
  
//设备连接断开会自动重连，用这个函数可以设置重试次数，设置为0为无限次。
-(void)SetConnectRetryMax:(int)value
{
    if (value > 0) {
        connect_fail_retry = value;
    } else {
        connect_fail_retry = 0;
    }
}
  
-(BOOL)Connect:(NSString *)device {
    if (device) {
        if (![device isEqualToString:bluetooth_device_new]) {
            bluetooth_device_new = [device copy];
            return true;
        }
    }
    return false;
}

-(void)Disconnect{
    bluetooth_device_new = @"";
    [thread_connect cancel];
}
 
-(float)matchBattery:(NSString *)line
{
    float value;
    
    NSString *lowerline = [line lowercaseString];
    
    NSString * reg = @"voltage (\\d+\\.?\\d*)v";    // 转换电池电压
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:lowerline options:0 range:NSMakeRange(0, lowerline.length)];
    
    if (match.numberOfRanges >= 2) {
        NSRange range = [match rangeAtIndex:1];
        NSString *result = [lowerline substringWithRange:range];
        @try {
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            NSNumber *number = [formatter numberFromString:result];
            
            if (number != nil) {
                value = [number floatValue];
            }
            
        } @catch (NSException * ex) {
            value = 0;
        }
    } else {
        value = 0;
    }
    
    return value;
}

-(int)matchAutoOffTime:(NSString *)line
{
    int value;
    
    NSString *lowerline = [line lowercaseString];
    
    NSString * reg = @"autoofftime (\\d*)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:lowerline options:0 range:NSMakeRange(0, lowerline.length)];
    
    if (match.numberOfRanges >= 2) {
        NSRange range = [match rangeAtIndex:1];
        NSString *result = [lowerline substringWithRange:range];
        @try {
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            NSNumber *number = [formatter numberFromString:result];
            
            if (number != nil) {
                value = [number intValue];
            }
            
        } @catch (NSException * ex) {
            value = 0;
        }
    }
    
    return value;
    
}

-(int)matchModeSeq:(NSString *)line
{
    int value;
    
    NSString *lowerline = [line lowercaseString];
    
    NSString * reg = @"modeseq (\\d*)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:lowerline options:0 range:NSMakeRange(0, lowerline.length)];
    
    if (match.numberOfRanges >= 2) {
        NSRange range = [match rangeAtIndex:1];
        NSString *result = [lowerline substringWithRange:range];
        @try {
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            NSNumber *number = [formatter numberFromString:result];
            
            if (number != nil) {
                value = [number intValue];
            }
            
        } @catch (NSException * ex) {
            value = 0;
        }
    } else {
        value = 0;
    }
    
    return value;
    
}

-(int)matchDefaultVolume:(NSString *)line
{
    int value;
    
    NSString *lowerline = [line lowercaseString];
    
    NSString * reg = @"defaultvolume (\\d*)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:lowerline options:0 range:NSMakeRange(0, lowerline.length)];
    
    if (match.numberOfRanges >= 2) {
        NSRange range = [match rangeAtIndex:1];
        NSString *result = [lowerline substringWithRange:range];
        @try {
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            NSNumber *number = [formatter numberFromString:result];
            
            if (number != nil) {
                value = [number intValue];
            }
            
        } @catch (NSException * ex) {
            value = 0;
        }
    } else {
        value = 0;
    }
    
    return value;
    
}

-(NSString *)matchUniqueId:(NSString *)line
{
    NSString * reg = @"(\\S{24})\r";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
    
    if (match.numberOfRanges >= 2) {
        NSRange range = [match rangeAtIndex:1];
        return [line substringWithRange:range];
    } else {
        return @"000000000000000000000000";
    }
}

-(NSArray *)matchSerialNumberAndProductionDate:(NSString *)line
{
    NSString *lowerline = [line lowercaseString];
    NSString *sn;
    NSString *date;
    
    NSString * reg = @"serial number (\\S{17})\\s*,\\s*production date (\\S{8})\r";    // 转换电池电压
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:lowerline options:0 range:NSMakeRange(0, lowerline.length)];
    
    if (match.numberOfRanges >= 3) {
        NSRange range_sn = [match rangeAtIndex:1];
        sn = [lowerline substringWithRange:range_sn];
        NSRange range_date = [match rangeAtIndex:2];
        date = [lowerline substringWithRange:range_date];
    } else {
        sn = @"00000000000000000";
        date = @"00000000";
    }
    return @[sn, date];
}
  
-(NSArray *)matchVersion:(NSString *)line
{
    NSString *lowerline = [line lowercaseString];
    NSString *hv;
    NSString *bv;
    NSString *fv;
    NSNumber *b;
    NSNumber *f;
    
    NSString * reg = @"hardware v(\\d+), bootloader v(\\d+\\.\\d+), firmware v\\d+\\.(\\d+\\.\\d+)";    // 转换电池电压
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:lowerline options:0 range:NSMakeRange(0, lowerline.length)];
    
    if (match.numberOfRanges >= 4) {
        NSRange range_hv = [match rangeAtIndex:1];
        hv = [lowerline substringWithRange:range_hv];
        NSRange range_bv = [match rangeAtIndex:2];
        bv = [lowerline substringWithRange:range_bv];
        NSRange range_fv = [match rangeAtIndex:3];
        fv = [lowerline substringWithRange:range_fv];
          
        @try {
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            NSNumber *number = [formatter numberFromString:fv];
            
            if (number != nil) {
                f = number;
            }
            
        } @catch (NSException * ex) {
            NSLog(@"Match Version f Error");
            @throw [NSException exceptionWithName:@"HanhongDevice" reason:@"Match Version f Error" userInfo:nil];
        }
        
        @try {
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            NSNumber *number = [formatter numberFromString:bv];
            
            if (number != nil) {
                b = number;
            }
            
        } @catch (NSException * ex) {
            NSLog(@"Match Version b Error");
            @throw [NSException exceptionWithName:@"HanhongDevice" reason:@"Match Version b Error" userInfo:nil];
        }
        
    } else {
        NSLog(@"Match Version Error");
        @throw [NSException exceptionWithName:@"HanhongDevice" reason:@"" userInfo:nil];
    }
    
    return @[hv, bv, [NSString stringWithFormat:@"V%@.%@", hv, fv], b, f];
}

-(void)Callback:(DEVICE_EVENT)event args1:(NSObject*)args1 args2:(NSObject*)args2 {
    @try {
        if (self.deviceEventDelegate) {
            [self.deviceEventDelegate on_device_event:event args1:args1 args2:args2];
        }
    } @catch (NSException *exception) {
        NSLog(@"event_callback error %@ %@", exception.name, exception.reason);
    }
}

-(void)ConnectThread{
    
    while (thread_enable) {

        while (thread_enable && (!connect_enabled)) {

            @try {
                [NSThread sleepForTimeInterval:0.1];
            }
            @catch (NSException *exception) {

            }

            if (thread_realtimeplay != NULL) {
                @try {
                    //等待线程退出
                    [condition_thread_realtimeplay lock];
                    while (!is_thread_realtimeplay_finished) {
                        [condition_thread_realtimeplay wait];
                    }
                    [condition_thread_realtimeplay unlock];
                }
                @catch (NSException *exception) {

                }
            }

            if (thread_realtimerecord != NULL) {
                @try {
                    //等待线程退出
                    [condition_thread_realtimerecord lock];
                    while (!is_thread_realtimerecord_finished) {
                        [condition_thread_realtimerecord wait];
                    }
                    [condition_thread_realtimerecord unlock];
                }
                @catch (NSException *exception) {

                }
            }
            if (![bluetooth_device_new isEqualToString:bluetooth_device]) {
                bluetooth_device = [bluetooth_device_new copy];
                if (![bluetooth_device isEqualToString:@""]) {
                    connect_enabled = true;
                    connection_running = true;
                }
            }
        }

        int connect_retry = 0;
        NSString *line;
        
        [self Callback:ConnectionBeginEvent args1:NULL args2:NULL];
    
        while (thread_enable && connect_enabled) {

            [mutex lock];

            if (connected && ready) {

                @try {

                    if (![bluetooth_device_new isEqualToString:bluetooth_device]) {
                        connect_enabled = false; //close the connection
                        @throw [NSException exceptionWithName:@"HanhongDevice" reason:@"" userInfo:nil];
                    }

                    //battery voltage
                    [bt_helper WriteStr:@"battery\r"];
                    line = [bt_helper ReadLine:true];
                    battery = [self matchBattery:line];
                      
                    //auto off time
                    [bt_helper WriteStr:@"AutoOffTime?\r"];
                    line = [bt_helper ReadLine:true];
                    auto_off_time = [self matchAutoOffTime:line];
                     
                    if (new_auto_off_time != auto_off_time) {
                        
                        NSString *auto_off_cmd = [NSString stringWithFormat:@"AutoOffTime %d\r", new_auto_off_time];
                        [bt_helper WriteStr:auto_off_cmd];
                        line = [bt_helper ReadLine:true];
                        auto_off_time = new_auto_off_time;
                    }
                     
                    if (device_model == POPULAR3) {
                        
                        //advstarton
                        [bt_helper WriteStr:@"AdvStartOn?\r"];
                        line = [bt_helper ReadLine:true];
                        if ([line containsString:@"=1"]) {
                            adv_start_on = true;
                        } else {
                            adv_start_on = false;
                        }

                        if (new_adv_start_on != adv_start_on) {
                            
                            NSString *adv_cmd = [NSString stringWithFormat:@"AdvStartOn=%@\r", new_adv_start_on ? @"1" : @"0"];
                            [bt_helper WriteStr:adv_cmd];
                            line = [bt_helper ReadLine:true];
                            adv_start_on = new_adv_start_on;
                        }

                        if ([firmware floatValue] > 1.1f) { //1.2版本以上增加的指令
                            
                            //set Mode Seq
                            [bt_helper WriteStr:@"ModeSeq?\r"];
                            line = [bt_helper ReadLine:true];
                            mode_seq = [self matchModeSeq:line];

                            if (new_mode_seq != mode_seq) {
                                NSString *mode_seq_cmd = [NSString stringWithFormat:@"ModeSeq %d\r", new_mode_seq];
                                [bt_helper WriteStr:mode_seq_cmd];
                                line = [bt_helper ReadLine:true];
                                mode_seq = new_mode_seq;
                            }
                        }

                        if ([firmware floatValue] > 1.2f) { //1.3版本以上增加的指令

                            [bt_helper WriteStr:@"DefaultVolume?\r"];
                            line = [bt_helper ReadLine:true];
                            default_volume = [self matchAutoOffTime:line];

                            if (new_default_volume != default_volume) {
                                
                                NSString *default_volume_cmd = [NSString stringWithFormat:@"DefaultVolume %d\r", new_default_volume];
                                [bt_helper WriteStr:default_volume_cmd];
                                line = [bt_helper ReadLine:true];
                                default_volume = new_default_volume;
                            }
                        }

                    }
                    
                }
                
                @catch (NSException *e) {

                    //bluetooth exception
                    [bt_helper Disconnect];

                    ready = false;
                    connected = false;

                    battery = 0;
                    [self Callback:DisconnectedEvent args1:NULL args2:NULL];
                }
            }

            if (!connected && [bluetooth_device_new isEqualToString:bluetooth_device]) {
                ready = false;

                if (![bt_helper CheckAdapter]) {
                    connect_enabled = false;
                    if ([bluetooth_device_new isEqualToString:bluetooth_device]) {
                        bluetooth_device_new = @"";
                        bluetooth_device = @"";
                    }
                   [self Callback:AdapterNotValidEvent args1:NULL args2:NULL];
                } else {
                   [self Callback:ConnectingEvent args1:NULL args2:NULL];

                    if ([bt_helper Connect:bluetooth_device]) {
                        connect_retry = 0;
                        connected = true;
                        [self Callback:ConnectedEvent args1:NULL args2:NULL];
                    } else {
                        //如果地址改变了，返回重新连接
                        if (![bluetooth_device_new isEqualToString:bluetooth_device]) {
                            connect_enabled = false;
                        } else {
                            if (connect_fail_retry > 0) {
                                if (connect_retry++ == connect_fail_retry) {
                                    if (connect_enabled) {
                                        connect_enabled = false;
                                        if ([bluetooth_device_new isEqualToString:bluetooth_device]) {
                                            bluetooth_device_new = @"";
                                            bluetooth_device = @"";
                                        }
                                        [self Callback:ConnectFailEvent args1:NULL args2:NULL];
                                    }
                                }
                            } else {
                                //不断重试
                            }
                        }
                    }
                }
                
            } else {
                @try {
                    if (![bluetooth_device_new isEqualToString:bluetooth_device]) {
                        connect_enabled = false; //close the connection
                        @throw [NSException exceptionWithName:@"HanhongDevice" reason:@"" userInfo:nil];
                    }
                    //check device state
                    [bt_helper WriteStr:@"testdev\r"];
                    line = [bt_helper ReadLine:true];
                    line = [line lowercaseString];
 
                    if ([line containsString:@"ready"]) {
                        if (!ready) {
                            //device information reading

                            //model name
                            [bt_helper WriteStr:@"model\r"];
                            line = [bt_helper ReadLine:true];
                            BOOL model_support = false;
                            
                            if ([line containsString:@"POPULAR-3"]) {
                                device_model = POPULAR3;
                                device_type = STETHOSCOPE;
                                model_support = true;
                            } else if ([line containsString:@"POP-3"]) {
                                device_model = POP3;
                                device_type = EARPHONE;
                                model_support = true;
                            } else {
                                device_model = UNKNOW_MODEL;
                            }
                            if (!model_support) {
                                
                                [self Callback:ModelNotSupportEvent args1:NULL args2:NULL];
                                connect_enabled = false; //close the connection
                                if ([bluetooth_device_new isEqualToString:bluetooth_device]) {
                                    bluetooth_device_new = @"";
                                    bluetooth_device = @"";
                                }
                                @throw [NSException exceptionWithName:@"HanhongDevice" reason:@"" userInfo:nil];
                            }

                            //unique id
                            [bt_helper WriteStr:@"uniqueid\r"];
                            line = [bt_helper ReadLine:true];
                            unique_id = [self matchUniqueId:line];

                            //serial number
                            [bt_helper WriteStr:@"readfactorynumber\r"];
                            line = [bt_helper ReadLine:true];

                            NSArray *sn_date_arr = [self matchSerialNumberAndProductionDate:line];
                            serial_number = sn_date_arr[0];
                            production_date = sn_date_arr[1];
                            
                            //battery voltage
                            [bt_helper WriteStr:@"battery\r"];
                            line = [bt_helper ReadLine:true];
                            battery = [self matchBattery:line];

                            //version
                            [bt_helper WriteStr:@"version\r"];
                            line = [bt_helper ReadLine:true];
                            NSArray *version =[self matchVersion:line];
                            hardware_version = version[0];
                            bootloader_version = version[1];
                            firmware_version = version[2];
                            bootloader = version[3];
                            firmware = version[4];
                            
                            if (device_model == POPULAR3) {
                                
                                //authentication
                                NSString *login_cmd = [NSString stringWithFormat:@"userlogin %@\r", password];
                                [bt_helper WriteStr:login_cmd];
                                line = [bt_helper ReadLine:true];
                                if (![line containsString:@"OK"]) {
                                    
                                    [self Callback:UserLoginErrorEvent args1:NULL args2:NULL];
                                    connect_enabled = false; //close the connection
                                    if ([bluetooth_device_new isEqualToString:bluetooth_device]) {
                                        bluetooth_device_new = @"";
                                        bluetooth_device = @"";
                                    }
                                    @throw [NSException exceptionWithName:@"HanhongDevice" reason:@"" userInfo:nil];
                                }

                                //advstarton
                                [bt_helper WriteStr:@"AdvStartOn?\r"];
                                line = [bt_helper ReadLine:true];
                                line = [line lowercaseString];
                                if ([line containsString:@"=1"]) {
                                    new_adv_start_on = adv_start_on = true;
                                } else {
                                    new_adv_start_on = adv_start_on = false;
                                }

                                //auto off time
                                [bt_helper WriteStr:@"AutoOffTime?\r"];
                                line = [bt_helper ReadLine:true];
                                new_auto_off_time = auto_off_time = [self matchAutoOffTime:line];
                                
                                if ([firmware floatValue] > 1.1f) { //1.2版本以上增加的指令
                                    //Mode Seq
                                    [bt_helper WriteStr:@"ModeSeq?\r"];
                                    line = [bt_helper ReadLine:true];
                                    new_mode_seq = mode_seq = [self matchModeSeq:line];
                                }

                                if ([firmware floatValue] > 1.2f) {

                                    [bt_helper WriteStr:@"DefaultVolume?\r"];
                                    line = [bt_helper ReadLine:true];
                                    new_default_volume = default_volume = [self matchDefaultVolume:line];
                                }

                            } else if (device_model == POP3) {
                                
                                //authentication
                                NSString *login_cmd = [NSString stringWithFormat:@"userlogin %@\r", password];
                                [bt_helper WriteStr:login_cmd];
                                line = [bt_helper ReadLine:true];
                                if (![line containsString:@"OK"]) {
                                    
                                    [self Callback:UserLoginErrorEvent args1:NULL args2:NULL];
                                    connect_enabled = false; //close the connection
                                    if ([bluetooth_device_new isEqualToString:bluetooth_device]) {
                                        bluetooth_device_new = @"";
                                        bluetooth_device = @"";
                                    }
                                    @throw [NSException exceptionWithName:@"HanhongDevice" reason:@"" userInfo:nil];
                                }

                                //auto off time
                                [bt_helper WriteStr:@"AutoOffTime?\r"];
                                line = [bt_helper ReadLine:true];
                                new_auto_off_time = auto_off_time = [self matchAutoOffTime:line];
                            }

                            ready = true;

                            //运行线程
                            if (thread_realtimeplay == NULL) {
                                thread_realtimeplay = [[NSThread alloc] initWithTarget:self selector:@selector(RealtimePlayThread) object:nil];
                                [thread_realtimeplay start];
                            }

                            if (device_type == STETHOSCOPE) {
                                if (thread_realtimerecord == NULL) {
                                    thread_realtimerecord = [[NSThread alloc] initWithTarget:self selector:@selector(RealtimeRecordThread) object:nil];
                                    [thread_realtimerecord start];
                                }
                            }

                            
                            [self Callback:ReadyEvent args1:NULL args2:NULL];

                        } // if (!ready)

                    } else //testdev\r response error string
                    {
                        [self Callback:TestDevErrorEvent args1:NULL args2:NULL];
                        connect_enabled = false; //close the connection
                        if ([bluetooth_device_new isEqualToString:bluetooth_device]) {
                            bluetooth_device_new = @"";
                            bluetooth_device = @"";
                        }
                        @throw [NSException exceptionWithName:@"HanhongDevice" reason:@"" userInfo:nil];
                    }
                }
                @catch (NSException * e)
                {
                    if (connect_enabled) {
                        [self Callback:TransferErrorEvent args1:NULL args2:NULL];
                    }

                    //bluetooth exception
                    [bt_helper Disconnect];

                    ready = false;
                    connected = false;

                    battery = 0;
                   [self Callback:DisconnectedEvent args1:NULL args2:NULL];
                }

            } //if (connected)
            
            [mutex unlock];

            if (connect_enabled) {
                @try {
                    [NSThread sleepForTimeInterval:1];
                } @catch (NSException * ex) {

                }
            }

        } // while (connect_enabled)

        [bt_helper Disconnect];

        if (connected) {
            ready = false;
            connected = false;

            battery = 0;
            [self Callback:DisconnectedEvent args1:NULL args2:NULL];
        }

        connection_running = false;
        [self Callback:ConnectionEndEvent args1:NULL args2:NULL];
    }

    thread_connect = NULL;
}

-(BOOL)RealtimeStartPlay:(BOOL)enable_realtimeplay_delay_limit
{
    if ([self Running]) {
        return false;
    }
     
    realtimeplay_delay_limit = enable_realtimeplay_delay_limit;
    realtimeplay_enabled = true;
    
    [self RealtimePlayBufferClear];
    
    return true;
}

-(void)RealtimePlayBufferWrite:(NSData *)pcm_data_pack
{
    if (pcm_data_pack.length != 400) {
        return;
    }
    
    [realtimeplay_data_buffer_mutex lock];
    
    if (realtimeplay_delay_limit) {
        if (realtimeplay_data_buffer.count >= realtimeplay_delay_max) {
            [realtimeplay_data_buffer removeAllObjects];
        }
    }
    
    [realtimeplay_data_buffer addObject:pcm_data_pack];
    [realtimeplay_data_buffer_mutex unlock];
    
}

-(void)RealtimePlayBufferClear
{
    [realtimeplay_data_buffer_mutex lock];
    [realtimeplay_data_buffer removeAllObjects];
    [realtimeplay_data_buffer_mutex unlock];
}

//获取当前播放缓存剩下多少
-(long)RealtimePlayBufferLength
{
    return realtimeplay_data_buffer.count;
}

-(void)RealtimePlayThread
{
    NSString * line;

    while (thread_enable && connect_enabled) {
        if (connect_enabled && connected && ready) {
            if (realtimeplay_enabled) {
                if (!realtimeplay_enable) {
                    realtimeplay_running = true;
                    realtimeplay_enable = true;
                   [self Callback:RealtimePlayBeginEvent args1:NULL args2:NULL];
                }

                if (realtimeplay_data_buffer.count > 0) {
                    
                    [mutex lock];

                    @try {
 
                        [bt_helper WriteStr:@"RealTimeStartPlay\r"];
                       
                        line = [bt_helper WaitResponse:@"OK"];

                        if (!realtimeplay_delay_limit) {
                            [bt_helper WriteStr:@"PCM_BUFF"];
                        }
 
                        realtimeplay_ready = true;
                        
                        [self Callback:RealtimePlayStartEvent args1:NULL args2:NULL];
                        
                        NSMutableData *pcm_buffer;
                        
                        pcm_buffer = [NSMutableData dataWithLength:408];

                        //
                        int buffer_sync_time_counter = 0;
                        NSDate * buffer_start_time_tick  = [NSDate date];
                        
                        //
                        if (realtimeplay_delay_limit) {
                            [realtimeplay_data_buffer_mutex lock];
                            [realtimeplay_data_buffer removeAllObjects];
                            [realtimeplay_data_buffer_mutex unlock];
                        }
                        //
                        
                        NSDate *data_receive_time = [NSDate date];
                          
                        NSDate *currentTime;
                        NSTimeInterval elapsedTime;
                        
                        BOOL empty_flag = false;
                        
                        //
                        while (thread_enable && connect_enabled && realtimeplay_enabled) {
                            
                            @autoreleasepool {
                                
                                BOOL data_ready = false;
                                BOOL data_waiting = false;
                                
                                [realtimeplay_data_buffer_mutex lock];
                                
                                if (realtimeplay_data_buffer.count > 0) {
                                    
                                    empty_flag = false;
                                    
                                    NSData *pcm_data = [realtimeplay_data_buffer firstObject];
                                    [realtimeplay_data_buffer removeObjectAtIndex:0];
                                    
                                    [realtimeplay_data_buffer_mutex unlock];
                                    
                                    //pcm_buffer = [NSMutableData dataWithLength:408];
                                    
                                    NSString *pcm_sync = @"PCM_SYNC";
                                    NSData *pcm_sync_data = [pcm_sync dataUsingEncoding:NSUTF8StringEncoding];
                                    
                                    [pcm_buffer replaceBytesInRange:NSMakeRange(400, 8) withBytes:pcm_sync_data.bytes];
                                    [pcm_buffer replaceBytesInRange:NSMakeRange(0, 400) withBytes:pcm_data.bytes];
                                    
                                    data_receive_time = [NSDate date];
                                    data_ready = true;
                                    
                                } else {
                                    
                                    [realtimeplay_data_buffer_mutex unlock];
                                    
                                    if (!empty_flag) {
                                        empty_flag = true;
                                        [self Callback:RealtimePlayBufferEmptyEvent args1:NULL args2:NULL];
                                    }
                                    
                                    data_waiting = true;
                                }
                                  
                                if (data_waiting) {
                                    
                                    currentTime = [NSDate date];
                                    elapsedTime = [currentTime timeIntervalSinceDate:data_receive_time];
                                    
                                    if (elapsedTime >= 0.1) {
                                        //no data > 100ms , to check sync receive
                                        if (buffer_sync_time_counter == buffer_sync_times) {
                                            buffer_sync_time_counter = 0;
                                            
                                            line = [bt_helper WaitResponse:@"eady"]; //Ready or ready
                                            
                                            int sample = buffer_sync_times * 200;
                                            
                                            [self Callback:RealtimePlayBufferSyncEvent args1:@(sample) args2:NULL];
                                            
                                            currentTime = [NSDate date];
                                            elapsedTime = [currentTime timeIntervalSinceDate:buffer_start_time_tick];
                                            
                                            if (elapsedTime >= 0.4) {
                                                //sync receive > 150ms , clear all data if enable discard
                                                if (realtimeplay_delay_limit) {
                                                    [realtimeplay_data_buffer_mutex lock];
                                                    [realtimeplay_data_buffer removeAllObjects];
                                                    [realtimeplay_data_buffer_mutex unlock];
                                                }
                                                
                                                [self Callback:RealtimePlayInstableEvent args1:NULL args2:NULL];
                                            }
                                        }
                                        
                                    }
                                    
                                    
                                    currentTime = [NSDate date];
                                    elapsedTime = [currentTime timeIntervalSinceDate:data_receive_time];
                                    
                                    if (elapsedTime >= 8.0) {
                                        break;
                                    }
                                    
                                    //data waiting sleep
                                    [NSThread sleepForTimeInterval:0.01];
                                }
                                
                                if (data_ready) {
                                    
                                    NSData *write_data = [NSData dataWithData:pcm_buffer];
                                    
                                    //pcm_buffer = nil;
                                    
                                    [bt_helper WriteBytes:write_data];
                                    
                                    [self Callback:RealtimePlaySyncEvent args1:NULL args2:NULL];
                                    
                                    if (buffer_sync_time_counter == buffer_sync_times) {
                                        buffer_sync_time_counter = 0;
                                        
                                        line = [bt_helper WaitResponse:@"eady"]; //Ready or ready
                                        
                                        int sample = buffer_sync_times * 200;
                                        
                                        [self Callback:RealtimePlayBufferSyncEvent args1:@(sample) args2:NULL];
                                        
                                        currentTime = [NSDate date];
                                        elapsedTime = [currentTime timeIntervalSinceDate:buffer_start_time_tick];
                                        
                                        if (elapsedTime >= 0.4) {
                                            //sync receive > 150ms , clear all data if enable discard
                                            if (realtimeplay_delay_limit) {
                                                [realtimeplay_data_buffer_mutex lock];
                                                [realtimeplay_data_buffer removeAllObjects];
                                                [realtimeplay_data_buffer_mutex unlock];
                                            }
                                            
                                            [self Callback:RealtimePlayInstableEvent args1:NULL args2:NULL];
                                            
                                        }
                                    }
                                    
                                    //sync request
                                    if (++buffer_sync_time_counter == buffer_sync_times - buffer_sync_time) {
                                        [bt_helper WriteStr:@"PCM_CMDFtestdev\r"];
                                        buffer_start_time_tick = [NSDate date];
                                    }
                                }
                            }
                        }

                        realtimeplay_ready = false;
                        
                        [self Callback:RealtimePlayStopEvent args1:NULL args2:NULL];

                        [bt_helper WriteStr:@"PCM_CMDFRealtimeStop\r"];
                        [bt_helper WaitResponse:@"RealtimeStopped"];

                    } @catch (NSException * e) {
                        
                        [self Callback:TransferErrorEvent args1:NULL args2:NULL];

                        //bluetooth exception
                        [bt_helper Disconnect];

                        ready = false;
                        connected = false;

                        battery = 0;
                        
                        [self Callback:DisconnectedEvent args1:NULL args2:NULL];
                    }

                    if (realtimeplay_ready) {
                        realtimeplay_ready = false;
                        
                        [self Callback:RealtimePlayStopEvent args1:NULL args2:NULL];
                    }
 
                    [mutex unlock];
                } else //realtimeplay buufer no data
                {
                    @try {
                        [NSThread sleepForTimeInterval:0.01];
                    } @catch (NSException * ex) {

                    }
                }
            } else //realtimeplay off
            {
                @try {
                    [NSThread sleepForTimeInterval:0.01];
                } @catch (NSException * ex) {

                }
            }
        } else // not connect && ready
        {
            @try {
                [NSThread sleepForTimeInterval:0.01];
            } @catch (NSException * ex) {

            }
        }

        if (realtimeplay_enable && !realtimeplay_enabled) {
            realtimeplay_enable = false;
            realtimeplay_running = false;
            [self Callback:RealtimePlayEndEvent args1:NULL args2:NULL];
        }

    } // connect close

    if (realtimeplay_enable) {
        realtimeplay_enabled = false;
        realtimeplay_enable = false;
        realtimeplay_running = false;
        [self Callback:RealtimePlayEndEvent args1:NULL args2:NULL];
    }

    [condition_thread_realtimeplay lock];
    is_thread_realtimeplay_finished = YES;
    [condition_thread_realtimeplay signal];
    [condition_thread_realtimeplay unlock];
    
    thread_realtimeplay = NULL;
}

-(BOOL)RealtimeStartRecord:(RECORD_TYPE)type
{
    if ([self Running]) {
        return false;
    }
    
    if (device_type != STETHOSCOPE) {
        realtimerecord_enabled = false;
        return false;
    }
    
    realtimerecord_type = type;
    realtimerecord_enabled = true;
    
    return true;
}

-(void)RealtimeRecordThread
{
    NSString * line;

    while (thread_enable && connect_enabled) {
        if (connect_enabled && connected && ready) {
            if (realtimerecord_enabled) {
                if (!realtimerecord_enable) {
                    realtimerecord_running = true;
                    realtimerecord_enable = true;
                   [self Callback:RealtimeRecordBeginEvent args1:NULL args2:NULL];
                }

                [mutex lock];

                @try
                {
                    //loop for audio reset
                    while (thread_enable && connect_enabled && realtimerecord_enabled) {
                        
                        if (realtimerecord_type == RECORD_WITH_BUTTON) {
                            [bt_helper WriteStr:@"RealtimeRecord\r"];
                        } else if (realtimerecord_type == RECORD_FULL_WITH_BUTTON) {
                            [bt_helper WriteStr:@"RealtimeRecordFULL\r"];
                        } else if (realtimerecord_type == RECORD_HEART_WITH_BUTTON) {
                            [bt_helper WriteStr:@"RealtimeRecordHEART\r"];
                        } else if (realtimerecord_type == RECORD_LUNG_WITH_BUTTON) {
                            [bt_helper WriteStr:@"RealtimeRecordLUNG\r"];
                        } else if (realtimerecord_type == RECORD_FULL_IMMEDIATELY) {
                            [bt_helper WriteStr:@"RealtimeStartFULL\r"];
                        } else if (realtimerecord_type == RECORD_HEART_IMMEDIATELY) {
                            [bt_helper WriteStr:@"RealtimeStartHEART\r"];
                        } else if (realtimerecord_type == RECORD_LUNG_IMMEDIATELY) {
                            [bt_helper WriteStr:@"RealtimeStartLUNG\r"];
                        } else {
                            [bt_helper WriteStr:@"RealtimeStartRecord\r"];
                        }

                        NSMutableData *recv_header_buffer = [NSMutableData dataWithLength:8];
                        unsigned char *_recv_header_buffer = [recv_header_buffer mutableBytes];
                        NSData *recv_header;
                        NSData *recv_data;
                        NSMutableData *recv_pcm;
                        recv_pcm = [NSMutableData dataWithLength:400];
                        
                        NSDate *currentTime;
                        NSTimeInterval elapsedTime;
                        
                        NSDate *data_receive_time = [NSDate date];

                        realtimerecord_ready = true;
                        
                        [self Callback:RealtimeRecordStartEvent args1:NULL args2:NULL];

                        BOOL header_ready = false;

                        NSString *pcm_sync = @"PCM_SYNC";
                        NSData *pcm_sync_data = [pcm_sync dataUsingEncoding:NSUTF8StringEncoding];
                        
                        NSString *pcm_cmdf = @"PCM_CMDF";
                        NSData *pcm_cmdf_data = [pcm_cmdf dataUsingEncoding:NSUTF8StringEncoding];
                        
                        NSString *pcm_losf = @"PCM_LOSF";
                        NSData *pcm_losf_data = [pcm_losf dataUsingEncoding:NSUTF8StringEncoding];
                       
                        //start receive data loop
                        while (thread_enable && connect_enabled && realtimerecord_enabled) {
                                
                            @autoreleasepool {
                                
                                // 先接收8字节，判断接收的数据类型
                                if (header_ready == false) {
                                    
                                    data_receive_time = [NSDate date];
                                    
                                    recv_header = [bt_helper ReadBytes:8];
                                    
                                    currentTime = [NSDate date];
                                    elapsedTime = [currentTime timeIntervalSinceDate:data_receive_time];
                                    
                                    if (elapsedTime >= 0.15) { //delay > 150ms
                                        [self Callback:RealtimeRecordInstableEvent args1:NULL args2:NULL];
                                    }
                                    
                                    header_ready = true;
                                }
                                
                                if ([recv_header isEqual:pcm_losf_data]) {
                                    // 是 PCM_LOSF
                                    [self Callback:RealtimeRecordLostEvent args1:NULL args2:NULL];
                                    header_ready = false;
                                } else if ([recv_header isEqual:pcm_cmdf_data]) {
                                    // 是 PCM_CMDF
                                    data_receive_time = [NSDate date];
                                    
                                    line = [bt_helper ReadLine:false];
                                    
                                    currentTime = [NSDate date];
                                    elapsedTime = [currentTime timeIntervalSinceDate:data_receive_time];
                                    
                                    if (elapsedTime >= 0.15) { //delay > 150ms
                                        [self Callback:RealtimeRecordInstableEvent args1:NULL args2:NULL];
                                    }
                                    
                                    if ([line containsString:@"RecordStart"]) {
                                        
                                        [self Callback:RealtimeRecordOnEvent args1:NULL args2:NULL];
                                    } else if ([line containsString:@"RecordStop"]) {
                                        
                                        [self Callback:RealtimeRecordOffEvent args1:NULL args2:NULL];
                                    }
                                    header_ready = false;
                                    
                                } else {
                                    
                                    //recv_pcm = [NSMutableData dataWithLength:400];
                                    
                                    //可能是音频数据，需进一步确认400字节
                                    [recv_pcm replaceBytesInRange:NSMakeRange(0, 8) withBytes:recv_header.bytes];
                                    
                                    data_receive_time = [NSDate date];
                                    
                                    recv_data = [bt_helper ReadBytes:392];
                                    recv_header = [bt_helper ReadBytes:8];
                                    
                                    currentTime = [NSDate date];
                                    elapsedTime = [currentTime timeIntervalSinceDate:data_receive_time];
                                    
                                    if (elapsedTime >= 0.15) { //delay > 150ms
                                        [self Callback:RealtimeRecordInstableEvent args1:NULL args2:NULL];
                                    }
                                    
                                    if ([recv_header isEqual:pcm_sync_data]) {
                                        
                                        [recv_pcm replaceBytesInRange:NSMakeRange(8, 392) withBytes:recv_data.bytes];
                                        recv_data = nil;
                                        
                                        [self Callback:RealtimeRecordSyncEvent args1:[NSData dataWithData:recv_pcm] args2:NULL];
                                        
                                        //recv_pcm = nil;
                                        
                                        header_ready = false;
                                        
                                    } else {
                                        
                                        [self Callback:LogEvent args1:@"pcm_sync error" args2:NULL];
                                        NSLog(@"pcm sync error");
                                        
                                        //不是PCM_SYNC 说明数据异常，重新同步，8字节环形缓存，收一个字节放到最后，第一个字节去掉
                                        while (thread_enable && connect_enabled && realtimerecord_enabled) {
                                            
                                            for (int i = 0; i < 7; i++) {
                                                _recv_header_buffer[i] = _recv_header_buffer[i + 1];
                                            }
                                            
                                            data_receive_time = [NSDate date];
                                            
                                            NSData *recv_byte = [bt_helper ReadBytes:1];
                                            
                                            const unsigned char *bytes = [recv_byte bytes];
                                            _recv_header_buffer[7] = bytes[0];
                                            
                                            currentTime = [NSDate date];
                                            elapsedTime = [currentTime timeIntervalSinceDate:data_receive_time];
                                            
                                            if (elapsedTime >= 0.15) { //delay > 150ms
                                                [self Callback:RealtimeRecordInstableEvent args1:NULL args2:NULL];
                                            }
                                            
                                            recv_header = [NSData dataWithData:recv_header_buffer];
                                            
                                            if ([recv_header isEqual:pcm_sync_data]) {
                                                header_ready = false;
                                                break;
                                            } else if ([recv_header isEqual:pcm_cmdf_data] || [recv_header isEqual:pcm_losf_data]) {
                                                header_ready = true;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        realtimerecord_ready = false;
                        
                        [self Callback:RealtimeRecordStopEvent args1:NULL args2:NULL];

                        [bt_helper WriteStr:@"RealTimeStop\r"];
                        [bt_helper WaitResponse:@"RealtimeStopped"];
                         
                        recv_header_buffer = nil;
                    }
                }
                @catch (NSException * e) {
                    [self Callback:TransferErrorEvent args1:NULL args2:NULL];

                    //bluetooth exception
                    [bt_helper Disconnect];

                    ready = false;
                    connected = false;

                    battery = 0;
                    [self Callback:DisconnectedEvent args1:NULL args2:NULL];
                }

                if (realtimerecord_ready) {
                    realtimerecord_ready = false;
                    [self Callback:RealtimeRecordStopEvent args1:NULL args2:NULL];
                }
                [mutex unlock];
                            
            } else //RECORD_WITH_BUTTON end
            {
                @try {
                    [NSThread sleepForTimeInterval:0.01];
                } @catch (NSException * ex) {

                }
            }
        } else //not connect and ready
        {
            @try {
                [NSThread sleepForTimeInterval:0.01];
            } @catch (NSException * ex) {

            }
        }

        if (realtimerecord_enable && !realtimerecord_enabled) {
            realtimerecord_enable = false;
            realtimerecord_running = false;
            [self Callback:RealtimeRecordEndEvent args1:NULL args2:NULL];
        }
    }

    if (realtimerecord_enable) {
        realtimerecord_enabled = false;
        realtimerecord_enable = false;
        realtimerecord_running = false;
        [self Callback:RealtimeRecordEndEvent args1:NULL args2:NULL];
    }

    [condition_thread_realtimerecord lock];
    is_thread_realtimerecord_finished = YES;
    [condition_thread_realtimerecord signal];
    [condition_thread_realtimerecord unlock];
    
    thread_realtimerecord = NULL;
}

-(void)RealtimeStop{
    realtimerecord_enabled = false;
    realtimeplay_enabled = false;
}

-(void)GenerateWavFileHeader:(int)pcm_data_size wav_file_header_buffer:(NSMutableData *)wav_file_header_buffer
{
    if (wav_file_header_buffer == NULL) return;
    if (wav_file_header_buffer.length < 44) return;
    
    unsigned char *buffer = [wav_file_header_buffer mutableBytes];
    
    buffer[0] = 'R';
    buffer[1] = 'I';
    buffer[2] = 'F';
    buffer[3] = 'F';
    buffer[4] = (unsigned char)((pcm_data_size + 44 - 8) & 0xFF);
    buffer[5] = (unsigned char)(((pcm_data_size + 44 - 8) >> 8) & 0xFF);
    buffer[6] = (unsigned char)(((pcm_data_size + 44 - 8) >> 16) & 0xFF);
    buffer[7] = (unsigned char)(((pcm_data_size + 44 - 8) >> 24) & 0xFF);
    buffer[8] = 'W';
    buffer[9] = 'A';
    buffer[10] = 'V';
    buffer[11] = 'E';
    buffer[12] = 'f';
    buffer[13] = 'm';
    buffer[14] = 't';
    buffer[15] = ' ';
    buffer[16] = 16;
    buffer[17] = 0;
    buffer[18] = 0;
    buffer[19] = 0;
    buffer[20] = 1;
    buffer[21] = 0;
    buffer[22] = 1;
    buffer[23] = 0;
    buffer[24] = (int)(11025) & 0xFF;
    buffer[25] = ((int)(11025) >> 8) & 0xFF;
    buffer[26] = ((int)(11025) >> 16) & 0xFF;
    buffer[27] = ((int)(11025) >> 24) & 0xFF;
    buffer[28] = (int)(22050) & 0xFF;
    buffer[29] = ((int)(22050) >> 8) & 0xFF;
    buffer[30] = ((int)(22050) >> 16) & 0xFF;
    buffer[31] = ((int)(22050) >> 24) & 0xFF;
    buffer[32] = 2;
    buffer[33] = 0;
    buffer[34] = 16;
    buffer[35] = 0;
    buffer[36] = 'd';
    buffer[37] = 'a';
    buffer[38] = 't';
    buffer[39] = 'a';
    buffer[40] = (unsigned char)((pcm_data_size) & 0xFF);
    buffer[41] = (unsigned char)( ((pcm_data_size) >> 8) & 0xFF);
    buffer[42] = (unsigned char)(((pcm_data_size) >> 16) & 0xFF);
    buffer[43] = (unsigned char)(((pcm_data_size) >> 24) & 0xFF);
    
}

@end
 
  
