//
//  HeartBodyView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/17.
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

@property (retain, nonatomic) NSArray                   *arrayButtonInfo;//按钮标题
@property (retain, nonatomic) NSArray                   *arrayNoImageName;//没选中时的图片
@property (retain, nonatomic) NSArray                   *arraySelectImageName;//选中时的图片
@property (retain, nonatomic) NSArray                   *arrayAlreadyImageName;//准备时的图片
@property (retain, nonatomic) NSArray                   *arrayButtonDot;//小圆点的图片
@property (retain, nonatomic) NSArray                   *arrayLabelPlace;

@property (retain, nonatomic) UIView                    *viewBody;
@property (retain, nonatomic) UIImageView               *imageViewBoay;

@property (retain, nonatomic) NSMutableArray            *arrayButtonsTpye;//按钮数组
@property (retain, nonatomic) NSMutableArray            *arrayButtonsCollected;//
@property (retain, nonatomic) NSMutableArray            *arrayImageViews;//图片数组


@property (retain, nonatomic) NSTimer                   *timer;
@property (assign, nonatomic) NSInteger                 buttonSelectIndex;
@property (retain, nonatomic) NSMutableArray            *arraySelectItem;

@property (assign, nonatomic) Boolean                   bActionFromAuto;//事件来自自动事件

@end

@implementation HeartBodyView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = WHITECOLOR;
        [self initData];
        [self initView];
    }
    return self;
}

- (void)setAutoAction:(Boolean)autoAction{
    _autoAction = autoAction;
}

- (void)recordingPause{
    self.timer.fireDate = [NSDate distantFuture];
}
- (void)recordingRestar{
    self.timer.fireDate = [NSDate distantPast];
}

- (void)setPositionValue:(NSDictionary *)positionValue{
    NSInteger index = [[positionValue objectForKey:@"id"] integerValue];
    UIButton *button = [self.arrayButtonsTpye objectAtIndex:index];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.bActionFromAuto = YES;
        [self actionButtonClick:button];
    });
    
}

- (void)recordingStart{
    if (!self.timer) {
        self.timer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(reloadButton) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    } else {
        self.timer.fireDate = [NSDate distantPast];
    }
    NSInteger idx = self.buttonSelectIndex;
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    UIButton *button = self.arrayButtonDot[idx];
    UIImageView *imageView = self.arrayImageViews[idx];
    imageView.image = [UIImage imageNamed:self.arraySelectImageName[idx]];
    UILabel *label = self.arrayLabelPlace[idx];
    label.textColor = MainColor;
    button.selected = YES;
}

- (void)reloadButton{
    UIButton *button = self.arrayButtonDot[self.buttonSelectIndex];
    button.selected = !button.selected;
}

