//
//  BaseRecordPlayVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/5.
//

#import "BaseRecordPlayVC.h"

@interface BaseRecordPlayVC ()



@end

@implementation BaseRecordPlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionRecieveBluetoothMessage:) name:HHBluetoothMessage object:nil];
}


//接收蓝牙底层消息
- (void)actionRecieveBluetoothMessage:(NSNotification *)notification{
    if (!self.bCurrentView) {
        return;
    }
    NSDictionary *userInfo = notification.userInfo;
    DEVICE_HELPER_EVENT event = [userInfo[@"event"] integerValue];
    NSObject *args1 = userInfo[@"args1"];
    //NSObject *args2 = userInfo[@"args2"];
    
    if (event == DeviceHelperPlayBegin) {
        self.bPlaying = YES;
        [self actionDeviceHelperPlayBegin];
        //self.viewLine.hidden = NO;
    } else if (event == DeviceHelperPlayingTime) {
        __weak typeof(self) wself = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSNumber *number = (NSNumber *)args1;
            float value = [number floatValue];
            [wself actionDeviceHelperPlayingTime:value];
            ///cell.playProgess = value;
            //wself.viewSmallWave.playProgess = value;
            //[wself playLineAnimation:value];
            NSLog(@"播放进度：%f", value);
        });
        
        
    } else if (event == DeviceHelperPlayEnd) {
        NSLog(@"播放结束");
        dispatch_sync(dispatch_get_main_queue(), ^{
           
            [self stopPlayRecord];
        });
        
    }
}

- (void)actionDeviceHelperPlayBegin{
    
}

- (void)actionDeviceHelperPlayingTime:(float)value{
    
}

- (void)actionDeviceHelperPlayEnd{
    
}




- (void)actionClickPlay:(UIButton *)button{
    if(![[HHBlueToothManager shareManager] getConnectState]) {
        [self.view makeToast:@"请先连接设备" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    if (!self.bPlaying) {
        button.selected = YES;
        [self actionToStar];
    } else {
        button.selected = NO;
        [self stopPlayRecord];
    }
}

- (void)stopPlayRecord{
    if(self.bPlaying) {
        [self actionDeviceHelperPlayEnd];
        self.bPlaying = NO;
        [[HHBlueToothManager shareManager] stop];
    }
    
}

- (void)actionToStar{
    NSString *path = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
    NSString *filePath = [NSString stringWithFormat:@"%@audio/%@", path,self.recordModel.tag];
    if ([HHFileLocationHelper fileExistsAtPath:filePath]) {
        [self startPlayRecordVoice:filePath];
    } else {
        //如果本地没有缓存文件，先下载，后播放缓存文件
        [AFNetRequestManager downLoadFileWithUrl:self.recordModel.url path:filePath downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            
        } successBlock:^(NSURL * _Nonnull url) {
            //播放下载后的文件
            [self startPlayRecordVoice:url.path];
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
- (void)startPlayRecordVoice:(NSString *)filePath{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [[HHBlueToothManager shareManager] setPlayFile:data];
    [[HHBlueToothManager shareManager] startPlay:PlayingWithSettingData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.bCurrentView = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.bCurrentView = NO;
    [self stopPlayRecord];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
