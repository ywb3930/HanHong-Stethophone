//
//  HHPopEditView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/19.
//

#import "HHPopEditView.h"

@interface HHPopEditView()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (retain, nonatomic) UIView                *viewBg;

@property (retain, nonatomic) UILabel               *labelUnit;
@property (retain, nonatomic) UIButton              *buttonCancel;
@property (retain, nonatomic) UIButton              *buttonCommit;
@property (retain, nonatomic) UIView                *viewLine1;
@property (retain, nonatomic) UIView                *viewLine2;
@property (retain, nonatomic) UIView                *viewLine3;

@end

@implementation HHPopEditView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        [self setupView];
    }
    return self;
}

- (void)setUnit:(NSString *)unit{
    self.labelUnit.text = unit;
}

- (void)setDefaultNumber:(NSString *)defaultNumber{
    self.textFieldNumber.text = defaultNumber;
}

- (void)disappear{
    [self removeFromSuperview];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)actionCancel:(UIButton *)button{
    [self disappear];
}

- (void)actionCommit:(UIButton *)button{
    NSString *string = self.textFieldNumber.text;
    if (![Tools checkNumber:string]) {
        [kAppWindow makeToast:@"请输入有效数字" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionClickCommnitCallback:tag:)]) {
        [self.delegate actionClickCommnitCallback:[string integerValue] tag:self.tag];
    }
    [self disappear];
}

- (void)setupView{
    self.backgroundColor = HEXCOLOR(0x000000, 0.5);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    [self addSubview:self.viewBg];
    self.viewBg.sd_layout.leftSpaceToView(self, Ratio5).rightSpaceToView(self, Ratio5).topSpaceToView(self, screenH/2 - Ratio99).heightIs(150.f*screenRatio);
    

    [self.viewBg addSubview:self.buttonCancel];
    self.buttonCancel.sd_layout.leftSpaceToView(self.viewBg, 0).bottomSpaceToView(self.viewBg, 0).widthIs(screenW/2-Ratio5).heightIs(Ratio33);
    [self.viewBg addSubview:self.buttonCommit];
    self.buttonCommit.sd_layout.rightSpaceToView(self.viewBg, 0).bottomSpaceToView(self.viewBg, 0).widthIs(screenW/2-Ratio5).heightIs(Ratio33);
    [self.viewBg addSubview:self.textFieldNumber];
    self.textFieldNumber.sd_layout.centerXEqualToView(self.viewBg).widthIs(Ratio99).heightIs(Ratio33).centerYIs(58.f*screenRatio);
    [self.viewBg addSubview:self.viewLine1];
    self.viewLine1.sd_layout.leftEqualToView(self.textFieldNumber).rightEqualToView(self.textFieldNumber).topSpaceToView(self.textFieldNumber, 0).heightIs(Ratio1);
    [self.viewBg addSubview:self.labelUnit];
    self.labelUnit.sd_layout.leftSpaceToView(self.textFieldNumber, Ratio5).heightIs(Ratio33).rightSpaceToView(self.viewBg, 0).centerYEqualToView(self.textFieldNumber);

    
    [self.viewBg addSubview:self.viewLine2];
    self.viewLine2.sd_layout.leftSpaceToView(self.viewBg, 0).rightSpaceToView(self.viewBg, 0).heightIs(Ratio1).bottomSpaceToView(self.buttonCancel, 0);
    [self.viewBg addSubview:self.viewLine3];
    self.viewLine3.sd_layout.centerXEqualToView(self.viewBg).widthIs(Ratio1).heightIs(Ratio33).bottomSpaceToView(self.viewBg, 0);
}

- (UIView *)viewBg{
    if(!_viewBg) {
        _viewBg = [[UIView alloc] init];
        _viewBg.backgroundColor = WHITECOLOR;
        _viewBg.layer.cornerRadius = Ratio8;
        
    }
    return _viewBg;
}


- (UILabel *)labelUnit{
    if(!_labelUnit) {
        _labelUnit = [[UILabel alloc] init];
        _labelUnit.font = Font15;
        _labelUnit.textColor = MainNormal;
    }
    return _labelUnit;
}

- (LRTextField *)textFieldNumber{
    if(!_textFieldNumber) {
        _textFieldNumber = [[LRTextField alloc] init];
        _textFieldNumber.textAlignment = NSTextAlignmentCenter;
        _textFieldNumber.font = Font15;
        _textFieldNumber.textColor = MainBlack;
        _textFieldNumber.delegate = self;
        _textFieldNumber.keyboardType = UIKeyboardTypeNumberPad;
        _textFieldNumber.returnKeyType = UIReturnKeyDone;
    }
    return _textFieldNumber;
}

- (UIButton *)buttonCancel{
    if(!_buttonCancel) {
        _buttonCancel = [[UIButton alloc] init];
        [_buttonCancel setTitle:@"取消" forState:UIControlStateNormal];
        [_buttonCancel setTitleColor:MainBlack forState:UIControlStateNormal];
        _buttonCancel.titleLabel.font = Font15;
        [_buttonCancel addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonCancel;
}

- (UIButton *)buttonCommit{
    if(!_buttonCommit) {
        _buttonCommit = [[UIButton alloc] init];
        [_buttonCommit setTitle:@"确定" forState:UIControlStateNormal];
        [_buttonCommit setTitleColor:MainColor forState:UIControlStateNormal];
        _buttonCommit.titleLabel.font = Font15;
        [_buttonCommit addTarget:self action:@selector(actionCommit:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonCommit;
}

- (UIView *)viewLine1{
    if(!_viewLine1) {
        _viewLine1 = [[UIView alloc] init];
        _viewLine1.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine1;
}

- (UIView *)viewLine2{
    if(!_viewLine2) {
        _viewLine2 = [[UIView alloc] init];
        _viewLine2.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine2;
}

- (UIView *)viewLine3{
    if(!_viewLine3) {
        _viewLine3 = [[UIView alloc] init];
        _viewLine3.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine3;
}

- (void)tap:(UITapGestureRecognizer *)tap
{
    switch (tap.state) {
        case UIGestureRecognizerStateEnded:{
            [self disappear];
        }
            break;
        default:
            break;
    }
}


@end
