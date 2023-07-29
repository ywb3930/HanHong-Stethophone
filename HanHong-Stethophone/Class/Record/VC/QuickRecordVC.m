//
//  QuickRecordVC.m
//  HanHong-Stethophone
//  快速录音界面
//  Created by Hanhong on 2023/6/16.
//

#import "QuickRecordVC.h"
#import "RecordFinishVC.h"
#import "HeartFilterLungView.h"
#import "ReadyRecordView.h"
#import "UINavigationController+QMUI.h"
#import "UIViewController+HBD.h"
#import "DeviceManagerVC.h"

@interface QuickRecordVC ()<HeartFilterLungViewDelegate, UINavigationControllerBackButtonHandlerProtocol, HHBluetoothButtonDelegate>


@property (retain, nonatomic) UIView                *viewInfo;//下部分界面(录音状态，设备状态，录音选择)
@property (retain ,nonatomic) UILabel               *labelRecordMessage;//录音状态
@property (retain, nonatomic) ReadyRecordView       *readyRecordView;//上部分界面(录音进度，准备录音，录音进度和事件)
@property (retain, nonatomic) UILabel               *labelConnectMessage;//设备状态
@property (retain, nonatomic) HeartFilterLungView   *heartFilterLungView;//心音肺音和滤波
@property (retain, nonatomic) NSOperationQueue      *mainQueue;
@property (assign, nonatomic) Boolean               bLoadedView;//是否已经进入界面，防止第一次进入界面重复调用actionStartRecord

@property (assign, nonatomic) NSInteger             recordingState;//录音状态
@property (assign, nonatomic) NSInteger             soundsType;//快速录音类型
@property (assign, nonatomic) NSInteger             recordDurationAll;// 录音总时长
@property (assign, nonatomic) NSInteger             isFiltrationRecord;//滤波状态
@property (retain, nonatomic) HHBluetoothButton     *buttonBluetooth;
@property (assign, nonatomic) NSInteger             RECORD_TYPE;//判断滤波状态
@property (assign, nonatomic) NSInteger             successCount;
@property (retain, nonatomic) NSString              *recordCode;//录音编号
@property (assign, nonatomic) Boolean               bAutoSaveRecord;//是否自动保存录音
@property (retain, nonatomic) RecordModel            *recordDataModel;
@property (retain, nonatomic) NSString              *relativePath;

@end

@implementation QuickRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = ViewBackGroundColor;
    
    self.mainQueue = [NSOperationQueue mainQueue];
    self.title = @"便捷录音";
//    self.recordType = QuickRecord;//快速录音
//    self.recordmodel = RecordingUntilRecordDuration;//录音达到设定的录音时长才会结束，用户调用Api结束录音无效，如果有按键事件则暂停
    self.bAutoSaveRecord = YES;
    [self initNavi];
    [self loadPlistData:YES];//读取录音配置
    [self initView];//初始化界面
    [self reloadView];//根据配置重新显示界面
    [self loadRecordTypeData]; //获取录音类型和滤波状态
    [self actionConfigRecordDuration];//设置录音时长
    [self actionStartRecord];//开始录音
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionRecieveBluetoothMessage:) name:HHBluetoothMessage object:nil];
    if ([[HHBlueToothManager shareManager] getConnectState] != DEVICE_CONNECTED) {
        [self showConnectMessage:@"设备未连接"];
    } else if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
        [self showConnectMessage:@"连接的设备不是听诊器，无录音功能"];
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


//显示录音进度
- (void)actionDeviceHelperRecordingTime:(float)number{
    //self.labelRecordMessage.text = @"";
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.readyRecordView.recordTime = number;
        wself.readyRecordView.progress = number / self.recordDurationAll;
    }];
    
}
//暂停录音事件处理
- (void)actionDeviceHelperRecordPause{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.readyRecordView.stop = YES;
        [wself showRecordMessage:@"按听诊器录音键开始录音"];
    }];
    
}
//开始录音事件处理
- (void)actionDeviceHelperRecordBegin{
    [self showRecordMessage:@""];
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.readyRecordView.recordCode = self.recordCode;
    }];
}
//准备录音显示
- (void)actionDeviceHelperRecordReady{
    [self showRecordMessage:@"按听诊器录音键开始录音"];
}
//重新录音显示
- (void)actionDeviceHelperRecordResume{
    [self showRecordMessage:@""];
}
- (void)actionDeviceConnecting{
    [self showConnectMessage:@"设备正在连接"];
}

- (void)actionDeviceConnectFailed{
    [self showConnectMessage:@"设备连接失败"];
}

- (void)actionDeviceRecordPlayInstable{
    [self showConnectMessage:@"无限数据传输不稳定"];
}

- (void)actionDeviceRecordLostEvent{
    [self showConnectMessage:@"无线信号弱，音频数据丢失"];
}

