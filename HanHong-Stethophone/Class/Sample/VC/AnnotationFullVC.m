//
//  AnnotationFullVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/4.
//

#import "AnnotationFullVC.h"
#import "HHBluetoothButton.h"
#import "WaveFullView.h"
#import "AnnotationInfoVC.h"

@interface AnnotationFullVC ()

@property (retain, nonatomic) UIView            *viewNavi;
@property (retain, nonatomic) UIButton          *buttonBack;
@property (retain, nonatomic) HHBluetoothButton *bluetoothButton;
@property (retain, nonatomic) UIView            *viewSelectAnnotation;
@property (retain, nonatomic) UIImageView       *imageViewDown;
@property (retain, nonatomic) UILabel           *labelAnnotation;

@property (retain, nonatomic) UILabel           *labelTop;
@property (retain, nonatomic) UILabel           *labelCenter;
@property (retain, nonatomic) UILabel           *labelBottom;

@property (retain, nonatomic) UIScrollView      *scrollView;
@property (retain, nonatomic) WaveFullView      *waveFullView;

@property (assign, nonatomic) CGFloat               rowWidth;
@property (assign, nonatomic) CGFloat               viewWidth;
@property (assign, nonatomic) CGFloat               viewHeight;

@property (retain, nonatomic) UIView                *viewLine;
@property (retain, nonatomic) UIButton              *buttonPlay;
@property (retain, nonatomic) UIButton              *buttonAnnotation;

@property (retain, nonatomic) UIView                *viewTouchBg;

@property (retain, nonatomic) UIView                *clipView;
@property (assign, nonatomic) CGPoint               startP;
@property (retain, nonatomic) UIImageView           *imageViewP;


@end

@implementation AnnotationFullVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = MainBlack;
    [self initNavi];
}


- (void)actionDeviceHelperPlayBegin{
    self.viewLine.hidden = NO;
    self.viewLine.frame = CGRectMake(kStatusBarHeight, kNavBarHeight, Ratio1, self.viewHeight);
}

- (void)actionDeviceHelperPlayingTime:(float)value{
    CGFloat width = value / self.recordModel.record_length * self.viewWidth;
    Boolean bFirstLoadA = YES;
    Boolean bBirstLoadB = YES;
    if (width <= (screenW - kStatusBarHeight) / 2) {
        self.viewLine.frame = CGRectMake(kStatusBarHeight + width, kNavBarHeight, Ratio1, self.viewHeight);
    } else if (width >= self.viewWidth - (screenW - kStatusBarHeight) / 2) {
        if (bFirstLoadA) {
            CGPoint offset = CGPointMake(self.viewWidth-screenW+kStatusBarHeight, 0);
            [self.scrollView setContentOffset:offset animated:YES];
            bFirstLoadA = NO;
        }
        self.viewLine.frame = CGRectMake(screenW - kStatusBarHeight-(self.viewWidth - width), kNavBarHeight, Ratio1, self.viewHeight);
    } else {
        if (bBirstLoadB) {
            self.viewLine.frame = CGRectMake(screenW/2, kNavBarHeight, Ratio1, self.viewHeight);
            bBirstLoadB = NO;
        }
        CGPoint offset = CGPointMake(width - (screenW - kStatusBarHeight) / 2, 0);
        [self.scrollView setContentOffset:offset animated:YES];
    }
}

- (void)actionDeviceHelperPlayEnd{
    self.buttonPlay.selected = NO;
    //[self.viewSmallWave actionStop];
    self.viewLine.frame = CGRectMake(kStatusBarHeight, kNavBarHeight, Ratio1, self.viewHeight);
    self.viewLine.hidden = YES;
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}


