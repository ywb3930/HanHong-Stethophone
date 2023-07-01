//
//  CodeItemView.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/14.
//

#import "CodeItemView.h"

@interface CodeItemView()

@property (retain, nonatomic) NSString              *title;
@property (retain, nonatomic) NSString              *placeholder;
@property (retain, nonatomic) UILabel           *labelCode;
@property (assign, nonatomic) Boolean           bMust;

@property (retain, nonatomic) UIButton          *buttonGetCode;
@property (retain, nonatomic) UIView            *viewLineGetCode;
@property (nonatomic, retain) NSTimer                   *timer;
@property (assign, nonatomic) NSInteger                 totalTime;
@property (retain, nonatomic) UIImageView       *imageViewStar;

@end

@implementation CodeItemView

- (instancetype)initWithTitle:(NSString *)title bMust:(Boolean)bMust placeholder:(NSString *)placeholder
{
    if (self = [super init]) {
        self.title = title;
        self.placeholder = placeholder;
        self.bMust = bMust;
        [self initView];
    }
    return self;
}

- (void)initView{
    [self addSubview:self.labelCode];
    [self addSubview:self.viewLineGetCode];
    [self addSubview:self.imageViewStar];
    [self addSubview:self.textFieldCode];
    [self addSubview:self.buttonGetCode];
    
    self.labelCode.sd_layout.leftSpaceToView(self, 0).widthIs(Ratio66).heightIs(Ratio33).topSpaceToView(self, 0);
    [self.labelCode setSingleLineAutoResizeWithMaxWidth:Ratio135];
    self.imageViewStar.sd_layout.centerYEqualToView(self.labelCode).leftSpaceToView(self.labelCode, Ratio2).widthIs(Ratio5).heightIs(Ratio5);
    self.buttonGetCode.sd_layout.rightSpaceToView(self, 0).centerYEqualToView(self.labelCode).widthIs(61.f*screenRatio).heightIs(Ratio33);
    self.textFieldCode.sd_layout.leftSpaceToView(self.imageViewStar, Ratio8).rightSpaceToView(self.buttonGetCode, Ratio11).heightIs(Ratio33).centerYEqualToView(self.labelCode);
    self.viewLineGetCode.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio1).bottomSpaceToView(self, 0);
}

-(UIImageView *)imageViewStar{
    if(!_imageViewStar) {
        _imageViewStar = [[UIImageView alloc] init];
        _imageViewStar.image = [UIImage imageNamed:@"xinghao"];
        _imageViewStar.hidden = !self.bMust;
    }
    return _imageViewStar;
}

-(void)startTime:(NSTimer *)timer{
    if(self.totalTime == 0){
        self.buttonGetCode.enabled = YES;
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.buttonGetCode setTitleColor:MainColor forState:UIControlStateNormal];
        [self.buttonGetCode setTitle:@"重新发送" forState:UIControlStateNormal];
        self.buttonGetCode.sd_layout.widthIs(Ratio55);
    } else {
        [self.buttonGetCode setTitle:[NSString stringWithFormat:@"重新获取(%lis)", (long)self.totalTime] forState:UIControlStateNormal];
        self.totalTime --;
    }
}

- (void)showTimer {
    self.totalTime = 60;
    self.buttonGetCode.enabled = NO;
    self.buttonGetCode.sd_layout.widthIs(Ratio77);
    [self.buttonGetCode setTitleColor:MainNormal forState:UIControlStateNormal];
    if(!self.timer){
        self.timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(startTime:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
    } else {
        [self.timer setFireDate:[NSDate date]];
    }
}

- (void)deallocView{
    self.buttonGetCode.sd_layout.widthIs(Ratio55);
    [self.buttonGetCode setTitleColor:MainColor forState:UIControlStateNormal];
    [self.timer invalidate];
    self.timer = nil;
}

- (UILabel *)labelCode{
    if(!_labelCode) {
        _labelCode = [[UILabel alloc] init];
        _labelCode.font = Font15;
        _labelCode.textColor = MainBlack;
        _labelCode.text = self.title;
    }
    return _labelCode;
}

- (UITextField *)textFieldCode{
    if(!_textFieldCode) {
        _textFieldCode = [[UITextField alloc] init];
        [_textFieldCode setPlaceholder:self.placeholder];
        _textFieldCode.font = Font15;
        _textFieldCode.textColor = MainBlack;
        _textFieldCode.textAlignment = NSTextAlignmentRight;
        _textFieldCode.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _textFieldCode;
}

- (UIView *)viewLineGetCode{
    if(!_viewLineGetCode) {
        _viewLineGetCode = [[UIView alloc] init];
        _viewLineGetCode.backgroundColor = HEXCOLOR(0xF5F5F5, 1);
    }
    return _viewLineGetCode;
}

- (UIButton *)buttonGetCode{
    if(!_buttonGetCode) {
        _buttonGetCode = [[UIButton alloc] init];
        [_buttonGetCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_buttonGetCode setTitleColor:MainColor forState:UIControlStateNormal];
        _buttonGetCode.titleLabel.font = [UIFont systemFontOfSize:Ratio10];
        [_buttonGetCode addTarget:self action:@selector(actionGetCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonGetCode;
}

-(void)actionGetCode:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionGetCode:)]) {
        [self.delegate actionGetCode:button];
    }
}

@end
