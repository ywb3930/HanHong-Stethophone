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
#import "DeviceManagerVC.h"

@interface StandartRecordVC ()<HeartVoiceViewDelegate, LungVoiceViewDelegate, StandarRecordBottomViewDelegate, UINavigationControllerBackButtonHandlerProtocol, HHBluetoothButtonDelegate>

@property (retain, nonatomic) UIButton                      *buttonHeart;//心音按钮
@property (retain, nonatomic) UIButton                      *buttonLung;//肺音按钮
@property (retain, nonatomic) UIView                        *viewLine;//心音肺音按钮下面的下划线
@property (assign, nonatomic) NSInteger                     selectIndex;//0 选择心音 1 选中肺音
@property (retain, nonatomic) StandarRecordBottomView       *recordBottomView;//下部分界面
@property (retain, nonatomic) HeartVoiceView                *heartVoiceView;//点击心音时显示的上部分界面
@property (retain, nonatomic) LungVoiceView                 *lungVoiceView;//点击肺音时显示的上部分界面
@property (assign, nonatomic) Boolean                       bAuscultationSequence;//是否自动录音
@property (retain, nonatomic) NSArray                       *arrayHeartReordSequence;//心音自动录音顺序
@property (retain, nonatomic) NSArray                       *arrayLungReordSequence;//肺音自动录音顺序
@property (retain, nonatomic) ReadyRecordView               *readyRecordView;//
@property (assign, nonatomic) NSInteger                     autoIndex;
@property (assign, nonatomic) Boolean                       bActionFromAuto;//事件来自自动事件
@property (assign, nonatomic) Boolean                       bPositionReady;//是否已经选中需要录音的位置
@property (retain, nonatomic) NSOperationQueue              *mainQueue;

@property (assign, nonatomic) NSInteger             recordingState;//录音状态
@property (assign, nonatomic) NSInteger             soundsType;//快速录音类型
@property (assign, nonatomic) NSInteger             recordDurationAll;// 录音总时长
@property (assign, nonatomic) NSInteger             isFiltrationRecord;//滤波状态
@property (retain, nonatomic) HHBluetoothButton     *buttonBluetooth;
@property (assign, nonatomic) NSInteger             RECORD_TYPE;//判断滤波状态
@property (assign, nonatomic) NSInteger             successCount;
@property (retain, nonatomic) NSString              *recordCode;//录音编号
@property (assign, nonatomic) Boolean               bAutoSaveRecord;//是否自动保存录音

@property (retain, nonatomic) NSString              *relativePath;
@property (retain, nonatomic) NSString              *currentPositon;

@end

@implementation StandartRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"标准录音";
    self.mainQueue = [NSOperationQueue mainQueue];
    self.view.backgroundColor = WHITECOLOR;
    self.bAutoSaveRecord = YES;
    //self.bStandart = YES;
    [self initNavi];
    self.selectIndex = 0;
    //self.recordType = StanarRecord;//标准录音
    //self.recordmodel = RecordingUntilRecordDuration;//录音达到设定的录音时长才会结束，用户调用Api结束录音无效，如果有按键事件则暂停
    self.autoIndex = 0;
    [self loadPlistData:YES];
    [self loadRecordTypeData];
    [self initView];
    //self.recordBottomView.labelStartRecord.hidden = YES;
    [self actionConfigRecordDuration];
    [self realodFilerView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionRecieveBluetoothMessage:) name:HHBluetoothMessage object:nil];
    if ([[HHBlueToothManager shareManager] getConnectState] != DEVICE_CONNECTED) {
        [self showDeviceMessage:@"设备未连接"];
    } else if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
        [self showDeviceMessage:@"连接的设备不是听诊器，无录音功能"];
    }
}

