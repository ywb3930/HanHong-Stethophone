//
//  ClassRoom.h
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/28.
//

#ifndef ClassRoom_h
#define ClassRoom_h

#import <Foundation/Foundation.h>

#import "MemberList.h"
#import "Member.h"
#import "DataService.h"

@interface ClassRoomInfo : NSObject

@property (assign, nonatomic) int classroom_id;
@property (assign, nonatomic) int teacher_id;
@property (copy, nonatomic) NSString *teacher_name;
@property (copy, nonatomic) NSString *teacher_avatar;
@property (assign, nonatomic) int class_state;
@property (copy, nonatomic) NSString *class_begin_time;
@property (copy, nonatomic) NSString *class_end_time;
@property (copy, nonatomic) NSString *create_time;
@property (assign, nonatomic) int number_of_learners;
@property (assign, nonatomic) int teaching_times;
@property (strong, nonatomic) MemberList *students_list;
@property (copy, nonatomic) NSString *data_server_url;
@property (copy, nonatomic) NSString *data_server_port;
@property (copy, nonatomic) NSString *data_server_access_token;
@property (assign, nonatomic) int user_id;
@property (assign, nonatomic) int role;

@end

typedef NS_ENUM(NSInteger, CLASSROOM_EVENT)
{
    ClassEntering = 0, //正在连接
    ClassEnterSuccess = 1, //连接成功
    ClassEnterFailed = 2,//连接失败
    ClassExited = 3,//连接断开了
    ClassInfoUpdate = 4, //房间状态变更 1个参数 classroom_info(ClassRoomInfo)，里面有房间的基本信息，具体查看 ClassRoomInfo 类
    ClassMemberUpdate = 5, //房间人员变更 3个参数
    // type(int)                    0 首次进入房间，获取的清单    1 新成员上线         -1 成员下线
    // member(Member)              null                        新成员的Member       下线成员的Member
    // online_member_list(MemberList)     最终MemberList对象          最终MemberList对象  最终MemberList对象
 
    ClassBeginControlResult = 6, //返回 1个参数 （int)  0 失败， 1 成功
    ClassEndControlResult = 7, //返回 1个参数 （int)  0 失败， 1 成功
    
    ClassStartAuscultationControlResult = 8, //返回 1个参数 （int)  0 失败， 1 成功
    ClassStopAuscultationControlResult = 9, //返回 1个参数 （int)  0 失败， 1 成功

    ClassStartAuscultation = 10,
    ClassStopAuscultation = 11,

    ClassTeachingCountControlResult = 19, //返回 1个参数 （int)  0 失败， 1 成功
 
    ClassDataServiceConnecting = 12,
    ClassDataServiceConnectSuccess = 13,
    ClassDataServiceConnectFailed = 14,
    ClassDataServiceDisconnected = 15,
    ClassDataServiceWavFrameReceived = 16,  //返回 2个参数
    ClassDataServiceCmdReceived = 17, 
    ClassDataServiceClientInfoReceived = 18, //返回 3个参数
};

@protocol ClassRoomDelegate <NSObject>

-(void)on_classroom_event:(CLASSROOM_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3;

@end

@interface ClassRoom : NSObject<DataServiceDelegate> {
    
}

@property (weak, nonatomic) id<ClassRoomDelegate> delegate;

@property (strong, atomic) MemberList * online_member_list;
@property (strong, atomic) ClassRoomInfo *classroom_info;


-(BOOL)DataServiceConnected;
-(BOOL)SendWavFrame:(int)flag wav_frame:(NSData*)wav_frame;
-(BOOL)SendCommand:(int)command data:(NSData*)data;
-(BOOL)isEntered;
-(void)Enter:(NSString *)token classroom_url:(NSString *)classroom_url classroom_id:(int)classroom_id;
-(void)Exit;
-(void)ClassBegin;
-(void)ClassEnd;
-(void)TeachingCount;
-(void)ConnectDataService;
-(void)DisconnectDataService;
-(void)StartAuscultation;
-(void)StopAuscultation;

@end

#endif /* ClassRoom_h */
