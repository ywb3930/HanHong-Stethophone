//
//  MeetingRoom.m
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/28.
//

#import "MeetingRoom.h"

@import SocketIO;

//
// 使用socket.io-client-swift 库，库中有一个bug，就是连接服务器时，服务器发的数据收不到，需要手改库的代码，在 SocketIOClient 384～385 行 增加一行代码  didConnect(toNamespace: nsp);
// 如下：
// case .event, .binaryEvent:
//    didConnect(toNamespace: nsp);
//    handleEvent(packet.event, data: packet.args, isInternalMessage: false, withAck: packet.id)
//

@implementation MeetingRoomInfo{
    
}

-(instancetype)init{
    self = [super init];
    return self;
}

@end

static int meetingroom_enter_state = 0;

@implementation MeetingRoom {
    
    SocketManager *mSocketManager;
    SocketIOClient *mSocket;
     
    DataService *data_service;
    
//    SocketManager *mSocket_data_serviceManager;
//    SocketIOClient *mSocket_data_service;
  
    Clients *clients;
    
    //BOOL meetingroom_entered;
    
    BOOL data_service_connected;
     
}

-(instancetype)init
{
    self = [super init];
    
    if(self) {
        mSocketManager = NULL;
        mSocket = NULL;
        
        clients = [Clients new];
        
        //meetingroom_entered = false;
        
        data_service_connected = false;
        
        _delegate = NULL;
        
        self.online_member_list = NULL;
         
        _meetingroom_info = [MeetingRoomInfo new];
         
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

-(void)Event:(MEETINGROOM_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3
{
    if (_delegate) {
        @try {
            [_delegate on_meetingroom_event:event args1:args1 args2:args2 args3:args3];
        } @catch (NSException *exception) {
            NSLog(@"MeetingRoom event callback error");
        }
    }
}

-(BOOL)isEntered{
   // return meetingroom_entered;
    return meetingroom_enter_state == 2;
}
  
-(BOOL)Enter:(NSString *)token meetingroom_url:(NSString *)meetingroom_url meetingroom_id:(int)meetingroom_id
{
    @try{
        
        if (meetingroom_enter_state != 0) {
            return false;
        }
        
        NSString *teaching_namespace = @"/api/meeting/meetingroom";

        NSRange range = [meetingroom_url rangeOfString:teaching_namespace];
        NSString *host;

        if (range.location != NSNotFound) {

            host = [meetingroom_url substringToIndex:range.location];

        } else {
            NSLog(@"MeetingRoom url error");
            [self Event:MeetingEnterFailed args1:NULL args2:NULL args3:NULL];
            return false;
        }
           
        NSURL *socketURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", host]];

        mSocketManager = [[SocketManager alloc] initWithSocketURL:socketURL config:@{@"log": @NO, @"compress": @YES, @"connectParams":@{@"token":token, @"id":[NSString stringWithFormat:@"%d", meetingroom_id]}}];
        mSocket = [mSocketManager socketForNamespace:teaching_namespace];

//        [mSocket onAny:^(SocketAnyEvent *event) {
//            NSLog(@"Received event: %@, with items: %@", event.event, event.items);
//        }];

        [mSocket on:@"connect" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"SocketIO connect");
        }];

        [mSocket on:@"disconnect" callback:^(NSArray * data, SocketAckEmitter * ack) {
           
            [self DisconnectDataService];
            
            //if (self->meetingroom_entered) {
            if (meetingroom_enter_state == 2) {
                meetingroom_enter_state = 0;
                NSLog(@"MeetingRoom exit");
                [self Event:MeetingExited args1:NULL args2:NULL args3:NULL];
            } else {
                meetingroom_enter_state = 0;
                NSLog(@"MeetingRoom enter failed");
                [self Event:MeetingEnterFailed args1:NULL args2:NULL args3:NULL];
            }
            //self->meetingroom_entered = false;
        }];

        [mSocket on:@"meetingroom" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket meetingroom");
            
            @try {
                
                NSDictionary *mdata = [data lastObject][@"data"];
                
                self.meetingroom_info.meetingroom_id = [mdata[@"meetingroom_id"] intValue];
                self.meetingroom_info.creator_id = [mdata[@"creator_id"] intValue];
                self.meetingroom_info.collector_id = [mdata[@"collector_id"] intValue];
                self.meetingroom_info.title = mdata[@"title"];
                self.meetingroom_info.begin_time = mdata[@"begin_time"];
                self.meetingroom_info.end_time = mdata[@"end_time"];
                self.meetingroom_info.create_time = mdata[@"create_time"];
                
                NSArray *marray = mdata[@"members"];
                
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
                    
                    self.meetingroom_info.meeting_member_list = [[MemberList alloc] initWithMembers:members];
                } else {
                    self.meetingroom_info.meeting_member_list = [MemberList new];
                }
                
                @try
                {
                    if (mdata[@"data_server_url"] != NULL) {
                        self.meetingroom_info.data_server_url = mdata[@"data_server_url"];
                   
                        self.meetingroom_info.data_server_port = mdata[@"data_server_port"];
                        self.meetingroom_info.data_server_access_token = mdata[@"data_server_access_token"];
                    }
                     
                    if (mdata[@"user_id"] != NULL) {
                        self.meetingroom_info.user_id = [mdata[@"user_id"] intValue];
                        self.meetingroom_info.role = [mdata[@"role"] intValue];
                    }
                }
                @catch (NSException *e) {
                    
                }
                
                //if (self->meetingroom_entered == false) {
                //    self->meetingroom_entered = true;
                    
                if (meetingroom_enter_state < 2) {
                    
                    meetingroom_enter_state = 2;
                    
                    NSLog(@"MeetingRoom enter room sucess");
                    
                    [self Event:MeetingEnterSuccess args1:NULL args2:NULL args3:NULL];
                    [self Event:MeetingInfoUpdate args1:self.meetingroom_info args2:NULL args3:NULL];
                } else {
                    NSLog(@"MeetingRoom room info update");
                    [self Event:MeetingInfoUpdate args1:self.meetingroom_info args2:NULL args3:NULL];
                }
                
            } @catch (NSException *exception) {
                
                NSLog(@"MeetingRoom error %@ %@", exception.name, exception.reason);
                
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
                
                [self Event:MeetingMemberUpdate args1:@(0) args2:NULL args3:self.online_member_list];
            }
            @catch (NSException *e) {
                NSLog(@"MeetingRoom room_user error %@ %@", e.name, e.reason);
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
      
                [self Event:MeetingMemberUpdate args1:@(1) args2:member args3:self.online_member_list];
            }
            @catch (NSException *e) {
                NSLog(@"MeetingRoom join_room error %@ %@", e.name, e.reason);
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
      
                [self Event:MeetingMemberUpdate args1:@(-1) args2:member args3:self.online_member_list];
            }
            @catch (NSException *e) {
                NSLog(@"MeetingRoom leave_room error %@ %@", e.name, e.reason);
            }
            
        }];

        [mSocket on:@"auscultation_state" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket auscultation_state");
            
            @try {
                 
                NSDictionary *s = [data lastObject][@"data"];
                
                int state = [s[@"auscultation_state"] intValue];
                
                if (state == 1) {
                    [self ConnectDataService];
                    [self Event:MeetingStartAuscultation args1:NULL args2:NULL args3:NULL];
                } else {
                    [self DisconnectDataService];
                    [self Event:MeetingStopAuscultation args1:NULL args2:NULL args3:NULL];
                }
            }
            @catch (NSException *e) {
                NSLog(@"MeetingRoom auscultation_state error %@ %@", e.name, e.reason);
            }
        }];

        [mSocket on:@"error" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket error");
            [self->mSocket disconnect];
        }];
        
        [mSocket on:@"connecting" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket connecting");
            [self Event:MeetingEntering args1:NULL args2:NULL args3:NULL];
        }];

        [mSocket on:@"connect_failed" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket error");
            [self Event:MeetingEnterFailed args1:NULL args2:NULL args3:NULL];
        }];
        

        [mSocket on:@"reconnect" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket reconnecting");
        }];
        
        [mSocket on:@"reconnecting" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket reconnecting");
            [self Event:MeetingEntering args1:NULL args2:NULL args3:NULL];
        }];

        [mSocket on:@"reconnect_failed" callback:^(NSArray * data, SocketAckEmitter * ack) {
            NSLog(@"Socket reconnect failed");
            [self Event:MeetingEnterFailed args1:NULL args2:NULL args3:NULL];
        }];
  
        meetingroom_enter_state = 1;
        [self->mSocket connect];
     
        return true;
        
    }
    @catch (NSException *e)
    {
        NSLog(@"MeetingRoom enter error %@ %@", e.name, e.reason);
        meetingroom_enter_state = 0;
    }
    
    return false;
}

