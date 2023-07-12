//
//  BaseRecordPlayVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/5.
//

#import "BaseRecordPlayVC.h"

@interface BaseRecordPlayVC ()

@property (assign, nonatomic) Boolean               bAddRecordData;
@property (retain, nonatomic) HHBluetoothButton              *buttonBluetooth;

@end

@implementation BaseRecordPlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionRecieveBluetoothMessage:) name:HHBluetoothMessage object:nil];
}

- (void)actionEventMain:(DEVICE_HELPER_EVENT)event args1:(NSObject *)args1{

    //NSObject *args2 = userInfo[@"args2"];
    
    if (event == DeviceHelperPlayBegin) {
        self.bPlaying = YES;
        [self actionDeviceHelperPlayBegin];
        //self.viewLine.hidden = NO;
    } else if (event == DeviceHelperPlayingTime) {
        __weak typeof(self) wself = self;
        NSNumber *number = (NSNumber *)args1;
        float value = [number floatValue];
        [wself actionDeviceHelperPlayingTime:value];
        NSLog(@"startTime 播放进度：%f", value);
        
    } else if (event == DeviceHelperPlayEnd) {
        NSLog(@"播放结束");
        [self stopPlayRecord];
    }
}


//接收蓝牙底层消息
- (void)actionRecieveBluetoothMessage:(NSNotification *)notification{
    if (!self.bCurrentView) {
        return;
    }
    NSDictionary *userInfo = notification.userInfo;
    DEVICE_HELPER_EVENT event = [userInfo[@"event"] integerValue];
    NSObject *args1 = userInfo[@"args1"];
    if ([NSThread isMainThread]) {
        [self actionEventMain:event args1:args1];
    } else {
        __weak typeof(self) wself = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [wself actionEventMain:event args1:args1];
        });
    }
}

- (void)actionDeviceHelperPlayBegin{
    
}

- (void)actionDeviceHelperPlayingTime:(float)value{
    
}

- (void)actionDeviceHelperPlayEnd{
    
}






- (void)stopPlayRecord{
    if(self.bPlaying) {
        [self actionDeviceHelperPlayEnd];
        self.bPlaying = NO;
        [[HHBlueToothManager shareManager] stop];
    }
    
}

- (void)actionToStar:(float)startTime endTime:(float)endTime{
    NSString *path = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
    NSString *filePath = [NSString stringWithFormat:@"%@audio/%@", path,self.recordModel.tag];
    NSLog(@"filePath = %@", filePath);
    if ([HHFileLocationHelper fileExistsAtPath:filePath]) {
        [self startPlayRecordVoice:filePath startTime:startTime endTime:endTime];
    } else {
        //如果本地没有缓存文件，先下载，后播放缓存文件
        [AFNetRequestManager downLoadFileWithUrl:self.recordModel.url path:filePath downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            
        } successBlock:^(NSURL * _Nonnull url) {
            //播放下载后的文件
            [self startPlayRecordVoice:url.path startTime:startTime endTime:endTime];
        } fileDownloadFail:^(NSError * _Nonnull error) {
            
        }];
    }
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


//播放录音文件
- (void)startPlayRecordVoice:(NSString *)filePath startTime:(float)startTime endTime:(float)endTime{
    if (!self.bAddRecordData) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSLog(@"data.length = %li", data.length);
        [[HHBlueToothManager shareManager] setPlayFile:data];
        self.bAddRecordData = YES;
    }
    //[UIImage imageWithContentsOfFile:<#(nonnull NSString *)#>]
    NSLog(@"startTime = %f, endTime = %f", startTime, endTime);
    if (startTime == 0 && endTime == 0) {
        [[HHBlueToothManager shareManager] setPlayTimeRange:0 end_time:self.recordModel.record_length];
    } else {
        [[HHBlueToothManager shareManager] setPlayTimeRange:startTime end_time:endTime];
    }
    [[HHBlueToothManager shareManager] startPlay:PlayingWithSettingData];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item0.width = Ratio11;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.buttonBluetooth];
    
    self.navigationItem.rightBarButtonItems = @[item0,item1];
    [self.buttonBluetooth star];
    self.bCurrentView = YES;
    
//    if(!self.bPlaying) {
//        
//        [[HHBlueToothManager shareManager] st];
//    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.bCurrentView = NO;
    [self.buttonBluetooth stop];
    
    [self stopPlayRecord];
}




- (HHBluetoothButton *)buttonBluetooth{
    if(!_buttonBluetooth) {
        _buttonBluetooth  = [[HHBluetoothButton alloc] init];
        //_buttonBluetooth.bluetoothButtonDelegate = self;
    }
    return _buttonBluetooth;
}

//- (void)actionClickBlueToothCallBack:(nonnull UIButton *)button {
//    
//}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
