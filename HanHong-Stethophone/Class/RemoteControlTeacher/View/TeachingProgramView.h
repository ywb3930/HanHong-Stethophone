//
//  TeachingProgramView.h
//  HanHong-Stethophone
//  教学计划
//  Created by 袁文斌 on 2023/6/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TeachingProgramView : UIView

@property (retain, nonatomic) NSDate *currentDate;
- (void)initData:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
