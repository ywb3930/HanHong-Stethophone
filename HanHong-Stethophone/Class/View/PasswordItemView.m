//
//  PasswordItemView.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/14.
//

#import "PasswordItemView.h"

@interface PasswordItemView()

@property (retain, nonatomic) NSString              *title;
@property (retain, nonatomic) NSString              *placeholder;
@property (retain, nonatomic) UILabel           *labelPass;
@property (retain, nonatomic) UIButton          *buttonShowPass;
@property (retain, nonatomic) UIView            *viewLinePa;
@property (assign, nonatomic) Boolean           bMust;
@property (retain, nonatomic) UIImageView       *imageViewStar;

@end

@implementation PasswordItemView

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
    [self addSubview:self.labelPass];
    [self addSubview:self.viewLinePa];
    [self addSubview:self.imageViewStar];
    [self addSubview:self.textFieldPass];
    [self addSubview:self.buttonShowPass];
    self.labelPass.sd_layout.leftSpaceToView(self, 0).widthIs(Ratio33).bottomSpaceToView(self, 0).topSpaceToView(self, 0);
    [self.labelPass setSingleLineAutoResizeWithMaxWidth:Ratio135];
    self.imageViewStar.sd_layout.centerYEqualToView(self.labelPass).leftSpaceToView(self.labelPass, Ratio2).widthIs(Ratio5).heightIs(Ratio5);
    self.buttonShowPass.sd_layout.rightSpaceToView(self, 0).centerYEqualToView(self.labelPass).widthIs(Ratio24).heightIs(Ratio24);
    self.textFieldPass.sd_layout.leftSpaceToView(self.imageViewStar, Ratio8).rightSpaceToView(self.buttonShowPass, Ratio11).bottomSpaceToView(self, 0).centerYEqualToView(self.labelPass);
    self.viewLinePa.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio1).topSpaceToView(self.labelPass, 0);
}

- (void)actionShowPass:(UIButton *)button{
    self.textFieldPass.secureTextEntry = button.selected;
    button.selected = !button.selected;
}

-(UIImageView *)imageViewStar{
    if(!_imageViewStar) {
        _imageViewStar = [[UIImageView alloc] init];
        _imageViewStar.image = [UIImage imageNamed:@"xinghao"];
        _imageViewStar.hidden = !self.bMust;
    }
    return _imageViewStar;
}

- (UILabel *)labelPass{
    if(!_labelPass) {
        _labelPass = [[UILabel alloc] init];
        _labelPass.font = Font15;
        _labelPass.textColor = MainBlack;
        _labelPass.text = self.title;
    }
    return _labelPass;
}

- (UITextField *)textFieldPass{
    if(!_textFieldPass) {
        _textFieldPass = [[UITextField alloc] init];
        [_textFieldPass setPlaceholder:self.placeholder];
        _textFieldPass.font = Font15;
        _textFieldPass.textColor = MainBlack;
        _textFieldPass.textAlignment = NSTextAlignmentRight;
        _textFieldPass.secureTextEntry = YES;
    }
    return _textFieldPass;
}

- (UIView *)viewLinePa{
    if(!_viewLinePa) {
        _viewLinePa = [[UIView alloc] init];
        _viewLinePa.backgroundColor = HEXCOLOR(0xF5F5F5, 1);
    }
    return _viewLinePa;
}

- (UIButton *)buttonShowPass{
    if(!_buttonShowPass) {
        _buttonShowPass = [[UIButton alloc] init];
        [_buttonShowPass setImage:[UIImage imageNamed:@"eyes_close"] forState:UIControlStateNormal];
        [_buttonShowPass setImage:[UIImage imageNamed:@"eye_open"] forState:UIControlStateSelected];
        [_buttonShowPass addTarget:self action:@selector(actionShowPass:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonShowPass;
}


@end
