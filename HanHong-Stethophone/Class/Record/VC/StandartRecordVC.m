//
//  StandartRecordVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import "StandartRecordVC.h"
#import "HeartVoiceView.h"
#import "LungVoiceView.h"
#import "StandarRecordBottomView.h"
#import "RecordFinishVC.h"
#import "ReadyRecordView.h"
#import "UINavigationController+QMUI.h"
#import "UIViewController+HBD.h"

@interface StandartRecordVC ()<HeartVoiceViewDelegate, LungVoiceViewDelegate, StandarRecordBottomViewDelegate, UINavigationControllerBackButtonHandlerProtocol>

@property (retain, nonatomic) UIButton                      *buttonHeart;
@property (retain, nonatomic) UIButton                      *buttonLung;
@property (retain, nonatomic) UIView                        *viewLine;
@property (assign, nonatomic) NSInteger                     selectIndex;
@property (retain, nonatomic) StandarRecordBottomView       *recordBottomView;
@property (retain, nonatomic) HeartVoiceView                *heartVoiceView;
@property (retain, nonatomic) LungVoiceView                 *lungVoiceView;
@property (assign, nonatomic) NSInteger                     buttonSelectIndex;
@property (assign, nonatomic) NSInteger                     lungSelectPositionIndex;
@property (assign, nonatomic) Boolean                       bAuscultationSequence;//是否自动录音
@property (retain, nonatomic) NSArray                      *arrayHeartReorcSequence;//心音自动录音顺序
@property (retain, nonatomic) NSArray                       *arrayLungReorcSequence;//肺音自动录音顺序
@property (retain, nonatomic) ReadyRecordView               *readyRecordView;
@property (assign, nonatomic) NSInteger                     autoIndex;
@property (assign, nonatomic) Boolean                       bActionFromAuto;//事件来自自动事件
@property (assign, nonatomic) Boolean                       bPositionReady;//事件来自自动事件
@property (retain, nonatomic) NSOperationQueue              *mainQueue;

@end

@implementation StandartRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"标准录音";
    self.mainQueue = [NSOperationQueue mainQueue];
    self.view.backgroundColor = WHITECOLOR;
    self.bAutoSaveRecord = YES;
    self.bStandart = YES;
    [self initNavi:1];
    self.selectIndex = 0;
    self.recordType = StanarRecord;
    self.autoIndex = 0;
    [self loadPlistData:YES];
    
    [self loadRecordTypeData];
    self.recordmodel = RecordingUntilRecordDuration;
    [self initView];
    self.recordBottomView.labelStartRecord.hidden = YES;
    [self actionConfigRecordDuration];
}

- (void)actionConfigRecordDuration{
    [super actionConfigRecordDuration];
    self.readyRecordView.duration = self.recordDurationAll;//录音总时长
}



- (void)actionClickHeartButtonBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag{
    self.soundsType = heart_sounds;
    self.currentPositon = string;
    [self actionAfterButtonTypeClick];
    self.recordBottomView.labelStartRecord.hidden = NO;
    self.bPositionReady = YES;
}

- (void)actionClickButtonLungBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag position:(NSInteger)position{
    //if(self.recordingState == record)
    self.soundsType = lung_sounds;
    self.currentPositon = string;
    [self actionAfterButtonTypeClick];
    self.bPositionReady = YES;
    
}

- (void)actionAfterButtonTypeClick{
    NSString *name = [[Constant shareManager] positionTagPositionCn:self.currentPositon];
    self.readyRecordView.labelReadyRecord.text = @"准备录音";
    self.recordBottomView.positionName = [NSString stringWithFormat:@"准备开始采集%@",name];
    self.recordBottomView.recordMessage = @"按听诊器录音键开始录音";
    [self actionStartRecord];
    
}

- (void)showRecordBottomViewRecordMessage:(NSString *)message {
    if ([NSThread isMainThread]) {
        self.recordBottomView.recordMessage = message;
    } else {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            wself.recordBottomView.recordMessage = message;
        }];
    }
}


- (void)actionDeviceConnecting{
    [self showRecordBottomViewRecordMessage:@"设备正在连接"];
}

- (void)actionDeviceConnectFailed{
    [self showRecordBottomViewRecordMessage:@"设备连接失败"];
}

