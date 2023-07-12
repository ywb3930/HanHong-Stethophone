//
//  LungBodyBackView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import "LungBodyBackView.h"


@interface LungBodyBackView()


@property (retain, nonatomic) NSArray                   *arrayButtonInfo;//按钮数组
@property (retain, nonatomic) NSArray                   *arrayNoImageName;//没选中时的图片
@property (retain, nonatomic) NSArray                   *arraySelectImageName;//选中时的图片
@property (retain, nonatomic) NSArray                   *arrayAlreadyImageName;//准备时的图片
@property (retain, nonatomic) NSArray                   *arrayButtonDot;//小圆点的图片
@property (retain, nonatomic) NSArray                   *arrayLabelNum;

@property (retain, nonatomic) UIView                    *viewBody;

@property (retain, nonatomic) UIImageView               *imageViewBoay;
@property (retain, nonatomic) NSMutableArray            *arrayButtonsTpye;//按钮数组
@property (retain, nonatomic) NSMutableArray            *arrayImageViews;//图片数组
@property (retain, nonatomic) NSMutableArray            *arrayButtonsCollected;


@property (retain, nonatomic) UIButton                  *buttonDot11;
@property (retain, nonatomic) UIButton                  *buttonDot12;


@property (retain, nonatomic) UILabel                   *labelNum11;
@property (retain, nonatomic) UILabel                   *labelNum12;

@property (retain, nonatomic) NSTimer                   *timer;
@property (assign, nonatomic) NSInteger                 buttonSelectIndex;
@property (retain, nonatomic) NSMutableArray            *arraySelectItem;

@property (assign, nonatomic) Boolean                   bActionFromAuto;//事件来自自动事件

@end

@implementation LungBodyBackView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = WHITECOLOR;
        [self initData];
        [self initView];
    }
    return self;
}

- (void)setPositionValue:(NSDictionary *)positionValue{
    NSInteger index = [[positionValue objectForKey:@"id"] integerValue];
    UIButton *button = [self.arrayButtonsTpye objectAtIndex:index-10];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.bActionFromAuto = YES;
        [self actionButtonClick:button];
    });
}

- (void)recordingPause{
    self.timer.fireDate = [NSDate distantFuture];
}
- (void)recordingRestar{
    self.timer.fireDate = [NSDate distantPast];
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
    UILabel *labelNum = self.arrayLabelNum[idx];
    labelNum.textColor = MainColor;
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
    UILabel *labelName = self.arrayLabelNum[idx];
    labelName.textColor = AlreadyColor;
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
            UILabel *labelNum = self.arrayLabelNum[i];
            labelNum.textColor = MainBlack;
        }
    }
    button.selected = YES;
    NSInteger index = button.tag - 100;
    UIImageView *imageViewLine = self.arrayImageViews[index];
    imageViewLine.image = [UIImage imageNamed:self.arraySelectImageName[index]];
    UIButton *buttonDot = self.arrayButtonDot[index];
    buttonDot.selected = YES;
    UILabel *labelPlace = self.arrayLabelNum[index];
    labelPlace.textColor = MainColor;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionClickButtonLungCallBack:tag:position:)]) {
        NSString *title = self.arrayButtonInfo[index];
        [self.delegate actionClickButtonLungCallBack:title tag:index position:Lung_back_bodyType];
        self.buttonSelectIndex = index;
    }
}

- (void)initData {
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
        buttonCollected.cs_imageSize = CGSizeMake(Ratio10, Ratio10);
        buttonCollected.cs_middleDistance = Ratio2;
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
    
    [self.viewBody addSubview:self.buttonDot11];
    self.buttonDot11.sd_layout.heightIs(Ratio6).widthIs(Ratio6).topSpaceToView(self.viewBody, 88.f*screenRatio).leftSpaceToView(self.viewBody, screenW/2 - Ratio13);
    
    [self.viewBody addSubview:self.buttonDot12];
    self.buttonDot12.sd_layout.heightIs(Ratio6).widthIs(Ratio6).centerYEqualToView(self.buttonDot11).rightSpaceToView(self.viewBody, screenW/2 - Ratio13);
   
    
    [self.viewBody addSubview:self.labelNum11];
    [self.viewBody addSubview:self.labelNum12];
    self.labelNum11.sd_layout.leftSpaceToView(self.viewBody, 0).heightIs(Ratio15).topSpaceToView(self.viewBody, 48.f*screenRatio).widthIs(screenW/3-Ratio11);
    self.labelNum12.sd_layout.rightSpaceToView(self.viewBody, 0).heightIs(Ratio15).centerYEqualToView(self.labelNum11).widthIs(screenW/3-Ratio11);
    
    self.arrayButtonDot = @[self.buttonDot11, self.buttonDot12];
    self.arrayLabelNum = @[self.labelNum11, self.labelNum12];
    
    
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

- (UILabel *)setLabelView:(NSString *)title{
    UILabel *label = [[UILabel alloc] init];
    label.font = Font12;
    label.textColor = MainBlack;
    label.text = title;
    return label;
}

- (UIButton *)setupButton{
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"black_dot"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"red_dot"] forState:UIControlStateSelected];
    return button;
}


@end
