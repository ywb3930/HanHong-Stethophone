//
//  HeartVoiceVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import "HeartVoiceView.h"
#import "AusultaionView.h"



@interface HeartVoiceView ()<HHBodyViewDelegate>

@property (retain, nonatomic) AusultaionView            *ausultaionView;

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

- (void)setRecordingState:(NSInteger)recordingState{
    self.heartBodyView.recordingState = recordingState;
}


//开始录音
- (void)recordingStart{
    [self.heartBodyView recordingStart];
}
//停止录音关闭计时器时调用
- (void)recordingReload{
    [self.heartBodyView recordingReload];
}

- (void)setAutoAction:(Boolean)autoAction{
    self.heartBodyView.autoAction = autoAction;
}
//停止录音时调用
- (void)recordingStop{
    [self.heartBodyView recordingStop];
}

- (void)recordingPause{
    [self.heartBodyView recordingPause];
}
- (void)recordingResume{
    [self.heartBodyView recordingResume];
}

- (void)actionClearSelectButton{
    [self.heartBodyView actionClearSelectButton];
}

- (void)actionClickButtonBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag position:(NSInteger)position{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionClickHeartButtonBodyPositionCallBack:tag:)]) {
        [self.delegate actionClickHeartButtonBodyPositionCallBack:string tag:tag];
    }
}



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