- (void)initNavi{
    self.viewHeight = screenW - 2 *  kNavBarHeight - Ratio22;
    self.rowWidth = self.viewHeight / 8.f;
    self.viewWidth = self.recordModel.record_length * 5 * self.rowWidth;
    
    [self.view addSubview:self.viewNavi];
    self.viewNavi.sd_layout.leftSpaceToView(self.view, 0).topSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).heightIs(kNavBarHeight);
    [self.viewNavi addSubview:self.buttonBack];
    self.buttonBack.sd_layout.leftSpaceToView(self.viewNavi, kStatusBarHeight + Ratio11).heightIs(Ratio22).widthIs(Ratio30).centerYEqualToView(self.viewNavi);
    [self.viewNavi addSubview:self.bluetoothButton];
    self.bluetoothButton.sd_layout.leftSpaceToView(self.buttonBack, Ratio33).heightIs(Ratio22).widthIs(Ratio22).centerYEqualToView(self.viewNavi);
    
    [self.viewNavi addSubview:self.viewSelectAnnotation];
    self.viewSelectAnnotation.sd_layout.centerYEqualToView(self.viewNavi).rightSpaceToView(self.viewNavi, kBottomSafeHeight + Ratio22).heightIs(Ratio28).widthIs(screenH/3);
    [self.viewSelectAnnotation addSubview:self.imageViewDown];
    self.imageViewDown.sd_layout.rightSpaceToView(self.viewSelectAnnotation, Ratio6).heightIs(Ratio8).widthIs(Ratio12).centerYEqualToView(self.viewSelectAnnotation);
    [self.viewSelectAnnotation addSubview:self.labelAnnotation];
    self.labelAnnotation.sd_layout.leftSpaceToView(self.viewSelectAnnotation, Ratio6).heightIs(Ratio17).rightSpaceToView(self.viewSelectAnnotation, Ratio8).centerYEqualToView(self.viewSelectAnnotation);
    
    
    [self.view addSubview:self.scrollView];
    self.scrollView.sd_layout.leftSpaceToView(self.view, kStatusBarHeight).rightSpaceToView(self.view, kStatusBarHeight).topSpaceToView(self.viewNavi, 0).heightIs(self.viewHeight);
    [self.scrollView addSubview:self.waveFullView];
    self.waveFullView.sd_layout.leftSpaceToView(self.scrollView, 0).widthIs(self.viewWidth).topSpaceToView(self.scrollView, 0).bottomSpaceToView(self.scrollView, 0);
    [self.scrollView addSubview:self.audioPlotView];
    self.audioPlotView.sd_layout.leftSpaceToView(self.scrollView, 0).widthIs(self.viewWidth).topSpaceToView(self.scrollView, 0).bottomSpaceToView(self.scrollView, 0);
    self.scrollView.contentSize = CGSizeMake(self.viewWidth, self.viewHeight);
    
   [self.scrollView addSubview:self.viewTouchBg];
    self.viewTouchBg.frame = CGRectMake(0, self.viewHeight/3, self.viewWidth, self.viewHeight/3);
    
    [self.view addSubview:self.labelTop];
    [self.view addSubview:self.labelCenter];
    [self.view addSubview:self.labelBottom];
    [self.view addSubview:self.buttonPlay];
    [self.view addSubview:self.buttonAnnotation];
    [self.view addSubview:self.viewLine];
    self.labelTop.sd_layout.topSpaceToView(self.viewNavi, Ratio5).leftSpaceToView(self.view, kStatusBarHeight + Ratio2).widthIs(Ratio33).heightIs(Ratio16);
    self.labelCenter.sd_layout.centerYIs(kNavBarHeight + 4*self.rowWidth).leftEqualToView(self.labelTop).widthIs(Ratio33).heightIs(Ratio16);
    self.labelBottom.sd_layout.leftEqualToView(self.labelTop).topSpaceToView(self.scrollView, -Ratio22).widthIs(Ratio33).heightIs(Ratio16);
    self.buttonPlay.sd_layout.centerXEqualToView(self.view).topSpaceToView(self.scrollView, Ratio11).widthIs(Ratio44).heightIs(Ratio28);
    self.buttonAnnotation.sd_layout.centerYEqualToView(self.buttonPlay).rightSpaceToView(self.view, Ratio22).heightIs(Ratio28).widthIs(Ratio44);
    self.viewLine.frame = CGRectMake(kStatusBarHeight, kNavBarHeight, Ratio1, self.viewHeight);
    
    [self openFileWithFilePathURL];
    //[self showWaveView:a];
}

