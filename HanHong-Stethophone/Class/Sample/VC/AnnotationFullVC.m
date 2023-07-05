//
//  AnnotationFullVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/4.
//

#import "AnnotationFullVC.h"
#import "HHBluetoothButton.h"
#import "WaveFullView.h"
#import "KSYAudioPlotView.h"
#import "KSYAudioFile.h"

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
@property (retain, nonatomic) KSYAudioPlotView              *audioPlotView;
@property (nonatomic, strong) KSYAudioFile                  *audioFile;

@property (assign, nonatomic) Boolean               bCurrentView;//是否在当前页面
@property (retain, nonatomic) UIView                *viewLine;
@property (retain, nonatomic) UIButton              *buttonPlay;
@property (assign, nonatomic) Boolean               bPlaying;

@property (assign, nonatomic) CGFloat               a;


@end

@implementation AnnotationFullVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = MainBlack;
    //[self changeRotate:YES];
    [self initNavi];
    //播放事件广播，用于显示播放进度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionRecieveBluetoothMessage:) name:HHBluetoothMessage object:nil];
    
}


//接收蓝牙底层消息
- (void)actionRecieveBluetoothMessage:(NSNotification *)notification{
    if (!self.bCurrentView) {
        return;
    }
    NSDictionary *userInfo = notification.userInfo;
    DEVICE_HELPER_EVENT event = [userInfo[@"event"] integerValue];
    NSObject *args1 = userInfo[@"args1"];
    //NSObject *args2 = userInfo[@"args2"];
    
    if (event == DeviceHelperPlayBegin) {
        self.bPlaying = YES;
        self.viewLine.hidden = NO;
        self.viewLine.frame = CGRectMake(kStatusBarHeight, kNavBarHeight, Ratio1, self.viewHeight);
    } else if (event == DeviceHelperPlayingTime) {
        __weak typeof(self) wself = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSNumber *number = (NSNumber *)args1;
            float value = [number floatValue];
            ///cell.playProgess = value;
            //wself.viewSmallWave.playProgess = value;
            [wself playLineAnimation:value];
            NSLog(@"播放进度：%f", value);
        });
        
        
    } else if (event == DeviceHelperPlayEnd) {
        NSLog(@"播放结束");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self stopPlayRecord];
        });
        
    }
}

- (void)playLineAnimation:(float)value{
    CGFloat width = value / self.recordModel.record_length * self.viewWidth;
    Boolean bA = YES;
    Boolean bB = YES;
    if (width <= (screenW - kStatusBarHeight) / 2) {
        self.viewLine.frame = CGRectMake(kStatusBarHeight + width, kNavBarHeight, Ratio1, self.viewHeight);
        
    } else if (width >= self.viewWidth - (screenW - kStatusBarHeight) / 2) {
        if (bA) {
            CGPoint offset = CGPointMake(self.viewWidth-screenW+kStatusBarHeight, 0);
            [self.scrollView setContentOffset:offset animated:YES];
            bA = NO;
        }
        self.viewLine.frame = CGRectMake(screenW - kStatusBarHeight-(self.viewWidth - width), kNavBarHeight, Ratio1, self.viewHeight);
    } else {
        if (bB) {
            self.viewLine.frame = CGRectMake(screenW/2, kNavBarHeight, Ratio1, self.viewHeight);
            bB = NO;
        }
        CGPoint offset = CGPointMake(width - (screenW - kStatusBarHeight) / 2, 0);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    
    
}


- (void)stopPlayRecord{
    self.bPlaying = NO;
    self.buttonPlay.selected = NO;
    //[self.viewSmallWave actionStop];
    self.viewLine.frame = CGRectMake(kStatusBarHeight, kNavBarHeight, Ratio1, self.viewHeight);
    self.viewLine.hidden = YES;
    [[HHBlueToothManager shareManager] stop];
}

- (void)actionToStar{
    NSString *path = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
    NSString *filePath = [NSString stringWithFormat:@"%@audio/%@", path,self.recordModel.tag];
    if ([HHFileLocationHelper fileExistsAtPath:filePath]) {
        [self startPlayRecordVoice:filePath];
    } else {
        //如果本地没有缓存文件，先下载，后播放缓存文件
        [AFNetRequestManager downLoadFileWithUrl:self.recordModel.url path:filePath downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            
        } successBlock:^(NSURL * _Nonnull url) {
            //播放下载后的文件
            [self startPlayRecordVoice:url.path];
        } fileDownloadFail:^(NSError * _Nonnull error) {
            
        }];
    }
}

