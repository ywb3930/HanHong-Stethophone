//
//  HHBaseRecordVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/5.
//

#import "HHBaseRecordVC.h"
#import "DeviceManagerVC.h"

@interface HHBaseRecordVC ()<HHBluetoothButtonDelegate,UIGestureRecognizerDelegate>


@end

@implementation HHBaseRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.successCount = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionRecieveBluetoothMessage:) name:HHBluetoothMessage object:nil];
}


//读取本地配置文件
- (void)loadPlistData:(Boolean)firstLoadData{
    NSString *path = [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    if(self.recordType == RemoteRecord) {
        self.recordDurationAll = [data[@"remote_record_duration"] integerValue];// 录音总时长
    } else {
        self.recordDurationAll = [data[@"record_duration"] integerValue];// 录音总时长
    }
    
    
    if (firstLoadData) {
        self.soundsType = [data[@"quick_record_default_type"] integerValue];//快速录音类型
        self.isFiltrationRecord = [data[@"is_filtration_record"] integerValue];//滤波状态
    }
}

- (void)actionDeviceHelperRecordReady{
    
}

- (void)actionDeviceHelperRecordBegin{
   
}

- (void)actionDeviceHelperRecordingTime:(float)number{
    
}

- (void)actionDeviceHelperRecordPause{
    
}

- (void)actionDeviceHelperRecordResume{
    
}

- (void)actionDeviceHelperRecordEnd{
    
}

- (void)actionDeviceHelperRecordingData:(NSData *)data{
    
}

- (void)actionDeviceConnecting{
    
}

- (void)actionDeviceConnected{
    
}

- (void)actionDeviceConnectFailed{
    
}

- (void)actionDeviceDisconnected{
    
}

- (void)actionDeviceHelperPlayBegin{
    
}

- (void)actionDeviceHelperPlayEnd{
    
}

- (void)actionDeviceRecordPlayInstable{
    
}

- (void)actionDeviceHelperEvent:(DEVICE_HELPER_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2 {
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
        self.recordDuration = (int)number;
        [self actionDeviceHelperRecordingTime:number];
        DLog(@"录音进度: %f",number);

    } else if (event == DeviceHelperRecordingData) {
        if (self.recordType == RemoteRecord) {
            //[[HHBlueToothManager shareManager] writePlayBuffer:(NSData *)args1];
            [self actionDeviceHelperRecordingData:(NSData *)args1];
        }
        //
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
    } else if (event == DeviceHelperPlayBegin) {
        DLog(@"播放开始");
        [self actionDeviceHelperPlayBegin];
    } else if (event == DeviceHelperPlayingTime) {
//        NSNumber *number = (NSNumber *)args1;
//        float value = [number floatValue];
       // [wself actionDeviceHelperPlayingTime:value];
        //DLog(@"startTime 播放进度：%f", value);
        
    } else if (event == DeviceHelperPlayEnd) {
        DLog(@"播放结束");
        [self actionDeviceHelperPlayEnd];
        
    } else if (event == DeviceRecordPlayInstable) {
        [self actionDeviceRecordPlayInstable];
    } else if (event == DeviceRecordLostEvent) {
        [self actionDeviceRecordLostEvent];
    }
}

- (void)actionDeviceRecordLostEvent{
    
}


//接收蓝牙广播通知
- (void)actionRecieveBluetoothMessage:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    DEVICE_HELPER_EVENT event = [userInfo[@"event"] integerValue];
    NSObject *args1 = userInfo[@"args1"];
    NSObject *args2 = userInfo[@"args2"];
    [self actionDeviceHelperEvent:event args1:args1 args2:args2];
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
    self.recordDataModel.record_mode = self.recordType;
    self.recordDataModel.type_id = self.soundsType;
    self.recordDataModel.record_filter = self.isFiltrationRecord;
    self.recordDataModel.record_time = [Tools dateToTimeStringYMDHMS:[NSDate now]];
    if (self.recordType == RecordingUntilRecordDuration) {
        self.recordDataModel.record_length = self.recordDurationAll;
    } else {
        self.recordDataModel.record_length = recordTimeLength;
    }
    
    self.recordDataModel.file_path = self.relativePath;
    if (self.recordType == StanarRecord) {
        DLog(@"self.currentPositon = %@", self.currentPositon);
        self.recordDataModel.position_tag =  self.currentPositon;
    }
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

//- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel{
//    if (self.recordingState == recordingState_ing || self.recordingState == recordingState_pause) {
//        [self.view makeToast:@"录音过程中，不可以改变录音模式" duration:showToastViewWarmingTime position:CSToastPositionCenter];
//        return NO;
//    }
//    self.isFiltrationRecord = filterModel;
//    [self loadRecordTypeData];
//    [self actionStartRecord];
//    return YES;
//}

- (void)actionStop {
    [[HHBlueToothManager shareManager] stop];
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

- (void)actionClickBlueToothToDeviceManager{
    
}

- (void)actionToDeviceManagerVC{
    DeviceManagerVC *deviceManager = [[DeviceManagerVC alloc] init];
    deviceManager.recordingState = self.recordingState;
    deviceManager.bStandart = self.bStandart;
    [self.navigationController pushViewController:deviceManager animated:YES];
}

- (void)initNavi:(NSInteger)number{
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.buttonBluetooth];
    item1.width = Ratio22;

    if(number == 2) {
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(actionRecordFinish)];
        
        self.navigationItem.rightBarButtonItems = @[item1,item2];
    } else {
        self.navigationItem.rightBarButtonItems = @[item1];
    }
    
}

- (void)actionRecordFinish{
    
}

- (HHBluetoothButton *)buttonBluetooth{
    if(!_buttonBluetooth) {
        _buttonBluetooth  = [[HHBluetoothButton alloc] init];
        _buttonBluetooth.bluetoothButtonDelegate = self;
        //_buttonBluetooth.imageEdgeInsets = UIEdgeInsetsMake(-Ratio5, -Ratio5, -Ratio5, -Ratio5);
    }
    return _buttonBluetooth;
}



//开始录音
- (void)actionStartRecord{
    if (self.recordingState != recordingState_ing) {
        [[HHBlueToothManager shareManager] startRecord:self.RECORD_TYPE record_mode:self.recordmodel];
    }
}

- (void)actionConfigRecordDuration {
    [[HHBlueToothManager shareManager] setRecordDuration:(int)self.recordDurationAll];//设置录音时长
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self loadPlistData:NO];
    [self loadRecordTypeData];
    [self actionConfigRecordDuration];
    [self.buttonBluetooth star];
}



- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.buttonBluetooth stop];
}


//- (void)viewDidAppear:(BOOL)animated{
//    self.navigationController.interactivePopGestureRecognizer.delegate = self;
//}
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    return NO;
//}



@end
