//
//  LungVoiceView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/17.
//

#import "LungVoiceView.h"
#import "AusultaionView.h"
#import "LungBodyFrontView.h"
#import "LungBodySideView.h"
#import "LungBodyBackView.h"

@interface LungVoiceView ()<LungBodyBackViewDelegate, LungBodySideViewDelegate, LungBodyFrontViewDelegate>

@property (retain, nonatomic) AusultaionView            *ausultaionView;
@property (retain, nonatomic) LungBodyFrontView         *lungBodyFrontView;
@property (retain, nonatomic) LungBodySideView          *lungBodySideView;
@property (retain, nonatomic) LungBodyBackView          *lungBodyBackView;

@property (retain, nonatomic) UIView                    *viewButtons;
@property (retain, nonatomic) UIButton                  *buttonFront;
@property (retain, nonatomic) UIButton                  *buttonSide;
@property (retain, nonatomic) UIButton                  *buttonBack;
@property (retain, nonatomic) UIView                    *viewLine;

@property (assign, nonatomic) NSInteger                     buttonSelectIndex;
@property (assign, nonatomic) NSInteger                     lungSelectPositionIndex;
@property (assign, nonatomic) Boolean                       bActionFromAuto;//事件来自自动事件

@end

@implementation LungVoiceView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = WHITECOLOR;
        [self setupView];
    }
    return self;
}

- (void)setAutoAction:(Boolean)autoAction{
    _autoAction = autoAction;
    self.lungBodyFrontView.autoAction = autoAction;
    self.lungBodySideView.autoAction = autoAction;
    self.lungBodyBackView.autoAction = autoAction;
}

- (void)setRecordingStae:(NSInteger)recordingStae{
    _recordingStae = recordingStae;
    if (self.lungSelectPositionIndex == Lung_front_bodyType) {
        self.lungBodyFrontView.recordingStae = recordingStae;
    } else if (self.lungSelectPositionIndex == Lung_side_bodyType) {
        self.lungBodySideView.recordingStae = recordingStae;
    } else if (self.lungSelectPositionIndex == Lung_back_bodyType) {
        self.lungBodyBackView.recordingStae = recordingStae;
    }
}

- (void)recordingStart{
    if (self.lungSelectPositionIndex == Lung_front_bodyType) {
        [self.lungBodyFrontView recordingStart];
    } else if (self.lungSelectPositionIndex == Lung_side_bodyType) {
        [self.lungBodySideView  recordingStart];
    } else if (self.lungSelectPositionIndex == Lung_back_bodyType) {
        [self.lungBodyBackView  recordingStart];
    }
}

- (void)recordingStop{
    if (self.lungSelectPositionIndex == Lung_front_bodyType) {
        [self.lungBodyFrontView recordingStop];
    } else if (self.lungSelectPositionIndex == Lung_side_bodyType) {
        [self.lungBodySideView recordingStop];
    } else if (self.lungSelectPositionIndex == Lung_back_bodyType) {
        [self.lungBodyBackView recordingStop];
    }
}

- (void)recordingPause{
    if (self.lungSelectPositionIndex == Lung_front_bodyType) {
        [self.lungBodyFrontView recordingPause];
    } else if (self.lungSelectPositionIndex == Lung_side_bodyType) {
        [self.lungBodySideView recordingPause];
    } else if (self.lungSelectPositionIndex == Lung_back_bodyType) {
        [self.lungBodyBackView recordingPause];
    }
}
- (void)recordingRestar{
    if (self.lungSelectPositionIndex == Lung_front_bodyType) {
        [self.lungBodyFrontView recordingRestar];
    } else if (self.lungSelectPositionIndex == Lung_side_bodyType) {
        [self.lungBodySideView recordingRestar];
    } else if (self.lungSelectPositionIndex == Lung_back_bodyType) {
        [self.lungBodyBackView recordingRestar];
    }
}