- (UIButton *)buttonPlay{
    if (!_buttonPlay) {
        _buttonPlay = [[UIButton alloc] init];
        [_buttonPlay setTitle:@"播放" forState:UIControlStateNormal];
        [_buttonPlay setTitle:@"停止" forState:UIControlStateSelected];
        _buttonPlay.titleLabel.textColor = WHITECOLOR;
        _buttonPlay.titleLabel.font = Font13;
        _buttonPlay.layer.cornerRadius = Ratio4;
        _buttonPlay.backgroundColor = HEXCOLOR(0x232323, 1);
        [_buttonPlay addTarget:self action:@selector(actionClickPlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonPlay;
}

- (UIButton *)buttonAnnotation{
    if (!_buttonAnnotation) {
        _buttonAnnotation = [[UIButton alloc] init];
        [_buttonAnnotation setTitle:@"标注" forState:UIControlStateNormal];
        _buttonAnnotation.titleLabel.textColor = WHITECOLOR;
        _buttonAnnotation.titleLabel.font = Font13;
        _buttonAnnotation.layer.cornerRadius = Ratio4;
        _buttonAnnotation.backgroundColor = HEXCOLOR(0x232323, 1);
        [_buttonAnnotation addTarget:self action:@selector(actionToSelctAnnotaion:) forControlEvents:UIControlEventTouchUpInside];
        _buttonAnnotation.hidden = YES;
    }
    return _buttonAnnotation;
}

- (void)actionToSelctAnnotaion:(UIButton *)button{
    AnnotationInfoVC *annotationInfoVC = [[AnnotationInfoVC alloc] init];
    [self.navigationController pushViewController:annotationInfoVC animated:YES];
}

- (UILabel *)labelTop{
    if (!_labelTop) {
        _labelTop = [self getLabelVertical:@" 1"];
    }
    return _labelTop;
}

- (UIView *)viewLine{
    if (!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = WHITECOLOR;
        _viewLine.hidden = YES;
    }
    return _viewLine;
}

- (UILabel *)labelCenter{
    if (!_labelCenter) {
        _labelCenter = [self getLabelVertical:@" 0"];
    }
    return _labelCenter;
}

- (UILabel *)labelBottom{
    if (!_labelBottom) {
        _labelBottom = [self getLabelVertical:@" -1"];
    }
    return _labelBottom;
}

- (UILabel *)getLabelVertical:(NSString *)name{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = Font15;
    label.textColor = WHITECOLOR;
    label.text = name;
    return label;
}


- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

- (UIView *)viewNavi{
    if (!_viewNavi) {
        _viewNavi = [[UIView alloc] init];
        _viewNavi.backgroundColor = HEXCOLOR(0x232323, 0.2);
    }
    return _viewNavi;
}

- (UIButton *)buttonBack{
    if (!_buttonBack) {
        _buttonBack = [[UIButton alloc] init];
        [_buttonBack setImage:[UIImage imageNamed:@"back_grey"] forState:UIControlStateNormal];
        _buttonBack.imageEdgeInsets = UIEdgeInsetsMake(Ratio3, Ratio10, Ratio3, Ratio10);
        [_buttonBack addTarget:self action:@selector(actionViewBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonBack;
}

- (HHBluetoothButton *)bluetoothButton{
    if (!_bluetoothButton) {
        _bluetoothButton = [[HHBluetoothButton alloc] init];
    }
    return _bluetoothButton;
}

- (UIImageView *)imageViewDown{
    if (!_imageViewDown) {
        _imageViewDown = [[UIImageView alloc] init];
        _imageViewDown.image = [UIImage imageNamed:@"pull_down_white"];
    }
    return _imageViewDown;
}

- (UILabel *)labelAnnotation{
    if (!_labelAnnotation) {
        _labelAnnotation = [[UILabel alloc] init];
        _labelAnnotation.text = [NSString stringWithFormat:@"0:000-%li:000 全部", self.recordModel.record_length];
        _labelAnnotation.textColor = WHITECOLOR;
        _labelAnnotation.font = Font15;
    }
    return _labelAnnotation;
}

- (void)actionViewBack:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)viewSelectAnnotation{
    if (!_viewSelectAnnotation) {
        _viewSelectAnnotation = [[UIView alloc] init];
        _viewSelectAnnotation.backgroundColor = HEXCOLOR(0x232323, 1);
        _viewSelectAnnotation.layer.cornerRadius = Ratio5;
    }
    return _viewSelectAnnotation;
}

- (WaveFullView *)waveFullView{
    if (!_waveFullView) {
        _waveFullView = [[WaveFullView alloc] initWithFrame:CGRectZero recordModel:self.recordModel];
    }
    return _waveFullView;
}

- (UIView *)viewTouchBg{
    if (!_viewTouchBg) {
        _viewTouchBg = [[UIView alloc] init];
        //_viewTouchBg.backgroundColor = HEXCOLOR(0xFFFF00, 0.2);
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionPanGesture:)];
        [_viewTouchBg addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGestuer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
        [_viewTouchBg addGestureRecognizer:tapGestuer];
    }
    return _viewTouchBg;
}

- (void)actionTapGesture:(UITapGestureRecognizer *)gesture{
    self.clipView.hidden = YES;
    self.buttonAnnotation.hidden = YES;
    self.labelAnnotation.text = [NSString stringWithFormat:@"0:000-%li:000 全部", self.recordModel.record_length];
}

- (void)actionPanGesture:(UIPanGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.startP = [gesture locationInView:self.viewTouchBg];
        self.labelAnnotation.text = @"新选区";
        
        
        UIView *clipView = [[UIView alloc] init];
        clipView.backgroundColor = HEXCOLOR(0x7AE300, 0.5);//FFFF33
        
        clipView.alpha = 0.5;
        [self.scrollView addSubview:clipView];
        self.clipView = clipView;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint curP = [gesture locationInView:self.scrollView];
        self.clipView.frame = CGRectMake(self.startP.x, 0, curP.x - self.startP.x, self.viewHeight);
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        self.buttonAnnotation.hidden = NO;
        CGPoint endP = [gesture locationInView:self.viewTouchBg];
        CGFloat startX = MIN(self.startP.x, endP.x);
        CGFloat endX = MAX(self.startP.x, endP.x);
        CGFloat timeStart = startX / self.viewWidth * self.recordModel.record_length;
        CGFloat timeEnd = endX / self.viewWidth * self.recordModel.record_length;
        NSLog(@"timeStart = %f, timeEnd = %f", timeStart, timeEnd);
    }
}

- (UIImageView *)imageViewP{
    if (!_imageViewP) {
        _imageViewP = [[UIImageView alloc] init];
    }
    return _imageViewP;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //self.bCurrentView = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //进入旋转
    [self changeRotate:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //退出恢复
    //self.bCurrentView = NO;
    [self changeRotate:NO];
}

- (void)viewDidDisappear:(BOOL)animated{
    
}

- (void)changeRotate:(BOOL)change{
    /*
     *采用KVO字段控制旋转
     */
    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    if (change) {
        orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    }
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

#pragma mark - *********** 旋转设置 ***********

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
