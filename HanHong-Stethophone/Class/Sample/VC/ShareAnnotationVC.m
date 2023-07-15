//
//  ShareAnnotationVC.m
//  HanHong-Stethophone
//
//  Created by HanHong on 2023/7/13.
//

#import "ShareAnnotationVC.h"

@interface ShareAnnotationVC ()

@property (retain, nonatomic) UIImageView           *imageViewLogo;
@property (retain, nonatomic) YYTextView            *textView;
@property (retain, nonatomic) UIButton              *buttonClose;
@property (retain, nonatomic) UIButton              *buttonCollect;

@end

@implementation ShareAnnotationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = WHITECOLOR;
    self.title = @"标本分享";
    [self setupView];
}

- (void)actionToCollect:(UIButton *)button{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [TTRequestManager recordShareFavorite:self.shareDataModel.share_code params:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:record_favorite_share object:nil];
        }
        [self.view makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


- (void)setupView{
    [self.view addSubview:self.imageViewLogo];
    self.imageViewLogo.sd_layout.centerXEqualToView(self.view).widthIs(Ratio77).heightIs(Ratio77).topSpaceToView(self.view, kNavBarAndStatusBarHeight + Ratio22);
    [self.view addSubview:self.buttonClose];
    [self.view addSubview:self.buttonCollect];
    [self.view addSubview:self.textView];
    CGFloat width = (screenW - Ratio49)/2;
    self.buttonClose.sd_layout.leftSpaceToView(self.view, Ratio18).widthIs(width).bottomSpaceToView(self.view, kBottomSafeHeight + Ratio18).heightIs(Ratio44);
    self.buttonCollect.sd_layout.rightSpaceToView(self.view, Ratio18).widthIs(width).bottomSpaceToView(self.view, kBottomSafeHeight + Ratio18).heightIs(Ratio44);
    self.textView.sd_layout.leftSpaceToView(self.view, Ratio18).rightSpaceToView(self.view, Ratio18).topSpaceToView(self.imageViewLogo, Ratio33).bottomSpaceToView(self.buttonClose, Ratio44);

    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendFormat:@"分享来源：%@", self.shareDataModel.name];
    NSInteger soundType = self.shareDataModel.type_id;
    if (soundType == heart_sounds) {
        [string appendFormat:@"\r\n分享来源：心音"];
    } else if (soundType == lung_sounds) {
        [string appendFormat:@"\r\n分享来源：肺音"];
    }
    NSString *positionTag = self.shareDataModel.position_tag;
    NSString *positionName = [[Constant shareManager] positionTagPositionCn:positionTag];
    [string appendFormat:@"\r\n录音位置：%@", positionName];
    [string appendFormat:@"\r\n患者病症：%@", self.shareDataModel.patient_symptom];
    [string appendFormat:@"\r\n临床诊断：%@", self.shareDataModel.patient_diagnosis];
    
    NSString *characteristic = @"";
    NSArray *array = [Tools jsonData2Array:self.shareDataModel.characteristics];
    for (NSDictionary *data in array) {
        characteristic = [NSString stringWithFormat:@"%@,%@", characteristic, data[@"characteristic"]];
    }
    if (characteristic.length > 0) {
        characteristic = [characteristic substringToIndex:characteristic.length - 1];
    }
    [string appendFormat:@"\r\n病理标注：%@", characteristic];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = Ratio10;
    NSDictionary *attributes = @{NSFontAttributeName: Font15, NSParagraphStyleAttributeName: paragraphStyle};;
    
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

- (UIImageView *)imageViewLogo{
    if (!_imageViewLogo) {
        _imageViewLogo = [[UIImageView alloc] init];
        _imageViewLogo.layer.cornerRadius = Ratio5;
        _imageViewLogo.clipsToBounds = YES;
        _imageViewLogo.image = [UIImage imageNamed:@"icon"];
    }
    return _imageViewLogo;
}

- (YYTextView *)textView{
    if (!_textView) {
        _textView = [[YYTextView alloc] init];
        _textView.editable = NO;
        _textView.text = @"信息加载中......";
        _textView.font = Font15;
        _textView.textColor = MainBlack;
       
    }
    return _textView;
}

- (UIButton *)buttonClose{
    if (!_buttonClose) {
        _buttonClose = [self setupButton:@"取消" backGroundColor:HEXCOLOR(0xBCBCBC, 1)];
        _buttonClose.layer.borderWidth = Ratio1;
        _buttonClose.layer.borderColor = HEXCOLOR(0xF5F5F5, 1).CGColor;
        [_buttonClose addTarget:self action:@selector(actionToCancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonClose;
}

- (void)actionToCancel:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIButton *)buttonCollect{
    if (!_buttonCollect) {
        _buttonCollect = [self setupButton:@"收藏" backGroundColor:MainColor];
        _buttonCollect.layer.borderWidth = Ratio1;
        _buttonCollect.layer.borderColor = HEXCOLOR(0xF5F5F5, 1).CGColor;
        [_buttonCollect addTarget:self action:@selector(actionToCollect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonCollect;
}

- (UIButton *)setupButton:(NSString *)title backGroundColor:(UIColor *)color{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:WHITECOLOR forState:UIControlStateNormal];
    button.backgroundColor = color;
    button.layer.cornerRadius = Ratio5;
    button.clipsToBounds = YES;
    button.titleLabel.font = Font15;
    return button;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
@end