- (void)actionClickButtonLungCallBack:(nonnull NSString *)string tag:(NSInteger)tag position:(NSInteger)position {
    
    self.buttonSelectIndex = tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionClickButtonLungBodyPositionCallBack:tag:position:)]) {
        [self.delegate actionClickButtonLungBodyPositionCallBack:string tag:tag position:position];
    }
}


- (void)setPositionValue:(NSDictionary *)positionValue{
    NSInteger index = [positionValue[@"id"] integerValue];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.bActionFromAuto = YES;
        if (index < 8) {
            [self actionClickFront:self.buttonFront];
            self.lungBodyFrontView.positionValue = positionValue;
        } else if (index == 9 || index == 8) {
            [self actionClickSide:self.buttonSide];
            self.lungBodySideView.positionValue = positionValue;
        } else if (index == 11 || index == 10) {
            [self actionClickBack:self.buttonBack];
            self.lungBodyBackView.positionValue = positionValue;
        }
    });
    
}

- (void)actionClickFront:(UIButton *)button{
    if (!self.bActionFromAuto) {
        if (self.autoAction) {
            [kAppWindow makeToast:@"自动录音状态，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        if(self.recordingStae == recordingState_ing) {
            [kAppWindow makeToast:@"正在录音中，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        
    }
    
    self.bActionFromAuto = NO;
    self.lungSelectPositionIndex = Lung_front_bodyType;
    self.buttonFront.selected = YES;
    self.buttonSide.selected = NO;
    self.buttonBack.selected = NO;
    self.lungBodyFrontView.hidden = NO;
    self.lungBodySideView.hidden = YES;
    self.lungBodyBackView.hidden = YES;
    self.viewLine.sd_layout.centerXEqualToView(self.buttonFront);
    [self.viewLine updateLayout];
}

- (void)actionClickSide:(UIButton *)button{
    if (!self.bActionFromAuto) {
        if (self.autoAction) {
            [kAppWindow makeToast:@"自动录音状态，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        if(self.recordingStae == recordingState_ing) {
            [kAppWindow makeToast:@"正在录音中，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        
    }
    
    self.bActionFromAuto = NO;
    self.lungSelectPositionIndex = Lung_side_bodyType;
    self.buttonFront.selected = NO;
    self.buttonSide.selected = YES;
    self.buttonBack.selected = NO;
    self.lungBodyFrontView.hidden = YES;
    self.lungBodySideView.hidden = NO;
    self.lungBodyBackView.hidden = YES;
    self.viewLine.sd_layout.centerXEqualToView(self.buttonSide);
    [self.viewLine updateLayout];
}

- (void)actionClickBack:(UIButton *)button{
    if (!self.bActionFromAuto) {
        if (self.autoAction) {
            [kAppWindow makeToast:@"自动录音状态，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        if(self.recordingStae == recordingState_ing) {
            [kAppWindow makeToast:@"正在录音中，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        
    }
    self.bActionFromAuto = NO;
    self.lungSelectPositionIndex = Lung_back_bodyType;
    self.buttonFront.selected = NO;
    self.buttonSide.selected = NO;
    self.buttonBack.selected = YES;
    self.lungBodyFrontView.hidden = YES;
    self.lungBodySideView.hidden = YES;
    self.lungBodyBackView.hidden = NO;
    self.viewLine.sd_layout.centerXEqualToView(self.buttonBack);
    [self.viewLine updateLayout];
}

- (void)setupView{
    [self addSubview:self.ausultaionView];
    self.ausultaionView.sd_layout.leftSpaceToView(self, 0).topSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio55);
    [self addSubview:self.lungBodyFrontView];
    self.lungBodyFrontView.sd_layout.leftSpaceToView(self, 0).topSpaceToView(self.ausultaionView, 0).rightSpaceToView(self, 0).heightIs(230.f*screenRatio);
    [self addSubview:self.lungBodySideView];
    self.lungBodySideView.sd_layout.leftSpaceToView(self, 0).topSpaceToView(self.ausultaionView, 0).rightSpaceToView(self, 0).heightIs(230.f*screenRatio);
    [self addSubview:self.lungBodyBackView];
    self.lungBodyBackView.sd_layout.leftSpaceToView(self, 0).topSpaceToView(self.ausultaionView, 0).rightSpaceToView(self, 0).heightIs(230.f*screenRatio);
    
    [self addSubview:self.viewButtons];
    self.viewButtons.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self.lungBodyFrontView, 0).heightIs(Ratio33);
    
    [self.viewButtons addSubview:self.buttonFront];
    [self.viewButtons addSubview:self.buttonSide];
    [self.viewButtons addSubview:self.buttonBack];
    [self.viewButtons addSubview:self.viewLine];
    self.buttonFront.sd_layout.leftSpaceToView(self.viewButtons, 0).widthIs(screenW/3).heightIs(Ratio28).topSpaceToView(self.viewButtons, 0);
    self.buttonSide.sd_layout.leftSpaceToView(self.buttonFront, 0).widthIs(screenW/3).heightIs(Ratio28).topSpaceToView(self.viewButtons, 0);
    self.buttonBack.sd_layout.leftSpaceToView(self.buttonSide, 0).widthIs(screenW/3).heightIs(Ratio28).topSpaceToView(self.viewButtons, 0);
    self.viewLine.sd_layout.centerXEqualToView(self.buttonFront).heightIs(Ratio2).bottomSpaceToView(self.viewButtons, 0).widthIs(Ratio33);
    
    
}

- (UIView *)viewLine{
    if(!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = MainColor;
    }
    return _viewLine;
}

- (AusultaionView *)ausultaionView{
    if(!_ausultaionView) {
        _ausultaionView = [[AusultaionView alloc] init];
        _ausultaionView.title = @"肺音听诊";
    }
    return _ausultaionView;
}

- (LungBodyFrontView *)lungBodyFrontView{
    if(!_lungBodyFrontView) {
        _lungBodyFrontView = [[LungBodyFrontView alloc] init];
        _lungBodyFrontView.delegate = self;
    }
    return _lungBodyFrontView;
}

- (LungBodySideView *)lungBodySideView{
    if(!_lungBodySideView) {
        _lungBodySideView = [[LungBodySideView alloc] init];
        _lungBodySideView.hidden = YES;
        _lungBodySideView.delegate = self;
    }
    return _lungBodySideView;
}

- (LungBodyBackView *)lungBodyBackView{
    if(!_lungBodyBackView) {
        _lungBodyBackView = [[LungBodyBackView alloc] init];
        _lungBodyBackView.hidden = YES;
        _lungBodyBackView.delegate = self;
    }
    return _lungBodyBackView;
}

- (UIButton *)buttonFront{
    if (!_buttonFront) {
        _buttonFront = [self setButtonOrientation:@"正面"];
        [_buttonFront addTarget:self action:@selector(actionClickFront:) forControlEvents:UIControlEventTouchUpInside];
        _buttonFront.selected = YES;
    }
    return _buttonFront;
}

- (UIButton *)buttonSide{
    if (!_buttonSide) {
        _buttonSide = [self setButtonOrientation:@"侧面"];
        [_buttonSide addTarget:self action:@selector(actionClickSide:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonSide;
}

- (UIButton *)buttonBack{
    if (!_buttonBack) {
        _buttonBack = [self setButtonOrientation:@"背面"];
        [_buttonBack addTarget:self action:@selector(actionClickBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonBack;
}

- (UIButton *)setButtonOrientation:(NSString *)info{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:info forState:UIControlStateNormal];
    [button setTitle:info forState:UIControlStateSelected];
    [button setTitleColor:MainBlack forState:UIControlStateSelected];
    [button setTitleColor:MainNormal forState:UIControlStateNormal];
    button.titleLabel.font = Font15;
    return button;
}

- (UIView *)viewButtons{
    if(!_viewButtons) {
        _viewButtons = [[UIView alloc] init];
    }
    return _viewButtons;
}



@end

