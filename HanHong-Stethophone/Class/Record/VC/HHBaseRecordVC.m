//
//  HHBaseRecordVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/5.
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
    
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionRecieveBluetoothMessage:) name:HHBluetoothMessage object:nil];
}

//读取本地配置文件
- (void)loadPlistData:(Boolean)firstLoadData{
    NSString *path = [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    
    self.recordDurationAll = [data[@"record_duration"] integerValue];// 录音总时长
    NSLog(@"self.recordDurationAll = %li", self.recordDurationAll);
    if (firstLoadData) {
        self.soundsType =  [data[@"quick_record_default_type"] integerValue];//快速录音类型
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

- (void)actionDeviceHelperRecordEnd{
    
}


//重新加载录音界面
- (void)reloadViewRecordView{
    self.readyRecordView.recordTime = 0;
    self.readyRecordView.progress = 0;
    self.recordingState = recordingState_prepare;
}

//接收蓝牙广播通知
- (void)actionRecieveBluetoothMessage:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    DEVICE_HELPER_EVENT event = [userInfo[@"event"] integerValue];
    NSObject *args1 = userInfo[@"args1"];
    NSObject *args2 = userInfo[@"args2"];
    if (event == DeviceHelperRecordReady) {
        self.recordingState = recordingState_prepare;
        NSLog(@"录音就绪");
        [self actionDeviceHelperRecordReady];
    } else if (event != DeviceHelperRecordingData) {
        NSLog(@"DEVICE_HELPER_EVENT = %li", event);
    }
    //开始录音
    if (event == DeviceHelperRecordBegin) {
        self.recordingState = recordingState_ing;
        self.recordCode = [NSString stringWithFormat:@"%@%@",[Tools getCurrentTimes], [Tools getRamdomString]];
        NSLog(@"录音开始: %@", self.recordCode);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.readyRecordView.recordCode = self.recordCode;
            [self actionDeviceHelperRecordBegin];
        });
    } else if (event == DeviceHelperRecordingTime) {
        //显示录音进度
        self.recordingState = recordingState_ing;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNumber *result = (NSNumber *)args1;
            float number = [result floatValue];
            [self actionDeviceHelperRecordingTime:number];
            NSLog(@"...%f",number);
            self.readyRecordView.recordTime = number;
            self.readyRecordView.progress = number / self.recordDurationAll;
//            self.labelStartRecord.hidden = YES;
        });

    } else if (event == DeviceHelperRecordingData) {

    } else if (event == DeviceHelperRecordPause) {
        
        self.recordingState = recordingState_pause;
        NSLog(@"录音暂停");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.readyRecordView.stop = YES;
            [self actionDeviceHelperRecordPause];
//            self.readyRecordView.stop = YES;
//            self.labelStartRecord.hidden = NO;
        });
    } else if (event == DeviceHelperRecordEnd) {
        NSLog(@"录音结束");
        self.recordingState = recordingState_stop;
        [self actionEndRecord];
    }
}
//录音结束事件处理
- (void)actionEndRecord{
    //获取录音二进制文件
    NSData *data = [[HHBlueToothManager shareManager] getRecordFile];
    //获取录音文件保存路径
    NSString *path = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
    self.relativePath = [NSString stringWithFormat:@"audio/%@.wav", self.recordCode];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", path, self.relativePath];
    //NSLog(@"filepath = %@", filePath);
    //将二进制文件写入目录
    Boolean success = [data writeToFile:filePath atomically:YES];
    if (success) {
        NSLog(@"保存成功");
        //保存成功回调
        [self saveSuccess];
    } else {
        NSLog(@"保存失败");
        //[self reloadViewRecordView];
    }
    
}