- (void)actionDeviceConnected{
    if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
        [self showConnectMessage:@"连接的设备不是听诊器，无录音功能"];
    } else {
        [self showConnectMessage:@""];
    }
}

- (void)actionDeviceDisconnected{
    [self showConnectMessage:@"设备已断开连接"] ;
    [self showRecordMessage:@""];
}
//结束录音事件处理
- (void)actionDeviceHelperRecordEnd{
    [self showRecordMessage:@""];
    [self actionStartRecord];
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.readyRecordView.labelReadyRecord.text = @"保存成功，准备下一个录音";
        [wself actionReloadRecordView];
    }];
}

- (void)actionRecordFinish{
    RecordFinishVC *recordFinish = [[RecordFinishVC alloc] init];
    recordFinish.recordCount = self.successCount;
    [self.navigationController pushViewController:recordFinish animated:YES];
}

//开始录音
- (void)actionStartRecord{
    if (self.recordingState != recordingState_ing) {
        [[HHBlueToothManager shareManager] startRecord:self.RECORD_TYPE record_mode:RecordingUntilRecordDuration];
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
    self.recordDataModel.record_mode = QuickRecord;
    self.recordDataModel.type_id = self.soundsType;
    self.recordDataModel.record_filter = self.isFiltrationRecord;
    self.recordDataModel.record_time = [Tools dateToTimeStringYMDHMS:[NSDate now]];
    self.recordDataModel.record_length = self.recordDurationAll;
    
    self.recordDataModel.file_path = self.relativePath;
    
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

//读取本地配置文件
- (void)loadPlistData:(Boolean)firstLoadData{
    NSString *path = [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    self.recordDurationAll = [data[@"record_duration"] integerValue];// 录音总时长
    if (firstLoadData) {
        self.soundsType = [data[@"quick_record_default_type"] integerValue];//快速录音类型
        self.isFiltrationRecord = [data[@"is_filtration_record"] integerValue];//滤波状态
    }
}


- (void)initNavi{
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.buttonBluetooth];
    item1.width = Ratio22;
    self.navigationItem.rightBarButtonItems = @[item1];
}

//显示录音信息
- (void)showRecordMessage:(NSString *)message{
    if ([NSThread isMainThread]) {
        self.labelRecordMessage.text = message;
    } else {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            wself.labelRecordMessage.text = message;
        }];
    }
}


//重新加载录音界面
- (void)actionReloadRecordView{
    self.readyRecordView.recordCode = @"--";//重置录音编号
    self.readyRecordView.startTime = @"00:00";//重置录音开始事件
    self.readyRecordView.progress = 0;//重置录音进度
    self.recordingState = recordingState_prepare;
}
//设置录音时长
- (void)actionConfigRecordDuration {
    [[HHBlueToothManager shareManager] setRecordDuration:(int)self.recordDurationAll];//设置录音时长
    self.readyRecordView.duration = self.recordDurationAll;//录音总时长
}


//打开关闭滤波事件
- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel{
    if (self.recordingState == recordingState_ing || self.recordingState == recordingState_pause) {
        [self.view makeToast:@"录音过程中，不可以改变录音模式" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    self.isFiltrationRecord = filterModel;
    [self loadRecordTypeData];
    [self actionStartRecord];
    return YES;
}


//显示设备信息
- (void)showConnectMessage:(NSString *)message{
    if ([NSThread isMainThread]) {
        self.labelConnectMessage.text = message;
    } else {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            wself.labelConnectMessage.text = message;
        }];
    }
}

//重新刷新录音界面
- (void)actionClickBlueToothToDeviceManager{
    [self actionStop];
    [self actionReloadRecordView];
    self.readyRecordView.labelReadyRecord.text = @"准备录音";
    [self showRecordMessage:@"按听诊器录音键开始录音"];
}

