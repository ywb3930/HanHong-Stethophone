//
//  HeartFilterLungView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol HeartFilterLungViewDelegate <NSObject>

- (Boolean)actionHeartLungButtonClickCallback:(NSInteger)idx;
- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel;

@end

@interface HeartFilterLungView : UIView

@property (weak, nonatomic) id<HeartFilterLungViewDelegate>  delegate;
@property (retain, nonatomic) UIButton              *buttonHeartVoice;
@property (retain, nonatomic) UIButton              *buttonLungVoice;
- (void)filterGrayString:(NSString *)grayString blueString:(NSString *)blueString;

@end

NS_ASSUME_NONNULL_END
