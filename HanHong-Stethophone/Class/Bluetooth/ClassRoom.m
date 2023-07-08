//
//  ClassRoom.m
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/28.
//

#import "ClassRoom.h"

@import SocketIO;

//
// 使用socket.io-client-swift 库，库中有一个bug，就是连接服务器时，服务器发的数据收不到，需要手改库的代码，在 SocketIOClient 384～385 行 增加一行代码  didConnect(toNamespace: nsp);
// 如下：
// case .event, .binaryEvent:
//    didConnect(toNamespace: nsp);
//    handleEvent(packet.event, data: packet.args, isInternalMessage: false, withAck: packet.id)
//

@implementation ClassRoomInfo{
    
}

-(instancetype)init{
    self = [super init];
    return self;
}

@end

@implementation ClassRoom {
    
    SocketManager *mSocketManager;
    SocketIOClient *mSocket;
     
    DataService *data_service;
    
//    SocketManager *mSocket_data_serviceManager;
//    SocketIOClient *mSocket_data_service;
 
    
    Clients *clients;
    
    BOOL classroom_entered;
    
    BOOL data_service_connected;
     
}

-(instancetype)init
{
    self = [super init];
    
    if(self) {
        mSocketManager = NULL;
        mSocket = NULL;
        
        clients = [Clients new];
        
        classroom_entered = false;
        data_service_connected = false;
        
        _delegate = NULL;
        
        self.online_member_list = NULL;
         
        _classroom_info = [ClassRoomInfo new];
         
    }
    
    return self;
}

-(BOOL)DataServiceConnected
{
    return data_service_connected;
}

-(BOOL)SendWavFrame:(int)flag wav_frame:(NSData *)wav_frame
{
    if (wav_frame.length != 400) {
        return false;
    }
    if (![self isEntered]) {
        return false;
    }
    if (data_service == NULL) {
        return false;
    }

    if (data_service_connected == false) {
        return false;
    }
    return [data_service SendData:[[[DataCodec alloc] init:0 type:type_audio format:0 flag:flag data:wav_frame] Encode] timeout:0];
}

-(BOOL)SendCommand:(int)command data:(NSData *)data
{
    if (![self isEntered]) {
        return false;
    }
    if (data_service == NULL) {
        return false;
    }

    if (data_service_connected == false) {
        return false;
    }
    return [data_service SendData:[[[DataCodec alloc] init:0 type:type_cmd cmd:command data:data] Encode] timeout:0];
}

