//
//  UserInfoTwoView.m
//  HanHong-Stethophone
//
//  Created by HanHong on 2023/7/25.
//

#import "UserInfoTwoView.h"


@interface UserInfoTwoView()

@property (retain, nonatomic) UILabel               *labelTitle;
@property (retain, nonatomic) UIView                *viewLine;
@property (retain, nonatomic) UILabel               *labelInfo;
@property (retain, nonatomic) UIImageView       *imageViewRight;

@end

@implementation UserInfoTwoView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = title;
        [self setupView];
    }
    return self;
}

- (void)setTitleFont:(UIFont *)titleFont{
    self.labelTitle.font = titleFont;
}

- (void)setInfoFont:(UIFont *)infoFont{
    self.labelInfo.font = infoFont;
}

- (void)setTitle:(NSString *)title{
    self.labelTitle.text = title;
}

- (void)setInfo:(NSString *)info{
    _info = info;
    self.labelInfo.text = info;
}

- (void)setupView{
    [self addSubview:self.labelTitle];
    [self addSubview:self.labelInfo];
    [self addSubview:self.viewLine];
    [self addSubview:self.imageViewRight];
    
    
    self.labelTitle.sd_layout.leftSpaceToView(self, Ratio11).topSpaceToView(self, 0).bottomSpaceToView(self, 0).widthIs(Ratio33);
    [self.labelTitle setSingleLineAutoResizeWithMaxWidth:screenW/2];
    self.imageViewRight.sd_layout.rightSpaceToView(self, Ratio11).centerYEqualToView(self.labelTitle).widthIs(Ratio8).heightIs(Ratio13);
    self.labelInfo.sd_layout.leftSpaceToView(self.labelTitle, Ratio11).rightSpaceToView(self.imageViewRight, Ratio5).topSpaceToView(self, 0).bottomSpaceToView(self, 0);
    self.viewLine.sd_layout.leftSpaceToView(self, Ratio11).bottomSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio1);

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapCallback:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
}

- (void)actionTapCallback:(UITapGestureRecognizer *)tap{
    if (self.tapBlock) {
        self.tapBlock();
    }
}


- (UILabel *)labelTitle{
    if(!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.font = Font15;
        _labelTitle.textColor = MainBlack;
        _labelTitle.text = self.title;
    }
    return _labelTitle;
}

- (UILabel *)labelInfo{
    if(!_labelInfo) {
        _labelInfo = [[UILabel alloc] init];
        _labelInfo.font = Font15;
        _labelInfo.textColor = MainGray;
        _labelInfo.textAlignment = NSTextAlignmentRight;
    }
    return _labelInfo;
}


-(UIView *)viewLine{
    if(!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = ColorF5F5F5;
    }
    return _viewLine;
}

-(UIImageView *)imageViewRight{
    if(!_imageViewRight){
        _imageViewRight = [[UIImageView alloc] init];
        _imageViewRight.image = [UIImage imageNamed:@"enter_into"];
    }
    return _imageViewRight;
}


@end
