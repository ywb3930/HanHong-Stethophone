//
//  AnnotationInfoVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/5.
//

#import "AnnotationInfoVC.h"

@interface AnnotationInfoVC ()

@property (retain, nonatomic) UIButton              *buttonHeart;
@property (retain, nonatomic) UIButton              *buttonLung;
@property (retain, nonatomic) UIButton              *buttonCancel;
@property (retain, nonatomic) UIButton              *buttonCommit;
@property (retain, nonatomic) UIView                *viewline1;
@property (retain, nonatomic) UIView                *viewline2;
@property (retain, nonatomic) UIView                *viewline3;
@property (retain, nonatomic) NSArray               *arrayData;
@property (retain, nonatomic) NSMutableArray        *arrayButtons;



@end

@implementation AnnotationInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    if (self.soundType == heart_sounds) {
        self.arrayData = heart_PathologyTypes;
    } else {
        self.arrayData = lungt_PathologyTypes;
    }
    self.arrayButtons = [NSMutableArray array];

    [self setupView];

    
}

- (void)setupView{
    [self.view addSubview:self.buttonHeart];
    [self.view addSubview:self.buttonLung];
    [self.view addSubview:self.viewline1];
    self.buttonHeart.sd_layout.leftSpaceToView(self.view, 0).widthIs(screenW/2).topSpaceToView(self.view, kStatusBarHeight).heightIs(Ratio40);
    self.buttonLung.sd_layout.rightSpaceToView(self.view, 0).widthIs(screenW/2).topSpaceToView(self.view, kStatusBarHeight).heightIs(Ratio40);
    self.viewline1.sd_layout.centerXEqualToView(self.buttonHeart).topSpaceToView(self.buttonHeart, -Ratio5).widthIs(Ratio99).heightIs(Ratio2);
    [self.view addSubview:self.buttonCancel];
    [self.view addSubview:self.buttonCommit];
    self.buttonCancel.sd_layout.leftSpaceToView(self.view, 0).widthIs(screenW/2).bottomSpaceToView(self.view, kBottomSafeHeight).heightIs(Ratio40);
    self.buttonCommit.sd_layout.rightSpaceToView(self.view, 0).widthIs(screenW/2).bottomSpaceToView(self.view, kBottomSafeHeight).heightIs(Ratio40);
    [self.view addSubview:self.viewline2];
    [self.view addSubview:self.viewline3];
    self.viewline2.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).bottomSpaceToView(self.buttonCancel, 0).heightIs(Ratio1);
    self.viewline3.sd_layout.bottomSpaceToView(self.view, 0).centerXEqualToView(self.view).widthIs(Ratio1).heightIs(Ratio40+kBottomSafeHeight);
    
    CGFloat width = (screenW - Ratio44)/2;
    for (NSInteger i = 0; i < self.arrayData.count; i++) {
        NSInteger ii = i % 2;
        NSInteger jj = i /2;
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:self.arrayData[i] forState:UIControlStateNormal];
        [button setTitleColor:MainBlack forState:UIControlStateNormal];
        button.tag = i;
        button.titleLabel.font = Font15;
        button.layer.cornerRadius = Ratio4;
        button.layer.borderColor = BorderCGColor;
        button.layer.borderWidth = Ratio1;
        [self.view addSubview:button];
        button.sd_layout.leftSpaceToView(self.view, Ratio17 + (width + Ratio10) * ii).heightIs(Ratio40).widthIs(width).topSpaceToView(self.buttonHeart, Ratio8+Ratio50*jj);
    }
}

- (UIView *)viewline1{
    if (!_viewline1) {
        _viewline1 = [[UIView alloc] init];
        _viewline1.backgroundColor = MainColor;
    }
    return _viewline1;
}
- (UIView *)viewline2{
    if (!_viewline2) {
        _viewline2 = [[UIView alloc] init];
        _viewline2.backgroundColor = ViewBackGroundColor;
    }
    return _viewline2;
}

- (UIView *)viewline3{
    if (!_viewline3) {
        _viewline3 = [[UIView alloc] init];
        _viewline3.backgroundColor = ViewBackGroundColor;
    }
    return _viewline3;
}

- (UIButton *)buttonHeart{
    if (!_buttonHeart) {
        _buttonHeart = [self setupButton:@"心音病理音类型"];
        _buttonHeart.selected = YES;
        _buttonHeart.enabled = YES;
    }
    return _buttonHeart;
}

- (UIButton *)buttonLung{
    if (!_buttonLung) {
        _buttonLung = [self setupButton:@"肺音病理音类型"];
        _buttonLung.selected = YES;
        _buttonLung.enabled = YES;
    }
    return _buttonLung;
}

- (UIButton *)buttonCancel{
    if (!_buttonCancel) {
        _buttonCancel = [self setupButton:@"取消"];
        [_buttonCancel setTitleColor:MainBlack forState:UIControlStateNormal];
        [_buttonCancel addTarget:self action:@selector(actionCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonCancel;
}

- (void)actionCancel{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIButton *)buttonCommit{
    if (!_buttonCommit) {
        _buttonCommit = [self setupButton:@"确定"];
        [_buttonCommit setTitleColor:MainColor forState:UIControlStateNormal];
    }
    return _buttonCommit;
}

- (UIButton *)setupButton:(NSString *)title{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateSelected];
    [button setTitleColor:MainBlack forState:UIControlStateSelected];
    [button setTitleColor:MainGray forState:UIControlStateNormal];
    button.titleLabel.font = Font15;
    return button;
}




- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //self.bCurrentView = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //进入旋转
    //[self changeRotate:YES];
}
//
//- (void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    //退出恢复
//    //self.bCurrentView = NO;
//    [self changeRotate:NO];
//}
//
//- (void)viewDidDisappear:(BOOL)animated{
//
//}
//
//- (void)changeRotate:(BOOL)change{
//    /*
//     *采用KVO字段控制旋转
//     */
//    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
//    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
//    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    if (change) {
//        orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
//    }
//    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//}
//
//#pragma mark - *********** 旋转设置 ***********
//
//- (BOOL)shouldAutorotate{
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskLandscapeRight;
//}
//
//- (void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
@end
