//
//  AnnotationVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/27.
//

#import "AnnotationVC.h"
#import "RegisterItemView.h"
#import "RightDirectionView.h"
#import "Constant.h"
#import "ItemAgeView.h"
#import "KSYAudioPlotView.h"
#import "KSYAudioFile.h"
#import "WaveSmallView.h"
#import "AnnotationFullVC.h"
#import "DeviceManagerVC.h"
#import "HHNavigationController.h"


@interface AnnotationVC ()<UITextFieldDelegate>

@property (retain, nonatomic) UIScrollView                  *scrollView;

@property (assign, nonatomic) CGFloat                       itemHeight;

@property (retain, nonatomic) RegisterItemView              *itemPatientId;//患者ID
@property (retain, nonatomic) RightDirectionView            *itemHeartHungVoice;//音频类别
@property (retain, nonatomic) RightDirectionView            *itempPositionTag;//听诊位置
@property (retain, nonatomic) RegisterItemView              *itemPatientSymptom;//患者病症
@property (retain, nonatomic) RegisterItemView              *itemPatientDiagnosis;//诊断
@property (retain, nonatomic) RightDirectionView            *itemPatientSex;//性别
@property (retain, nonatomic) ItemAgeView                   *itemPatientAge;//年龄
@property (retain, nonatomic) RegisterItemView              *itemPatientHeight;//患者身高
@property (retain, nonatomic) RegisterItemView              *itemPatientWeight;//患者体重
@property (retain, nonatomic) RightDirectionView            *itemPatientArea;//患者地区
@property (retain, nonatomic) RegisterItemView              *itemPatientAnnotation;//标注

@property (retain, nonatomic) WaveSmallView                 *viewSmallWave;
@property (retain, nonatomic) KSYAudioPlotView              *audioPlotView;
@property (nonatomic, strong) KSYAudioFile                  *audioFile;

@property (retain, nonatomic) UIButton                      *buttonPlay;
@property (retain, nonatomic) UIButton                      *buttonToAnnotation;
@property (retain, nonatomic) UIView                        *viewLine;
@property (assign, nonatomic) Boolean                       bPlaying;
@property (assign, nonatomic) CGFloat                       startYLine;
@property (assign, nonatomic) Boolean                       bCurrentView;//是否在当前页面


@end

@implementation AnnotationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"标注";
    self.view.backgroundColor = WHITECOLOR;
    self.itemHeight = Ratio33;
    [self setupView];
    //播放事件广播，用于显示播放进度
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
        self.viewLine.hidden = NO;
    } else if (event == DeviceHelperPlayingTime) {
        __weak typeof(self) wself = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSNumber *number = (NSNumber *)args1;
            float value = [number floatValue];
            ///cell.playProgess = value;
            //wself.viewSmallWave.playProgess = value;
            [wself playLineAnimation:value];
            NSLog(@"播放进度：%f", value);
        });
        
        
    } else if (event == DeviceHelperPlayEnd) {
        NSLog(@"播放结束");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self stopPlayRecord];
        });
        
    }
}

- (void)playLineAnimation:(float)value{
    CGFloat width = value / self.recordModel.record_length * (screenW - Ratio22);
    
    //[UIView animateWithDuration:0.2 animations:^{
        self.viewLine.frame = CGRectMake(Ratio11+width, self.startYLine, Ratio1, Ratio150);
    //}];
}



