//
//  HeartVoiceView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import <UIKit/UIKit.h>
#import "HeartBodyView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol HeartVoiceViewDelegate <NSObject>

- (void)actionClickHeartButtonBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag;

@end

@interface HeartVoiceView : UIView

@property (weak, nonatomic) id<HeartVoiceViewDelegate> delegate;
@property (assign, nonatomic) NSInteger    recordingState;
@property (retain, nonatomic) NSDictionary     *positionValue;
@property (assign, nonatomic) Boolean      autoAction;
@property (retain, nonatomic) HeartBodyView             *heartBodyView;

- (void)recordingStart;//开始录音
- (void)recordingReload;//停止录音关闭计时器时调用
- (void)recordingStop;//停止录音时调用
- (void)recordingPause;
- (void)recordingResume;
- (void)actionClearSelectButton;

@end

NS_ASSUME_NONNULL_END
