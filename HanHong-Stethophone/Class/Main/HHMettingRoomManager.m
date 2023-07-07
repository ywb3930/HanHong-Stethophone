//
//  HHMettingRoomManager.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/7.
//

#import "HHMettingRoomManager.h"

@implementation HHMettingRoomManager
static MeetingRoom             *_mettingRoom;

+(instancetype)shareManager{
    static HHMettingRoomManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HHMettingRoomManager alloc] init];
        [manager initMettingRoom];
    });
    
    return manager;
}

- (void)on_meetingroom_event:(MEETINGROOM_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3{
    
}

- (void)initMettingRoom{
    _mettingRoom = [[MeetingRoom alloc] init];
    _mettingRoom.delegate = self;
}

@end
