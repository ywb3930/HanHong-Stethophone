//
//  LungVoiceView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import <UIKit/UIKit.h>
#import "LungBodyFrontView.h"
#import "LungBodySideView.h"
#import "LungBodyBackView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^LungVoiceViewBodyPositionBlock)(void);

@protocol LungVoiceViewDelegate <NSObject>

- (void)actionClickButtonLungBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag position:(NSInteger)position;

@end

@interface LungVoiceView : UIView

@property (weak, nonatomic) id<LungVoiceViewDelegate>  delegate;
@property (assign, nonatomic) NSInteger    recordingState;
@property (assign, nonatomic) NSInteger    name;
@property (assign, nonatomic) Boolean      autoAction;
@property (retain, nonatomic) NSDictionary     *positionValue;
@property (nonatomic, copy) LungVoiceViewBodyPositionBlock bodyPositionBlock;
@property (retain, nonatomic) LungBodyFrontView         *lungBodyFrontView;
@property (retain, nonatomic) LungBodySideView          *lungBodySideView;
@property (retain, nonatomic) LungBodyBackView          *lungBodyBackView;
- (void)recordingStart;//开始录音
- (void)recordingReload;//停止录音关闭计时器时调用
- (void)recordingStop;//停止录音时调用
- (void)recordingPause;
- (void)recordingResume;
- (void)actionClearSelectButton;

@end

NS_ASSUME_NONNULL_END
