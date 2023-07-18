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

@interface QuickRecordVC ()<HeartFilterLungViewDelegate, UINavigationControllerBackButtonHandlerProtocol>


@property (retain, nonatomic) UIView                *viewInfo;
@property (retain ,nonatomic) UILabel               *labelStartRecord;
@property (retain, nonatomic) ReadyRecordView       *readyRecordView;
@property (retain, nonatomic) UILabel               *labelMessage;
@property (retain, nonatomic) HeartFilterLungView   *heartFilterLungView;
@property (retain, nonatomic) NSOperationQueue      *mainQueue;

@end

@implementation QuickRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = ViewBackGroundColor;
    self.mainQueue = [NSOperationQueue mainQueue];
    self.title = @"便捷录音";
    self.recordType = QuickRecord;
    self.recordmodel = RecordingUntilRecordDuration;
    self.bAutoSaveRecord = YES;
    [self initNavi:1];
    [self loadPlistData:YES];
    [self initView];
    [self reloadView];
    [self loadRecordTypeData];
    
    [self actionConfigRecordDuration];
    [self actionStartRecord];
}

- (void)actionRecordFinish{
    RecordFinishVC *recordFinish = [[RecordFinishVC alloc] init];
    recordFinish.recordCount = self.successCount;
    [self.navigationController pushViewController:recordFinish animated:YES];
}

//重新加载录音界面
- (void)reloadViewRecordView{
    //self.readyRecordView.recordTime = 0;
    self.readyRecordView.progress = 0;
    self.recordingState = recordingState_prepare;
}

- (void)actionConfigRecordDuration {
    [super actionConfigRecordDuration];
    self.readyRecordView.duration = self.recordDurationAll;//录音总时长
}


//显示录音进度
- (void)actionDeviceHelperRecordingTime:(float)number{
    //self.labelStartRecord.text = @"";
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.readyRecordView.recordTime = number;
        wself.readyRecordView.progress = number / self.recordDurationAll;
    }];
    
}

- (void)actionDeviceHelperRecordPause{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.readyRecordView.stop = YES;
        [wself showLabelStartRecordMessage:@"按听诊器录音键开始录音"];
    }];
    
}

- (void)actionDeviceHelperRecordBegin{
    [self showLabelStartRecordMessage:@""];
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.readyRecordView.recordCode = self.recordCode;
    }];
    
}

- (void)actionDeviceHelperRecordEnd{
    [self showLabelStartRecordMessage:@""];
    
    if ([NSThread isMainThread]) {
        [self showViewInMainDeviceHelperRecordEnd];
    } else {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            [wself showViewInMainDeviceHelperRecordEnd];
        }];
    }
}

- (void)showViewInMainDeviceHelperRecordEnd {
    self.readyRecordView.labelReadyRecord.text = @"保存成功，准备下一个录音";
    self.readyRecordView.recordCode = @"--";
    self.readyRecordView.startTime = @"00:00";
    [self reloadViewRecordView];
}

- (void)showLabelStartRecordMessage:(NSString *)message{
    if ([NSThread isMainThread]) {
        self.labelStartRecord.text = message;
    } else {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            wself.labelStartRecord.text = message;
        }];
    }
}

- (void)actionDeviceHelperRecordReady{
    [self showLabelStartRecordMessage:@"按听诊器录音键开始录音"];
}

- (void)actionDeviceHelperRecordResume{
    [self showLabelStartRecordMessage:@""];
}

- (void)actionDeviceConnecting{
    [self showLabelStartRecordMessage:@"设备正在连接"];
}

- (void)actionDeviceConnectFailed{
    [self showLabelStartRecordMessage:@"设备连接失败"];
}

- (void)actionDeviceRecordPlayInstable{
    [self showLabelStartRecordMessage:@"无限数据传输不稳定"];
}

- (void)actionDeviceRecordLostEvent{
    [self showLabelStartRecordMessage:@"无线信号弱，音频数据丢失"];
}

- (void)actionDeviceConnected{
    if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
        [self showLabelStartRecordMessage:@"连接的设备不是听诊器，无录音功能"];
    }
}

- (void)actionDeviceDisconnected{
    [self showLabelStartRecordMessage:@"设备已断开"] ;
}

- (void)actionCancelClickBluetooth{

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

- (void)realodFilerView{
    if (self.isFiltrationRecord == open_filtration) {
        [self.heartFilterLungView filterGrayString:@"关闭滤波" blueString:@"打开滤波/"];
    } else if (self.isFiltrationRecord == close_filtration) {
        [self.heartFilterLungView filterGrayString:@"打开滤波" blueString:@"/关闭滤波"];
    }
}


- (void)initView{

    [self.view addSubview:self.readyRecordView];
    self.readyRecordView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).heightIs(143.f*screenRatio);

    [self.view addSubview:self.viewInfo];
    self.viewInfo.sd_layout.leftSpaceToView(self.view, 0).topSpaceToView(self.readyRecordView, Ratio8).heightIs(140.f*screenRatio).rightSpaceToView(self.view, 0);

    [self.viewInfo addSubview:self.labelStartRecord];
    [self.viewInfo addSubview:self.heartFilterLungView];
    [self.viewInfo addSubview:self.labelMessage];


    self.labelStartRecord.sd_layout.leftSpaceToView(self.viewInfo, 0).rightSpaceToView(self.viewInfo, 0).heightIs(Ratio16).topSpaceToView(self.viewInfo, Ratio22);
    self.heartFilterLungView.sd_layout.leftSpaceToView(self.viewInfo, 0).rightSpaceToView(self.viewInfo, 0).topSpaceToView(self.labelStartRecord, Ratio22).heightIs(Ratio33);

    self.labelMessage.sd_layout.leftSpaceToView(self.viewInfo, 0).rightSpaceToView(self.viewInfo, 0).heightIs(Ratio18).topSpaceToView(self.heartFilterLungView, Ratio11);
}

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
    //[self realodFilerView];
    
    
}

//- (void)realodFilerView{
//    if (self.isFiltrationRecord == open_filtration) {
//        [self.heartFilterLungView filterGrayString:@"关闭滤波" blueString:@"打开滤波/"];
//    } else if (self.isFiltrationRecord == close_filtration) {
//        [self.heartFilterLungView filterGrayString:@"打开滤波" blueString:@"/关闭滤波"];
//    }
//}


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
        _labelStartRecord.text = @"";
    }
    return _labelStartRecord;
}

- (UILabel *)labelMessage{
    if(!_labelMessage) {
        _labelMessage = [[UILabel alloc] init];
        _labelMessage.textAlignment = NSTextAlignmentCenter;
        _labelMessage.font = Font15;
        _labelMessage.textColor = UIColor.redColor;
        _labelMessage.text = @"";
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

- (HeartFilterLungView *)heartFilterLungView{
    if (!_heartFilterLungView) {
        _heartFilterLungView = [[HeartFilterLungView alloc] init];
        _heartFilterLungView.delegate = self;
    }
    return _heartFilterLungView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self actionStartRecord];
}
//
//- (void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    [[HHBlueToothManager shareManager] stop];
//    self.recordingState = recordingState_pause;
//}


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
    //if (self.recordingState == recordingState_prepare || self.recordingState == recordingState_ing) {
        [[HHBlueToothManager shareManager] stop];
    //}
    self.recordingState = recordingState_stop;
}



@end
