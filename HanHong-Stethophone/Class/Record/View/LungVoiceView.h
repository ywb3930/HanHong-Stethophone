//
//  LungVoiceView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LungVoiceViewBodyPositionBlock)(void);

@protocol LungVoiceViewDelegate <NSObject>

- (void)actionClickButtonLungBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag position:(NSInteger)position;

@end

@interface LungVoiceView : UIView

@property (weak, nonatomic) id<LungVoiceViewDelegate>  delegate;
@property (assign, nonatomic) NSInteger    recordingState;
@property (assign, nonatomic) Boolean      autoAction;
@property (retain, nonatomic) NSDictionary     *positionValue;
@property (nonatomic, copy) LungVoiceViewBodyPositionBlock bodyPositionBlock;
- (void)recordingStart;
- (void)recordingStop;
- (void)recordingPause;
- (void)recordingRestar;
- (void)actionClearSelectButton;

@end

NS_ASSUME_NONNULL_END
