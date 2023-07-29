//
//  HeartBodyView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import "HeartBodyView.h"

@interface HeartBodyView()

@property (retain, nonatomic) UIButton                  *buttonDotA;
@property (retain, nonatomic) UIButton                  *buttonDotE;
@property (retain, nonatomic) UIButton                  *buttonDotM;
@property (retain, nonatomic) UIButton                  *buttonDotP;
@property (retain, nonatomic) UIButton                  *buttonDotT;

@property (retain, nonatomic) UILabel                   *labelAAorticValve;//A 主动脉瓣听诊区
@property (retain, nonatomic) UILabel                   *labelTTricuspid;//T 三尖瓣听诊区
@property (retain, nonatomic) UILabel                   *labelPPulmonaryArtery;//P 肺动脉听诊区
@property (retain, nonatomic) UILabel                   *labelEAortaSecond;//E 主动脉第二听诊区
@property (retain, nonatomic) UILabel                   *labelMValvulaBicuspidalis;//M 二尖瓣听诊区

@property (retain, nonatomic) UIView                    *viewBody;
@property (retain, nonatomic) UIImageView               *imageViewBoay;


@end

@implementation HeartBodyView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = WHITECOLOR;
        self.positionIndex = 0;
        [self initData];
        [self initView];
    }
    return self;
}

- (void)initData {
    self.arrayButtonsCollected = [NSMutableArray array];
    self.arrayButtonsTpye = [NSMutableArray array];
    self.arraySelectItem = [NSMutableArray array];
    self.arrayImageViews = [NSMutableArray array];
    self.arrayButtonInfo = @[@"M", @"P", @"A", @"E", @"T"];
    self.arrayNoImageName = @[@"heart_not_m", @"heart_not_p", @"heart_not_a", @"heart_not_e", @"heart_not_t"];
    self.arraySelectImageName = @[@"heart_select_m", @"heart_select_p", @"heart_select_a", @"heart_select_e", @"heart_select_t"];
    self.arrayAlreadyImageName = @[@"heart_already_m", @"heart_already_p", @"heart_already_a", @"heart_already_e", @"heart_already_t"];
}

- (void)setArrayReordSequence:(NSArray *)arrayReordSequence{
    for (NSDictionary *data in arrayReordSequence) {
        NSInteger index = [data[@"id"] integerValue];
        UIButton *buttonType = self.arrayButtonsTpye[index];
        buttonType.layer.borderWidth = Ratio1;
        buttonType.layer.borderColor = MainColor.CGColor;
    }
}

- (void)actionRecordNextpositionCallBack:(NSInteger)index{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionClickButtonBodyPositionCallBack:tag:position:)]) {
        NSString *title = self.arrayButtonInfo[index];
        [self.delegate actionClickButtonBodyPositionCallBack:title tag:index position:0];
        self.buttonSelectIndex = index;
    }
}