- (void)actionClickBlueTooth:(UIButton *)button{
    DeviceManagerVC *deviceManager = [[DeviceManagerVC alloc] init];
    [self.navigationController pushViewController:deviceManager animated:YES];
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
    self.bPlaying = NO;
    self.buttonPlay.selected = NO;
    //[self.viewSmallWave actionStop];
    self.viewLine.frame = CGRectMake(Ratio11, self.startYLine, Ratio0_5, Ratio150);
    self.viewLine.hidden = YES;
    [[HHBlueToothManager shareManager] stop];
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

//播放录音文件
- (void)startPlayRecordVoice:(NSString *)filePath{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [[HHBlueToothManager shareManager] setPlayFile:data];
    [[HHBlueToothManager shareManager] startPlay:PlayingWithSettingData];
}

- (void)setupView{
    [self.view addSubview:self.scrollView];
    self.scrollView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).bottomSpaceToView(self.view, 0);
    
    [self.scrollView addSubview:self.itemPatientId];
    self.itemPatientId.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.scrollView, 0).heightIs(self.itemHeight);
    [self.scrollView addSubview:self.itemHeartHungVoice];
    self.itemHeartHungVoice.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientId, 0).heightIs(self.itemHeight);
    [self.scrollView addSubview:self.itempPositionTag];
    self.itempPositionTag.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemHeartHungVoice, 0).heightIs(self.itemHeight);
    
    
    [self.scrollView addSubview:self.itemPatientSymptom];
    [self.scrollView addSubview:self.itemPatientDiagnosis];
    [self.scrollView addSubview:self.itemPatientSex];
    [self.scrollView addSubview:self.itemPatientAge];
    [self.scrollView addSubview:self.itemPatientHeight];
    [self.scrollView addSubview:self.itemPatientWeight];
    [self.scrollView addSubview:self.itemPatientArea];
    [self.scrollView addSubview:self.itemPatientAnnotation];
    
    self.itemPatientSymptom.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itempPositionTag, 0).heightIs(self.itemHeight);
    self.itemPatientDiagnosis.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientSymptom, 0).heightIs(self.itemHeight);
    self.itemPatientSex.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientDiagnosis, 0).heightIs(self.itemHeight);
    self.itemPatientAge.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientSex, 0).heightIs(self.itemHeight);
    self.itemPatientHeight.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientAge, 0).heightIs(self.itemHeight);
    self.itemPatientWeight.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientHeight, 0).heightIs(self.itemHeight);
    self.itemPatientArea.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientWeight, 0).heightIs(self.itemHeight);
    self.itemPatientAnnotation.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientArea, 0).heightIs(self.itemHeight);
    
    [self.scrollView addSubview:self.viewSmallWave];
    [self.scrollView addSubview:self.audioPlotView];
    self.viewSmallWave.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientAnnotation, Ratio22).heightIs(150.f*screenRatio);
    self.audioPlotView.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientAnnotation, Ratio22).heightIs(150.f*screenRatio);
    
    [self.scrollView addSubview:self.buttonPlay];
    self.buttonPlay.sd_layout.centerXEqualToView(self.scrollView).widthIs(Ratio44).heightIs(Ratio44).topSpaceToView(self.viewSmallWave, Ratio5);
    [self.scrollView addSubview:self.buttonToAnnotation];
    self.buttonToAnnotation.sd_layout.centerYEqualToView(self.buttonPlay).heightIs(Ratio20).rightSpaceToView(self.scrollView, Ratio8).widthIs(Ratio77);
    [self.scrollView addSubview:self.viewLine];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat maxY = CGRectGetMaxY(self.buttonPlay.frame);
        self.scrollView.contentSize = CGSizeMake(screenW, maxY + Ratio55);
        self.startYLine = CGRectGetMinY(self.viewSmallWave.frame);
        self.viewLine.frame = CGRectMake(Ratio11, self.startYLine, Ratio0_5, Ratio150);
    });
    //NSString *a = [[NSBundle mainBundle] pathForResource:@"6" ofType:@"wav"];
    [self openFileWithFilePathURL];
    //[self showWaveView:a];
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
    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData, int length) {
        [weakSelf.audioPlotView updateBuffer:waveformData[0] withBufferSize:length];
    }];

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _scrollView;
}


- (RegisterItemView *)itemPatientId{
    if (!_itemPatientId) {
        _itemPatientId = [[RegisterItemView alloc] initWithTitle:@"患者ID" bMust:NO placeholder:@""];
        if(![Tools isBlankString:self.recordModel.patient_id]) {
            _itemPatientId.textFieldInfo.text = self.recordModel.patient_id;
            _itemPatientId.textFieldInfo.enabled = NO;
            
        }
        _itemPatientId.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientId.textFieldInfo.delegate = self;
    }
    return _itemPatientId;
}

- (RightDirectionView *)itemHeartHungVoice{
    if (!_itemHeartHungVoice) {
        _itemHeartHungVoice = [[RightDirectionView alloc] initWithTitle:@"音频类别"];
        if (self.recordModel.type_id == heart_sounds) {
            _itemHeartHungVoice.labelInfo.text = @"心音";
        } else if (self.recordModel.type_id == lung_sounds) {
            _itemHeartHungVoice.labelInfo.text = @"肺音";
        } else {
            _itemHeartHungVoice.labelInfo.text = @"";
        }
    }
    return _itemHeartHungVoice;
}

