//
//  DataService.m
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/28.
//

#import "DataService.h"
#import "TcpHelper.h"

@implementation Packet

-(instancetype)init{
    self = [super init];
    if (self) {
       
    }
    return self;
}

-(instancetype)initWithData:(int)type data:(NSData *)data
{
    self = [super init];
    if (self) {
        _type = type;
        _data = data;
    }
    return self;
}

@end


@implementation Clients
{
    NSLock *lock;
    NSMutableArray *edit_members;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        lock = [NSLock new];
        edit_members  = [NSMutableArray array];
    }
    return self;
}

+(int)CalcUid:(const unsigned char *)buffer index:(int)index
{
    @try {
        return (buffer[index + 0] << 24) |  (buffer[index + 1] << 16) |  (buffer[index + 2] << 8) | buffer[index + 3];
    }
    @catch(NSException *e) {
        return 0;
    }
}

-(int)Decode:(NSData*)data
{
    int result = 0;
    
    const unsigned char *input = [data bytes];
    
    [lock lock];
    @try {
        
        if (input[0] == 0) {
            [edit_members removeAllObjects];
            int count = input[1] & 0xFF;
            for (int i = 0; i < count; i++) {
                int uid = [Clients CalcUid:input index:2 + i * 4];
                [edit_members addObject: [NSNumber numberWithInt:uid]];
            }
            
            _member = 0;
            result = 0;
            
        } else if (input[0] == 1) {
            int uid = [Clients CalcUid:input index:1];
            BOOL exist = false;
            for (NSNumber* u in edit_members) {
                if (uid == [u intValue]) {
                    exist = true;
                }
            }
            if (!exist) {
                [edit_members addObject:[NSNumber numberWithInt:uid]];
            }
            
            _member = uid;
            result = 1;
            
        } else if (input[0] == 2){
            int uid = [Clients CalcUid:input index:1];
            NSNumber *exist_member = NULL;
            for (NSNumber *u in edit_members) {
                if (uid == [u intValue]) {
                    exist_member = u;
                    break;
                }
            }
            
            if (exist_member != NULL) {
                [edit_members removeObject:exist_member];
            }

            _member = uid;
            result = 2;
            
        } else {
            @throw [NSException exceptionWithName:@"DataService" reason:@"" userInfo:nil];
        }
    }
    @catch (NSException *e) {
        result = -1;
    }
    [lock unlock];
    return result;
}
 
-(NSArray<NSNumber *> *)members
{
    return [edit_members copy];
}
 
-(int)count
{
    return (int)edit_members.count;
}
 


@end



@implementation DataCodec {
    
}

-(instancetype)init{
    self = [super init];
    return self;
}

-(instancetype)init:(int)version type:(int)type format:(int)format flag:(int)flag data:(NSData *)data
{
    self = [super init];
    if (self) {
        _version = version;
        _type = type;
        _format = format;
        _flag = flag;
        _data = data;
    }
    return self;
}

-(instancetype)init:(int)version type:(int)type cmd:(int)command data:(NSData *)data
{
    self = [super init];
    if (self) {
        _version = version;
        _type = type;
        _command = command;
        _data = data;
    }
    return self;
}

-(BOOL)Decode:(NSData *)data
{
    const unsigned char *input = [data bytes];
    if (data.length >= 6) {
        _user_id = [Clients CalcUid:input index:0];
        _version = (input[4] & 0xF0) >> 4; //数据接口版本  0 ~ 15
        _type = input[4] & 0x0F;  //数据类型  0 ~ 15
        if (_version == 0) { //通信版本
            if (_type == type_audio) {  //数据类型音频
                _format = (input[5] & 0xE0) >> 5;  //音频格式 0 ~ 7
                _flag = input[5] & 0x1F; //其他标志
                _data = NULL;
                if (_format == 0) {  //格式wav
                    NSMutableData *buffer = [NSMutableData dataWithLength:400];
                    [buffer replaceBytesInRange:NSMakeRange(0, 400) withBytes:(input + 6)];
                    _data = [NSData dataWithData:buffer];
                    return true;
                }
            } else if (_type == type_cmd) {
                _command = input[5];
                int data_length = (input[7] << 8) | input[6];
                if (data_length > 0) {
                    NSMutableData *buffer = [NSMutableData dataWithLength:data_length];
                    [buffer replaceBytesInRange:NSMakeRange(0, data_length) withBytes:(input + 8)];
                    _data = [NSData dataWithData:buffer];
                } else {
                    _data = NULL;
                }

                return true;
            }

        }
    }
    return false;
}