- (void)actionDeviceConnected{
    if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
        [self showRecordBottomViewRecordMessage:@"连接的设备不是听诊器，无录音功能"];
    }
}

- (void)actionDeviceDisconnected{
    [self showRecordBottomViewRecordMessage:@"设备已断开"];
}

- (void)actionDeviceHelperRecordReady{
    if (self.soundsType == heart_sounds) {
        self.heartVoiceView.recordingState = recordingState_prepare;
    } else if (self.soundsType == lung_sounds) {
        self.lungVoiceView.recordingState = recordingState_prepare;
    }
    [self showRecordBottomViewRecordMessage:@"按听诊器录音键开始录音"];
    
}

- (void)actionDeviceHelperRecordBegin{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        if (wself.soundsType == heart_sounds) {
            wself.heartVoiceView.recordingState = recordingState_ing;
            [wself.heartVoiceView recordingStart];
        } else if (wself.soundsType == lung_sounds) {
            wself.lungVoiceView.recordingState = recordingState_ing;
            [wself.lungVoiceView recordingStart];
        }
        NSString *name = [[Constant shareManager] positionTagPositionCn:wself.currentPositon];
        wself.readyRecordView.recordCode = wself.recordCode;
        wself.recordBottomView.positionName = [NSString stringWithFormat:@"正在采集%@",name];
    }];
    
}

- (void)actionDeviceHelperRecordingTime:(float)number{
    if (self.soundsType == heart_sounds) {
        self.heartVoiceView.recordingState = recordingState_ing;
    } else if(self.soundsType == lung_sounds) {
        self.lungVoiceView.recordingState = recordingState_ing;
    }
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.readyRecordView.recordTime = number;
        wself.readyRecordView.progress = number / self.recordDurationAll;
    }];
    
    [self showRecordBottomViewRecordMessage:@""];
}

- (void)actionDeviceHelperRecordResume{
    [self showRecordBottomViewRecordMessage:@""];
}

- (void)actionDeviceHelperRecordPause{
    if (self.soundsType == heart_sounds) {
        self.heartVoiceView.recordingState = recordingState_pause;
    } else if (self.soundsType == lung_sounds) {
        self.lungVoiceView.recordingState = recordingState_pause;
    }
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself showRecordBottomViewRecordMessage:@"按听诊器录音键开始录音"];
        if (wself.soundsType == heart_sounds) {
            [wself.heartVoiceView recordingPause];
        } else if (wself.soundsType == lung_sounds) {
            [wself.lungVoiceView recordingPause];
        }
        wself.readyRecordView.stop = YES;
    }];
}

- (void)actionDeviceHelperRecordEnd{
    
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        if (wself.soundsType == heart_sounds) {
            wself.heartVoiceView.recordingState = recordingState_stop;
            [wself.heartVoiceView recordingStop];
        } else if (wself.soundsType == lung_sounds) {
            wself.lungVoiceView.recordingState = recordingState_stop;
            [wself.lungVoiceView recordingStop];
        }
        
        [wself reloadViewRecordView];
        wself.recordBottomView.recordMessage = @"";
        wself.readyRecordView.labelReadyRecord.text = @"保存成功，请选择下一个位置";
        wself.readyRecordView.recordCode = @"--";
        wself.readyRecordView.startTime = @"00:00";
        wself.recordBottomView.positionName = @"请选择采集位置";
        if (wself.bAuscultationSequence) {
            wself.autoIndex++;
            [wself performSelector:@selector(actionNextPosition) withObject:nil afterDelay:1.f];
            
        }
    }];
    
    [[HHBlueToothManager shareManager] stop];
}

- (void)actionNextPosition{
    [self autoSelectNexrPositionSequence];
}

- (void)actionCancelClickBluetooth{
  
//    [self reloadViewRecordView];
//    self.readyRecordView.labelReadyRecord.text = @"准备录音";
//    self.readyRecordView.recordCode = @"--";
}

- (void)loadPlistData:(Boolean)firstLoadData{
    [super loadPlistData:firstLoadData];
    NSString *path = [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];

    Boolean aSequence = [data[@"auscultation_sequence"] boolValue];
    if (aSequence) {
        self.arrayHeartReorcSequence = data[@"heartReorcSequence"];
        self.arrayLungReorcSequence = data[@"lungReorcSequence"];
        if (self.arrayHeartReorcSequence.count > 0 || self.arrayLungReorcSequence.count > 0) {
            self.bAuscultationSequence = YES;
            [self autoSelectNexrPositionSequence];
        }
    }
    [self loadRecordTypeData];
}

