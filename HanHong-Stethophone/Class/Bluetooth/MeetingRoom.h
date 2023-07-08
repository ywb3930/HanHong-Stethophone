//
//  MeetingRoom.h
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/28.
//

#ifndef MeetingRoom_h
#define MeetingRoom_h

#import <Foundation/Foundation.h>

#import "MemberList.h"
#import "Member.h"
#import "DataService.h"

@interface MeetingRoomInfo : NSObject

@property (assign, nonatomic) int meetingroom_id;
@property (assign, nonatomic) int collector_id;
@property (assign, nonatomic) int creator_id;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *begin_time;
@property (copy, nonatomic) NSString *end_time;
@property (copy, nonatomic) NSString *create_time;
@property (strong, nonatomic) MemberList *meeting_member_list;
@property (copy, nonatomic) NSString *data_server_url;
@property (copy, nonatomic) NSString *data_server_port;
@property (copy, nonatomic) NSString *data_server_access_token;
@property (assign, nonatomic) int user_id;
@property (assign, nonatomic) int role;

@end

typedef NS_ENUM(NSInteger, MEETINGROOM_EVENT)
{
    MeetingEntering = 0, //正在连接
    MeetingEnterSuccess = 1, //连接成功
    MeetingEnterFailed = 2,//连接失败
    MeetingExited = 3,//连接断开了
    MeetingInfoUpdate = 4, //房间状态变更 1个参数 meetingroom_info(MeetingRoomInfo)，里面有房间的基本信息，具体查看 MeetingRoomInfo 类
    MeetingMemberUpdate = 5, //房间人员变更 3个参数
    // type(int)                    0 首次进入房间，获取的清单    1 新成员上线         -1 成员下线
    // member(Member)              null                        新成员的Member       下线成员的Member
    // online_member_list(MemberList)     最终MemberList对象          最终MemberList对象  最终MemberList对象

    MeetingSetCollectorControlResult = 6, //返回 1个参数 （int)  0 失败， 1 成功

    MeetingModifyMeetingControlResult = 7, //返回 1个参数 （int)  0 失败， 1 成功

    MeetingStartAuscultationControlResult = 8, //返回 1个参数 （int)  0 失败， 1 成功
    MeetingStopAuscultationControlResult = 9, //返回 1个参数 （int)  0 失败， 1 成功

    MeetingStartAuscultation = 10,
    MeetingStopAuscultation = 11,

    MeetingDataServiceConnecting = 12,
    MeetingDataServiceConnectSuccess = 13,
    MeetingDataServiceConnectFailed = 14,
    MeetingDataServiceDisconnected = 15,
    MeetingDataServiceWavFrameReceived = 16,  //返回 2个参数
    MeetingDataServiceCmdReceived = 17,
    MeetingDataServiceClientInfoReceived = 18, //返回 3个参数
};

@protocol MeetingRoomDelegate <NSObject>

-(void)on_meetingroom_event:(MEETINGROOM_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3;

@end

@interface MeetingRoom : NSObject<DataServiceDelegate> {
    
}

@property (weak, nonatomic) id<MeetingRoomDelegate> delegate;

@property (strong, atomic) MemberList * online_member_list;
@property (strong, atomic) MeetingRoomInfo *meetingroom_info;


-(BOOL)DataServiceConnected;
-(BOOL)SendWavFrame:(int)flag wav_frame:(NSData*)wav_frame;
-(BOOL)SendCommand:(int)command data:(NSData*)data;
-(BOOL)isEntered;
-(void)Enter:(NSString *)token meetingroom_url:(NSString *)meetingroom_url meetingroom_id:(int)meetingroom_id;
-(void)Exit;
-(void)SetCollector:(int)collector_id;
-(void)ModifyMeeting:(NSString *)title begin:(NSString *)begin end:(NSString *)end collector_id:(NSString *)collector_id member_id:(NSArray<NSNumber *> *)member_id;
-(void)ConnectDataService;
-(void)DisconnectDataService;
-(void)StartAuscultation;
-(void)StopAuscultation;

@end

#endif /* MeetingRoom_h */
