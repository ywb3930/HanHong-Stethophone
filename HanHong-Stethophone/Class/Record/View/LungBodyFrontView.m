//
//  LungBodyFrontView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import "LungBodyFrontView.h"

@interface LungBodyFrontView()

@property (retain, nonatomic) UIView                    *viewBody;
@property (retain, nonatomic) UIImageView               *imageViewBoay;

@property (retain, nonatomic) UIButton                  *buttonDot1;
@property (retain, nonatomic) UIButton                  *buttonDot2;
@property (retain, nonatomic) UIButton                  *buttonDot3;
@property (retain, nonatomic) UIButton                  *buttonDot4;
@property (retain, nonatomic) UIButton                  *buttonDot5;
@property (retain, nonatomic) UIButton                  *buttonDot6;
@property (retain, nonatomic) UIButton                  *buttonDot7;
@property (retain, nonatomic) UIButton                  *buttonDot8;

@property (retain, nonatomic) UILabel                   *labelNum1;
@property (retain, nonatomic) UILabel                   *labelNum2;
@property (retain, nonatomic) UILabel                   *labelNum3;
@property (retain, nonatomic) UILabel                   *labelNum4;
@property (retain, nonatomic) UILabel                   *labelNum5;
@property (retain, nonatomic) UILabel                   *labelNum6;
@property (retain, nonatomic) UILabel                   *labelNum7;
@property (retain, nonatomic) UILabel                   *labelNum8;


@end

@implementation LungBodyFrontView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.positionIndex = 1;
        self.backgroundColor = WHITECOLOR;
        [self initData];
        [self initView];
    }
    return self;
}

- (void)actionRecordNextpositionCallBack:(NSInteger)index{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionClickButtonBodyPositionCallBack:tag:position:)]) {
        NSString *title = self.arrayButtonInfo[index];
        [self.delegate actionClickButtonBodyPositionCallBack:title tag:index position:Lung_front_bodyType];
        self.buttonSelectIndex = index;
    }

}

- (void)initData {
    self.arrayButtonsCollected = [NSMutableArray array];
    self.arraySelectItem = [NSMutableArray array];
    self.arrayButtonsTpye = [NSMutableArray array];
    self.arrayImageViews = [NSMutableArray array];
    self.arrayButtonInfo = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8"];
    self.arrayNoImageName = @[@"lung_not_num1", @"lung_not_num2", @"lung_not_num3", @"lung_not_num4", @"lung_not_num5", @"lung_not_num6", @"lung_not_num7", @"lung_not_num8"];
    self.arraySelectImageName = @[@"lung_select_num1", @"lung_select_num2", @"lung_select_num3", @"lung_select_num4", @"lung_select_num5", @"lung_select_num6", @"lung_select_num7", @"lung_select_num8"];
    self.arrayAlreadyImageName = @[@"lung_already_num1", @"lung_already_num2", @"lung_already_num3", @"lung_already_num4", @"lung_already_num5", @"lung_already_num6", @"lung_already_num7", @"lung_already_num8"];
}

