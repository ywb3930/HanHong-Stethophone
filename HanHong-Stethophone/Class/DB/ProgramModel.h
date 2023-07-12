//
//  ProgramModel.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProgramModel : NSObject

@property (assign, nonatomic) long                  program_id;
@property (assign, nonatomic) NSString              *program_title;//计划标题
@property (assign, nonatomic) long                  startTime;//开始时间
@property (assign, nonatomic) long                  endTime;//结束时间
@property (assign, nonatomic) NSInteger             duration;//时长（分钟）
@property (assign, nonatomic) NSString              *system_calender_reminder;//存储接送记录提醒的内容数组

@end

NS_ASSUME_NONNULL_END
