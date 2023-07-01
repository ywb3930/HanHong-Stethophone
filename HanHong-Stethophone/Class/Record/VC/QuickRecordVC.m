//
//  QuickRecordVC.m
//  HanHong-Stethophone
//  快速录音界面
//  Created by 袁文斌 on 2023/6/16.
//

#import "QuickRecordVC.h"
#import "ReadyRecordView.h"
#import "HeartFilterLungView.h"
#import "DeviceManagerVC.h"
#import "RecordModel.h"
#import "AboutUsVC.h"

@interface QuickRecordVC ()<UIGestureRecognizerDelegate, AVAudioPlayerDelegate, HHBluetoothButtonDelegate, HHBlueToothManagerDelegate, HeartFilterLungViewDelegate>

@property (retain, nonatomic) HHBluetoothButton     *buttonBluetooth;
@property (retain, nonatomic) UIButton              *buttonCommit;

@property (retain, nonatomic) ReadyRecordView       *readyRecordView;

@property (retain, nonatomic) UIView                *viewInfo;
@property (retain ,nonatomic) UILabel               *labelStartRecord;
@property (retain, nonatomic) HeartFilterLungView   *heartFilterLungView;

@property (retain, nonatomic) UILabel               *labelMessage;

@property (assign, nonatomic) NSInteger             recordDuration;//记录录音时长
@property (assign, nonatomic) NSInteger             recordingState;//录音状态
@property (assign, nonatomic) NSInteger             soundsType;//快速录音类型
@property (assign, nonatomic) NSInteger             isFiltrationRecord;//滤波状态
@property (assign, nonatomic) NSInteger             recordDurationAll;// 录音总时长
@property (assign, nonatomic) NSInteger             RECORD_TYPE;//判断滤波状态
@property (retain, nonatomic) NSString              *recordCode;//录音编号
@property (retain, nonatomic) NSString              *relativePath;
@property (assign, nonatomic) NSInteger             successCount;

@end

@implementation QuickRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = ViewBackGroundColor;
    self.successCount = 0;
    self.title = @"便捷录音";
    [HHBlueToothManager shareManager].delegate = self;
    [self loadPlistData:YES];
    [self initNavi];
    [self loadData];
    [self initView];
    [self reloadView];
    [self actionStart];
}


- (void)loadPlistData:(Boolean)firstLoadData{
    NSString *path = [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    self.recordDurationAll = [data[@"record_duration"] integerValue];// 录音总时长
    if (firstLoadData) {
        self.soundsType =  [data[@"quick_record_default_type"] integerValue];//快速录音类型
        self.isFiltrationRecord = [data[@"is_filtration_record"] integerValue];//滤波状态
    }
}



- (void)on_device_helper_event:(DEVICE_HELPER_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2{
    if (event == DeviceHelperRecordReady) {
        self.recordingState = recordingState_prepare;
        NSLog(@"录音就绪");
    } else if (event != DeviceHelperRecordingData) {
        NSLog(@"DEVICE_HELPER_EVENT = %li", event);
    } else if (event == DeviceHelperRecordBegin) {
        self.recordingState = recordingState_ing;
        self.recordCode = [NSString stringWithFormat:@"%@%@",[Tools getCurrentTimes], [Tools getRamdomString]];
        NSLog(@"录音开始: %@", self.recordCode);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.readyRecordView.recordCode = self.recordCode;
            
        });
    } else if (event == DeviceHelperRecordingTime) {
        self.recordingState = recordingState_ing;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNumber *result = (NSNumber *)args1;
            float number = [result floatValue];
            NSLog(@"...%f",number);
            self.readyRecordView.recordTime = number;
            self.readyRecordView.progress = number / self.recordDurationAll;
            self.labelStartRecord.hidden = YES;
        });
        
    } else if (event == DeviceHelperRecordingData) {
        
    } else if (event == DeviceHelperRecordPause) {
        self.recordingState = recordingState_pause;
        NSLog(@"录音暂停");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.readyRecordView.stop = YES;
            self.labelStartRecord.hidden = NO;
        });
    } else if (event == DeviceHelperRecordEnd) {
        NSLog(@"录音结束");
        self.recordingState = recordingState_stop;
        [self actionStopRecord];
    }
}