- (RightDirectionView *)itempPositionTag{
    if (!_itempPositionTag) {
        _itempPositionTag = [[RightDirectionView alloc] initWithTitle:@"听诊位置"];
        if (![Tools isBlankString:self.recordModel.position_tag]) {
            _itempPositionTag.labelInfo.text = [[Constant shareManager] positionTagPositionCn:self.recordModel.position_tag];
            _itempPositionTag.labelInfo.textColor = MainBlack;
        } else {
            _itempPositionTag.labelInfo.text = @"请选择听诊位置";
            _itempPositionTag.labelInfo.textColor = PlaceholderColor;
        }
        
        
    }
    return _itempPositionTag;
}

- (RegisterItemView *)itemPatientSymptom{
    if (!_itemPatientSymptom) {
        _itemPatientSymptom = [[RegisterItemView alloc] initWithTitle:@"患者病症" bMust:NO placeholder:@"请输入患者病症"];
        if (![Tools isBlankString:self.recordModel.patient_symptom]) {
            _itemPatientSymptom.textFieldInfo.text = self.recordModel.patient_symptom;
        }
        _itemPatientSymptom.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientSymptom.textFieldInfo.delegate = self;
    }
    return _itemPatientSymptom;
}

- (RegisterItemView *)itemPatientDiagnosis{
    if (!_itemPatientDiagnosis) {
        _itemPatientDiagnosis = [[RegisterItemView alloc] initWithTitle:@"诊断结果" bMust:NO placeholder:@"请输入诊断结果"];
        if (![Tools isBlankString:self.recordModel.patient_diagnosis]) {
            _itemPatientDiagnosis.textFieldInfo.text = self.recordModel.patient_diagnosis;
        }
        _itemPatientDiagnosis.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientDiagnosis.textFieldInfo.delegate = self;
    }
    return _itemPatientDiagnosis;
}

- (RightDirectionView *)itemPatientSex{
    if (!_itemPatientSex) {
        _itemPatientSex = [[RightDirectionView alloc] initWithTitle:@"性别"];
        _itemPatientSex.labelInfo.text = self.recordModel.patient_sex == woman ? @"女" : @"男";
    }
    return _itemPatientSex;
}

- (ItemAgeView *)itemPatientAge{
    if (!_itemPatientAge) {
        _itemPatientAge = [[ItemAgeView alloc] init];
        if (![Tools isBlankString:self.recordModel.patient_birthday]) {
            NSDictionary *data = [Tools getAgeFromBirthday:self.recordModel.patient_birthday];
            _itemPatientAge.textFieldAge.text = data[@"age"];
            _itemPatientAge.textFieldMonth.text = data[@"month"];
        } else {
            _itemPatientAge.textFieldAge.text = @"0";
            _itemPatientAge.textFieldMonth.text = @"0";
        }
        _itemPatientAge.textFieldAge.returnKeyType = UIReturnKeyDone;
        _itemPatientAge.textFieldAge.delegate = self;
        
        _itemPatientAge.textFieldMonth.returnKeyType = UIReturnKeyDone;
        _itemPatientAge.textFieldMonth.delegate = self;
        
    }
    return _itemPatientAge;
}

- (RegisterItemView *)itemPatientHeight{
    if (!_itemPatientHeight) {
        _itemPatientHeight = [[RegisterItemView alloc] initWithTitle:@"身高" bMust:NO placeholder:@""];
        if (![Tools isBlankString:self.recordModel.patient_height]) {
            _itemPatientHeight.textFieldInfo.enabled = NO;
            _itemPatientHeight.textFieldInfo.text = self.recordModel.patient_height;
        } else {
            _itemPatientHeight.textFieldInfo.placeholder = @"请输入患者的身高(cm)";
        }
        _itemPatientHeight.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientHeight.textFieldInfo.delegate = self;
    }
    return _itemPatientHeight;
}

