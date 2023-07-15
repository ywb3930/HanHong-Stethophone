//
//  ItemAgeView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/16.
//

#import "ItemAgeView.h"
#import "UITextField+UsefulMethod.h"

@interface ItemAgeView()

@property (retain, nonatomic) UILabel           *labelTitle;
@property (retain, nonatomic) UILabel           *labelAge;
@property (retain, nonatomic) UILabel           *labelMonth;
@property (retain, nonatomic) UIView            *viewLine;

@end

@implementation ItemAgeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        [self initView];
    }
    return self;
}

- (void)initView{
    [self addSubview:self.labelTitle];
    [self addSubview:self.textFieldAge];
    [self addSubview:self.labelAge];
    [self addSubview:self.textFieldMonth];
    [self addSubview:self.labelMonth];
    [self addSubview:self.viewLine];
    
    self.labelTitle.sd_layout.leftSpaceToView(self, 0).widthIs(Ratio33).heightIs(Ratio22).centerYEqualToView(self);
    self.labelMonth.sd_layout.rightSpaceToView(self, 0).centerYEqualToView(self).heightIs(Ratio22).widthIs(Ratio33);
    self.textFieldMonth.sd_layout.rightSpaceToView(self.labelMonth, 0).widthIs(Ratio44).centerYEqualToView(self).heightIs(Ratio33);
    self.labelAge.sd_layout.rightSpaceToView(self.textFieldMonth, 0).widthIs(Ratio18).centerYEqualToView(self).heightIs(Ratio22);
    self.textFieldAge.sd_layout.rightSpaceToView(self.labelAge, 0).heightIs(Ratio33).widthIs(Ratio44).centerYEqualToView(self);
    self.viewLine.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).bottomSpaceToView(self, 0).heightIs(Ratio1);
}

- (UILabel *)labelTitle{
    if(!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.text = @"年龄";
        _labelTitle.textColor = MainBlack;
        _labelTitle.font = Font15;
    }
    return _labelTitle;
}

- (UITextField *)textFieldAge{
    if(!_textFieldAge) {
        _textFieldAge = [[UITextField alloc] init];
        _textFieldAge.textColor = MainBlack;
        _textFieldAge.keyboardType = UIKeyboardTypeNumberPad;
        _textFieldAge.textAlignment = NSTextAlignmentCenter;
        [_textFieldAge addInputAccessoryViewButtonWithTitle:@"收起键盘"];
    }
    return _textFieldAge;
}

- (UILabel *)labelAge{
    if(!_labelAge) {
        _labelAge = [[UILabel alloc] init];
        _labelAge.text = @"岁";
        _labelAge.textColor = MainBlack;
        _labelAge.font = Font15;
    }
    return _labelAge;
}

- (UITextField *)textFieldMonth{
    if(!_textFieldMonth) {
        _textFieldMonth = [[UITextField alloc] init];
        _textFieldMonth.textColor = MainBlack;
        _textFieldMonth.keyboardType = UIKeyboardTypeNumberPad;
        _textFieldMonth.textAlignment = NSTextAlignmentCenter;
        [_textFieldMonth addInputAccessoryViewButtonWithTitle:@"收起键盘"];
    }
    return _textFieldMonth;
}

- (UILabel *)labelMonth{
    if(!_labelMonth) {
        _labelMonth = [[UILabel alloc] init];
        _labelMonth.text = @"个月";
        _labelMonth.textColor = MainBlack;
        _labelMonth.font = Font15;
    }
    return _labelMonth;
}

- (UIView *)viewLine{
    if(!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine;
}


@end
