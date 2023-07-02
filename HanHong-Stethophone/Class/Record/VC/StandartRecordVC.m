//
//  StandartRecordVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/17.
//

#import "StandartRecordVC.h"
#import "HeartVoiceView.h"
#import "LungVoiceView.h"
#import "StandarRecordBottomView.h"
#import "HHBlueToothManager.h"
#import "DeviceManagerVC.h"
#import "RecordFinishVC.h"

@interface StandartRecordVC ()<HHBlueToothManagerDelegate, HeartVoiceViewDelegate, LungVoiceViewDelegate, StandarRecordBottomViewDelegate>

@property (retain, nonatomic) UIButton                      *buttonHeart;
@property (retain, nonatomic) UIButton                      *buttonLung;
@property (retain, nonatomic) UIView                        *viewLine;
@property (assign, nonatomic) NSInteger                     selectIndex;
@property (retain, nonatomic) ReadyRecordView               *readyRecordView;
@property (retain, nonatomic) StandarRecordBottomView       *recordBottomView;
@property (retain, nonatomic) HeartVoiceView                *heartVoiceView;
@property (retain, nonatomic) LungVoiceView                 *lungVoiceView;

@property (assign, nonatomic) NSInteger                     recordDurationAll;
@property (assign, nonatomic) NSInteger                     soundsType;
@property (assign, nonatomic) NSInteger                     isFiltrationRecord;
@property (assign, nonatomic) NSInteger                     RECORD_TYPE;
@property (assign, nonatomic) NSInteger                     recordingState;
@property (retain, nonatomic) NSString                      *recordCode;
@property (retain, nonatomic) NSString                      *relativePath;

@property (assign, nonatomic) NSInteger                     buttonSelectIndex;
@property (assign, nonatomic) NSInteger                     lungSelectPositionIndex;

@property (retain, nonatomic) NSString                      *currentPositon;

@property (assign, nonatomic) Boolean                       bAuscultationSequence;//是否自动录音
@property (retain, nonatomic) NSArray *arrayHeartReorcSequence;//心音自动录音顺序
@property (retain, nonatomic) NSArray *arrayLungReorcSequence;//肺音自动录音顺序

@property (assign, nonatomic) NSInteger                     autoIndex;
@property (assign, nonatomic) Boolean                       bActionFromAuto;//事件来自自动事件

@end

@implementation StandartRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"标准录音";
    self.view.backgroundColor = WHITECOLOR;
    self.selectIndex = 0;
    self.autoIndex = 0;
    [self loadPlistData:YES];
    [HHBlueToothManager shareManager].delegate = self;
    [self initView];
    [self reloadView];
}

- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel{
    if (self.recordingState == recordingState_ing) {
        [self.view makeToast:@"录音过程中，不可以改变录音模式" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    self.isFiltrationRecord = filterModel;
    [self loadData];
    [self realodFilerView];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadPlistData:NO];
}

- (void)actionClickHeartButtonBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag{
    self.soundsType = heart_sounds;
    self.currentPositon = string;
    [self actionAfterButtonTypeClick];
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
    self.recordBottomView.labelStartRecord.hidden = NO;
    [self actionStart];
}

- (void)reloadView{
    [self realodFilerView];
    self.readyRecordView.duration = self.recordDurationAll;//录音总时长
}

- (void)on_device_helper_event:(DEVICE_HELPER_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2{
    if (event == DeviceHelperRecordReady) {
        self.recordingState = recordingState_prepare;
        if (self.soundsType == heart_sounds) {
            self.heartVoiceView.recordingStae = recordingState_prepare;
        } else if (self.soundsType == lung_sounds) {
            self.lungVoiceView.recordingStae = recordingState_prepare;
        }
        NSLog(@"录音就绪");
    } else if (event != DeviceHelperRecordingData) {
       // NSLog(@"DEVICE_HELPER_EVENT = %li", event);
    }
    if (event == DeviceHelperRecordBegin) {
        self.recordingState = recordingState_ing;
        if (self.soundsType == heart_sounds) {
            self.heartVoiceView.recordingStae = recordingState_ing;
        } else if (self.soundsType == lung_sounds) {
            self.lungVoiceView.recordingStae = recordingState_ing;
        }
        self.recordCode = [NSString stringWithFormat:@"%@%@",[Tools getCurrentTimes], [Tools getRamdomString]];
        
        NSLog(@"录音开始: %@", self.recordCode);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.readyRecordView.recordCode = self.recordCode;
            if (self.soundsType == heart_sounds) {
                [self.heartVoiceView recordingStart];
            } else if(self.soundsType == lung_sounds) {
                [self.lungVoiceView recordingStart];
            }
            NSString *name = [[Constant shareManager] positionTagPositionCn:self.currentPositon];
            
            self.recordBottomView.positionName = [NSString stringWithFormat:@"正在采集%@",name];
        });
        
    } else if (event == DeviceHelperRecordingTime) {
        self.recordingState = recordingState_ing;
        if (self.soundsType == heart_sounds) {
            self.heartVoiceView.recordingStae = recordingState_ing;
        } else if(self.soundsType == lung_sounds) {
            self.lungVoiceView.recordingStae = recordingState_ing;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNumber *result = (NSNumber *)args1;
            float number = [result floatValue];
            NSLog(@"...%f",number);
            self.readyRecordView.recordTime = number;
            self.readyRecordView.progress = number / self.recordDurationAll;
            self.recordBottomView.labelStartRecord.hidden = YES;
        });
        
    } else if (event == DeviceHelperRecordingData) {
        
    } else if (event == DeviceHelperRecordPause) {
        self.recordingState = recordingState_pause;
        if (self.soundsType == heart_sounds) {
            self.heartVoiceView.recordingStae = recordingState_pause;
        } else if (self.soundsType == lung_sounds) {
            self.lungVoiceView.recordingStae = recordingState_pause;
        }
        NSLog(@"录音暂停");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.readyRecordView.stop = YES;
            self.recordBottomView.labelStartRecord.hidden = NO;
            if (self.soundsType == heart_sounds) {
                [self.heartVoiceView recordingPause];
            } else if (self.soundsType == lung_sounds) {
                [self.lungVoiceView recordingPause];
            }
        });
    } else if (event == DeviceHelperRecordEnd) {
        NSLog(@"录音结束");
        self.recordingState = recordingState_stop;
        
        [self actionStopRecord];
    }
}

- (void)actionClickBlueToothCallBack:(nonnull UIButton *)button{
    NSLog(@"actionClickBlueTooth");

    if(self.recordingState == recordingState_ing) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"正在录音，离开需要取消录音" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *go = [UIAlertAction actionWithTitle:@"继续录音" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self actionStart];
        }];
        [alert addAction:go];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消录音" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSInteger time = 0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //[self.buttonBluetooth actionToDeviceManagerVC:self];
                [self reloadViewRecordView];
                self.readyRecordView.labelReadyRecord.text = @"准备录音";
                self.recordBottomView.labelStartRecord.hidden = NO;
                self.readyRecordView.recordCode = @"--";
                [self actionToDeviceManagerVC];
            });
        }];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self actionToDeviceManagerVC];
    }
}


- (void)actionToDeviceManagerVC{
    DeviceManagerVC *deviceManager = [[DeviceManagerVC alloc] init];
    deviceManager.recordingState = self.recordingState;
    deviceManager.bStandart = YES;
    [self.navigationController pushViewController:deviceManager animated:YES];
}



- (void)actionStopRecord{
    NSData *data = [[HHBlueToothManager shareManager] getRecordFile];
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"wav"];
    NSString *path = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
    self.relativePath = [NSString stringWithFormat:@"audio/%@.wav", self.recordCode];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", path, self.relativePath];
    NSLog(@"filepath = %@", filePath);
    Boolean success = [data writeToFile:filePath atomically:YES];
    if (success) {
        NSLog(@"保存成功");
        [self saveSuccess];
    } else {
        NSLog(@"保存失败");
        [self reloadViewRecordView];
    }
}


