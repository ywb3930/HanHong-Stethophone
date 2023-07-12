//
//  StudentProgramView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StudentProgramView : UIView

@property (retain, nonatomic) NSDate *currentDate;
- (void)initData:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
