//
//  ItemSwitchView.m
//  HanHong-Stethophone
//
//  Created by HanHong on 2023/7/25.
//

#import "ItemSwitchView.h"

@interface ItemSwitchView()

@property (retain, nonatomic) UILabel               *labelTitle;

@property (retain, nonatomic) UIView                *viewLine;

@end

@implementation ItemSwitchView

- (instancetype)initWithFrame:(CGRect)frame title:(nullable NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = title;
        [self setupView];
    }
    return self;
}


- (void)actionSwitchChange:(UISwitch *)switchBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionSwitchChangeCallback:tag:)]) {
        [self.delegate actionSwitchChangeCallback:switchBtn.isOn tag:self.tag];
    }
}

- (void)setTitle:(NSString *)title{
    self.labelTitle.text = title;
}

- (void)setValue:(NSString *)value{
    self.switchButton.on = [value boolValue];
}

- (void)setupView{
    [self addSubview:self.switchButton];
    [self addSubview:self.labelTitle];
    self.switchButton.sd_layout.centerYEqualToView(self).heightIs(Ratio22).widthIs(Ratio33).rightSpaceToView(self, Ratio11);
    self.labelTitle.sd_layout.leftSpaceToView(self, Ratio11).centerYEqualToView(self).rightSpaceToView(self.switchButton, Ratio11).heightIs(Ratio22);
    [self addSubview:self.viewLine];
    self.viewLine.sd_layout.leftEqualToView(self.labelTitle).rightEqualToView(self.switchButton).heightIs(Ratio1).bottomSpaceToView(self, 0);
}

- (UILabel *)labelTitle{
    if(!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textColor = MainBlack;
        _labelTitle.font = Font15;
        _labelTitle.text = self.title;
    }
    return _labelTitle;
}

- (UISwitch *)switchButton{
    if(!_switchButton) {
        _switchButton = [[UISwitch alloc] init];
        [_switchButton addTarget:self action:@selector(actionSwitchChange:) forControlEvents:UIControlEventValueChanged];
        _switchButton.onTintColor = MainColor;
    }
    return _switchButton;
}

- (UIView *)viewLine{
    if(!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine;
}

@end