//接收蓝牙广播通知
- (void)actionRecieveBluetoothMessage:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    DEVICE_HELPER_EVENT event = [userInfo[@"event"] integerValue];
    NSObject *args1 = userInfo[@"args1"];
    NSObject *args2 = userInfo[@"args2"];
    if (event!=12) {
        DLog(@"DEVICE_HELPER_EVENT = %li", event);
    }
    if (event == DeviceConnecting) {
        [self actionDeviceConnecting];
    } else if (event == DeviceConnected) {
        [self actionDeviceConnected];
    } else if (event == DeviceConnectFailed) {
        [self actionDeviceConnectFailed];
    } else if (event == DeviceDisconnected) {
        [self actionDeviceDisconnected];
    }
    
    
    if (event == DeviceHelperRecordReady) {
        self.recordingState = recordingState_prepare;
        DLog(@"录音就绪");
        [self actionDeviceHelperRecordReady];
    } else if (event == DeviceHelperRecordBegin) {
        self.recordingState = recordingState_ing;
        self.recordCode = [NSString stringWithFormat:@"%@%@",[Tools getCurrentTimes], [Tools getRamdomString]];
        DLog(@"录音开始: %@", self.recordCode);
        [self actionDeviceHelperRecordBegin];
    } else if (event == DeviceHelperRecordingTime) {
        //显示录音进度
        self.recordingState = recordingState_ing;
        NSNumber *result = (NSNumber *)args1;
        float number = [result floatValue];
        [self actionDeviceHelperRecordingTime:number];
        DLog(@"录音进度: %f",number);

    } else if (event == DeviceHelperRecordingData) {
        
    } else if (event == DeviceHelperRecordPause) {
        self.recordingState = recordingState_pause;
        DLog(@"录音暂停");
        [self actionDeviceHelperRecordPause];
    } else if (event == DeviceHelperRecordResume) {
        DLog(@"录音恢复");
        self.recordingState = recordingState_ing;
        [self actionDeviceHelperRecordResume];
    } else if (event == DeviceHelperRecordEnd) {
        DLog(@"录音结束");
        self.recordingState = recordingState_stop;
        [self actionEndRecord];
    }  else if (event == DeviceRecordPlayInstable) {
        [self actionDeviceRecordPlayInstable];
    } else if (event == DeviceRecordLostEvent) {
        [self actionDeviceRecordLostEvent];
    }
}



//录音结束事件处理
- (void)actionEndRecord{
    //获取录音二进制文件
    NSArray *array = [[HHBlueToothManager shareManager] getRecordFile];
   
    if (array) {
        NSInteger recordTimeLength = [array[0] integerValue];
        DLog(@"recordTimeLength = %li", recordTimeLength);
        if(!self.bAutoSaveRecord || recordTimeLength < record_time_minimum || recordTimeLength > record_time_maximum) {
           // [self actionStartRecord];
            [self actionDeviceHelperRecordEnd];
            return;
        }
        
        //获取录音文件保存路径
        NSData *data = (NSData *)array[1];
        NSString *path = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
        self.relativePath = [NSString stringWithFormat:@"audio/%@.wav", self.recordCode];
        NSString *filePath = [NSString stringWithFormat:@"%@%@", path, self.relativePath];
        //DLog(@"filepath = %@", filePath);
        //将二进制文件写入目录
        Boolean success = [data writeToFile:filePath atomically:YES];
        if (success) {
            __weak typeof(self) wself = self;
            NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                [wself.view makeToast:@"保存成功" duration:showToastViewWarmingTime position:CSToastPositionBottom];
            }];
            
            //保存成功回调
            [self saveSuccess:recordTimeLength];
        } else {
            DLog(@"保存失败");
        }
    }
    
    
}

//保存成功后写入数据库
- (void)saveSuccess:(NSInteger)recordTimeLength{
    [[HHBlueToothManager shareManager] stop];
   // RecordModel *recordModel = [[RecordModel alloc] init];
    if(!self.recordDataModel) {
        self.recordDataModel = [[RecordModel alloc] init];
    }
    self.recordDataModel.user_id = [@(LoginData.userID) stringValue];
    self.recordDataModel.record_mode = StanarRecord;
    self.recordDataModel.type_id = self.soundsType;
    self.recordDataModel.record_filter = self.isFiltrationRecord;
    self.recordDataModel.record_time = [Tools dateToTimeStringYMDHMS:[NSDate now]];
    self.recordDataModel.record_length = self.recordDurationAll;
    
    self.recordDataModel.file_path = self.relativePath;
    self.recordDataModel.position_tag =  self.currentPositon;
    self.recordDataModel.tag = [NSString stringWithFormat:@"%@.wav", self.recordCode];
    self.recordDataModel.modify_time = self.recordDataModel.record_time;
    Boolean result = [[HHDBHelper shareInstance] addRecordItem:self.recordDataModel];
    if (result) {
        DLog(@"保存数据库成功");
    } else {
        DLog(@"保存数据库失败");
    }
   
    [self actionDeviceHelperRecordEnd];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AddLocalRecordSuccess object:nil];
    self.successCount ++;
}


