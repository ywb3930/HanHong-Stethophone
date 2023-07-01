//
//  HHCalendarView.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/25.
//

#import <UIKit/UIKit.h>
#import "HHCalendarManager.h"
#import "HHCalendarCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HHCalendarViewDelegate <NSObject>
@optional
- (void)actionClickCalendarItemCallback:(HHCalendarDayModel *)day;

@end

@interface HHCalendarView : UIView

@property (weak, nonatomic) id<HHCalendarViewDelegate>              delegate;
@property (retain, nonatomic) HHCalendarManager                     *calendarManager;
- (void)reloadCollectView;

@end

NS_ASSUME_NONNULL_END
