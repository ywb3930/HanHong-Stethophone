//
//  HHCalendarManager.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/25.
//

#import "HHCalendarManager.h"

@interface HHCalendarManager()

@property (nonatomic, strong) NSDateFormatter * dateFormatter;

@end

@implementation HHCalendarManager

+ (HHCalendarManager *)shareManage
{
    static HHCalendarManager * manageSinglenton = nil;
    static dispatch_once_t onceCalendar;
    dispatch_once(&onceCalendar, ^{
        manageSinglenton = [[self alloc] init];
        [manageSinglenton getWeekString];
    });
    return manageSinglenton;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _dateFormatter;
}


- (void)getWeekString
{
    self.weekList = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
}

#pragma mark - 查看所选日期所处的月份
- (void)checkThisMonthRecordFromToday:(NSDate *)today
{
    if (!today) {
        today = [NSDate date];
    }
    
    [self calculationThisMonthDays:today];
    [self calculationThisMonthFirstDayInWeek:today];
}

#pragma mark - 计算本月天数
- (void)calculationThisMonthDays:(NSDate *)days
{
    NSCalendar * calendar = [NSCalendar currentCalendar];

    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:days];
    self.days = range.length;
}


#pragma mark - 计算本月第一天是周几
- (void)calculationThisMonthFirstDayInWeek:(NSDate *)date;
{

    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    NSDateComponents * theComps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear;
    comps = [calendar components:unitFlags fromDate:date];
    theComps = [calendar components:unitFlags fromDate:[NSDate date]];
    self.theMonth = [theComps month];// 本月的月份
    NSUInteger day = [comps day];// 是本月第几天
    self.todayInMonth = day;
    NSString *dateStr = [self.dateFormatter stringFromDate:date];
    NSString *todayStr = [self.dateFormatter stringFromDate:[NSDate date]];
    if (day > 1) {// 如果不是本月第一天
        // 将日期推算到本月第一天
        NSInteger hours = (day - 1) * -24;
        date = [NSDate dateWithTimeInterval:hours * 60 * 60 sinceDate:date];
    }
    NSString *stringYM = [Tools dateToStringYM:[NSDate date]];
    NSString *firstString = [NSString stringWithFormat:@"%@-01 00:00:00",stringYM];
    NSDate *firstDate = [Tools stringToDateYMDHMS:firstString];
    NSString *firstStringSub8 = [Tools dateAddMinuteYMDHMS:firstDate minute:-8*60];
    self.startDate = [Tools stringToDateYMDHMS:firstStringSub8];
    
    NSString *lastDayString = [NSString stringWithFormat:@"%@-%li 15:59:59", stringYM, self.days];
    self.endDate = [Tools stringToDateYMDHMS:lastDayString];
    
    comps = [calendar components:unitFlags fromDate:date];
    self.dayInWeek = [comps weekday];// 是周几
    if ([dateStr isEqualToString:todayStr]) {
        self.todayPosition = day + self.dayInWeek - 2;
    }

    [self creatcalendarArrayWithDate:date];
}

#pragma mark - 创建日历数组
- (void)creatcalendarArrayWithDate:(NSDate *)date
{
    self.calendarDate = [NSMutableArray new];
    for (NSInteger j = 0; j < 42; j ++) {// 创建空占位数组
        [self.calendarDate addObject:[HHCalendarDayModel new]];
    }
    // 向前推算日期到本月第一天
    //NSDate * firstDay = date;
    self.todayInMonth = self.todayInMonth + self.dayInWeek - 2;// 计算在本月日历上所处的位置
    for (NSInteger i = 1; i <= self.days + self.dayInWeek - 1; i ++) {
        if (i >= self.dayInWeek) {
            HHCalendarDayModel *model = [[HHCalendarDayModel alloc] init];
            model.dayValue = (i - self.dayInWeek + 1);
            if (i - 1 == self.todayInMonth) {
                model.bCurrentDay = YES;
            }
            [self.calendarDate replaceObjectAtIndex:i - 1 withObject:model];
        }
    }
    
}


@end