- (void)initView{
    NSInteger count = self.arrayButtonInfo.count;
    CGFloat imageWidth = Ratio30;
    CGFloat width = (screenW - Ratio30 - imageWidth * count) / (count - 1);
    UIImage *imageMainColor = [Tools viewImageFromColor:MainColor rect:CGRectMake(0, 0, Ratio44, Ratio44)];
    for(NSInteger i = 0; i < count; i++) {
        UIButton *buttonType = [[UIButton alloc] init];
        buttonType.tag = 100 + i;
        [buttonType setTitle:self.arrayButtonInfo[i] forState:UIControlStateNormal];
        
        [buttonType setBackgroundImage:imageMainColor forState:UIControlStateSelected];
        [buttonType setBackgroundImage:imageMainColor forState:UIControlStateDisabled];
        [buttonType setTitleColor:MainNormal forState:UIControlStateNormal];
        [buttonType setTitleColor:WHITECOLOR forState:UIControlStateSelected];
        [buttonType setTitleColor:AlreadyColor forState:UIControlStateDisabled];
        buttonType.layer.cornerRadius = imageWidth/2;
        buttonType.titleLabel.font = FontBold18;
        buttonType.clipsToBounds = YES;
        [buttonType addTarget:self action:@selector(actionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonType];
        buttonType.sd_layout.leftSpaceToView(self, Ratio18 +  (imageWidth + width) * i).widthIs(imageWidth).heightIs(imageWidth).topSpaceToView(self, Ratio22);
        [buttonType setBackgroundImage:[UIImage imageNamed:@"circle_false"] forState:UIControlStateNormal];
        [self.arrayButtonsTpye addObject:buttonType];
        
        
        
        
        UIButton *buttonCollected = [[UIButton alloc] init];
        [self addSubview:buttonCollected];
        [buttonCollected setTitleColor:MainColor forState:UIControlStateNormal];
        [buttonCollected setTitle:@"已采" forState:UIControlStateNormal];
        [buttonCollected setImage:[UIImage imageNamed:@"check_true"] forState:UIControlStateNormal];
        buttonCollected.enabled = NO;
        buttonCollected.imageView.clipsToBounds = YES;
        buttonCollected.contentMode = UIViewContentModeScaleAspectFit;
        buttonCollected.titleLabel.font = Font11;
        buttonCollected.cs_imagePositionMode = ImagePositionModeDefault;
        buttonCollected.cs_imageSize = CGSizeMake(Ratio8, Ratio8);
        buttonCollected.cs_middleDistance = Ratio3;
        buttonCollected.hidden = YES;
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

    [self.viewBody addSubview:self.buttonDotA];
    self.buttonDotA.sd_layout.heightIs(Ratio6).widthIs(Ratio6).leftSpaceToView(self.viewBody, screenW/2-7.f*screenRatio).topSpaceToView(self.viewBody, 109.f*screenRatio);
    
    [self.viewBody addSubview:self.buttonDotT];
    self.buttonDotT.sd_layout.heightIs(Ratio6).widthIs(Ratio6).leftSpaceToView(self.viewBody, screenW/2-Ratio8).topSpaceToView(self.viewBody, 119.f*screenRatio);
    
    [self.viewBody addSubview:self.buttonDotP];
    self.buttonDotP.sd_layout.heightIs(Ratio6).widthIs(Ratio6).leftSpaceToView(self.viewBody, screenW/2+Ratio8).topSpaceToView(self.viewBody, 109.f*screenRatio);
    
    [self.viewBody addSubview:self.buttonDotE];
    self.buttonDotE.sd_layout.heightIs(Ratio6).widthIs(Ratio6).leftSpaceToView(self.viewBody, screenW/2+Ratio8).topSpaceToView(self.viewBody, 119.f*screenRatio);
    
    [self.viewBody addSubview:self.buttonDotM];
    self.buttonDotM.sd_layout.heightIs(Ratio6).widthIs(Ratio6).leftSpaceToView(self.viewBody, screenW/2+Ratio10).topSpaceToView(self.viewBody, 125.f*screenRatio);
    
    [self.viewBody addSubview:self.labelAAorticValve];
    self.labelAAorticValve.sd_layout.leftSpaceToView(self.viewBody, 0).heightIs(Ratio17).topSpaceToView(self.viewBody, 81.f*screenRatio).widthIs(screenW / 3 - Ratio3);
    
    [self.viewBody addSubview:self.labelTTricuspid];
    self.labelTTricuspid.sd_layout.leftSpaceToView(self.viewBody, 0).heightIs(Ratio17).topSpaceToView(self.labelAAorticValve, Ratio10).widthIs(screenW / 3 - Ratio3);
    
    [self.viewBody addSubview:self.labelPPulmonaryArtery];
    self.labelPPulmonaryArtery.sd_layout.rightSpaceToView(self.viewBody, 0).heightIs(Ratio17).centerYEqualToView(self.labelAAorticValve).widthIs(screenW / 3 + Ratio15);
    
    [self.viewBody addSubview:self.labelEAortaSecond];
    self.labelEAortaSecond.sd_layout.rightSpaceToView(self.viewBody, 0).heightIs(Ratio17).centerYEqualToView(self.labelTTricuspid).widthIs(screenW / 3 + Ratio15);

    [self.viewBody addSubview:self.labelMValvulaBicuspidalis];
    self.labelMValvulaBicuspidalis.sd_layout.rightSpaceToView(self.viewBody, 0).heightIs(Ratio17).topSpaceToView(self.labelEAortaSecond, Ratio8).widthIs(screenW / 3 + Ratio15);

    
    self.arrayButtonDot = @[self.buttonDotM, self.buttonDotP, self.buttonDotA, self.buttonDotE, self.buttonDotT];;
    self.arrayLabelPlace = @[self.labelMValvulaBicuspidalis, self.labelPPulmonaryArtery, self.labelAAorticValve, self.labelEAortaSecond, self.labelTTricuspid];
}

- (UIButton *)buttonDotA{
    if(!_buttonDotA) {
        _buttonDotA = [self setupButton];
    }
    return _buttonDotA;
}

- (UIButton *)buttonDotE{
    if(!_buttonDotE) {
        _buttonDotE = [self setupButton];
    }
    return _buttonDotE;
}

- (UIView *)viewBody{
    if(!_viewBody) {
        _viewBody = [[UIView alloc] init];
        _viewBody.backgroundColor = WHITECOLOR;
    }
    return _viewBody;
}

- (UIButton *)buttonDotP{
    if(!_buttonDotP) {
        _buttonDotP = [self setupButton];
    }
    return _buttonDotP;
}

- (UIButton *)buttonDotM{
    if(!_buttonDotM) {
        _buttonDotM = [self setupButton];
    }
    return _buttonDotM;
}

- (UIButton *)buttonDotT{
    if(!_buttonDotT) {
        _buttonDotT = [self setupButton];
    }
    return _buttonDotT;
}


- (UILabel *)labelAAorticValve{
    if(!_labelAAorticValve) {
        _labelAAorticValve = [self setLabelView:@"A 主动脉瓣听诊区"];
        _labelAAorticValve.textAlignment = NSTextAlignmentRight;
    }
    return _labelAAorticValve;
}

- (UILabel *)labelTTricuspid{
    if(!_labelTTricuspid) {
        _labelTTricuspid = [self setLabelView:@"T 三尖瓣听诊区"];
        _labelTTricuspid.textAlignment = NSTextAlignmentRight;
    }
    return _labelTTricuspid;
}

- (UILabel *)labelPPulmonaryArtery{
    if(!_labelPPulmonaryArtery) {
        _labelPPulmonaryArtery = [self setLabelView:@"P 肺动脉听诊区"];
        
    }
    return _labelPPulmonaryArtery;
}

- (UILabel *)labelEAortaSecond{
    if(!_labelEAortaSecond) {
        _labelEAortaSecond = [self setLabelView:@"E 主动脉第二听诊区"];
    }
    return _labelEAortaSecond;
}

- (UILabel *)labelMValvulaBicuspidalis{
    if(!_labelMValvulaBicuspidalis) {
        _labelMValvulaBicuspidalis = [self setLabelView:@"M 二尖瓣听诊区"];
    }
    return _labelMValvulaBicuspidalis;
}

- (UIImageView *)imageViewBoay{
    if(!_imageViewBoay) {
        _imageViewBoay = [[UIImageView alloc] init];
        _imageViewBoay.image = [UIImage imageNamed:@"heart_select_false"];
        _imageViewBoay.contentMode = UIViewContentModeScaleToFill;
        _imageViewBoay.backgroundColor = WHITECOLOR;
    }
    return _imageViewBoay;
}


@end
