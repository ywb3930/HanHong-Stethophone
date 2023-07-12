//
//  WaveFullView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WaveFullView : UIView

- (instancetype)initWithFrame:(CGRect)frame recordModel:(RecordModel *)recordModel cellCount:(NSInteger)cellCount viewHeight:(CGFloat)viewHeight;

@end

NS_ASSUME_NONNULL_END