-(void)Event:(CLASSROOM_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3
{
    if (_delegate) {
        @try {
            [_delegate on_classroom_event:event args1:args1 args2:args2 args3:args3];
        } @catch (NSException *exception) {
            NSLog(@"ClassRoom event callback error");
        }
    }
}

-(BOOL)isEntered{
    return classroom_entered;
}
  
-(void)Enter:(NSString *)token classroom_url:(NSString *)classroom_url classroom_id:(int)classroom_id
{
    @try{
        
        NSString *teaching_namespace = @"/api/teaching/classroom";

        NSRange range = [classroom_url rangeOfString:teaching_namespace];
        NSString *host;

        if (range.location != NSNotFound) {

            host = [classroom_url substringToIndex:range.location];

        } else {
            NSLog(@"ClassRoom url error");
            [self Event:ClassEnterFailed args1:NULL args2:NULL args3:NULL];
            return;
        }
           
        NSURL *socketURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", host]];

        mSocketManager = [[SocketManager alloc] initWithSocketURL:socketURL config:@{@"log": @NO, @"compress": @YES, @"connectParams":@{@"token":token, @"id":[NSString stringWithFormat:@"%d", classroom_id]}}];
        mSocket = [mSocketManager socketForNamespace:teaching_namespace];

//        [mSocket onAny:^(SocketAnyEvent *event) {
//            NSLog(@"Received event: %@, with items: %@", event.event, event.items);
//        }];

        [mSocket on:@"connect" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"SocketIO connect");
        }];

        [mSocket on:@"disconnect" callback:^(NSArray * data, SocketAckEmitter * ack) {
            if (self->classroom_entered) {
                NSLog(@"ClassRoom exit");
                [self Event:ClassExited args1:NULL args2:NULL args3:NULL];
            } else {
                NSLog(@"ClassRoom enter failed");
                [self Event:ClassEnterFailed args1:NULL args2:NULL args3:NULL];
            }
            self->classroom_entered = false;
            [self DisconnectDataService];
        }];

        [mSocket on:@"classroom" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket classroom");
            
            @try {
                
                NSDictionary *mdata = [data lastObject][@"data"];
                
                self.classroom_info.classroom_id = [mdata[@"classroom_id"] intValue];
                self.classroom_info.class_state = [mdata[@"class_state"] intValue];
                self.classroom_info.class_begin_time = mdata[@"class_begin_time"];
                self.classroom_info.class_end_time = mdata[@"class_end_time"];
                self.classroom_info.create_time = mdata[@"create_time"];
                 
                @try
                {
                    
                    self.classroom_info.teacher_id = [mdata[@"teacher_id"] intValue];
                    self.classroom_info.teacher_name = mdata[@"teacher_name"];
                    self.classroom_info.teacher_avatar = mdata[@"teacher_avatar"];
                    self.classroom_info.number_of_learners = [mdata[@"number_of_learners"] intValue];
                    self.classroom_info.teaching_times = [mdata[@"teaching_times"] intValue];
                    
                    NSArray *marray = mdata[@"students"];
                    
                    if (marray.count > 0) {
                        
                        NSMutableArray<Member *> * members = [NSMutableArray array];
                        
                        for (NSDictionary *m in marray) {
                            Member *member = [Member new];
                            
                            member.role = [m[@"role"] intValue];
                            member.user_id = [m[@"id"] intValue];
                            member.user_name = m[@"name"];
                            member.user_phone = m[@"phone"];
                            member.user_avatar = m[@"avatar"];
                            
                            [members addObject:member];
                        }
                        
                        self.classroom_info.students_list = [[MemberList alloc] initWithMembers:members];
                    } else {
                        self.classroom_info.students_list = [MemberList new];
                    }
                }
                @catch (NSException *e) {
                        
                }
                
                @try {
                    if (mdata[@"data_server_url"] != NULL) {
                        self.classroom_info.data_server_url = mdata[@"data_server_url"];
                        self.classroom_info.data_server_port = mdata[@"data_server_port"];
                        self.classroom_info.data_server_access_token = mdata[@"data_server_access_token"];
                    }
                    
                    if (mdata[@"user_id"] != NULL) {
                        self.classroom_info.user_id = [mdata[@"user_id"] intValue];
                        self.classroom_info.role = [mdata[@"role"] intValue];
                    }
                }
                @catch (NSException *e) {
                    
                }
                
                if (self->classroom_entered == false) {
                    self->classroom_entered = true;
                    
                    NSLog(@"ClassRoom enter room sucess");
                    
                    [self Event:ClassEnterSuccess args1:NULL args2:NULL args3:NULL];
                    [self Event:ClassInfoUpdate args1:self.classroom_info args2:NULL args3:NULL];
                } else {
                    NSLog(@"ClassRoom room info update");
                    [self Event:ClassInfoUpdate args1:self.classroom_info args2:NULL args3:NULL];
                }
                
            } @catch (NSException *exception) {
                
                NSLog(@"ClassRoom error %@ %@", exception.name, exception.reason);
                
            } @finally {
                
            }
        }];

        [mSocket on:@"room_users" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket auscultation_state");
            
            @try {
                NSArray *clients = [data lastObject][@"data"];
                
                NSMutableArray<Member *> * members = [NSMutableArray array];
                
                for (NSDictionary *c in clients) {
                    
                    Member *member = [Member new];
                    
                    member.role = [c[@"role"] intValue];
                    member.user_id = [c[@"id"] intValue];
                    member.user_name = c[@"name"];
                    member.user_phone = c[@"phone"];
                    member.user_avatar = c[@"avatar"];
                    
                    [members addObject:member];
                }
                
                self.online_member_list = [[MemberList alloc] initWithMembers:members];
                
                [self Event:ClassMemberUpdate args1:@(0) args2:NULL args3:self.online_member_list];
            }
            @catch (NSException *e) {
                NSLog(@"ClassRoom room_user error %@ %@", e.name, e.reason);
            }
        }];

        [mSocket on:@"join_room" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket join_room");
            
            @try {
                 
                NSDictionary *c = [data lastObject][@"data"];
                
                Member *member = [Member new];
                
                member.role = [c[@"role"] intValue];
                member.user_id = [c[@"id"] intValue];
                member.user_name = c[@"name"];
                member.user_phone = c[@"phone"];
                member.user_avatar = c[@"avatar"];
                
                [self.online_member_list addMember:member];
      
                [self Event:ClassMemberUpdate args1:@(1) args2:member args3:self.online_member_list];
            }
            @catch (NSException *e) {
                NSLog(@"ClassRoom join_room error %@ %@", e.name, e.reason);
            }
            
        }];

        [mSocket on:@"leave_room" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket leave_room");
            
            @try {
                 
                NSDictionary *c = [data lastObject][@"data"];
                
                Member *member = [Member new];
                
                member.role = [c[@"role"] intValue];
                member.user_id = [c[@"id"] intValue];
                member.user_name = c[@"name"];
                member.user_phone = c[@"phone"];
                member.user_avatar = c[@"avatar"];
                
                [self.online_member_list removeMember:member];
      
                [self Event:ClassMemberUpdate args1:@(-1) args2:member args3:self.online_member_list];
            }
            @catch (NSException *e) {
                NSLog(@"ClassRoom leave_room error %@ %@", e.name, e.reason);
            }
            
        }];

        [mSocket on:@"auscultation_state" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket auscultation_state");
            
            @try {
                 
                NSDictionary *s = [data lastObject][@"data"];
                
                int state = [s[@"auscultation_state"] intValue];
                
                if (state == 1) {
                    [self ConnectDataService];
                    [self Event:ClassStartAuscultation args1:NULL args2:NULL args3:NULL];
                } else {
                    [self DisconnectDataService];
                    [self Event:ClassStopAuscultation args1:NULL args2:NULL args3:NULL];
                }
            }
            @catch (NSException *e) {
                NSLog(@"ClassRoom auscultation_state error %@ %@", e.name, e.reason);
            }
        }];

        [mSocket on:@"error" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket error");
            [self->mSocket disconnect];
        }];
        
        [mSocket on:@"connecting" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket connecting");
            [self Event:ClassEntering args1:NULL args2:NULL args3:NULL];
        }];

        [mSocket on:@"connect_failed" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket error");
            [self Event:ClassEnterFailed args1:NULL args2:NULL args3:NULL];
        }];
        

        [mSocket on:@"reconnect" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket reconnecting");
        }];
        
        [mSocket on:@"reconnecting" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket reconnecting");
            [self Event:ClassEntering args1:NULL args2:NULL args3:NULL];
        }];

        [mSocket on:@"reconnect_failed" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket reconnect failed");
            [self Event:ClassEnterFailed args1:NULL args2:NULL args3:NULL];
        }];
  
        [self->mSocket connect];
     
    }
    @catch (NSException *e)
    {
        NSLog(@"ClassRoom enter error %@ %@", e.name, e.reason);
    }
}

