//
//  HHCalendarCell.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/25.
//

#import <UIKit/UIKit.h>
#import "HHCalendarDayModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHCalendarCell : UICollectionViewCell

@property (retain, nonatomic) HHCalendarDayModel            *calendarDayModel;

@end

NS_ASSUME_NONNULL_END
