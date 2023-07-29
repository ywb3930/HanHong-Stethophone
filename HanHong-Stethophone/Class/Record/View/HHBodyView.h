//
//  HHBodyView.h
//  HanHong-Stethophone
//  处理各个部位的事件
//  Created by HanHong on 2023/7/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HHBodyViewDelegate <NSObject>

- (void)actionClickButtonBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag position:(NSInteger)position;

@end

@interface HHBodyView : UIView


@property (weak, nonatomic) id<HHBodyViewDelegate>      delegate;
@property (assign, nonatomic) NSInteger                 recordingState;
@property (retain, nonatomic) NSDictionary              *positionValue;
@property (assign, nonatomic) Boolean                   autoAction;
@property (retain, nonatomic) NSMutableArray            *arrayButtonsTpye;//按钮数组
@property (retain, nonatomic) NSMutableArray            *arrayButtonsCollected;//
@property (retain, nonatomic) NSMutableArray            *arrayImageViews;//图片数组

@property (retain, nonatomic) NSArray                   *arrayButtonInfo;//按钮标题
@property (retain, nonatomic) NSArray                   *arrayNoImageName;//没选中时的图片
@property (retain, nonatomic) NSArray                   *arraySelectImageName;//选中时的图片
@property (retain, nonatomic) NSArray                   *arrayAlreadyImageName;//准备时的图片
@property (retain, nonatomic) NSArray                   *arrayButtonDot;//小圆点的图片
@property (retain, nonatomic) NSArray                   *arrayLabelPlace;//标签数组

@property (retain, nonatomic) NSTimer                   *timer;
@property (assign, nonatomic) NSInteger                 buttonSelectIndex;//当前选中第几个按钮
@property (retain, nonatomic) NSMutableArray            *arraySelectItem;//已经录音过的位置

@property (assign, nonatomic) Boolean                   bActionFromAuto;//事件来自自动事件
@property (assign, nonatomic) NSInteger                 positionIndex;//0 心音  1 肺音前面  2 肺音侧面 3 肺音背面


- (void)recordingStart;//开始录音
- (void)recordingReload;//停止录音关闭计时器时调用
- (void)recordingStop;//停止录音时调用
- (void)recordingPause;//暂停录音时调用
- (void)recordingResume;//重启录音
- (void)actionClearSelectButton;//清理按钮选择状态
- (UILabel *)setLabelView:(NSString *)title;
- (UIButton *)setupButton;
- (void)actionButtonClick:(UIButton *)button;
- (void)actionRecordNextpositionCallBack:(NSInteger)index;//自动录音时模拟选中下一个位置事件



@end

NS_ASSUME_NONNULL_END