//保存成功后写入数据库
- (void)saveSuccess{
    [[HHBlueToothManager shareManager] stop];
    RecordModel *recordModel = [[RecordModel alloc] init];
    recordModel.user_id = [@(LoginData.id) stringValue];
    recordModel.record_mode = self.recordModel;
    recordModel.type_id = self.soundsType;
    recordModel.record_filter = self.isFiltrationRecord;
    recordModel.record_time = [Tools dateToTimeStringYMDHMS:[NSDate now]];
    recordModel.record_length = self.recordDurationAll;
    recordModel.file_path = self.relativePath;
    //NSArray *array = [self.relativePath mutableArrayValueForKey:@"/"];
    recordModel.tag = [NSString stringWithFormat:@"%@.wav", self.recordCode];
    recordModel.modify_time = recordModel.record_time;
    Boolean result = [[HHDBHelper shareInstance] addRecordItem:recordModel];
    if (result) {
        NSLog(@"保存数据库成功");
    } else {
        NSLog(@"保存数据库失败");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.labelStartRecord.hidden = NO;
//
//
        self.readyRecordView.labelReadyRecord.text = @"保存成功，准备下一个录音";
        [self reloadViewRecordView];
        [self actionStartRecord];
        [self actionDeviceHelperRecordEnd];
        [[NSNotificationCenter defaultCenter] postNotificationName:AddLocalRecordSuccess object:nil];
    });
    self.successCount ++;
}

- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel{
    if (self.recordingState == recordingState_ing) {
        [self.view makeToast:@"录音过程中，不可以改变录音模式" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    self.isFiltrationRecord = filterModel;
    [self loadData];
    [self realodFilerView];
    [self actionStartRecord];
    return YES;
}

- (void)realodFilerView{
    
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

//点击蓝牙按钮到蓝牙配置界面
- (void)actionClickBlueToothCallBack:(UIButton *)button{
    if(self.recordingState == recordingState_ing) {
        [Tools showAlertView:@"提示" andMessage:@"正在录音，离开会取消录音" andTitles:@[@"取消录音", @"继续录音"] andColors:@[MainGray, MainColor] sure:^{
            
        } cancel:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadViewRecordView];
                self.readyRecordView.labelReadyRecord.text = @"准备录音";
//                self.labelStartRecord.hidden = NO;
                self.readyRecordView.recordCode = @"--";
                [self actionToDeviceManagerVC];
                [self actionCancelClickBluetooth];
            });
        }];
    } else {
        [self actionToDeviceManagerVC];
    }
}

- (void)actionCancelClickBluetooth{
    
}

- (void)actionToDeviceManagerVC{
    DeviceManagerVC *deviceManager = [[DeviceManagerVC alloc] init];
    deviceManager.recordingState = self.recordingState;
    deviceManager.bStandart = YES;
    [self.navigationController pushViewController:deviceManager animated:YES];
}




- (void)initNavi:(NSInteger)number{
    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item0.width = Ratio11;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.buttonBluetooth];
    item1.width = Ratio22;
    
    if(number == 2) {
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(actionRecordFinish)];
        
        self.navigationItem.rightBarButtonItems = @[item0,item1,item2];
    } else {
        self.navigationItem.rightBarButtonItems = @[item0,item1];
    }
    
}

- (void)actionRecordFinish{
    
}

- (ReadyRecordView *)readyRecordView{
    if(!_readyRecordView) {
        _readyRecordView = [[ReadyRecordView alloc] init];
        _readyRecordView.backgroundColor = WHITECOLOR;
    }
    return _readyRecordView;
}

- (HHBluetoothButton *)buttonBluetooth{
    if(!_buttonBluetooth) {
        _buttonBluetooth  = [[HHBluetoothButton alloc] init];
        _buttonBluetooth.bluetoothButtonDelegate = self;
    }
    return _buttonBluetooth;
}



//开始录音
- (void)actionStartRecord{
    [[HHBlueToothManager shareManager] setRecordDuration:(int)self.recordDurationAll];//设置录音时长
    [[HHBlueToothManager shareManager] startRecord:self.RECORD_TYPE record_mode:RecordingUntilRecordDuration];
}

- (void)reloadView{
    [self realodFilerView];
    NSLog(@"self.recordDurationAll === %li", self.recordDurationAll);
    self.readyRecordView.duration = self.recordDurationAll;//录音总时长
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self loadPlistData:NO];
    [self loadData];
    if (self.recordingState == recordingState_prepare || self.recordingState == recordingState_ing) {
        [self actionStartRecord];
    }
    
    [self reloadView];
    [self.buttonBluetooth star];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.recordingState == recordingState_prepare || self.recordingState == recordingState_ing) {
        [[HHBlueToothManager shareManager] stop];
    }
    [self.buttonBluetooth stop];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.recordingState == recordingState_prepare || self.recordingState == recordingState_ing) {
        [[HHBlueToothManager shareManager] stop];
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}


@end
