//
//  HeartFilterLungView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/24.
//

#import "HeartFilterLungView.h"

@interface HeartFilterLungView()

@property (retain, nonatomic) YYLabel               *labelFilter;

@end

@implementation HeartFilterLungView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    [self addSubview:self.buttonHeartVoice];
    [self addSubview:self.buttonLungVoice];
    [self addSubview:self.labelFilter];
    
    CGFloat widhtSelect = [Tools widthForString:@"打开滤波/关闭滤波" fontSize:Ratio15 andHeight:Ratio18];
    self.labelFilter.sd_layout.centerXEqualToView(self).heightIs(Ratio18).widthIs(widhtSelect).topSpaceToView(self, 0);
    self.buttonHeartVoice.sd_layout.rightSpaceToView(self.labelFilter, Ratio11).heightIs(Ratio33).widthIs(Ratio66).centerYEqualToView(self.labelFilter);
    self.buttonLungVoice.sd_layout.leftSpaceToView(self.labelFilter, Ratio11).heightIs(Ratio33).widthIs(Ratio66).centerYEqualToView(self.labelFilter);
    //[self filterGrayString:@"关闭滤波" blueString:@"打开滤波"];
}

- (void)actionClickButton:(UIButton *)button{
    if (button.selected) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionHeartLungButtonClickCallback:)]) {
        Boolean result = [self.delegate actionHeartLungButtonClickCallback:button.tag];
        if (result) {
            button.selected = !button.selected;
            button.backgroundColor = MainColor;
            if (button.tag == 1) {
                self.buttonLungVoice.backgroundColor = ColorDAECFD;
                self.buttonLungVoice.selected = NO;
            } else {
                self.buttonHeartVoice.backgroundColor = ColorDAECFD;
                self.buttonHeartVoice.selected = NO;
            }
        }
    }
}


- (YYLabel *)labelFilter{
    if(!_labelFilter) {
        _labelFilter = [[YYLabel alloc] init];
    }
    return _labelFilter;
}

- (void)filterGrayString:(NSString *)grayString blueString:(NSString *)blueString{
    NSString *title = @"打开滤波/关闭滤波";
    NSMutableAttributedString* atext=[[NSMutableAttributedString alloc]initWithString:title];
    NSRange grayRange=[[atext string] rangeOfString:grayString];
    NSRange blueRange=[[atext string] rangeOfString:blueString];
    atext.yy_font = Font13;
    atext.yy_color = MainColor;
    atext.yy_alignment = NSTextAlignmentCenter;
    [atext yy_setTextHighlightRange:grayRange color:MainNormal backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(actionHeartLungFilterChange:)]) {
            Boolean result = [grayString containsString:@"打开滤波"];
            Boolean change = [self.delegate actionHeartLungFilterChange:result ? open_filtration : close_filtration];
            if (change) {
                NSLog(@"change = %i", change);
                [self filterGrayString:blueString blueString:grayString];
            }
        }
        
    }];
    [atext yy_setTextHighlightRange:blueRange color:MainColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(actionHeartLungFilterChange:)]) {
            Boolean result = [blueString containsString:@"打开滤波"];
            Boolean change = [self.delegate actionHeartLungFilterChange:result ? open_filtration : close_filtration];
            if (change) {
                NSLog(@"change = %i", change);
                [self filterGrayString:grayString blueString:blueString];
            }
        }
    }];
    self.labelFilter.attributedText = atext;
    
}

- (UIButton *)buttonHeartVoice{
    if(!_buttonHeartVoice) {
        _buttonHeartVoice = [self setupButton:@"心音"];
        _buttonHeartVoice.backgroundColor = MainColor;
        _buttonHeartVoice.tag = 1;
        _buttonHeartVoice.selected = YES;
        [_buttonHeartVoice addTarget:self action:@selector(actionClickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonHeartVoice;
}

- (UIButton *)buttonLungVoice{
    if(!_buttonLungVoice) {
        _buttonLungVoice = [self setupButton:@"肺音"];
        _buttonLungVoice.backgroundColor = ColorDAECFD;
        _buttonLungVoice.tag = 2;
        [_buttonLungVoice addTarget:self action:@selector(actionClickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonLungVoice;
}

- (UIButton *)setupButton:(NSString *)title{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateSelected];
    [button setTitleColor:MainColor forState:UIControlStateNormal];
    [button setTitleColor:WHITECOLOR forState:UIControlStateSelected];
    button.layer.cornerRadius = Ratio6;
    button.titleLabel.font = Font15;
    button.clipsToBounds = YES;
    return button;
}

@end
