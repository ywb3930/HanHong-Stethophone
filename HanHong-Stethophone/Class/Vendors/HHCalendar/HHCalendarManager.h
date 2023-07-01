//
//  HHCalendarManager.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/25.
//

#import <Foundation/Foundation.h>
#import "HHCalendarDayModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHCalendarManager : NSObject


@property (nonatomic, strong) NSMutableArray<HHCalendarDayModel *> *calendarDate;// 公历
@property (nonatomic, strong) NSArray * weekList;
@property (nonatomic, assign) NSUInteger days;// 本月天数
@property (nonatomic, assign) NSUInteger theMonth;// 本月
@property (nonatomic, assign) NSInteger todayInMonth;// 今天在本月是第几天
@property (nonatomic, assign) NSUInteger dayInWeek;// 本月第一天是周几,
@property (nonatomic, assign) NSUInteger todayPosition;// 今天在所属月份中所处位置
@property (nonatomic, retain) NSDate    *startDate;//本月的起始时间
@property (nonatomic, retain) NSDate    *endDate;//本月的结束时间

- (void)checkThisMonthRecordFromToday:(NSDate *)today;
+ (HHCalendarManager *)shareManage;

@end

NS_ASSUME_NONNULL_END