- (RegisterItemView *)itemPatientWeight{
    if (!_itemPatientWeight) {
        _itemPatientWeight = [[RegisterItemView alloc] initWithTitle:@"体重" bMust:NO placeholder:@""];
        if (![Tools isBlankString:self.recordModel.patient_weight]) {
            _itemPatientWeight.textFieldInfo.enabled = NO;
            _itemPatientWeight.textFieldInfo.text = self.recordModel.patient_weight;
        } else {
            _itemPatientWeight.textFieldInfo.placeholder = @"请输入患者的体重(kg)";
        }
        _itemPatientWeight.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientWeight.textFieldInfo.delegate = self;
    }
    return _itemPatientWeight;
}

- (RightDirectionView *)itemPatientArea{
    if (!_itemPatientArea) {
        _itemPatientArea = [[RightDirectionView alloc] initWithTitle:@"患者地区"];
        if (![Tools isBlankString:self.recordModel.patient_area]) {
            _itemPatientArea.labelInfo.text = self.recordModel.patient_area;
            _itemPatientArea.labelInfo.textColor = MainBlack;
        } else {
            _itemPatientArea.labelInfo.text = @"请选择患者的地区";
            _itemPatientArea.labelInfo.textColor = PlaceholderColor;
        }
    }
    return _itemPatientArea;
}

- (RegisterItemView *)itemPatientAnnotation{
    if (!_itemPatientAnnotation) {
        _itemPatientAnnotation = [[RegisterItemView alloc] initWithTitle:@"标注" bMust:NO placeholder:@""];
        _itemPatientAnnotation.textFieldInfo.enabled = NO;
        if ([Tools isBlankString:self.recordModel.characteristics]) {
            _itemPatientAnnotation.textFieldInfo.text = @"未标注";
        } else {
            NSArray *array = [Tools jsonData2Array:self.recordModel.characteristics];
            NSString *string = @"";
            for (NSDictionary *data in array) {
                //string = [NSString stringWithFormat:@"%@," [data ke]];
                string = [NSString stringWithFormat:@"%@%@,", string , data[@"characteristic"]];
            }
            if (string.length > 0) {
                string = [string substringToIndex:string.length - 1];
            }
            _itemPatientAnnotation.textFieldInfo.text = string;
        }
        _itemPatientAnnotation.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientAnnotation.textFieldInfo.delegate = self;
    }
    return _itemPatientAnnotation;
}

- (WaveSmallView *)viewSmallWave{
    if (!_viewSmallWave) {
        _viewSmallWave = [[WaveSmallView alloc] initWithFrame:CGRectZero recordModel:self.recordModel];
        _viewSmallWave.backgroundColor = MainBlack;
        
    }
    return _viewSmallWave;
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
        _audioPlotView.waveformLayer.lineWidth = Ratio1;
        
    }
    return _audioPlotView;
}

- (UIButton *)buttonPlay{
    if(!_buttonPlay) {
        _buttonPlay = [[UIButton alloc] init];
        [_buttonPlay setImage:[UIImage imageNamed:@"start_play"] forState:UIControlStateNormal];
        [_buttonPlay setImage:[UIImage imageNamed:@"pause_play"] forState:UIControlStateSelected];
        [_buttonPlay addTarget:self action:@selector(actionClickPlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonPlay;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.bCurrentView = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

//切换页面时停止播放
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.bCurrentView = NO;
    [self stopPlayRecord];
}

- (UIButton *)buttonToAnnotation{
    if (!_buttonToAnnotation) {
        _buttonToAnnotation = [[UIButton alloc] init];
        [_buttonToAnnotation setTitle:@"进入标注>>" forState:UIControlStateNormal];
        [_buttonToAnnotation setTitleColor:MainColor forState:UIControlStateNormal];
        _buttonToAnnotation.titleLabel.font = Font12;
        [_buttonToAnnotation addTarget:self action:@selector(actionToAnnotationFull:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonToAnnotation;
}

- (UIView *)viewLine{
    if (!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = WHITECOLOR;
        _viewLine.hidden = YES;
    }
    return _viewLine;
}


- (void)actionToAnnotationFull:(UIButton *)button{
    AnnotationFullVC *annotationFull = [[AnnotationFullVC alloc] init];
    annotationFull.recordModel = self.recordModel;
    [self.navigationController pushViewController:annotationFull animated:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
