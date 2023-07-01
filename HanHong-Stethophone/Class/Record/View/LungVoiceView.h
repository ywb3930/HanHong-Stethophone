//
//  LungVoiceView.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LungVoiceViewDelegate <NSObject>

- (void)actionClickButtonLungBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag position:(NSInteger)position;

@end

@interface LungVoiceView : UIView

@property (weak, nonatomic) id<LungVoiceViewDelegate>  delegate;
@property (assign, nonatomic) NSInteger    recordingStae;
@property (assign, nonatomic) Boolean      autoAction;
@property (retain, nonatomic) NSDictionary     *positionValue;
- (void)recordingStart;
- (void)recordingStop;
- (void)recordingPause;
- (void)recordingRestar;

@end

NS_ASSUME_NONNULL_END