- (void)recordingStop{
    NSInteger idx = self.buttonSelectIndex;
    UIButton *buttonDot = self.arrayButtonDot[idx];
    buttonDot.selected = NO;
    [buttonDot setImage:[UIImage imageNamed:@"already_dot"] forState:UIControlStateNormal];
    UIImageView *imageView = self.arrayImageViews[idx];
    imageView.image = [UIImage imageNamed:self.arrayAlreadyImageName[idx]];
    UILabel *label = self.arrayLabelPlace[idx];
    label.textColor = AlreadyColor;
    self.timer.fireDate = [NSDate distantFuture];
    
    UIButton *buttonTag = self.arrayButtonsTpye[idx];
    buttonTag.selected = YES;
    [buttonTag setTitleColor:AlreadyColor forState:UIControlStateSelected];
    UIButton *buttonCollect = self.arrayButtonsCollected[idx];
    buttonCollect.hidden = NO;
    NSString *string = [@(idx) stringValue];
    if (![self.arraySelectItem containsObject:string]) {
        [self.arraySelectItem addObject:string];
    }
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

- (void)actionButtonClick:(UIButton *)button {
    if (!self.bActionFromAuto) {
        if (self.autoAction) {
            [kAppWindow makeToast:@"自动录音状态，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        
    }
    self.bActionFromAuto = NO;
    if(self.recordingStae == recordingState_ing) {
        [kAppWindow makeToast:@"正在录音中，不可改变位置" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    if (button.selected) {
        return;
    }
    for (NSInteger i = 0; i < self.arrayButtonsTpye.count; i++) {
        
        NSString *string = [@(i) stringValue];
        if (![self.arraySelectItem containsObject:string]) {
            UIButton *buttonType = self.arrayButtonsTpye[i];
            buttonType.selected = (buttonType == button);
            UIImageView *imageViewLine = self.arrayImageViews[i];
            imageViewLine.image = [UIImage imageNamed:self.arrayNoImageName[i]];
            UIButton *buttonDot = self.arrayButtonDot[i];
            buttonDot.selected = NO;
            UILabel *labelPlace = self.arrayLabelPlace[i];
            labelPlace.textColor = MainBlack;
        }
    }
    button.selected = YES;
    NSInteger index = button.tag - 100;
    UIImageView *imageViewLine = self.arrayImageViews[index];
    imageViewLine.image = [UIImage imageNamed:self.arraySelectImageName[index]];
    UIButton *buttonDot = self.arrayButtonDot[index];
    buttonDot.selected = YES;
    UILabel *labelPlace = self.arrayLabelPlace[index];
    labelPlace.textColor = MainColor;
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionClickButtonHeartBodyPositionCallBack:tag:)]) {
        NSString *title = self.arrayButtonInfo[index];
        [self.delegate actionClickButtonHeartBodyPositionCallBack:title tag:index];
        self.buttonSelectIndex = index;
    }
}

- (void)initView{
    NSInteger count = self.arrayButtonInfo.count;
    CGFloat imageWidth = Ratio30;
    CGFloat width = (screenW - Ratio30 - imageWidth * count) / (count - 1);
    for(NSInteger i = 0; i < count; i++) {
        UIButton *buttonType = [[UIButton alloc] init];
        buttonType.tag = 100 + i;
        [buttonType setTitle:self.arrayButtonInfo[i] forState:UIControlStateNormal];
        [buttonType setBackgroundImage:[UIImage imageNamed:@"circle_false"] forState:UIControlStateNormal];
        [buttonType setBackgroundImage:[Tools viewImageFromColor:MainColor rect:CGRectMake(0, 0, Ratio44, Ratio44)]
                          forState:UIControlStateSelected];
        [buttonType setBackgroundImage:[Tools viewImageFromColor:MainColor rect:CGRectMake(0, 0, Ratio44, Ratio44)]
                          forState:UIControlStateDisabled];
        [buttonType setTitleColor:MainNormal forState:UIControlStateNormal];
        [buttonType setTitleColor:WHITECOLOR forState:UIControlStateSelected];
        [buttonType setTitleColor:AlreadyColor forState:UIControlStateDisabled];
        buttonType.layer.cornerRadius = imageWidth/2;
        buttonType.titleLabel.font = FontBold18;
        buttonType.clipsToBounds = YES;
        [buttonType addTarget:self action:@selector(actionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonType];
        buttonType.sd_layout.leftSpaceToView(self, Ratio18 +  (imageWidth + width) * i).widthIs(imageWidth).heightIs(imageWidth).topSpaceToView(self, Ratio22);
        [self.arrayButtonsTpye addObject:buttonType];
        
        
        UIButton *buttonCollected = [[UIButton alloc] init];
        [self addSubview:buttonCollected];
        [buttonCollected setTitleColor:MainColor forState:UIControlStateNormal];
        [buttonCollected setTitle:@"已采" forState:UIControlStateNormal];
        [buttonCollected setImage:[UIImage imageNamed:@"check_true"] forState:UIControlStateNormal];
        buttonCollected.enabled = NO;
        buttonCollected.titleLabel.font = Font11;
        buttonCollected.cs_imagePositionMode = ImagePositionModeDefault;
        buttonCollected.cs_imageSize = CGSizeMake(Ratio8, Ratio8);
        buttonCollected.cs_middleDistance = Ratio3;
        buttonCollected.hidden = YES;
        [self.arrayButtonsCollected addObject:buttonCollected];
        buttonCollected.sd_layout.centerXEqualToView(buttonType).widthIs(imageWidth*2).heightIs(Ratio13).topSpaceToView(buttonType, Ratio3);
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

- (UIButton *)setupButton{
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"black_dot"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"red_dot"] forState:UIControlStateSelected];
    return button;
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

- (UILabel *)setLabelView:(NSString *)title{
    UILabel *label = [[UILabel alloc] init];
    label.font = Font12;
    
    label.textColor = MainBlack;
    label.text = title;
    return label;
}

@end
