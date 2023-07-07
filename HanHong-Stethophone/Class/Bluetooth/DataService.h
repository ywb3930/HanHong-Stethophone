//
//  DataService.h
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/28.
//

#ifndef DataService_h
#define DataService_h

#import <Foundation/Foundation.h>

@interface Packet : NSObject

@property (copy, nonatomic, readonly) NSData *data;
@property (assign, nonatomic, readonly) int type;
-(instancetype)initWithData:(int)type data:(NSData *)data;
@end


@interface Clients : NSObject

@property (copy, nonatomic, readonly) NSArray<NSNumber *> *members;
@property (assign, nonatomic, readonly) int member;
 
-(int)Decode:(NSData*)data;
-(NSArray<NSNumber *> *)members;
-(int)count;

@end

typedef NS_ENUM(NSInteger, DataCodec_Type)
{
    type_audio = 0,
    type_cmd = 1
};

@interface DataCodec : NSObject
{
    
}

@property (assign, nonatomic) int user_id;
@property (assign, nonatomic) int version;
@property (assign, nonatomic) int type;
@property (assign, nonatomic) int format;
@property (assign, nonatomic) int flag;
@property (assign, nonatomic) int command;
@property (copy, nonatomic) NSData *data;

-(instancetype)init:(int)version type:(int)type format:(int)format flag:(int)flag data:(NSData *)data;
-(instancetype)init:(int)version type:(int)type cmd:(int)cmd data:(NSData *)data;

-(BOOL)Decode:(NSData*)data;
-(NSData *)Encode;

@end

typedef NS_ENUM(NSInteger, SERVICE_EVENT)
{
    ServiceConnectionBeginEvent,// 连接开始
    ServiceConnectingEvent,// 正在连接
    ServiceConnectFailEvent,// 连接失败
    ServiceConnectedEvent,// 已连接
    ServiceAuthEvent, //身份认证
    ServiceReceiveForwardDataEvent,// 接收转发数据
    ServiceReceiveClientInfoEvent, // 接收在线客户信息
    ServiceDisconnectEvent,// 已断开
    ServiceConnectionEndEvent,// 连接关闭
};

typedef NS_ENUM(NSInteger, DATA_TYPE)
{
    DATA_TYPE_TOKEN = 0,
    DATA_TYPE_RESPONSE = 1,
    DATA_TYPE_HEARTBIT = 2,
    DATA_TYPE_FORWARD_DATA = 3,
    DATA_TYPE_CLIENT_INFO = 4
};

@protocol DataServiceDelegate <NSObject>

-(void)on_data_service_event:(SERVICE_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2;

@end

@interface DataService : NSObject
{
    
}

@property (weak, nonatomic) id<DataServiceDelegate> delegate; //通过代理事件和数据

-(void)SetServer:(NSString *)server_domain_or_ip server_port:(int)server_port access_token:(NSString *)access_token;
-(BOOL)Running;
-(void)SetRetry:(int)retry;
-(BOOL)Connect;
-(void)Disconnect;
-(void)SendDataBufferClear;
-(BOOL)SendData:(NSData *)data timeout:timeout;
 
@end

#endif /* DataService_h */
