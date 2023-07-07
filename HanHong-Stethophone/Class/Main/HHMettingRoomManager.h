//
//  HHMettingRoomManager.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/7.
//

#import <Foundation/Foundation.h>
#import "MeetingRoom.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHMettingRoomManager : NSObject<MeetingRoomDelegate>
+ (instancetype)shareManager;

@end

NS_ASSUME_NONNULL_END
