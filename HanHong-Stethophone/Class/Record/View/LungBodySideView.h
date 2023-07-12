//
//  LungBodySideView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LungBodySideViewDelegate <NSObject>

- (void)actionClickButtonLungCallBack:(NSString *)string tag:(NSInteger)tag position:(NSInteger)position;

@end

@interface LungBodySideView : UIView

@property (weak, nonatomic) id<LungBodySideViewDelegate>   delegate;
@property (assign, nonatomic) NSInteger    recordingStae;
@property (retain, nonatomic) NSDictionary     *positionValue;
@property (assign, nonatomic) Boolean      autoAction;
- (void)recordingStart;
- (void)recordingStop;
- (void)recordingPause;
- (void)recordingRestar;

@end

NS_ASSUME_NONNULL_END