- (void)saveSuccess{
    [[HHBlueToothManager shareManager] stop];
    self.recordModel.user_id = [@(LoginData.id) stringValue];
    self.recordModel.record_mode = QuickRecord;
    self.recordModel.type_id = self.soundsType;
    self.recordModel.record_filter = self.isFiltrationRecord;
    self.recordModel.record_time = [Tools dateToTimeStringYMDHMS:[NSDate now]];
    self.recordModel.record_length = self.recordDurationAll;
    self.recordModel.file_path = self.relativePath;
    //NSArray *array = [self.relativePath mutableArrayValueForKey:@"/"];
    self.recordModel.tag = [NSString stringWithFormat:@"%@.wav", self.recordCode];
    self.recordModel.modify_time = self.recordModel.record_time;
    Boolean result = [[HHDBHelper shareInstance] addRecordItem:self.recordModel];
    if (result) {
        NSLog(@"保存数据库成功");
    } else {
        NSLog(@"保存数据库失败");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recordBottomView.labelStartRecord.hidden = NO;
        if (self.soundsType == heart_sounds) {
            self.heartVoiceView.recordingStae = recordingState_stop;
            [self.heartVoiceView recordingStop];
        } else if (self.soundsType == lung_sounds) {
            self.lungVoiceView.recordingStae = recordingState_stop;
            [self.lungVoiceView recordingStop];
        }
        [self reloadViewRecordView];
        self.recordBottomView.labelStartRecord.hidden = YES;
        self.readyRecordView.labelReadyRecord.text = @"保存成功，请选择下一个位置";
        if (self.bAuscultationSequence) {
            self.autoIndex++;
            NSLog(@"autoIndex = %li", self.autoIndex);
            [self autoSelectNexrPositionSequence];
        }
        //[self actionStart];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"add_record_success" object:nil];
    });
}

- (void)actionStart{
    [[HHBlueToothManager shareManager] setRecordDuration:(int)self.recordDurationAll];//设置录音时长
    [[HHBlueToothManager shareManager] startRecord:self.RECORD_TYPE record_mode:RecordingUntilRecordDuration];
}

- (void)loadPlistData:(Boolean)firstLoadData{
    NSString *path = [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    
    self.recordDurationAll = [data[@"record_duration"] integerValue];// 录音总时长
    if (!firstLoadData) {
        self.soundsType = heart_sounds;
        self.isFiltrationRecord = [data[@"is_filtration_record"] integerValue];//滤波状态
       
    }
    Boolean aSequence = [data[@"auscultation_sequence"] boolValue];
    if (aSequence) {
        self.arrayHeartReorcSequence = data[@"heartReorcSequence"];
        self.arrayLungReorcSequence = data[@"lungReorcSequence"];
        if (self.arrayHeartReorcSequence.count > 0 || self.arrayLungReorcSequence.count > 0) {
            self.bAuscultationSequence = YES;
            [self autoSelectNexrPositionSequence];
        }
    }
    [self loadData];
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


- (void)loadData{
    if (self.isFiltrationRecord == open_filtration) {
        //判断音类型
        if (self.soundsType == heart_sounds) {//---------
            self.RECORD_TYPE = RECORD_HEART_WITH_BUTTON;
        } else {
            self.RECORD_TYPE = RECORD_LUNG_WITH_BUTTON;
        }
    } else if (self.isFiltrationRecord == close_filtration) {
        self.RECORD_TYPE = RECORD_FULL_WITH_BUTTON;
    }
}

- (void)realodFilerView{
    if (self.isFiltrationRecord == open_filtration) {
        [self.recordBottomView filterGrayString:@"关闭滤波" blueString:@"打开滤波/"];
    } else if (self.isFiltrationRecord == close_filtration) {
        [self.recordBottomView filterGrayString:@"打开滤波" blueString:@"/关闭滤波"];
    }
}

- (void)reloadViewRecordView{
    self.readyRecordView.recordTime = 0;
    self.readyRecordView.progress = 0;
    self.recordingState = recordingState_prepare;
}

- (void)actionClickButtonHeart:(UIButton *)button{
    if(!self.bActionFromAuto) {
        if (self.bAuscultationSequence) {
            [self.view makeToast:@"当前为自动录音状态，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return ;
        }
        if (button.selected) {
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
    [self loadData];
    [self actionStart];

}

- (void)actionClickButtonLung:(UIButton *)button{
    if(!self.bActionFromAuto) {
        if (self.bAuscultationSequence) {
            [self.view makeToast:@"当前为自动录音状态，不可点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return ;
        }
        if (button.selected) {
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
    [self loadData];
    [self actionStart];
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
    }
    return _recordBottomView;
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

@end
