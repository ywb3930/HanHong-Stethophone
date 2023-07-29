//
//  HHBodyView.m
//  HanHong-Stethophone
//
//  Created by HanHong on 2023/7/15.
//

#import "HHBodyView.h"


@implementation HHBodyView


- (void)actionClearSelectButton{
    NSInteger idx = self.buttonSelectIndex;
    if(idx >= 0 && ![self.arraySelectItem containsObject:[@(idx) stringValue]]) {
        UIButton *buttonType = self.arrayButtonsTpye[idx];
        buttonType.selected = NO;
        UIImageView *imageViewLine = self.arrayImageViews[idx];
        imageViewLine.image = [UIImage imageNamed:self.arrayNoImageName[idx]];
        UIButton *buttonDot = self.arrayButtonDot[idx];
        buttonDot.selected = NO;
        UILabel *labelPlace = self.arrayLabelPlace[idx];
        labelPlace.textColor = MainBlack;
        self.buttonSelectIndex = -1;
    }
}

- (void)setAutoAction:(Boolean)autoAction{
    _autoAction = autoAction;
}

- (void)recordingPause{
    self.timer.fireDate = [NSDate distantFuture];
}
- (void)recordingResume{
    self.timer.fireDate = [NSDate distantPast];
}



- (void)setPositionValue:(NSDictionary *)positionValue{
    NSInteger index = [[positionValue objectForKey:@"id"] integerValue];
    self.bActionFromAuto = YES;
    if (self.positionIndex == 2) {
        UIButton *button = [self.arrayButtonsTpye objectAtIndex:index-8];
        [self actionButtonClick:button];
    } else if(self.positionIndex == 3) {
        UIButton *button = [self.arrayButtonsTpye objectAtIndex:index-10];
        [self actionButtonClick:button];
    } else {
        UIButton *button = [self.arrayButtonsTpye objectAtIndex:index];
        [self actionButtonClick:button];
    }
    
}
//开始录音
- (void)recordingStart{
    if (!self.timer) {
        self.timer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(reloadButton) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    } else {
        self.timer.fireDate = [NSDate distantPast];
    }
    NSInteger idx = self.buttonSelectIndex;
    if (self.buttonSelectIndex == -1) {
        return;
    }
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    UIButton *button = self.arrayButtonDot[idx];
    UIImageView *imageView = self.arrayImageViews[idx];
    imageView.image = [UIImage imageNamed:self.arraySelectImageName[idx]];
    UILabel *label = self.arrayLabelPlace[idx];
    label.textColor = MainColor;
    button.selected = YES;
}
//停止录音关闭计时器时调用
- (void)recordingReload{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)reloadButton{
    if (self.buttonSelectIndex == -1) {
        return;
    }
    UIButton *button = self.arrayButtonDot[self.buttonSelectIndex];
    button.selected = !button.selected;
}
//停止录音时调用
- (void)recordingStop{
    if (self.buttonSelectIndex == -1) {
        return;
    }
    NSInteger idx = self.buttonSelectIndex;
    UIButton *buttonDot = self.arrayButtonDot[idx];
    buttonDot.selected = NO;
    [buttonDot setImage:[UIImage imageNamed:@"already_dot"] forState:UIControlStateNormal];
    UIImageView *imageView = self.arrayImageViews[idx];
    imageView.image = [UIImage imageNamed:self.arrayAlreadyImageName[idx]];
    UILabel *label = self.arrayLabelPlace[idx];
    label.textColor = AlreadyColor;
    self.timer.fireDate = [NSDate distantFuture];
    UIButton *buttonTag = self.arrayButtonsTpye[idx];
    buttonTag.selected = YES;
    [buttonTag setTitleColor:AlreadyColor forState:UIControlStateSelected];
    UIButton *buttonCollect = self.arrayButtonsCollected[idx];
    buttonCollect.hidden = NO;
    NSString *string = [@(idx) stringValue];
    if (![self.arraySelectItem containsObject:string]) {
        [self.arraySelectItem addObject:string];
    }
}

- (void)setRecordingState:(NSInteger)recordingState{
    _recordingState = recordingState;
}

- (void)actionButtonClick:(UIButton *)button {
    if (!self.bActionFromAuto) {
        if (self.autoAction) {
            [kAppWindow makeToast:@"自动录音状态，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        
    }
    self.bActionFromAuto = NO;
    if(self.recordingState == recordingState_ing || self.recordingState == recordingState_pause) {
        [kAppWindow makeToast:@"正在录音中，不可改变位置" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    if ([[HHBlueToothManager shareManager] getConnectState] != DEVICE_CONNECTED) {
        [kAppWindow makeToast:@"请先连接设备" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    
    NSString *string = [@(button.tag-100) stringValue];
    
    if (button.selected && [self.arraySelectItem containsObject:string]) {
        [Tools showAlertView:@"提示" andMessage:@"是否重新采集该位置" andTitles:@[@"取消", @"重新采集"] andColors:@[MainNormal, MainColor] sure:^{
            [self actionRecordNextposition:button];
        } cancel:^{
            
        }];
        return;
    }
    [self actionRecordNextposition:button];
}

- (void)actionRecordNextpositionCallBack:(NSInteger)index{
    
}

- (void)actionRecordNextposition:(UIButton *)button{
    for (NSInteger i = 0; i < self.arrayButtonsTpye.count; i++) {
        
        NSString *string = [@(i) stringValue];
        if (![self.arraySelectItem containsObject:string]) {
            UIButton *buttonType = self.arrayButtonsTpye[i];
            buttonType.selected = (buttonType == button);
            UIImageView *imageViewLine = self.arrayImageViews[i];
            imageViewLine.image = [UIImage imageNamed:self.arrayNoImageName[i]];
            UIButton *buttonDot = self.arrayButtonDot[i];
            buttonDot.selected = NO;
            UILabel *labelPlace = self.arrayLabelPlace[i];
            labelPlace.textColor = MainBlack;
        }
    }
    NSInteger index = button.tag - 100;
    NSString *stringButton = [@(index) stringValue];
    
    if (![self.arraySelectItem containsObject:stringButton]) {
        button.selected = YES;
        UIImageView *imageViewLine = self.arrayImageViews[index];
        imageViewLine.image = [UIImage imageNamed:self.arraySelectImageName[index]];
        UIButton *buttonDot = self.arrayButtonDot[index];
        buttonDot.selected = YES;
        UILabel *labelPlace = self.arrayLabelPlace[index];
        labelPlace.textColor = MainColor;
    }
    
    [self actionRecordNextpositionCallBack:index];
}

- (UIButton *)setupButton{
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"black_dot"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"red_dot"] forState:UIControlStateSelected];
    return button;
}

- (UILabel *)setLabelView:(NSString *)title{
    UILabel *label = [[UILabel alloc] init];
    label.font = Font12;
    
    label.textColor = MainBlack;
    label.text = title;
    return label;
}

@end