//播放录音文件
- (void)startPlayRecordVoice:(NSString *)filePath{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [[HHBlueToothManager shareManager] setPlayFile:data];
    [[HHBlueToothManager shareManager] startPlay:PlayingWithSettingData];
}

- (void)actionToPlay:(UIButton *)button{

    if(![[HHBlueToothManager shareManager] getConnectState]) {
        [self.view makeToast:@"请先连接设备" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    if (!self.bPlaying) {
        button.selected = YES;
        [self actionToStar];
    } else {
        button.selected = NO;
        //[self stopPlayRecord];
    }
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
    
    [self.view addSubview:self.labelTop];
    [self.view addSubview:self.labelCenter];
    [self.view addSubview:self.labelBottom];
    [self.view addSubview:self.buttonPlay];
    [self.view addSubview:self.viewLine];
    self.labelTop.sd_layout.topSpaceToView(self.viewNavi, Ratio5).leftSpaceToView(self.view, kStatusBarHeight + Ratio2).widthIs(Ratio33).heightIs(Ratio16);
    self.labelCenter.sd_layout.centerYIs(kNavBarHeight + 4*self.rowWidth).leftEqualToView(self.labelTop).widthIs(Ratio33).heightIs(Ratio16);
    self.labelBottom.sd_layout.leftEqualToView(self.labelTop).topSpaceToView(self.scrollView, -Ratio22).widthIs(Ratio33).heightIs(Ratio16);
    self.buttonPlay.sd_layout.centerXEqualToView(self.view).topSpaceToView(self.scrollView, Ratio11).widthIs(Ratio44).heightIs(Ratio28);
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
        [_buttonPlay addTarget:self action:@selector(actionToPlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonPlay;
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

- (void)openFileWithFilePathURL
{
    NSString *path = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
    NSString *filePath = [NSString stringWithFormat:@"%@audio/%@", path,self.recordModel.tag];
    
    if ([HHFileLocationHelper fileExistsAtPath:filePath]) {
        [self showWaveView:filePath];
    } else {
        //如果本地没有缓存文件，先下载，后播放缓存文件
        [AFNetRequestManager downLoadFileWithUrl:self.recordModel.url path:filePath downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            
        } successBlock:^(NSURL * _Nonnull url) {
            //播放下载后的文件
            [self showWaveView:filePath];
        } fileDownloadFail:^(NSError * _Nonnull error) {
            
        }];
    }
}

- (void)showWaveView:(NSString *)path{
    self.audioFile = [KSYAudioFile audioFileWithURL:[NSURL fileURLWithPath:path]];
    self.audioPlotView.plotType = KSYPlotTypeBuffer;
    self.audioPlotView.shouldFill = YES;
    self.audioPlotView.shouldMirror = YES;
    __weak typeof (self) weakSelf = self;
    [Tools showWithStatus:@"正在加载音频数据"];
    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData, int length) {
        [weakSelf.audioPlotView updateBuffer:waveformData[0] withBufferSize:length];
        [SVProgressHUD dismiss];
    }];

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
        _labelAnnotation.text = @"0:000-15:000 全部";
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

- (KSYAudioPlotView *)audioPlotView{
    if (!_audioPlotView) {
        _audioPlotView = [[KSYAudioPlotView alloc] init];
        _audioPlotView.backgroundColor = UIColor.clearColor;
        _audioPlotView.color = MainColor;
        _audioPlotView.plotType = KSYPlotTypeBuffer;
        _audioPlotView.shouldFill = YES;
        _audioPlotView.shouldMirror = YES;
        _audioPlotView.shouldOptimizeForRealtimePlot = NO;
        
        _audioPlotView.waveformLayer.shadowOffset = CGSizeMake(0.0, 1.0);
        _audioPlotView.waveformLayer.shadowRadius = 0.0;
        _audioPlotView.waveformLayer.shadowColor = MainColor.CGColor;
        _audioPlotView.waveformLayer.shadowOpacity = 5.0;
        _audioPlotView.waveformLayer.lineWidth = Ratio3;
        
    }
    return _audioPlotView;
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.bCurrentView = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //进入旋转
    [self changeRotate:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //退出恢复
    self.bCurrentView = NO;
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
