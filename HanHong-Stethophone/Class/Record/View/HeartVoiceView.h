//
//  HeartVoiceView.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol HeartVoiceViewDelegate <NSObject>

- (void)actionClickHeartButtonBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag;

@end

@interface HeartVoiceView : UIView

@property (weak, nonatomic) id<HeartVoiceViewDelegate> delegate;
@property (assign, nonatomic) NSInteger    recordingStae;
@property (retain, nonatomic) NSDictionary     *positionValue;
@property (assign, nonatomic) Boolean      autoAction;
- (void)recordingStart;
- (void)recordingStop;
- (void)recordingPause;
- (void)recordingRestar;
@end

NS_ASSUME_NONNULL_END