-(NSData *)Encode
{
    if (_version == 0) { //通信版本
        if (_type == type_audio) {  //数据类型音频
            if (_format == 0) {  //格式wav
                if (_data != NULL) {
                    if (_data.length == 400) {
                        NSMutableData *data = [NSMutableData dataWithLength:402];
                        unsigned char *output = (unsigned char *)data.bytes;
                        //encode 发送不需要user id
                        output[0] = (unsigned char)(((_version & 0x0F) << 4) + (_type & 0xF));
                        output[1] = (unsigned char)(((_format & 0x07) << 5) + (_flag & 0x1F));
                        
                        [data replaceBytesInRange:NSMakeRange(2, 400) withBytes:_data.bytes];
                        
                        NSData *ret_data = [NSData dataWithData:data];
                        data = nil;
                        return ret_data;
                    }
                }
            }
        } else if (_type == type_cmd) {  //数据类型命令

            int data_length = 0;
            if (_data != NULL) {
                data_length = (int)_data.length;
            }

            NSMutableData *data = [NSMutableData dataWithLength:data_length + 4];
            unsigned char *output = (unsigned char *)data.bytes;
            //encode 发送不需要user id
            output[0] = (unsigned char)(((_version & 0x0F) << 4) + (_type & 0xF));
            output[1] = (unsigned char)(_command & 0xFF);
            output[2] = (unsigned char)(data_length & 0xFF);
            output[3] = (unsigned char)((data_length >> 8) & 0xFF);
            if (_data != NULL) {
                [data replaceBytesInRange:NSMakeRange(4, data_length) withBytes:_data.bytes];
            }
            NSData *ret_data = [NSData dataWithData:data];
            data = nil;
            return ret_data;
        }
    }

    return NULL;
}


@end

@implementation DataService
{
    NSString *domain_or_ip;
    int port;
    
    TcpHelper *tcp_helper;
    
    NSString *token;
    
    int retry;
    
    BOOL ready;
    BOOL service_enabled;
    BOOL service_running;
    
    BOOL second_thread_enabled;
    
    NSThread *main_thread;
    NSThread *second_thread;
    
    __block BOOL is_main_thread_finished;
    NSCondition *condition_main_thread;
    
    __block BOOL is_second_thread_finished;
    NSCondition *condition_second_thread;
    
    NSLock *send_queue_lock;
    NSMutableArray *send_queue;
    
}

-(instancetype)init{
    self = [super init];
    if (self) {
        
        domain_or_ip = @"";
        port = 38888;
        tcp_helper = [TcpHelper new];
        
        token = @"";
        retry = 3;
        
        ready = false;
        service_enabled = false;
        service_running = false;
        
        second_thread_enabled = false;
        
        main_thread = [[NSThread alloc] initWithTarget:self selector:@selector(MainThread) object:nil];
        is_main_thread_finished = NO;
        condition_main_thread = [[NSCondition alloc] init];
        
        second_thread = NULL;
        is_second_thread_finished = NO;
        condition_second_thread = [[NSCondition alloc] init];
        
        _delegate = NULL;
        
        send_queue_lock = [NSLock new];
        send_queue = [NSMutableArray array];
        
    }
    
    return self;
}


-(void) SetServer:(NSString *)server_domain_or_ip server_port:(int)server_port access_token:(NSString *)access_token
{
    domain_or_ip = [server_domain_or_ip copy];
    port = server_port;
    token = [access_token copy];
}

-(BOOL)Running
{
    return service_enabled || service_running;
}

-(void)SetRetry:(int)retry
{
    self->retry = retry;
}

-(BOOL)Connect{
    if ([self Running]) {
        return false;
    }
    
    service_running = true;
    service_enabled = true;
    
    
    [main_thread start];
    
    return true;
}

-(void)Disconnect
{
    service_enabled = false;
     
    @try {
        //等待线程退出
        [condition_main_thread lock];
        while (!is_main_thread_finished) {
            [condition_main_thread wait];
        }
        [condition_main_thread unlock];
    }
    @catch (NSException *exception) {

    }
}

-(BOOL)SendPacket:(Packet *)pkt
{
    NSMutableData *nsbuffer;
    
    if (pkt.data != NULL) {
        int packet_len = 7 + (int) pkt.data.length;
        
        nsbuffer = [NSMutableData dataWithLength:packet_len];
        unsigned char *buffer = (unsigned char *)[nsbuffer bytes];
        
        [nsbuffer replaceBytesInRange:NSMakeRange(7, pkt.data.length) withBytes:pkt.data.bytes];
        
        if (pkt.data.length > 1024) {
            return false;
        }
        
        buffer[0] = 0xFE;
        buffer[1] = 0xEF;
        buffer[2] = 0x01;
        buffer[3] = 0x10;
        buffer[4] = pkt.type;
        buffer[5] = (pkt.data.length >> 8);
        buffer[6] = (pkt.data.length & 0xFF);
        
    } else {
        
        int packet_len = 7;
        
        nsbuffer = [NSMutableData dataWithLength:packet_len];
        unsigned char *buffer = (unsigned char *)[nsbuffer bytes];
        buffer[0] = 0xFE;
        buffer[1] = 0xEF;
        buffer[2] = 0x01;
        buffer[3] = 0x10;
        buffer[4] = pkt.type;
        buffer[5] = 0x00;
        buffer[6] = 0x00;
    }
    
    NSData *send_data = [NSData dataWithData:nsbuffer];
    
    nsbuffer = nil;
    
    [tcp_helper WriteBytes:send_data];
    
    return true;
    
}