- (void)autoSelectNexrPositionSequence{
    NSInteger heartCount = self.arrayHeartReorcSequence.count;
    if(self.autoIndex == heartCount + self.arrayLungReorcSequence.count) {
        __weak typeof(self) wself = self;
        [self.view makeToast:@"录音已完成" duration:showToastViewSuccessTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
            RecordFinishVC *finishVC = [[RecordFinishVC alloc] init];
            finishVC.recordCount = [@(wself.autoIndex) integerValue];
            [wself.navigationController pushViewController:finishVC animated:YES];
        }];
        return;
    }
    if (self.autoIndex < heartCount) {
        NSDictionary *positionValue = self.arrayHeartReorcSequence[self.autoIndex];
        self.heartVoiceView.positionValue = positionValue;
    }
    
    if (self.autoIndex >= heartCount) {
        if (self.autoIndex == heartCount) {
            [self performSelector:@selector(actionClickLung) withObject:nil afterDelay:0.5];
        }
        NSDictionary *positionValue = self.arrayLungReorcSequence[self.autoIndex - heartCount];
        self.lungVoiceView.positionValue = positionValue;
    }
}

- (void)actionClickLung{
    self.bActionFromAuto = YES;
    [self actionClickButtonLung:self.buttonLung];
}

//重新加载录音界面
- (void)reloadViewRecordView{
    //self.readyRecordView.recordTime = 0;
    self.readyRecordView.progress = 0;
    self.recordingState = recordingState_prepare;
}

- (void)realodFilerView{
    if (self.isFiltrationRecord == open_filtration) {
        [self.recordBottomView filterGrayString:@"关闭滤波" blueString:@"打开滤波/"];
    } else if (self.isFiltrationRecord == close_filtration) {
        [self.recordBottomView filterGrayString:@"打开滤波" blueString:@"/关闭滤波"];
    }
}