-(void)Exit
{
    if(mSocket) {
        [mSocket disconnect];
    }
}

-(void)SetCollector:(int)collector_id
{
    @try {
        if ([self isEntered]) {
            
            if (self.meetingroom_info.creator_id == self.meetingroom_info.user_id) {
                
                NSMutableDictionary *control = [NSMutableDictionary new];
                control[@"command"] = @"set_collector";
                control[@"collector_id"] = [NSString stringWithFormat:@"%d", collector_id];
                
                [[mSocket emitWithAck:@"control" with:@[control]] timingOutAfter:(0) callback:^(NSArray *data) {
                    @try {
                         
                        NSDictionary *r = [data lastObject];
                        
                        int control_errorcode = [r[@"errorCode"] intValue];
                        
                        if (control_errorcode == 0) {
                            [self Event:MeetingSetCollectorControlResult args1:[NSNumber numberWithBool:true] args2:NULL args3:NULL];
                        } else {
                            [self Event:MeetingSetCollectorControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
                        }
                    }
                    @catch (NSException *e) {
                        NSLog(@"MeetingRoom set_collector control_ack error %@ %@", e.name, e.reason);
                    }
                }];
            } else {
                [self Event:MeetingSetCollectorControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
            }
        }
    } @catch (NSException *e) {
        NSLog(@"MeetingRoom set_collector error %@ %@", e.name, e.reason);
    }
}

-(void)ModifyMeeting:(NSString *)title begin:(NSString *)begin end:(NSString *)end collector_id:(NSString *)collector_id member_id:(NSArray<NSNumber *> *)member_id
{
 
    @try {
        if ([self isEntered]) {
            
            if (self.meetingroom_info.creator_id == self.meetingroom_info.user_id) {
                
                NSMutableDictionary *control = [NSMutableDictionary new];
                control[@"command"] = @"modify_meeting";
                if (title) {
                    control[@"title"] = title;
                }
                if (begin) {
                    control[@"begin"] = begin;
                }
                if(end) {
                    control[@"end"] = end;
                }
                if(collector_id) {
                    control[@"collector_id"] = collector_id;
                }
                if (member_id) {
                    NSMutableArray *members_json = [NSMutableArray array];
                    for (NSNumber *member in member_id) {
                        NSDictionary *member_json = @{@"id": member};
                        [members_json addObject:member_json];
                    }
                    control[@"members"] = members_json;
                }
                 
                [[mSocket emitWithAck:@"control" with:@[control]] timingOutAfter:(0) callback:^(NSArray *data) {
                    @try {
                         
                        NSDictionary *r = [data lastObject];
                        
                        int control_errorcode = [r[@"errorCode"] intValue];
                        
                        if (control_errorcode == 0) {
                            [self Event:MeetingModifyMeetingControlResult args1:[NSNumber numberWithBool:true] args2:NULL args3:NULL];
                        } else {
                            [self Event:MeetingModifyMeetingControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
                        }
                    }
                    @catch (NSException *e) {
                        NSLog(@"MeetingRoom modify_meeting control_ack error %@ %@", e.name, e.reason);
                    }
                }];
            } else {
                [self Event:MeetingModifyMeetingControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
            }
        }
    } @catch (NSException *e) {
        NSLog(@"MeetingRoom modify_meeting error %@ %@", e.name, e.reason);
    }
}

-(void)ConnectDataService{
    [self DisconnectDataService];
    
    data_service = [DataService new];
    [data_service SetServer:self.meetingroom_info.data_server_url server_port:[self.meetingroom_info.data_server_port intValue] access_token:_meetingroom_info.data_server_access_token];
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
        [self Event:MeetingDataServiceConnecting args1:NULL args2:NULL args3:NULL];
    } else if (event == ServiceConnectedEvent) {
        NSLog(@"data service 服务器连接成功");
    } else if (event == ServiceAuthEvent) {
        if ([(NSNumber *)args1 boolValue]) {
            NSLog(@"data service 远程服务器登陆成功");
            data_service_connected = true;
            [self Event:MeetingDataServiceConnectSuccess args1:NULL args2:NULL args3:NULL];
        } else {
            NSString *error = (NSString *)args2;
            NSLog(@"data service 远程服务器登陆失败 %@" , error);  // 这个可以提示用户，包含服务器满载时的错误信息
            [self Event:MeetingDataServiceConnectFailed args1:error args2: NULL args3: NULL];
        }
    } else if (event == ServiceReceiveForwardDataEvent) {

        NSData *data = (NSData *)args1;

        DataCodec* data_codec = [DataCodec new];
        if ([data_codec Decode:data]) {
            if (data_codec.version == 0) { //通信版本
                if (data_codec.type == type_audio) {  //数据类型音频
                    if (data_codec.format == 0) {  //格式wav
                        //指接收教师的音频数据
                        if (self.meetingroom_info.collector_id == data_codec.user_id) {
                            [self Event:MeetingDataServiceWavFrameReceived args1:[NSNumber numberWithInt:data_codec.flag] args2:data_codec.data args3:NULL];
                        }
                    }
                } else if (data_codec.type == type_cmd) {
                    if (self.meetingroom_info.collector_id == data_codec.user_id) { //只接收采集人的指令
                        [self Event:MeetingDataServiceCmdReceived args1:[NSNumber numberWithInt:data_codec.command] args2:data_codec.data args3:NULL];
                    }
                }
            }
        }

        //NSLog(@"data service 收到服务器数据包：" + data.length);
    } else if (event == ServiceReceiveClientInfoEvent) {

        NSData *data = (NSData *)args1;

        int type = [clients Decode:data];

        if (type == 0) {
            [self Event:MeetingDataServiceClientInfoReceived args1:@(0) args2:NULL args3:clients];
            NSLog(@"data service 在线客户：%d", (int)[clients count]);
        } else if (type == 1) {
            [self Event:MeetingDataServiceClientInfoReceived args1:@(1) args2:@(clients.member) args3:clients];
            NSLog(@"data service 新上线 %d", clients.member);
        } else if (type == 2) {
            [self Event:MeetingDataServiceClientInfoReceived args1:@(-1) args2:@(clients.member) args3:clients];
            NSLog(@"data service 下线 %d", clients.member);
        }

        //NSLog(@"data service 收到服务器数据包：" + data.length);

    } else if (event == ServiceConnectFailEvent) {
        NSLog(@"data service 远程服务器连接失败");
        [self Event:MeetingDataServiceConnectFailed args1:@"" args2:NULL args3:NULL];
    } else if (event == ServiceDisconnectEvent) {
        data_service_connected = false;
        [self Event:MeetingDataServiceDisconnected args1:NULL args2:NULL args3:NULL];
        NSLog(@"data service 远程服务器断开了");
    } else if (event == ServiceConnectionEndEvent) {

    }
}

-(void)StartAuscultation
{
    @try {
        if ([self isEntered]) {
            
            if (self.meetingroom_info.collector_id == self.meetingroom_info.user_id) {
                
                NSMutableDictionary *control = [NSMutableDictionary new];
                control[@"command"] = @"start_auscultation";
                
                [[mSocket emitWithAck:@"control" with:@[control]] timingOutAfter:(0) callback:^(NSArray *data) {
                    @try {
                         
                        NSDictionary *r = [data lastObject];
                        
                        int control_errorcode = [r[@"errorCode"] intValue];
                        
                        if (control_errorcode == 0) {
                            [self Event:MeetingStartAuscultationControlResult args1:[NSNumber numberWithBool:true] args2:NULL args3:NULL];
                        } else {
                            [self Event:MeetingStartAuscultationControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
                        }
                    }
                    @catch (NSException *e) {
                        NSLog(@"MeetingRoom start_auscultation control_ack error %@ %@", e.name, e.reason);
                    }
                }];
            } else {
                [self Event:MeetingStartAuscultationControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
            }
        }
    } @catch (NSException *e) {
        NSLog(@"MeetingRoom start_auscultation error %@ %@", e.name, e.reason);
    }
}

-(void)StopAuscultation
{
    @try {
        if ([self isEntered]) {
            
            if (self.meetingroom_info.collector_id == self.meetingroom_info.user_id) {
                
                NSMutableDictionary *control = [NSMutableDictionary new];
                control[@"command"] = @"stop_auscultation";
                
                [[mSocket emitWithAck:@"control" with:@[control]] timingOutAfter:(0) callback:^(NSArray *data) {
                    @try {
                         
                        NSDictionary *r = [data lastObject];
                        
                        int control_errorcode = [r[@"errorCode"] intValue];
                        
                        if (control_errorcode == 0) {
                            [self Event:MeetingStopAuscultationControlResult args1:[NSNumber numberWithBool:true] args2:NULL args3:NULL];
                        } else {
                            [self Event:MeetingStopAuscultationControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
                        }
                    }
                    @catch (NSException *e) {
                        NSLog(@"MeetingRoom stop_auscultation control_ack error %@ %@", e.name, e.reason);
                    }
                }];
            } else {
                [self Event:MeetingStopAuscultationControlResult args1:[NSNumber numberWithBool:false] args2:NULL args3:NULL];
            }
        }
    } @catch (NSException *e) {
        NSLog(@"MeetingRoom stop_auscultation error %@ %@", e.name, e.reason);
    }
}

@end
