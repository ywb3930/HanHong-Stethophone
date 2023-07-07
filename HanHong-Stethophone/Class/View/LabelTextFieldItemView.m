//
//  LabelTextFieldItemView.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/13.
//

#import "LabelTextFieldItemView.h"

@interface LabelTextFieldItemView()

@property (retain, nonatomic) NSString          *title;
@property (assign, nonatomic) Boolean           bMust;
@property (retain, nonatomic) NSString          *placeholder;

@property (retain, nonatomic) UILabel           *labelTitle;
@property (retain, nonatomic) UIImageView       *imageViewStar;

@property (retain, nonatomic) UIView            *viewLine;
@property (retain, nonatomic) UIImageView       *imageViewRight;
 
@end

@implementation LabelTextFieldItemView

- (instancetype)initWithTitle:(NSString *)title bMust:(Boolean)bMust  placeholder:(NSString *)placeholder
{
    if (self = [super init]) {
        self.title = title;
        self.placeholder = placeholder;
        self.bMust = bMust;
        [self initView];
    }
    return self;
}

- (void)setBShowDirection:(Boolean)bShowDirection{
    self.imageViewRight.hidden = NO;
    self.imageViewRight.sd_layout.widthIs(Ratio8);
    self.textFieldInfo.sd_layout.rightSpaceToView(self.imageViewRight, Ratio11);
    [self.imageViewRight updateLayout];
    [self.textFieldInfo updateLayout];
}

- (void)setHiddenLine:(Boolean)hiddenLine{
    self.viewLine.hidden = hiddenLine;
}

- (void)initView{
    [self addSubview:self.labelTitle];
    [self addSubview:self.imageViewStar];
    [self addSubview:self.textFieldInfo];
    [self addSubview:self.viewLine];
    [self addSubview:self.imageViewRight];
    self.labelTitle.sd_layout.leftSpaceToView(self, 0).topSpaceToView(self, 0).bottomSpaceToView(self, 0);
    [self.labelTitle setSingleLineAutoResizeWithMaxWidth:screenW/3];
    self.imageViewStar.sd_layout.centerYEqualToView(self.labelTitle).leftSpaceToView(self.labelTitle, Ratio2).widthIs(Ratio5).heightIs(Ratio5);
    self.imageViewRight.sd_layout.rightSpaceToView(self, 0).centerYEqualToView(self.labelTitle).widthIs(0).heightIs(Ratio13);
    self.textFieldInfo.sd_layout.leftSpaceToView(self.imageViewStar, Ratio11).rightSpaceToView(self.imageViewRight, 0).centerYEqualToView(self.labelTitle).bottomSpaceToView(self, 0);
    self.viewLine.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(1).bottomSpaceToView(self, 0);
}

- (UILabel *)labelTitle{
    if(!_labelTitle){
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.font = Font15;
        _labelTitle.textColor = MainBlack;
        _labelTitle.text = self.title;
    }
    return _labelTitle;
}

-(UIImageView *)imageViewRight{
    if(!_imageViewRight){
        _imageViewRight = [[UIImageView alloc] init];
        _imageViewRight.image = [UIImage imageNamed:@"enter_into"];
        _imageViewRight.hidden = YES;
    }
    return _imageViewRight;
}

-(UIImageView *)imageViewStar{
    if(!_imageViewStar) {
        _imageViewStar = [[UIImageView alloc] init];
        _imageViewStar.image = [UIImage imageNamed:@"xinghao"];
        _imageViewStar.hidden = !self.bMust;
    }
    return _imageViewStar;
}

- (UITextField *)textFieldInfo{
    if(!_textFieldInfo) {
        _textFieldInfo = [[UITextField alloc] init];
        [_textFieldInfo setPlaceholder:self.placeholder];
        _textFieldInfo.font = Font15;
        _textFieldInfo.textColor = MainBlack;
        _textFieldInfo.textAlignment = NSTextAlignmentRight;
    }
    return _textFieldInfo;
}

- (UIView *)viewLine{
    if(!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = HEXCOLOR(0xF5F5F5, 1);
    }
    return _viewLine;
}

@end