- (void)initView {
    NSInteger count = self.arrayButtonInfo.count;
    CGFloat imageWidth = Ratio30;
    CGFloat width = (screenW - Ratio16 - imageWidth * count) / (count - 1);
    for(NSInteger i = 0; i < count; i++) {
        UIButton *buttonType = [[UIButton alloc] init];
        buttonType.tag = 100 + i;
        [buttonType setTitle:self.arrayButtonInfo[i] forState:UIControlStateNormal];
        [buttonType setBackgroundImage:[UIImage imageNamed:@"circle_false"] forState:UIControlStateNormal];
        [buttonType setBackgroundImage:[Tools viewImageFromColor:MainColor rect:CGRectMake(0, 0, Ratio44, Ratio44)] forState:UIControlStateSelected];
        [buttonType setTitleColor:MainNormal forState:UIControlStateNormal];
        [buttonType setTitleColor:WHITECOLOR forState:UIControlStateSelected];
        buttonType.layer.cornerRadius = imageWidth/2;
        buttonType.titleLabel.font = FontBold18;
        buttonType.clipsToBounds = YES;
        [buttonType addTarget:self action:@selector(actionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonType];
        buttonType.sd_layout.leftSpaceToView(self, Ratio11 +  (imageWidth + width) * i).widthIs(imageWidth).heightIs(imageWidth).topSpaceToView(self, Ratio22);
        [self.arrayButtonsTpye addObject:buttonType];
        
        UIButton *buttonCollected = [[UIButton alloc] init];
        [self addSubview:buttonCollected];
        [buttonCollected setTitleColor:MainColor forState:UIControlStateNormal];
        [buttonCollected setTitle:@"已采" forState:UIControlStateNormal];
        [buttonCollected setImage:[UIImage imageNamed:@"check_true"] forState:UIControlStateNormal];
        buttonCollected.enabled = NO;
        buttonCollected.titleLabel.font = Font11;
        buttonCollected.hidden = YES;
        buttonCollected.cs_imageSize = CGSizeMake(Ratio8, Ratio8);
        buttonCollected.cs_middleDistance = Ratio3;
        [self.arrayButtonsCollected addObject:buttonCollected];
        buttonCollected.sd_layout.centerXEqualToView(buttonType).widthIs(imageWidth*2).heightIs(Ratio17).topSpaceToView(buttonType, Ratio1);
    }
    
    [self addSubview:self.viewBody];
    self.viewBody.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self, imageWidth + Ratio44).heightIs(screenW*35/72);
    [self.viewBody addSubview:self.imageViewBoay];
    self.imageViewBoay.sd_layout.leftSpaceToView(self.viewBody, 0).topSpaceToView(self.viewBody, 0).rightSpaceToView(self.viewBody, 0).bottomSpaceToView(self.viewBody, 0);
    
    for(NSInteger i = 0; i < count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 1000 + i;
        imageView.image = [UIImage imageNamed:self.arrayNoImageName[i]];
        imageView.contentMode = UIViewContentModeScaleToFill;
        [self.viewBody addSubview:imageView];
        imageView.sd_layout.leftSpaceToView(self.viewBody, 0).rightSpaceToView(self.viewBody, 0).topSpaceToView(self.viewBody, 0).bottomSpaceToView(self.viewBody, 0);
        [self.arrayImageViews addObject:imageView];
    }
    
    [self.viewBody addSubview:self.buttonDot1];
    self.buttonDot1.sd_layout.heightIs(Ratio6).widthIs(Ratio6).topSpaceToView(self.viewBody, 79.f*screenRatio).rightSpaceToView(self.viewBody, screenW/2 - Ratio11);
    
    [self.viewBody addSubview:self.buttonDot2];
    self.buttonDot2.sd_layout.heightIs(Ratio6).widthIs(Ratio6).topSpaceToView(self.viewBody, 79.f*screenRatio).leftSpaceToView(self.viewBody, screenW/2 - Ratio11);
    
    [self.viewBody addSubview:self.buttonDot3];
    self.buttonDot3.sd_layout.heightIs(Ratio6).widthIs(Ratio6).topSpaceToView(self.viewBody, 87.f*screenRatio).rightSpaceToView(self.viewBody, screenW/2 - Ratio16);
    
    [self.viewBody addSubview:self.buttonDot4];
    self.buttonDot4.sd_layout.heightIs(Ratio6).widthIs(Ratio6).topSpaceToView(self.viewBody, 87.f*screenRatio).leftSpaceToView(self.viewBody, screenW/2 - Ratio16);
    
    [self.viewBody addSubview:self.buttonDot5];
    self.buttonDot5.sd_layout.heightIs(Ratio6).widthIs(Ratio6).topSpaceToView(self.viewBody, 98.f*screenRatio).rightSpaceToView(self.viewBody, screenW/2 - Ratio16);
    
    [self.viewBody addSubview:self.buttonDot6];
    self.buttonDot6.sd_layout.heightIs(Ratio6).widthIs(Ratio6).topSpaceToView(self.viewBody, 98.f*screenRatio).leftSpaceToView(self.viewBody, screenW/2 - Ratio16);
    
    [self.viewBody addSubview:self.buttonDot7];
    self.buttonDot7.sd_layout.heightIs(Ratio6).widthIs(Ratio6).topSpaceToView(self.viewBody, 115.f*screenRatio).rightSpaceToView(self.viewBody, screenW/2 - 22.f*screenRatio);
    
    [self.viewBody addSubview:self.buttonDot8];
    self.buttonDot8.sd_layout.heightIs(Ratio6).widthIs(Ratio6).topSpaceToView(self.viewBody, 115.f*screenRatio).leftSpaceToView(self.viewBody, screenW/2 -  22.f*screenRatio);
    
    [self.viewBody addSubview:self.labelNum1];
    [self.viewBody addSubview:self.labelNum2];
    self.labelNum1.sd_layout.rightSpaceToView(self.viewBody, 0).heightIs(Ratio15).topSpaceToView(self.viewBody, 38.f*screenRatio).widthIs(screenW/3-Ratio18);
    self.labelNum2.sd_layout.leftSpaceToView(self.viewBody, 0).heightIs(Ratio15).centerYEqualToView(self.labelNum1).widthIs(screenW/3-Ratio18);
    
    [self.viewBody addSubview:self.labelNum3];
    [self.viewBody addSubview:self.labelNum4];
    self.labelNum3.sd_layout.rightSpaceToView(self.viewBody, 0).heightIs(Ratio15).topSpaceToView(self.labelNum1, Ratio14).widthIs(screenW/3-Ratio18);
    self.labelNum4.sd_layout.leftSpaceToView(self.viewBody, 0).heightIs(Ratio15).centerYEqualToView(self.labelNum3).widthIs(screenW/3-Ratio18);
    
    [self.viewBody addSubview:self.labelNum5];
    [self.viewBody addSubview:self.labelNum6];
    self.labelNum5.sd_layout.rightSpaceToView(self.viewBody, 0).heightIs(Ratio15).topSpaceToView(self.labelNum3, Ratio12).widthIs(screenW/3-Ratio18);
    self.labelNum6.sd_layout.leftSpaceToView(self.viewBody, 0).heightIs(Ratio15).centerYEqualToView(self.labelNum5).widthIs(screenW/3-Ratio18);
    
    [self.viewBody addSubview:self.labelNum7];
    [self.viewBody addSubview:self.labelNum8];
    self.labelNum7.sd_layout.rightSpaceToView(self.viewBody, 0).heightIs(Ratio15).topSpaceToView(self.labelNum5, Ratio12).widthIs(screenW/3-Ratio18);
    self.labelNum8.sd_layout.leftSpaceToView(self.viewBody, 0).heightIs(Ratio15).centerYEqualToView(self.labelNum7).widthIs(screenW/3-Ratio18);
    
    self.arrayButtonDot = @[self.buttonDot1, self.buttonDot2, self.buttonDot3, self.buttonDot4, self.buttonDot5, self.buttonDot6, self.buttonDot7, self.buttonDot8];
    self.arrayLabelPlace = @[self.labelNum1, self.labelNum2, self.labelNum3, self.labelNum4, self.labelNum5, self.labelNum6, self.labelNum7, self.labelNum8];
}