//读取本地配置文件
- (void)loadPlistData:(Boolean)firstLoadData{
    NSString *path = [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    self.recordDurationAll = [data[@"record_duration"] integerValue];// 录音总时长
    if (firstLoadData) {
        self.soundsType = [data[@"quick_record_default_type"] integerValue];//快速录音类型
        self.isFiltrationRecord = [data[@"is_filtration_record"] integerValue];//滤波状态
        
        NSString *path = [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
        NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];

        Boolean aSequence = [data[@"auscultation_sequence"] boolValue];
        if (aSequence) {
            self.arrayHeartReordSequence = data[@"heartReordSequence"];
            self.arrayLungReordSequence = data[@"lungReordSequence"];
            if (self.arrayHeartReordSequence.count > 0 || self.arrayLungReordSequence.count > 0) {
                self.bAuscultationSequence = YES;
                [self autoSelectNexrPositionSequence];
            }
        }
        [self loadRecordTypeData];
    }

}

- (void)loadRecordTypeData{
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


//设置录音时长
- (void)actionConfigRecordDuration{
    [[HHBlueToothManager shareManager] setRecordDuration:(int)self.recordDurationAll];//设置录音时长
    self.readyRecordView.duration = self.recordDurationAll;//录音总时长
}


//心音选择录音位置时的回调
- (void)actionClickHeartButtonBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag{
    self.soundsType = heart_sounds;
    self.currentPositon = string;
    [self actionAfterButtonTypeClick];
    //self.recordBottomView.labelStartRecord.hidden = NO;
    self.bPositionReady = YES;
}
//肺音选择录音位置时的回调
- (void)actionClickButtonLungBodyPositionCallBack:(NSString *)string tag:(NSInteger)tag position:(NSInteger)position{
    //if(self.recordingState == record)

    self.soundsType = lung_sounds;
    self.currentPositon = string;
    [self actionAfterButtonTypeClick];
    self.bPositionReady = YES;
}

- (void)initNavi{
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.buttonBluetooth];
    item1.width = Ratio22;
    self.navigationItem.rightBarButtonItems = @[item1];
}

- (void)actionAfterButtonTypeClick{
    NSString *name = [[Constant shareManager] positionTagPositionCn:self.currentPositon];
    if (!self.bAuscultationSequence) {
        self.readyRecordView.labelReadyRecord.text = @"准备录音";
    }
    
    self.recordBottomView.positionName = [NSString stringWithFormat:@"准备开始采集%@",name];
    self.recordBottomView.recordMessage = @"按听诊器录音键开始录音";
    [self actionStartRecord];
    
}

//开始录音
- (void)actionStartRecord{
    if (self.recordingState != recordingState_ing) {
        [[HHBlueToothManager shareManager] startRecord:self.RECORD_TYPE record_mode:RecordingUntilRecordDuration];
    }
    
}
//显示录音消息
- (void)showRecordMessage:(NSString *)message {
    if ([Tools isBlankString:message]) {
        NSLog(@"");
    }
    if ([NSThread isMainThread]) {
        self.recordBottomView.recordMessage = message;
    } else {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            wself.recordBottomView.recordMessage = message;
        }];
    }
}
//显示设备信息
- (void)showDeviceMessage:(NSString *)message {
    if ([NSThread isMainThread]) {
        self.recordBottomView.deviceConnectMessage = message;
    } else {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            wself.recordBottomView.deviceConnectMessage = message;
        }];
    }
}


- (void)actionDeviceConnecting{
    [self showDeviceMessage:@"设备正在连接"];
}

- (void)actionDeviceConnectFailed{
    [self showDeviceMessage:@"设备连接失败"];
}

- (void)actionDeviceConnected{
    if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
        [self showDeviceMessage:@"连接的设备不是听诊器，无录音功能"];
    } else {
        if (self.bPositionReady) {
            [self showDeviceMessage:@"按听诊器录音键可以开始录音"];
        } else {
            [self showDeviceMessage:@""];
        }
        
    }
    [self showDeviceMessage:@""];
}

- (void)actionDeviceDisconnected{
//    [self showRecordMessage:@"设备已断开"];
    [self showDeviceMessage:@"设备已断开"];
    [self showRecordMessage:@""];
}

- (void)actionDeviceHelperRecordReady{
    [self setVoiceViewRecordingState];
    [self showRecordMessage:@"按听诊器录音键开始录音"];
}

- (void)setVoiceViewRecordingState{
    if (self.soundsType == heart_sounds) {
        self.heartVoiceView.recordingState = self.recordingState;
    } else if (self.soundsType == lung_sounds) {
        self.lungVoiceView.recordingState = self.recordingState;
    }
}