-(Packet *)RecvPacket
{
    NSMutableData *nsheader = [NSMutableData dataWithLength:7];
    
    unsigned char *header = (unsigned char *)[nsheader bytes];
    
    [tcp_helper ReadBytes:nsheader len:7 timeout:2.0];
    
    if (header[0] != 0xFE || header[1] != 0xEF || header[2] != 0x01 || header[3] != 0x10) {
        return NULL;
    }

    unsigned char type = header[4];

    int h_ = header[5];
    int l_ = header[6];
    int length = (h_ << 8) + l_;

    if (length > 1024) return NULL;

    NSMutableData *nsd = NULL;

    if (length > 0) {
        nsd = [NSMutableData dataWithLength:length];
        [tcp_helper ReadBytes:nsd len:length timeout:5.0];
    }

    NSData *d = [NSData dataWithData:nsd];
    nsd = nil;
    
    Packet *packet = [[Packet alloc] initWithData:type data:d];

    return packet;
}

-(void)SendDataBufferClear{
    
    [send_queue_lock lock];
    [send_queue removeAllObjects];
    [send_queue_lock unlock];
}

-(BOOL)SendData:(NSData *)data timeout:timeout  //timeout 功能暂时无实现
{
    [send_queue_lock lock];
    [send_queue addObject:data];
    [send_queue_lock unlock];
    
    return true;
}