- (UIView *)viewBody{
    if(!_viewBody) {
        _viewBody = [[UIView alloc] init];
        _viewBody.backgroundColor = WHITECOLOR;
    }
    return _viewBody;
}

- (UIImageView *)imageViewBoay{
    if(!_imageViewBoay) {
        _imageViewBoay = [[UIImageView alloc] init];
        _imageViewBoay.image = [UIImage imageNamed:@"lung_front_select_false"];
        _imageViewBoay.contentMode = UIViewContentModeScaleToFill;
        _imageViewBoay.backgroundColor = WHITECOLOR;
    }
    return _imageViewBoay;
}

- (UIButton *)buttonDot1{
    if(!_buttonDot1) {
        _buttonDot1 = [self setupButton];
    }
    return _buttonDot1;
}

- (UIButton *)buttonDot2{
    if(!_buttonDot2) {
        _buttonDot2 = [self setupButton];
    }
    return _buttonDot2;
}

- (UIButton *)buttonDot3{
    if(!_buttonDot3) {
        _buttonDot3 = [self setupButton];
    }
    return _buttonDot3;
}


- (UIButton *)buttonDot4{
    if(!_buttonDot4) {
        _buttonDot4 = [self setupButton];
    }
    return _buttonDot4;
}

- (UIButton *)buttonDot5{
    if(!_buttonDot5) {
        _buttonDot5 = [self setupButton];
    }
    return _buttonDot5;
}

- (UIButton *)buttonDot6{
    if(!_buttonDot6) {
        _buttonDot6 = [self setupButton];
    }
    return _buttonDot6;
}


- (UIButton *)buttonDot7{
    if(!_buttonDot7) {
        _buttonDot7 = [self setupButton];
    }
    return _buttonDot7;
}

- (UIButton *)buttonDot8{
    if(!_buttonDot8) {
        _buttonDot8 = [self setupButton];
    }
    return _buttonDot8;
}

- (UILabel *)labelNum1{
    if(!_labelNum1) {
        _labelNum1 = [self setLabelView:@"1 左肺尖"];
    }
    return _labelNum1;
}

- (UILabel *)labelNum2{
    if(!_labelNum2) {
        _labelNum2 = [self setLabelView:@"2 右肺尖"];
        _labelNum2.textAlignment = NSTextAlignmentRight;
    }
    return _labelNum2;
}

- (UILabel *)labelNum3{
    if(!_labelNum3) {
        _labelNum3 = [self setLabelView:@"3 左上肺"];
    }
    return _labelNum3;
}

- (UILabel *)labelNum4{
    if(!_labelNum4) {
        _labelNum4 = [self setLabelView:@"4 右上肺"];
        _labelNum4.textAlignment = NSTextAlignmentRight;
    }
    return _labelNum4;
}

- (UILabel *)labelNum5{
    if(!_labelNum5) {
        _labelNum5 = [self setLabelView:@"5 左前胸"];
    }
    return _labelNum5;
}

- (UILabel *)labelNum6{
    if(!_labelNum6) {
        _labelNum6 = [self setLabelView:@"6 右前胸"];
        _labelNum6.textAlignment = NSTextAlignmentRight;
    }
    return _labelNum6;
}

- (UILabel *)labelNum7{
    if(!_labelNum7) {
        _labelNum7 = [self setLabelView:@"7 左下肺"];
    }
    return _labelNum7;
}

- (UILabel *)labelNum8{
    if(!_labelNum8) {
        _labelNum8 = [self setLabelView:@"8 右下肺"];
        _labelNum8.textAlignment = NSTextAlignmentRight;
    }
    return _labelNum8;
}

@end
