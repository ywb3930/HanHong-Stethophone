//
//  HMEditView.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/15.
//

#import "HMEditView.h"


@interface HMEditView()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (retain, nonatomic) NSString                  *placeholder;
@property (retain, nonatomic) NSString                  *title;
@property (retain, nonatomic) NSString                  *info;
@property (assign, nonatomic) NSInteger                 idx;

@property (retain, nonatomic) UILabel                   *labelTitle;

@property (retain, nonatomic) UIButton                  *buttonCancel;
@property (retain, nonatomic) UIButton                  *buttonCommit;
@property (retain, nonatomic) UIView                    *viewBg;

@end

@implementation HMEditView

- (instancetype)initWithTitle:(NSString *)title info:(nullable NSString *)info placeholder:(NSString *)placeholder idx:(NSInteger)idx;
{
    if (self = [super init]) {
        self.title = title;
        self.placeholder = placeholder;
        self.info = info;
        self.idx = idx;
        [self initView];
        self.frame = CGRectMake(0, 0, screenW, screenH);
    }
    return self;
}

- (void)disappear{
    [self removeFromSuperview];
}

- (void)actionDismiss:(UITapGestureRecognizer *)tap{
    [self disappear];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)actionCommit{
    NSString *string = self.textField.text;
    if([Tools isBlankString:string]) {
        [self makeToast:self.placeholder duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(actionEditInfoCallback:idx:)]) {
        [self.delegate actionEditInfoCallback:string idx:self.idx];
    }
    [self disappear];
}

- (void)initView{
    self.backgroundColor = HEXCOLOR(0x000000, 0.5);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    [self addSubview:self.viewBg];
    self.viewBg.sd_layout.leftSpaceToView(self, Ratio5).rightSpaceToView(self, Ratio5).topSpaceToView(self, screenH/2 - Ratio99).heightIs(150.f*screenRatio);
    
    [self.viewBg addSubview:self.labelTitle];
    [self.viewBg addSubview:self.textField];
    [self.viewBg addSubview:self.buttonCancel];
    [self.viewBg addSubview:self.buttonCommit];
    self.labelTitle.sd_layout.leftSpaceToView(self.viewBg, 0).rightSpaceToView(self.viewBg, 0).topSpaceToView(self.viewBg, 0).heightIs(Ratio55);
    self.textField.sd_layout.leftSpaceToView(self.viewBg, Ratio5).rightSpaceToView(self.viewBg, Ratio5).topSpaceToView(self.labelTitle, 0).heightIs(Ratio40);
    self.buttonCancel.sd_layout.leftSpaceToView(self.viewBg, 0).widthIs(screenW/2-Ratio5).topSpaceToView(self.textField, 0).heightIs(Ratio55);
    self.buttonCommit.sd_layout.rightSpaceToView(self.viewBg, 0).widthIs(screenW/2-Ratio5).topSpaceToView(self.textField, 0).heightIs(Ratio55);
}


- (UIView *)viewBg{
    if(!_viewBg) {
        _viewBg = [[UIView alloc] init];
        _viewBg.backgroundColor = WHITECOLOR;
        _viewBg.layer.cornerRadius = Ratio8;
        
    }
    return _viewBg;
}

- (UILabel *)labelTitle{
    if(!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.text = self.title;
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        _labelTitle.font = Font18;
        _labelTitle.textColor = MainBlack;
    }
    return _labelTitle;
}

- (LRTextField *)textField{
    if(!_textField) {
        _textField = [[LRTextField alloc] init];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = Font15;
        if([Tools isBlankString:self.info]) {
            _textField.placeholder = self.placeholder;
        } else {
            _textField.text = self.info;
        }
        _textField.textColor = MainBlack;
        _textField.backgroundColor = HEXCOLOR(0xE5E5E5, 0.5);
        _textField.delegate = self;
        _textField.returnKeyType = UIReturnKeyDone;
    }
    return _textField;
}

- (UIButton *)buttonCancel{
    if(!_buttonCancel){
        _buttonCancel = [[UIButton alloc] init];
        [_buttonCancel setTitle:@"取消" forState:UIControlStateNormal];
        [_buttonCancel setTitleColor:MainBlack forState:UIControlStateNormal];
        _buttonCancel.titleLabel.font = Font15;
        [_buttonCancel addTarget:self action:@selector(disappear) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonCancel;
}

- (UIButton *)buttonCommit{
    if(!_buttonCommit){
        _buttonCommit = [[UIButton alloc] init];
        [_buttonCommit setTitle:@"确定" forState:UIControlStateNormal];
        [_buttonCommit setTitleColor:MainColor forState:UIControlStateNormal];
        _buttonCommit.titleLabel.font = Font15;
        [_buttonCommit addTarget:self action:@selector(actionCommit) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonCommit;
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