-(void)Exit
{
    if(mSocket) {
        [mSocket disconnect];
    }
}

-(void)ClassBegin
{
    @try {
        if ([self isEntered]) {
            
            if (self.classroom_info.role == 2) {
                
                NSMutableDictionary *control = [NSMutableDictionary new];
                control[@"command"] = @"begin_class";
                
                [[mSocket emitWithAck:@"control" with:@[control]] timingOutAfter:(0) callback:^(NSArray *data) {
                    @try {
                         
                        NSDictionary *r = [data lastObject];
                        
                        int control_errorcode = [r[@"errorCode"] intValue];
                        
                        if (control_errorcode == 0) {
                            [self Event:ClassBeginControlResult args1:[NSNumber numberWithBool:true] args2:NULL args3:NULL];
                        } else {
                            [self Event:ClassBeginControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
                        }
                    }
                    @catch (NSException *e) {
                        NSLog(@"ClassRoom class_begin control_ack error %@ %@", e.name, e.reason);
                    }
                }];
            } else {
                [self Event:ClassBeginControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
            }
        }
    } @catch (NSException *e) {
        NSLog(@"ClassRoom class_begin error %@ %@", e.name, e.reason);
    }
}

-(void)ClassEnd
{
    
    @try {
        if ([self isEntered]) {
            
            if (self.classroom_info.role == 2) {
                
                NSMutableDictionary *control = [NSMutableDictionary new];
                control[@"command"] = @"end_class";
                
                [[mSocket emitWithAck:@"control" with:@[control]] timingOutAfter:(0) callback:^(NSArray *data) {
                    @try {
                         
                        NSDictionary *r = [data lastObject];
                        
                        int control_errorcode = [r[@"errorCode"] intValue];
                        
                        if (control_errorcode == 0) {
                            [self Event:ClassEndControlResult args1:[NSNumber numberWithBool:true] args2:NULL args3:NULL];
                        } else {
                            [self Event:ClassEndControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
                        }
                    }
                    @catch (NSException *e) {
                        NSLog(@"ClassRoom class_end control_ack error %@ %@", e.name, e.reason);
                    }
                }];
            } else {
                [self Event:ClassEndControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
            }
        }
    } @catch (NSException *e) {
        NSLog(@"ClassRoom class_end error %@ %@", e.name, e.reason);
    }
}

-(void)TeachingCount
{
    @try {
        if ([self isEntered]) {
            
            if (self.classroom_info.role == 2) {
                
                NSMutableDictionary *control = [NSMutableDictionary new];
                control[@"command"] = @"teaching_count";
                
                [[mSocket emitWithAck:@"control" with:@[control]] timingOutAfter:(0) callback:^(NSArray *data) {
                    @try {
                         
                        NSDictionary *r = [data lastObject];
                        
                        int control_errorcode = [r[@"errorCode"] intValue];
                        
                        if (control_errorcode == 0) {
                            [self Event:ClassTeachingCountControlResult args1:[NSNumber numberWithBool:true] args2:NULL args3:NULL];
                        } else {
                            [self Event:ClassTeachingCountControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
                        }
                    }
                    @catch (NSException *e) {
                        NSLog(@"ClassRoom teaching_count control_ack error %@ %@", e.name, e.reason);
                    }
                }];
            } else {
                [self Event:ClassTeachingCountControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
            }
        }
    } @catch (NSException *e) {
        NSLog(@"ClassRoom teaching_count error %@ %@", e.name, e.reason);
    }
}

-(void)ConnectDataService{
    [self DisconnectDataService];
    
    data_service = [DataService new];
    [data_service SetServer:self.classroom_info.data_server_url server_port:[self.classroom_info.data_server_port intValue] access_token:_classroom_info.data_server_access_token];
    data_service.delegate = self;
    [data_service SetRetry:0];
    
    [data_service Connect];
}

-(void)DisconnectDataService
{
    if (data_service) {
        [data_service Disconnect];
        data_service = nil;
    }
}

-(void)on_data_service_event:(SERVICE_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2
{
    if (event == ServiceConnectionBeginEvent) {
        data_service_connected = false;
    } else if (event == ServiceConnectingEvent) {
        NSLog(@"data service 正在连接远程服务器");
        [self Event:ClassDataServiceConnecting args1:NULL args2:NULL args3:NULL];
    } else if (event == ServiceConnectedEvent) {
        NSLog(@"data service 服务器连接成功");
    } else if (event == ServiceAuthEvent) {
        if ([(NSNumber *)args1 boolValue]) {
            NSLog(@"data service 远程服务器登陆成功");
            data_service_connected = true;
            [self Event:ClassDataServiceConnectSuccess args1:NULL args2:NULL args3:NULL];
        } else {
            NSString *error = (NSString *)args2;
            NSLog(@"data service 远程服务器登陆失败 %@" , error);  // 这个可以提示用户，包含服务器满载时的错误信息
            [self Event:ClassDataServiceConnectFailed args1:error args2: NULL args3: NULL];
        }
    } else if (event == ServiceReceiveForwardDataEvent) {

        NSData *data = (NSData *)args1;

        DataCodec* data_codec = [DataCodec new];
        if ([data_codec Decode:data]) {
            if (data_codec.version == 0) { //通信版本
                if (data_codec.type == type_audio) {  //数据类型音频
                    if (data_codec.format == 0) {  //格式wav
                        //指接收教师的音频数据
                        if (self.classroom_info.teacher_id == data_codec.user_id) {
                            [self Event:ClassDataServiceWavFrameReceived args1:[NSNumber numberWithInt:data_codec.flag] args2:data_codec.data args3:NULL];
                        }
                    }
                } else if (data_codec.type == type_cmd) {
                    if (self.classroom_info.teacher_id == data_codec.user_id) { //只接收采集人的指令
                        [self Event:ClassDataServiceCmdReceived args1:[NSNumber numberWithInt:data_codec.command] args2:data_codec.data args3:NULL];
                    }
                }
            }
        }

        //NSLog(@"data service 收到服务器数据包：" + data.length);
    } else if (event == ServiceReceiveClientInfoEvent) {

        NSData *data = (NSData *)args1;

        int type = [clients Decode:data];

        if (type == 0) {
            [self Event:ClassDataServiceClientInfoReceived args1:@(0) args2:NULL args3:clients];
            NSLog(@"data service 在线客户：%d", (int)[clients count]);
        } else if (type == 1) {
            [self Event:ClassDataServiceClientInfoReceived args1:@(1) args2:@(clients.member) args3:clients];
            NSLog(@"data service 新上线 %d", clients.member);
        } else if (type == 2) {
            [self Event:ClassDataServiceClientInfoReceived args1:@(-1) args2:@(clients.member) args3:clients];
            NSLog(@"data service 下线 %d", clients.member);
        }

        //NSLog(@"data service 收到服务器数据包：" + data.length);

    } else if (event == ServiceConnectFailEvent) {
        NSLog(@"data service 远程服务器连接失败");
        [self Event:ClassDataServiceConnectFailed args1:@"" args2:NULL args3:NULL];
    } else if (event == ServiceDisconnectEvent) {
        data_service_connected = false;
        [self Event:ClassDataServiceDisconnected args1:NULL args2:NULL args3:NULL];
        NSLog(@"data service 远程服务器断开了");
    } else if (event == ServiceConnectionEndEvent) {

    }
}

-(void)StartAuscultation
{
    @try {
        if ([self isEntered]) {
            
            if (self.classroom_info.role == 2) {
                
                NSMutableDictionary *control = [NSMutableDictionary new];
                control[@"command"] = @"start_auscultation";
                
                [[mSocket emitWithAck:@"control" with:@[control]] timingOutAfter:(0) callback:^(NSArray *data) {
                    @try {
                         
                        NSDictionary *r = [data lastObject];
                        
                        int control_errorcode = [r[@"errorCode"] intValue];
                        
                        if (control_errorcode == 0) {
                            [self Event:ClassStartAuscultationControlResult args1:[NSNumber numberWithBool:true] args2:NULL args3:NULL];
                        } else {
                            [self Event:ClassStartAuscultationControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
                        }
                    }
                    @catch (NSException *e) {
                        NSLog(@"ClassRoom start_auscultation control_ack error %@ %@", e.name, e.reason);
                    }
                }];
            } else {
                [self Event:ClassStartAuscultationControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
            }
        }
    } @catch (NSException *e) {
        NSLog(@"ClassRoom start_auscultation error %@ %@", e.name, e.reason);
    }
}

-(void)StopAuscultation
{
    @try {
        if ([self isEntered]) {
            
            if (self.classroom_info.role == 2) {
                
                NSMutableDictionary *control = [NSMutableDictionary new];
                control[@"command"] = @"stop_auscultation";
                
                [[mSocket emitWithAck:@"control" with:@[control]] timingOutAfter:(0) callback:^(NSArray *data) {
                    @try {
                         
                        NSDictionary *r = [data lastObject];
                        
                        int control_errorcode = [r[@"errorCode"] intValue];
                        
                        if (control_errorcode == 0) {
                            [self Event:ClassStopAuscultationControlResult args1:[NSNumber numberWithBool:true] args2:NULL args3:NULL];
                        } else {
                            [self Event:ClassStopAuscultationControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
                        }
                    }
                    @catch (NSException *e) {
                        NSLog(@"ClassRoom stop_auscultation control_ack error %@ %@", e.name, e.reason);
                    }
                }];
            } else {
                [self Event:ClassStopAuscultationControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
            }
        }
    } @catch (NSException *e) {
        NSLog(@"ClassRoom stop_auscultation error %@ %@", e.name, e.reason);
    }
}

@end
