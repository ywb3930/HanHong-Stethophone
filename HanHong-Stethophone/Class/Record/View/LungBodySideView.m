//
//  LungBodySideView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import "LungBodySideView.h"

@interface LungBodySideView()

@property (retain, nonatomic) UIView                    *viewBody;
@property (retain, nonatomic) UIImageView               *imageViewBoay;
@property (retain, nonatomic) UIButton                  *buttonDot9;
@property (retain, nonatomic) UIButton                  *buttonDot10;
@property (retain, nonatomic) UILabel                   *labelNum9;
@property (retain, nonatomic) UILabel                   *labelNum10;


@end

@implementation LungBodySideView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = WHITECOLOR;
        [self initData];
        [self initView];
    }
    return self;
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
    self.arrayButtonInfo = @[ @"9", @"10"];
    self.arrayNoImageName = @[@"lung_not_num9", @"lung_not_num10"];
    self.arraySelectImageName = @[@"lung_select_num9", @"lung_select_num10"];
    self.arrayAlreadyImageName = @[@"lung_already_num9", @"lung_already_num10"];
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
    
    [self.viewBody addSubview:self.buttonDot9];
    self.buttonDot9.sd_layout.heightIs(Ratio6).widthIs(Ratio6).topSpaceToView(self.viewBody, 95.f*screenRatio).leftSpaceToView(self.viewBody, screenW/2 - Ratio36);
    
    [self.viewBody addSubview:self.buttonDot10];
    self.buttonDot10.sd_layout.heightIs(Ratio6).widthIs(Ratio6).centerYEqualToView(self.buttonDot9).rightSpaceToView(self.viewBody, screenW/2 - Ratio36);
   
    
    [self.viewBody addSubview:self.labelNum9];
    [self.viewBody addSubview:self.labelNum10];
    self.labelNum9.sd_layout.leftSpaceToView(self.viewBody, 0).heightIs(Ratio15).topSpaceToView(self.viewBody, 55.f*screenRatio).widthIs(screenW/3-39.f*screenRatio);
    self.labelNum10.sd_layout.rightSpaceToView(self.viewBody, 0).heightIs(Ratio15).centerYEqualToView(self.labelNum9).widthIs(screenW/3-39.f*screenRatio);
    
    self.arrayButtonDot = @[self.buttonDot9, self.buttonDot10];
    self.arrayLabelPlace = @[self.labelNum9, self.labelNum10];
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
        _imageViewBoay.image = [UIImage imageNamed:@"lung_side_select_false"];
        _imageViewBoay.contentMode = UIViewContentModeScaleToFill;
        _imageViewBoay.backgroundColor = WHITECOLOR;
    }
    return _imageViewBoay;
}


- (UIButton *)buttonDot9{
    if(!_buttonDot9) {
        _buttonDot9 = [self setupButton];
    }
    return _buttonDot9;
}

- (UIButton *)buttonDot10{
    if(!_buttonDot10) {
        _buttonDot10 = [self setupButton];
    }
    return _buttonDot10;
}

- (UILabel *)labelNum9{
    if(!_labelNum9) {
        _labelNum9 = [self setLabelView:@"9 左侧胸"];
        _labelNum9.textAlignment = NSTextAlignmentRight;
    }
    return _labelNum9;
}

- (UILabel *)labelNum10{
    if(!_labelNum10) {
        _labelNum10 = [self setLabelView:@"10 右侧胸"];
        
    }
    return _labelNum10;
}


@end