//点击蓝牙按钮到蓝牙配置界面
- (void)actionClickBlueToothCallBack:(UIButton *)button{
    if(self.recordingState == recordingState_ing || self.recordingState == recordingState_pause) {
        __weak typeof(self) wself = self;
        [Tools showAlertView:nil andMessage:@"正在录音，确认要进入蓝牙设置吗？" andTitles:@[@"取消", @"确定"] andColors:@[MainGray, MainColor] sure:^{
            [wself actionClickBluetooth];
        } cancel:^{
            
        }];
    } else {
        [self actionClickBluetooth];
    }
}

- (void)actionClickBluetooth{
    
    [self actionToDeviceManagerVC];
    [self actionClickBlueToothToDeviceManager];
}



- (void)actionToDeviceManagerVC{
    DeviceManagerVC *deviceManager = [[DeviceManagerVC alloc] init];
    deviceManager.recordingState = self.recordingState;
    deviceManager.bStandart = YES;
    [self.navigationController pushViewController:deviceManager animated:YES];
}

- (void)actionDeviceHelperRecordBegin{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself setVoiceViewRecordingState];
        if (wself.soundsType == heart_sounds) {
            [wself.heartVoiceView recordingStart];
        } else if (wself.soundsType == lung_sounds) {
            [wself.lungVoiceView recordingStart];
        }
        [wself showRecordMessage:@""];
        [wself showDeviceMessage:@""];
        NSString *name = [[Constant shareManager] positionTagPositionCn:wself.currentPositon];
        wself.readyRecordView.recordCode = wself.recordCode;
        wself.recordBottomView.positionName = [NSString stringWithFormat:@"正在采集%@",name];
    }];
    
}

- (void)actionDeviceHelperRecordingTime:(float)number{
    [self setVoiceViewRecordingState];
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.readyRecordView.recordTime = number;
        wself.readyRecordView.progress = number / self.recordDurationAll;
    }];
    
    [self showRecordMessage:@""];
}

- (void)actionDeviceRecordPlayInstable{
//    [self showRecordMessage:@"无限数据传输不稳定"];
    [self showDeviceMessage:@"无限数据传输不稳定"];
}

- (void)actionDeviceRecordLostEvent{
//    [self showRecordMessage:@"无线信号弱，音频数据丢失"];
    [self showDeviceMessage:@"无线信号弱，音频数据丢失"];
}


- (void)actionDeviceHelperRecordResume{
    [self showRecordMessage:@""];
}

- (void)actionDeviceHelperRecordPause{
    [self setVoiceViewRecordingState];
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself showRecordMessage:@"按听诊器录音键开始录音"];
        wself.readyRecordView.stop = YES;
    }];
}

- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel{
    if (self.recordingState == recordingState_ing || self.recordingState == recordingState_pause) {
        [self.view makeToast:@"录音过程中，不可以改变录音模式" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    self.isFiltrationRecord = filterModel;
    [self loadRecordTypeData];
    if (self.bPositionReady) {
        [self actionStartRecord];
    }
    //
    return YES;
}

- (void)actionDeviceHelperRecordEnd{
    
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself setVoiceViewRecordingState];
        if (wself.soundsType == heart_sounds) {
            [wself.heartVoiceView recordingStop];
        } else if (wself.soundsType == lung_sounds) {
            [wself.lungVoiceView recordingStop];
        }
        
        [wself actionReloadRecordView];

        wself.readyRecordView.labelReadyRecord.text = @"保存成功，准备下一个录音";
//        wself.readyRecordView.recordCode = @"--";
        
        wself.recordBottomView.positionName = @"请选择采集位置";
        if (wself.bAuscultationSequence) {
            wself.autoIndex++;
            [wself performSelector:@selector(actionNextPosition) withObject:nil afterDelay:1.f];
            
        }
    }];
    
    //[[HHBlueToothManager shareManager] stop];
}

- (void)actionNextPosition{
    [self autoSelectNexrPositionSequence];
}

- (void)actionClickBlueToothToDeviceManager{
    [self actionStop];
    if (!self.bAuscultationSequence) {
        if (self.soundsType == heart_sounds) {
            [self.heartVoiceView actionClearSelectButton];
            [self.heartVoiceView recordingReload];
        } else if (self.soundsType == lung_sounds) {
            [self.lungVoiceView recordingReload];
            [self.heartVoiceView actionClearSelectButton];
        }
        self.recordBottomView.positionName = @"请选择采集位置";
        self.bPositionReady = NO;
    }  else {
        self.recordBottomView.recordMessage = @"按听诊器录音键开始录音";
    }
    self.recordingState = recordingState_stop;
    [self setVoiceViewRecordingState];
    //[self actionStop];
    [self actionReloadRecordView];
    self.readyRecordView.labelReadyRecord.text = @"准备录音";
    
    
}

