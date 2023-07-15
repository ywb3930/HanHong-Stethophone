//
//  HHBodyView.h
//  HanHong-Stethophone
//
//  Created by HanHong on 2023/7/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HHBodyViewDelegate <NSObject>

- (void)actionClickButtonBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag position:(NSInteger)position;

@end

@interface HHBodyView : UIView


@property (weak, nonatomic) id<HHBodyViewDelegate>    delegate;
@property (assign, nonatomic) NSInteger    recordingState;
@property (retain, nonatomic) NSDictionary     *positionValue;
@property (assign, nonatomic) Boolean           autoAction;
@property (retain, nonatomic) NSMutableArray            *arrayButtonsTpye;//按钮数组
@property (retain, nonatomic) NSMutableArray            *arrayButtonsCollected;//
@property (retain, nonatomic) NSMutableArray            *arrayImageViews;//图片数组

@property (retain, nonatomic) NSArray                   *arrayButtonInfo;//按钮标题
@property (retain, nonatomic) NSArray                   *arrayNoImageName;//没选中时的图片
@property (retain, nonatomic) NSArray                   *arraySelectImageName;//选中时的图片
@property (retain, nonatomic) NSArray                   *arrayAlreadyImageName;//准备时的图片
@property (retain, nonatomic) NSArray                   *arrayButtonDot;//小圆点的图片
@property (retain, nonatomic) NSArray                   *arrayLabelPlace;

@property (retain, nonatomic) NSTimer                   *timer;
@property (assign, nonatomic) NSInteger                 buttonSelectIndex;
@property (retain, nonatomic) NSMutableArray            *arraySelectItem;

@property (assign, nonatomic) Boolean                   bActionFromAuto;//事件来自自动事件

- (void)recordingStart;
- (void)recordingStop;
- (void)recordingPause;
- (void)recordingRestar;
- (void)actionClearSelectButton;
- (UILabel *)setLabelView:(NSString *)title;
- (UIButton *)setupButton;
- (void)actionButtonClick:(UIButton *)button;
- (void)actionRecordNextpositionCallBack:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