- (void)actionStopRecord{
    NSData *data = [[HHBlueToothManager shareManager] getRecordFile];
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"wav"];
    NSString *path = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
    self.relativePath = [NSString stringWithFormat:@"audio/%@.wav", self.recordCode];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", path, self.relativePath];
    //NSLog(@"filepath = %@", filePath);
    Boolean success = [data writeToFile:filePath atomically:YES];
    if (success) {
        NSLog(@"保存成功");
        [self saveSuccess];
    } else {
        NSLog(@"保存失败");
        [self reloadViewRecordView];
    }
}

- (void)reloadViewRecordView{
    self.readyRecordView.recordTime = 0;
    self.readyRecordView.progress = 0;
    self.recordingState = recordingState_prepare;
}

- (void)saveSuccess{
    [[HHBlueToothManager shareManager] stop];
    RecordModel *recordModel = [[RecordModel alloc] init];
    recordModel.user_id = [@(LoginData.id) stringValue];
    recordModel.record_mode = QuickRecord;
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
        self.labelStartRecord.hidden = NO;

        [self reloadViewRecordView];
        self.readyRecordView.labelReadyRecord.text = @"保存成功，准备下一个录音";
        [self actionStart];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"add_record_success" object:nil];
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
    [self actionStart];
    return YES;
}

- (void)actionClickBlueToothCallBack:(UIButton *)button{
    if(self.recordingState == recordingState_ing) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"正在录音，离开需要取消录音" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *go = [UIAlertAction actionWithTitle:@"继续录音" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:go];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消录音" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSInteger time = 0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //[self.buttonBluetooth actionToDeviceManagerVC:self];
                [self reloadViewRecordView];
                self.readyRecordView.labelReadyRecord.text = @"准备录音";
                self.labelStartRecord.hidden = NO;
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
    [self.navigationController pushViewController:deviceManager animated:YES];
}


- (void)loadData{
    if (self.isFiltrationRecord == open_filtration) {
        //判断音类型
        if (self.soundsType == heart_sounds) {
            self.RECORD_TYPE = RECORD_HEART_WITH_BUTTON;
        } else {
            self.RECORD_TYPE = RECORD_LUNG_WITH_BUTTON;
        }
    } else if (self.isFiltrationRecord == close_filtration) {
        self.RECORD_TYPE = RECORD_FULL_WITH_BUTTON;
    }
}

- (void)actionStart{
    [[HHBlueToothManager shareManager] setRecordDuration:(int)self.recordDurationAll];//设置录音时长
    [[HHBlueToothManager shareManager] startRecord:self.RECORD_TYPE record_mode:RecordingUntilRecordDuration];
}

