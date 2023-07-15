//
//  HeartVoiceVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import "HeartVoiceView.h"
#import "AusultaionView.h"
#import "HeartBodyView.h"


@interface HeartVoiceView ()<HHBodyViewDelegate>

@property (retain, nonatomic) AusultaionView            *ausultaionView;
@property (retain, nonatomic) HeartBodyView             *heartBodyView;




@end

@implementation HeartVoiceView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setPositionValue:(NSDictionary *)positionValue{
    self.heartBodyView.positionValue = positionValue;
}

- (void)setrecordingState:(NSInteger)recordingState{
    self.heartBodyView.recordingState = recordingState;
}

- (void)recordingStart{
    [self.heartBodyView recordingStart];
}

- (void)setAutoAction:(Boolean)autoAction{
    self.heartBodyView.autoAction = autoAction;
}

- (void)recordingStop{
    [self.heartBodyView recordingStop];
}

- (void)recordingPause{
    [self.heartBodyView recordingPause];
}
- (void)recordingRestar{
    [self.heartBodyView recordingRestar];
}

- (void)actionClearSelectButton{
    [self.heartBodyView actionClearSelectButton];
}

- (void)actionClickButtonBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag position:(NSInteger)position{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionClickHeartButtonBodyPositionCallBack:tag:)]) {
        [self.delegate actionClickHeartButtonBodyPositionCallBack:string tag:tag];
    }
}

//- (void)actionClickButtonHeartBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(actionClickHeartButtonBodyPositionCallBack:tag:)]) {
//        [self.delegate actionClickHeartButtonBodyPositionCallBack:string tag:tag];
//    }
//}

- (void)setupView{
    [self addSubview:self.ausultaionView];
    self.ausultaionView.sd_layout.leftSpaceToView(self, 0).topSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio55);
    
    [self addSubview:self.heartBodyView];
    self.heartBodyView.sd_layout.leftSpaceToView(self, 0).topSpaceToView(self.ausultaionView, 0).rightSpaceToView(self, 0).heightIs(250.f*screenRatio);
}

- (AusultaionView *)ausultaionView{
    if(!_ausultaionView) {
        _ausultaionView = [[AusultaionView alloc] init];
        _ausultaionView.title = @"心音听诊";
    }
    return _ausultaionView;
}

- (HeartBodyView *)heartBodyView{
    if(!_heartBodyView) {
        _heartBodyView = [[HeartBodyView alloc] init];
        _heartBodyView.delegate = self;
    }
    return _heartBodyView;
}




@end
