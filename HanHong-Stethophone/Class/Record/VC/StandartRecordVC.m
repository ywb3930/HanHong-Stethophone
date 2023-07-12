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
@property (retain, nonatomic) ReadyRecordView       *readyRecordView;
@property (assign, nonatomic) NSInteger                     autoIndex;
@property (assign, nonatomic) Boolean                       bActionFromAuto;//事件来自自动事件


@end

@implementation StandartRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"标准录音";
    self.view.backgroundColor = WHITECOLOR;
    self.bAutoSaveRecord = YES;
    [self initNavi:1];
    self.selectIndex = 0;
    self.recordType = StanarRecord;
    self.autoIndex = 0;
    [self loadPlistData:YES];
    [self loadRecordTypeData];
    [self initView];
    [self reloadView];
    self.recordBottomView.labelStartRecord.hidden = YES;
}

- (void)reloadView{
    [super reloadView];
    self.readyRecordView.duration = self.recordDurationAll;//录音总时长
    
}

- (void)actionClickHeartButtonBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag{
    self.soundsType = heart_sounds;
    self.currentPositon = string;
    [self actionAfterButtonTypeClick];
    self.recordBottomView.labelStartRecord.hidden = NO;
}

- (void)actionClickButtonLungBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag position:(NSInteger)position{
    self.soundsType = lung_sounds;
    self.currentPositon = string;
    [self actionAfterButtonTypeClick];
}

- (void)actionAfterButtonTypeClick{
    NSString *name = [[Constant shareManager] positionTagPositionCn:self.currentPositon];
    self.readyRecordView.labelReadyRecord.text = @"准备录音";
    self.recordBottomView.positionName = [NSString stringWithFormat:@"准备开始采集%@",name];
    self.recordBottomView.recordMessage = @"按听诊器录音键开始录音";
    [self actionStartRecord];
}


- (void)actionDeviceConnecting{
    self.recordBottomView.recordMessage = @"设备正在连接";
}

- (void)actionDeviceConnectFailed{
    self.recordBottomView.recordMessage = @"设备连接失败";
}

- (void)actionDeviceConnected{
    if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
        self.recordBottomView.recordMessage = @"连接的设备不是听诊器，无录音功能";
    }
}

- (void)actionDeviceDisconnected{
    self.recordBottomView.recordMessage = @"设备已断开";
}

- (void)actionDeviceHelperRecordReady{
    if (self.soundsType == heart_sounds) {
        self.heartVoiceView.recordingStae = recordingState_prepare;
    } else if (self.soundsType == lung_sounds) {
        self.lungVoiceView.recordingStae = recordingState_prepare;
    }
    self.recordBottomView.recordMessage = @"按听诊器录音键开始录音";
    
}

- (void)actionDeviceHelperRecordBegin{
    if (self.soundsType == heart_sounds) {
        self.heartVoiceView.recordingStae = recordingState_ing;
        [self.heartVoiceView recordingStart];
    } else if (self.soundsType == lung_sounds) {
        self.lungVoiceView.recordingStae = recordingState_ing;
        [self.lungVoiceView recordingStart];
    }
    
    NSString *name = [[Constant shareManager] positionTagPositionCn:self.currentPositon];
    self.readyRecordView.recordCode = self.recordCode;
    self.recordBottomView.positionName = [NSString stringWithFormat:@"正在采集%@",name];
}

- (void)actionDeviceHelperRecordingTime:(float)number{
    if (self.soundsType == heart_sounds) {
        self.heartVoiceView.recordingStae = recordingState_ing;
    } else if(self.soundsType == lung_sounds) {
        self.lungVoiceView.recordingStae = recordingState_ing;
    }
    self.readyRecordView.recordTime = number;
    self.readyRecordView.progress = number / self.recordDurationAll;
    self.recordBottomView.recordMessage = @"";
}

- (void)actionDeviceHelperRecordResume{
    self.recordBottomView.recordMessage = @"";
}

- (void)actionDeviceHelperRecordPause{
    if (self.soundsType == heart_sounds) {
        self.heartVoiceView.recordingStae = recordingState_pause;
    } else if (self.soundsType == lung_sounds) {
        self.lungVoiceView.recordingStae = recordingState_pause;
    }
    self.recordBottomView.recordMessage = @"按听诊器录音键开始录音";
    if (self.soundsType == heart_sounds) {
        [self.heartVoiceView recordingPause];
    } else if (self.soundsType == lung_sounds) {
        [self.lungVoiceView recordingPause];
    }
    self.readyRecordView.stop = YES;
}

- (void)actionDeviceHelperRecordEnd{
    if (self.soundsType == heart_sounds) {
        self.heartVoiceView.recordingStae = recordingState_stop;
        [self.heartVoiceView recordingStop];
    } else if (self.soundsType == lung_sounds) {
        self.lungVoiceView.recordingStae = recordingState_stop;
        [self.lungVoiceView recordingStop];
    }
    [self reloadViewRecordView];
    self.recordBottomView.recordMessage = @"";
    self.readyRecordView.labelReadyRecord.text = @"保存成功，请选择下一个位置";
    self.readyRecordView.recordCode = @"--";
    self.readyRecordView.startTime = @"00:00";
    if (self.bAuscultationSequence) {
        self.autoIndex++;
        NSLog(@"autoIndex = %li", self.autoIndex);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self autoSelectNexrPositionSequence];
        });
        
    }
}

- (void)actionCancelClickBluetooth{
    //self.recordBottomView.recordMessage = @"按听诊器录音键开始录音";
    [self reloadViewRecordView];
    self.readyRecordView.labelReadyRecord.text = @"准备录音";
    self.readyRecordView.recordCode = @"--";
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
        [self.view makeToast:@"录音已完成" duration:showToastViewSuccessTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
            RecordFinishVC *finishVC = [[RecordFinishVC alloc] init];
            finishVC.recordCount = [@(self.autoIndex) integerValue];
            [self.navigationController pushViewController:finishVC animated:YES];
        }];
        return;
    }
    if (self.autoIndex < heartCount) {
        NSDictionary *positionValue = self.arrayHeartReorcSequence[self.autoIndex];
        self.heartVoiceView.positionValue = positionValue;
    }
    
    if (self.autoIndex >= heartCount) {
        if (self.autoIndex == heartCount) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.bActionFromAuto = YES;
                [self actionClickButtonLung:self.buttonLung];
            });
            
        }

        NSDictionary *positionValue = self.arrayLungReorcSequence[self.autoIndex - heartCount];
        self.lungVoiceView.positionValue = positionValue;
        
    }
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
        } else if(self.recordingState == recordingState_ing) {
            [kAppWindow makeToast:@"正在录音中，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        
    }
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
    [self actionStartRecord];

}

- (void)actionClickButtonLung:(UIButton *)button{
    if(!self.bActionFromAuto) {
        if (self.bAuscultationSequence) {
            [self.view makeToast:@"当前为自动录音状态，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return ;
        }
        if (button.selected) {
            return;
        } else if(self.recordingState == recordingState_ing) {
            [kAppWindow makeToast:@"正在录音中，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
    }
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
    [self actionStartRecord];
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
    }
    return _lungVoiceView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.recordingState != recordingState_ing) {
        [self actionStartRecord];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[HHBlueToothManager shareManager] stop];
    self.recordingState = recordingState_pause;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.recordingState == recordingState_prepare || self.recordingState == recordingState_ing) {
        [[HHBlueToothManager shareManager] stop];
    }
    self.recordingState = recordingState_stop;
}


@end