-(void)Event:(SERVICE_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2
{
    if (_delegate) {
        @try{
            [_delegate on_data_service_event:event args1:args1 args2:args2];
        }
        @catch (NSException *e){
            NSLog(@"DataService event callback error");
        }
    }
}

-(void)MainThread
{
    
    int connect_retry = 0;
    BOOL connected = false;

    [self Event:ServiceConnectionBeginEvent args1:NULL args2:NULL];

    while(service_enabled) {

        //连接部分
        @try {

            [self Event:ServiceConnectingEvent args1:NULL args2:NULL];
            [tcp_helper Connect:domain_or_ip port:port];
            [self Event:ServiceConnectedEvent args1:NULL args2:NULL];

            connected = true;
            connect_retry = 0;

        }
        @catch (NSException *e) {

            if (retry > 0) {  //如果retry = 0 ，一直重连
                if (++connect_retry > retry) {
                    service_enabled = false;  //退出线程
                    [self Event:ServiceConnectFailEvent args1:NULL args2:NULL];
                }
            }

            //当连接异常，不能频繁访问服务器，适当延迟
            @try {
                [NSThread sleepForTimeInterval:1.0];
            }
            @catch (NSException *ex) {

            }
        }

        //通信部分
        if (connected) {
            @try {
                //连接成功后，发送认证
                NSData * token_bytes = [token dataUsingEncoding:NSUTF8StringEncoding];
                [self SendPacket:[[Packet alloc] initWithData:DATA_TYPE_TOKEN data:token_bytes]];
                Packet *packet = [self RecvPacket];
                if (packet != NULL) {
                    if (packet.type == DATA_TYPE_RESPONSE) {
                        //获取应答
                        NSString * Resp = [[NSString alloc] initWithData:packet.data encoding:NSUTF8StringEncoding];
                        if ([Resp containsString:@"Success"]) {

                            NSLog(@"data forward service ready");

                            ready = true;
                            [self Event:ServiceAuthEvent args1:[NSNumber numberWithBool:true] args2:@"Ready"];

                            second_thread_enabled = true;
                            is_second_thread_finished = NO;
                            condition_second_thread = [[NSCondition alloc] init];
                            second_thread = [[NSThread alloc] initWithBlock:^{
                                
                                //运行接收线程
                                while(self->second_thread_enabled) {
                                    
                                    @autoreleasepool {
                                        @try {
                                            
                                            Packet *packet = [self RecvPacket];
                                            
                                            if (packet.type == DATA_TYPE_FORWARD_DATA) {
                                                [self Event:ServiceReceiveForwardDataEvent args1:packet.data args2:NULL];
                                            } else if (packet.type == DATA_TYPE_CLIENT_INFO) {
                                                //Log.e("data service client info", bytes2hexStr(packet.data));
                                                [self Event:ServiceReceiveClientInfoEvent args1:packet.data args2:NULL];
                                            }
                                            
                                        }
                                        @catch (NSException *e) {
                                            
                                        }
                                    }
                                }
                                 
                                [self->condition_second_thread lock];
                                self->is_second_thread_finished = YES;
                                [self->condition_second_thread signal];
                                [self->condition_second_thread unlock];
                                
                            }];
                             
                             
                            [second_thread start];

                            //这个线程主要负责发送数据
                            while (service_enabled) {
                                
                                @autoreleasepool {
                                    
                                    NSData* send_data;
                                    
                                    NSDate *start_time = [NSDate date];
                                    
                                    //等待数据的while循环
                                    do {
                                        
                                        @autoreleasepool {
                                            
                                            //取数据
                                            [send_queue_lock lock];
                                            
                                            if (send_queue.count > 0) {
                                                send_data = [send_queue firstObject];
                                                [send_queue removeObjectAtIndex:0];
                                                start_time = [NSDate date];
                                            } else {
                                                send_data = NULL;
                                            }
                                            
                                            [send_queue_lock unlock];
                                            
                                            if (send_data == NULL) {
                                                //无数据的，等待超时
                                                NSDate *currentTime = [NSDate date];
                                                NSTimeInterval elapsedTime = [currentTime timeIntervalSinceDate:start_time];
                                                if (elapsedTime >= 3.0) {
                                                    break;
                                                }
                                                [NSThread sleepForTimeInterval:0.005];
                                            } else {
                                                //有数据就发送
                                                break;
                                            }
                                        }
                                        
                                    } while (service_enabled);
                                      
                                    if (send_data != NULL) {
                                        //发送数据
                                        [self SendPacket:[[Packet alloc] initWithData:DATA_TYPE_FORWARD_DATA data:send_data]];
                                    } else {
                                        //超时了，发送心跳包
                                        [self SendPacket:[[Packet alloc] initWithData:DATA_TYPE_HEARTBIT data:NULL]];
                                    }
                                }
                            }

                        } else {

                            if ([Resp containsString:@"limit"]) {

                                [self Event:ServiceAuthEvent args1:false args2:Resp];

                                [tcp_helper Disconnect];
                                connected = false;

                                //有连接，才有断开消息
                                [self Event:ServiceDisconnectEvent args1:NULL args2:NULL];

                                //服务器连接已满，延迟后继续尝试连接
                                @try {
                                    [NSThread sleepForTimeInterval:1.0];
                                }
                                @catch (NSException *ex) {

                                }

                            } else {

                                [self Event:ServiceAuthEvent args1:false args2:Resp];

                                //token error
                                service_enabled = false;

                            }

                        }
                    }
                }
            }
            @catch (NSException *e) {

                //用于SendPacket 和 RecvPacket 抛出的网络异常（断线）
                ready = false;

                [tcp_helper Disconnect];
                connected = false;

                //有连接，才有断开消息
                [self Event:ServiceDisconnectEvent args1:NULL args2:NULL];

                if (second_thread != NULL) {
                    
                    second_thread_enabled = false;
                     
                    @try {
                        //等待线程退出
                        [condition_second_thread lock];
                        while (!is_second_thread_finished) {
                            [condition_second_thread wait];
                        }
                        [condition_second_thread unlock];
                    }
                    @catch (NSException *exception) {

                    }
                     
                    second_thread = NULL;
                }

                //当连接异常，不能频繁访问服务器，适当延迟
                @try {
                    [NSThread sleepForTimeInterval:1.0];
                } @catch (NSException *ex) {

                }
            }
        }
    }

    service_enabled = false;

    if (connected) {
        [tcp_helper Disconnect];
        connected = false;
        //有连接，才有断开消息
        [self Event:ServiceDisconnectEvent args1:NULL args2:NULL];

    }

    if (second_thread != NULL) {
        //等待第二线程退出
        second_thread_enabled = false;
        @try {
            //等待线程退出
            [condition_second_thread lock];
            while (!is_second_thread_finished) {
                [condition_second_thread wait];
            }
            [condition_second_thread unlock];
        }
        @catch (NSException *exception) {

        }
         
        second_thread = NULL;
    }

    service_running = false;

    [self Event:ServiceConnectionEndEvent args1:NULL args2:NULL];
     
    [condition_main_thread lock];
    is_main_thread_finished = YES;
    [condition_main_thread signal];
    [condition_main_thread unlock];
        
}

@end