- (void)actionStop {
    [[HHBlueToothManager shareManager] stop];
}




- (void)autoSelectNexrPositionSequence{
    NSInteger heartCount = self.arrayHeartReordSequence.count;
    if(self.autoIndex == heartCount + self.arrayLungReordSequence.count) {
        __weak typeof(self) wself = self;
        [self.view makeToast:@"录音已完成" duration:showToastViewSuccessTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
            RecordFinishVC *finishVC = [[RecordFinishVC alloc] init];
            finishVC.recordCount = [@(wself.autoIndex) integerValue];
            [wself.navigationController pushViewController:finishVC animated:YES];
        }];
        return;
    }
    if (self.autoIndex < heartCount) {
        NSDictionary *positionValue = self.arrayHeartReordSequence[self.autoIndex];
        self.heartVoiceView.positionValue = positionValue;
    }
    
    if (self.autoIndex >= heartCount) {
        if (self.autoIndex == heartCount) {
            [self performSelector:@selector(actionClickLung) withObject:nil afterDelay:0.5];
        }
        NSDictionary *positionValue = self.arrayLungReordSequence[self.autoIndex - heartCount];
        self.lungVoiceView.positionValue = positionValue;
    }
}

- (void)actionClickLung{
    self.bActionFromAuto = YES;
   
    [self actionClickButtonLung:self.buttonLung];
}

//重新加载录音界面
- (void)actionReloadRecordView{
    //self.readyRecordView.recordTime = 0;
    self.readyRecordView.progress = 0;
    //self.recordingState = recordingState_prepare;
    self.readyRecordView.recordCode = @"--";
    self.recordBottomView.recordMessage = @"";
    self.readyRecordView.startTime = @"00:00";
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
        [self actionStop];
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
    self.recordBottomView.positionName = @"请选择采集位置";
    [self loadRecordTypeData];
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
        [self actionStop];
    }
    self.bPositionReady = NO;
    self.bActionFromAuto = NO;
    self.selectIndex = 1;
    self.soundsType = lung_sounds;
    self.recordBottomView.index = 1;
    button.selected = YES;
    self.buttonHeart.selected = NO;
    if (self.bAuscultationSequence) {
        self.readyRecordView.labelReadyRecord.text = @"保存成功，准备下一个录音";
    } else {
        self.recordBottomView.positionName = @"请选择采集位置";
    }
    
    self.viewLine.sd_layout.centerXEqualToView(self.buttonLung);
    [self.viewLine updateLayout];
    self.recordBottomView.sd_layout.topSpaceToView(self.lungVoiceView, 0);
    [self.recordBottomView updateLayout];
    self.lungVoiceView.hidden = NO;
    [self loadRecordTypeData];
    [self.heartVoiceView actionClearSelectButton];
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
    if(!self.bAuscultationSequence) {
        self.bActionFromAuto = YES;
        if (self.soundsType == heart_sounds) {//---------
            [self actionClickButtonHeart:self.buttonHeart];
        } else {
            [self actionClickButtonLung:self.buttonLung];
        }
    } else {
        self.heartVoiceView.heartBodyView.arrayReordSequence = self.arrayHeartReordSequence;
        self.lungVoiceView.lungBodyBackView.arrayReordSequence = self.arrayLungReordSequence;
        self.lungVoiceView.lungBodySideView.arrayReordSequence = self.arrayLungReordSequence;
        self.lungVoiceView.lungBodyFrontView.arrayReordSequence = self.arrayLungReordSequence;
    }
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
            wself.recordBottomView.positionName = @"请选择采集位置";
        };
    }
    return _lungVoiceView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self loadPlistData:NO];
    [self loadRecordTypeData];
    [self actionConfigRecordDuration];
   // [self.buttonBluetooth star];
    if (self.bPositionReady) {
        [self actionStartRecord];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[HHBlueToothManager shareManager] stop];
    self.recordingState = recordingState_stop;
}
//禁止滑动返回
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

- (HHBluetoothButton *)buttonBluetooth{
    if(!_buttonBluetooth) {
        _buttonBluetooth  = [[HHBluetoothButton alloc] init];
        _buttonBluetooth.bluetoothButtonDelegate = self;
        //_buttonBluetooth.imageEdgeInsets = UIEdgeInsetsMake(-Ratio5, -Ratio5, -Ratio5, -Ratio5);
    }
    return _buttonBluetooth;
}
@end
