//
//  LungBodyBackView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import "LungBodyBackView.h"


@interface LungBodyBackView()

@property (retain, nonatomic) UIView                    *viewBody;
@property (retain, nonatomic) UIImageView               *imageViewBoay;
@property (retain, nonatomic) UIButton                  *buttonDot11;
@property (retain, nonatomic) UIButton                  *buttonDot12;
@property (retain, nonatomic) UILabel                   *labelNum11;
@property (retain, nonatomic) UILabel                   *labelNum12;


@end

@implementation LungBodyBackView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.positionIndex = 3;
        self.backgroundColor = WHITECOLOR;
        [self initData];
        [self initView];
    }
    return self;
}

- (void)setArrayReordSequence:(NSArray *)arrayReordSequence{
    for (NSDictionary *data in arrayReordSequence) {
        NSInteger index = [data[@"id"] integerValue];
        if (index == 10 || index == 11) {
            UIButton *buttonType = self.arrayButtonsTpye[index - 10];
            buttonType.layer.borderWidth = Ratio1;
            buttonType.layer.borderColor = MainColor.CGColor;
        }
        
    }
}


- (void)actionRecordNextpositionCallBack:(NSInteger)index{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionClickButtonBodyPositionCallBack:tag:position:)]) {
        NSString *title = self.arrayButtonInfo[index];
        [self.delegate actionClickButtonBodyPositionCallBack:title tag:index position:Lung_back_bodyType];
        self.buttonSelectIndex = index;
    }
}

- (void)initData {
    self.arrayButtonsCollected = [NSMutableArray array];
    self.arraySelectItem = [NSMutableArray array];
    self.arrayButtonsTpye = [NSMutableArray array];
    self.arrayImageViews = [NSMutableArray array];
    self.arrayButtonInfo = @[ @"11", @"12"];
    self.arrayNoImageName = @[@"lung_not_num11", @"lung_not_num12"];
    self.arraySelectImageName = @[@"lung_select_num11", @"lung_select_num12"];
    self.arrayAlreadyImageName = @[@"lung_already_num11", @"lung_already_num12"];
}

- (void)initView {
    NSInteger count = self.arrayButtonInfo.count;
    CGFloat imageWidth = Ratio30;
   // CGFloat width = (screenW - Ratio16 - imageWidth * count) / (count - 1);
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
        buttonType.sd_layout.centerXIs(screenW/3*(i+1)).widthIs(imageWidth).heightIs(imageWidth).topSpaceToView(self, Ratio22);
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
    
    [self.viewBody addSubview:self.buttonDot11];
    self.buttonDot11.sd_layout.heightIs(Ratio6).widthIs(Ratio6).topSpaceToView(self.viewBody, 88.f*screenRatio).leftSpaceToView(self.viewBody, screenW/2 - Ratio13);
    
    [self.viewBody addSubview:self.buttonDot12];
    self.buttonDot12.sd_layout.heightIs(Ratio6).widthIs(Ratio6).centerYEqualToView(self.buttonDot11).rightSpaceToView(self.viewBody, screenW/2 - Ratio13);
   
    
    [self.viewBody addSubview:self.labelNum11];
    [self.viewBody addSubview:self.labelNum12];
    self.labelNum11.sd_layout.leftSpaceToView(self.viewBody, 0).heightIs(Ratio15).topSpaceToView(self.viewBody, 48.f*screenRatio).widthIs(screenW/3-Ratio11);
    self.labelNum12.sd_layout.rightSpaceToView(self.viewBody, 0).heightIs(Ratio15).centerYEqualToView(self.labelNum11).widthIs(screenW/3-Ratio11);
    
    self.arrayButtonDot = @[self.buttonDot11, self.buttonDot12];
    self.arrayLabelPlace = @[self.labelNum11, self.labelNum12];
    
    
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
        _imageViewBoay.image = [UIImage imageNamed:@"lung_back_select_false"];
        _imageViewBoay.contentMode = UIViewContentModeScaleToFill;
        _imageViewBoay.backgroundColor = WHITECOLOR;
    }
    return _imageViewBoay;
}

- (UIButton *)buttonDot11{
    if (!_buttonDot11) {
        _buttonDot11 = [self setupButton];
    }
    return _buttonDot11;
}

- (UIButton *)buttonDot12{
    if (!_buttonDot12) {
        _buttonDot12 = [self setupButton];
    }
    return _buttonDot12;
}

- (UILabel *)labelNum11{
    if(!_labelNum11) {
        _labelNum11 = [self setLabelView:@"11 背左"];
        _labelNum11.textAlignment = NSTextAlignmentRight;
    }
    return _labelNum11;
}

- (UILabel *)labelNum12{
    if(!_labelNum12) {
        _labelNum12 = [self setLabelView:@"12 背右"];
        
    }
    return _labelNum12;
}


@end
