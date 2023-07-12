//
//  HHCalendarDayModel.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/25.
//

#import <Foundation/Foundation.h>
#import "ProgramModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHCalendarDayModel : NSObject

@property (assign, nonatomic) NSInteger             dayValue;//当天日期
@property (assign, nonatomic) Boolean               bCurrentDay;//是否时当天
@property (assign, nonatomic) Boolean               bTeachingProgramme;//当天是否有教学计划
@property (retain, nonatomic) NSMutableArray<ProgramModel *>   *modelList;


@end

NS_ASSUME_NONNULL_END