- (void)actionClickButtonHeart:(UIButton *)button{
    if(!self.bActionFromAuto) {
        if (self.bAuscultationSequence) {
            [self.view makeToast:@"当前为自动录音状态，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return ;
        }
        if (button.selected) {
            return;
        } else if(self.recordingState == recordingState_ing || self.recordingState == recordingState_pause) {
            [kAppWindow makeToast:@"正在录音中，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        
    }
    self.bPositionReady = NO;
    self.bActionFromAuto = NO;
    self.selectIndex = 0;
    self.soundsType = heart_sounds;
    self.recordBottomView.index = 0;
    button.selected = YES;
    self.buttonLung.selected = NO;
    self.viewLine.sd_layout.centerXEqualToView(self.buttonHeart);
    [self.viewLine updateLayout];
    self.recordBottomView.sd_layout.topSpaceToView(self.heartVoiceView, 0);
    [self.recordBottomView updateLayout];
    self.lungVoiceView.hidden = YES;
    [self loadRecordTypeData];
    //[self actionStartRecord];
    [self.lungVoiceView actionClearSelectButton];
}

- (void)actionClickButtonLung:(UIButton *)button{
    if(!self.bActionFromAuto) {
        if (self.bAuscultationSequence) {
            [self.view makeToast:@"当前为自动录音状态，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return ;
        }
        if (button.selected) {
            return;
        } else if(self.recordingState == recordingState_ing || self.recordingState == recordingState_pause) {
            [kAppWindow makeToast:@"正在录音中，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
    }
    self.bPositionReady = NO;
    self.bActionFromAuto = NO;
    self.selectIndex = 1;
    self.soundsType = lung_sounds;
    self.recordBottomView.index = 1;
    button.selected = YES;
    self.buttonHeart.selected = NO;
    self.viewLine.sd_layout.centerXEqualToView(self.buttonLung);
    [self.viewLine updateLayout];
    self.recordBottomView.sd_layout.topSpaceToView(self.lungVoiceView, 0);
    [self.recordBottomView updateLayout];
    self.lungVoiceView.hidden = NO;
    [self loadRecordTypeData];
    [self.heartVoiceView actionClearSelectButton];
    //[self actionStartRecord];
}

- (void)initView {
    [self.view addSubview:self.buttonHeart];
    [self.view addSubview:self.buttonLung];
    [self.view addSubview:self.viewLine];
    self.viewLine.sd_layout.centerXEqualToView(self.buttonHeart).heightIs(Ratio2).topSpaceToView(self.buttonHeart, -Ratio10).widthIs(Ratio33);
    
    [self.view addSubview:self.heartVoiceView];
    [self.view addSubview:self.lungVoiceView];
    [self.view addSubview:self.recordBottomView];
    self.heartVoiceView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.buttonHeart, 0).heightIs(305.f*screenRatio);
    self.lungVoiceView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.buttonHeart, 0).heightIs(318.f*screenRatio);
    self.recordBottomView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.heartVoiceView, 0).bottomSpaceToView(self.view, 0);
    self.readyRecordView = self.recordBottomView.readyRecordView;
    self.lungVoiceView.autoAction = self.bAuscultationSequence;
    self.heartVoiceView.autoAction = self.bAuscultationSequence;
}




- (UIButton *)buttonHeart{
    if (!_buttonHeart) {
        _buttonHeart = [self setupButton:@"心音"];
        _buttonHeart.frame = CGRectMake(0, kNavBarAndStatusBarHeight, screenW/2, Ratio44);
        _buttonHeart.selected = YES;
        [_buttonHeart addTarget:self action:@selector(actionClickButtonHeart:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonHeart;
}

- (UIButton *)buttonLung{
    if (!_buttonLung) {
        _buttonLung = [self setupButton:@"肺音"];
        _buttonLung.frame = CGRectMake(screenW/2, kNavBarAndStatusBarHeight, screenW/2, Ratio44);
        _buttonLung.selected = NO;
        [_buttonLung addTarget:self action:@selector(actionClickButtonLung:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonLung;
}

- (UIView *)viewLine{
    if (!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = MainColor;
    }
    return _viewLine;
}

- (UIButton *)setupButton:(NSString *)title{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateSelected];
    [button setTitleColor:MainNormal forState:UIControlStateNormal];
    [button setTitleColor:MainBlack forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:Ratio17];
    return button;
}

- (StandarRecordBottomView *)recordBottomView{
    if (!_recordBottomView) {
        _recordBottomView = [[StandarRecordBottomView alloc] init];
        _recordBottomView.delegate = self;
    }
    return _recordBottomView;
}

- (ReadyRecordView *)readyRecordView{
    if(!_readyRecordView) {
        _readyRecordView = [[ReadyRecordView alloc] init];
        _readyRecordView.backgroundColor = WHITECOLOR;
    }
    return _readyRecordView;
}

- (HeartVoiceView *)heartVoiceView{
    if (!_heartVoiceView) {
        _heartVoiceView = [[HeartVoiceView alloc] init];
        _heartVoiceView.delegate = self;
    }
    return _heartVoiceView;
}

- (LungVoiceView *)lungVoiceView{
    if (!_lungVoiceView) {
        _lungVoiceView = [[LungVoiceView alloc] init];
        _lungVoiceView.hidden = YES;
        _lungVoiceView.delegate = self;
        __weak typeof(self) wself = self;
        _lungVoiceView.bodyPositionBlock = ^{
            wself.bPositionReady = NO;
        };
    }
    return _lungVoiceView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.bPositionReady) {
        [self actionStartRecord];
    }
//
//    if (self.recordingState == recordingState_pause) {
//        //
//    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[[HHBlueToothManager shareManager] stop];
    //self.recordingState = recordingState_pause;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //if (self.recordingState == recordingState_prepare || self.recordingState == recordingState_ing) {
        [[HHBlueToothManager shareManager] stop];
    //}
    //self.recordingState = recordingState_stop;
}

- (BOOL)shouldHoldBackButtonEvent {
    return YES;
}

- (BOOL)canPopViewController {
    // 这里不要做一些费时的操作，否则可能会卡顿。
    __weak typeof(self) wself = self;
    [Tools showAlertView:nil andMessage:@"确定退出吗？" andTitles:@[@"取消", @"确定"] andColors:@[MainGray, MainColor] sure:^{
        [wself.navigationController popViewControllerAnimated:YES];
    } cancel:^{
        
    }];
    return NO;
}


@end