- (Boolean)actionHeartLungButtonClickCallback:(NSInteger)idx{
    if (self.recordingState == recordingState_ing) {
        [self.view makeToast:@"录音过程中，不可以改变录音模式" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    
    if (idx == 1) {
        self.soundsType = heart_sounds;
    } else if (idx == 2) {
        self.soundsType = lung_sounds;
    }
    [self loadData];
    [self actionStart];
    return YES;
}

- (void)initNavi{
    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item0.width = Ratio11;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.buttonBluetooth];
    item1.width = Ratio22;
    
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"] style:UIBarButtonItemStylePlain target:self action:nil];
    
    self.navigationItem.rightBarButtonItems = @[item0,item1,item2];
    
}



- (void)initView{

    [self.view addSubview:self.readyRecordView];
    self.readyRecordView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).heightIs(143.f*screenRatio);

    [self.view addSubview:self.viewInfo];
    self.viewInfo.sd_layout.leftSpaceToView(self.view, 0).topSpaceToView(self.readyRecordView, Ratio8).heightIs(140.f*screenRatio).rightSpaceToView(self.view, 0);

    [self.viewInfo addSubview:self.labelStartRecord];
    [self.viewInfo addSubview:self.heartFilterLungView];
    [self.viewInfo addSubview:self.labelMessage];


    self.labelStartRecord.sd_layout.leftSpaceToView(self.viewInfo, 0).rightSpaceToView(self.viewInfo, 0).autoHeightRatio(0).topSpaceToView(self.viewInfo, Ratio22);
    self.heartFilterLungView.sd_layout.leftSpaceToView(self.viewInfo, 0).rightSpaceToView(self.viewInfo, 0).topSpaceToView(self.labelStartRecord, Ratio22).heightIs(Ratio33);

    self.labelMessage.sd_layout.leftSpaceToView(self.viewInfo, 0).rightSpaceToView(self.viewInfo, 0).heightIs(Ratio18).topSpaceToView(self.heartFilterLungView, Ratio11);
}

- (void)reloadView{
    if (self.soundsType == heart_sounds) {//显示心音
        self.heartFilterLungView.buttonHeartVoice .selected = YES;
        self.heartFilterLungView.buttonLungVoice .selected = NO;
        self.heartFilterLungView.buttonHeartVoice.backgroundColor = MainColor;
        self.heartFilterLungView.buttonLungVoice.backgroundColor = HEXCOLOR(0xDAECFD, 1);
    } else if (self.soundsType == lung_sounds) {//显示肺音
        self.heartFilterLungView.buttonHeartVoice .selected = NO;
        self.heartFilterLungView.buttonLungVoice .selected = YES;
        self.heartFilterLungView.buttonHeartVoice.backgroundColor = HEXCOLOR(0xDAECFD, 1);
        self.heartFilterLungView.buttonLungVoice.backgroundColor = MainColor;
    }
    //判断滤波状态
    [self realodFilerView];

    self.readyRecordView.duration = self.recordDurationAll;//录音总时长
}

- (void)realodFilerView{
    if (self.isFiltrationRecord == open_filtration) {
        [self.heartFilterLungView filterGrayString:@"关闭滤波" blueString:@"打开滤波/"];
    } else if (self.isFiltrationRecord == close_filtration) {
        [self.heartFilterLungView filterGrayString:@"打开滤波" blueString:@"/关闭滤波"];
    }
}


- (UIView *)viewInfo{
    if(!_viewInfo) {
        _viewInfo = [[UIView alloc] init];
        _viewInfo.backgroundColor = WHITECOLOR;
    }
    return _viewInfo;
}

- (UILabel *)labelStartRecord{
    if(!_labelStartRecord) {
        _labelStartRecord = [[UILabel alloc] init];
        _labelStartRecord.textAlignment = NSTextAlignmentCenter;
        _labelStartRecord.font = Font15;
        _labelStartRecord.textColor = UIColor.redColor;
        _labelStartRecord.text = @"按听诊器录音键可开始录音";
    }
    return _labelStartRecord;
}

- (HeartFilterLungView *)heartFilterLungView{
    if (!_heartFilterLungView) {
        _heartFilterLungView = [[HeartFilterLungView alloc] init];
        _heartFilterLungView.delegate = self;
    }
    return _heartFilterLungView;
}

- (UILabel *)labelMessage{
    if(!_labelMessage) {
        _labelMessage = [[UILabel alloc] init];
        _labelMessage.textAlignment = NSTextAlignmentCenter;
        _labelMessage.font = Font15;
        _labelMessage.textColor = UIColor.redColor;
        _labelMessage.text = @"无线信号弱，音频数据丢失";
        _labelMessage.hidden = YES;
    }
    return _labelMessage;
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


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self loadPlistData:NO];
    [self loadData];
    if (self.recordingState == recordingState_prepare || self.recordingState == recordingState_ing) {
        [self actionStart];
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