//点击心音肺音按钮事件
- (Boolean)actionHeartLungButtonClickCallback:(NSInteger)idx{

    if (self.recordingState == recordingState_ing || self.recordingState == recordingState_pause) {
        //self.recordingState = recordingState_pause;
        //[[HHBlueToothManager shareManager] stop];
        [self.view makeToast:@"录音过程中，不可以改变录音模式" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    
    if (idx == 1) {
        self.soundsType = heart_sounds;
    } else if (idx == 2) {
        self.soundsType = lung_sounds;
    }
    [self loadRecordTypeData];
    [self actionStartRecord];
    return YES;
}
//显示打开关闭滤波
- (void)realodFilerView{
    if (self.isFiltrationRecord == open_filtration) {
        [self.heartFilterLungView filterGrayString:@"关闭滤波" blueString:@"打开滤波/"];
    } else if (self.isFiltrationRecord == close_filtration) {
        [self.heartFilterLungView filterGrayString:@"打开滤波" blueString:@"/关闭滤波"];
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
    deviceManager.bStandart = NO;
    [self.navigationController pushViewController:deviceManager animated:YES];
}


- (void)initView{

    [self.view addSubview:self.readyRecordView];
    self.readyRecordView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).heightIs(143.f*screenRatio);

    [self.view addSubview:self.viewInfo];
    self.viewInfo.sd_layout.leftSpaceToView(self.view, 0).topSpaceToView(self.readyRecordView, Ratio8).heightIs(140.f*screenRatio).rightSpaceToView(self.view, 0);

    [self.viewInfo addSubview:self.labelRecordMessage];
    [self.viewInfo addSubview:self.heartFilterLungView];
    [self.viewInfo addSubview:self.labelConnectMessage];


    self.labelRecordMessage.sd_layout.leftSpaceToView(self.viewInfo, 0).rightSpaceToView(self.viewInfo, 0).heightIs(Ratio16).topSpaceToView(self.viewInfo, Ratio22);
    self.heartFilterLungView.sd_layout.leftSpaceToView(self.viewInfo, 0).rightSpaceToView(self.viewInfo, 0).topSpaceToView(self.labelRecordMessage, Ratio22).heightIs(Ratio33);

    self.labelConnectMessage.sd_layout.leftSpaceToView(self.viewInfo, 0).rightSpaceToView(self.viewInfo, 0).heightIs(Ratio18).topSpaceToView(self.heartFilterLungView, Ratio11);
}
//根据配置重新显示界面
- (void)reloadView{
    if (self.soundsType == heart_sounds) {//显示心音
        self.heartFilterLungView.buttonHeartVoice .selected = YES;
        self.heartFilterLungView.buttonLungVoice .selected = NO;
        self.heartFilterLungView.buttonHeartVoice.backgroundColor = MainColor;
        self.heartFilterLungView.buttonLungVoice.backgroundColor = ColorDAECFD;
    } else if (self.soundsType == lung_sounds) {//显示肺音
        self.heartFilterLungView.buttonHeartVoice .selected = NO;
        self.heartFilterLungView.buttonLungVoice .selected = YES;
        self.heartFilterLungView.buttonHeartVoice.backgroundColor = ColorDAECFD;
        self.heartFilterLungView.buttonLungVoice.backgroundColor = MainColor;
    }
    //判断滤波状态
    [self realodFilerView];
    
    
}

- (UIView *)viewInfo{
    if(!_viewInfo) {
        _viewInfo = [[UIView alloc] init];
        _viewInfo.backgroundColor = WHITECOLOR;
    }
    return _viewInfo;
}

- (UILabel *)labelRecordMessage{
    if(!_labelRecordMessage) {
        _labelRecordMessage = [[UILabel alloc] init];
        _labelRecordMessage.textAlignment = NSTextAlignmentCenter;
        _labelRecordMessage.font = Font15;
        _labelRecordMessage.textColor = UIColor.redColor;
        _labelRecordMessage.text = @"";
    }
    return _labelRecordMessage;
}

- (UILabel *)labelConnectMessage{
    if(!_labelConnectMessage) {
        _labelConnectMessage = [[UILabel alloc] init];
        _labelConnectMessage.textAlignment = NSTextAlignmentCenter;
        _labelConnectMessage.font = Font15;
        _labelConnectMessage.textColor = UIColor.redColor;
        _labelConnectMessage.text = @"";
        //_labelConnectMessage.hidden = YES;
    }
    return _labelConnectMessage;
}



- (ReadyRecordView *)readyRecordView{
    if(!_readyRecordView) {
        _readyRecordView = [[ReadyRecordView alloc] init];
        _readyRecordView.backgroundColor = WHITECOLOR;
    }
    return _readyRecordView;
}

- (HeartFilterLungView *)heartFilterLungView{
    if (!_heartFilterLungView) {
        _heartFilterLungView = [[HeartFilterLungView alloc] init];
        _heartFilterLungView.delegate = self;
    }
    return _heartFilterLungView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.bLoadedView) {
        
        [self loadPlistData:NO];
        [self loadRecordTypeData];
        [self actionConfigRecordDuration];
        //[self.buttonBluetooth star];
        [self actionStartRecord];
    
    }
    
    self.bLoadedView = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   // [self.buttonBluetooth stop];
}

- (void)actionStop {
    [[HHBlueToothManager shareManager] stop];
}

//禁止华东返回
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


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     [[HHBlueToothManager shareManager] stop];
    self.recordingState = recordingState_stop;
}

- (HHBluetoothButton *)buttonBluetooth{
    if(!_buttonBluetooth) {
        _buttonBluetooth  = [[HHBluetoothButton alloc] init];
        _buttonBluetooth.bluetoothButtonDelegate = self;
    }
    return _buttonBluetooth;
}

@end
