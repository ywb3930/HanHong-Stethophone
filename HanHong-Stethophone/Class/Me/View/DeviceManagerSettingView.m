//
//  DeviceManagerSettingView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/19.
//

#import "DeviceManagerSettingView.h"
#import "ItemSwitchCell.h"
#import "UserInfoTwoCell.h"
#import "HHPopEditView.h"
#import "RecordSequenceVC.h"

#import "UserInfoTwoView.h"
#import "ItemSwitchView.h"

@interface DeviceManagerSettingView()<ItemSwitchViewDelegaete,TTActionSheetDelegate, HHPopEditViewDelegate>

@property (retain, nonatomic) NSString          *filePath;

@property (retain, nonatomic) ItemSwitchView                    *viewAutoConnect;//自动连接
@property (retain, nonatomic) UserInfoTwoView                   *viewStethoscopeBtState;//听诊器蓝牙默认状态
@property (retain, nonatomic) UserInfoTwoView                   *viewPowerOnDefaultMode;//开机默认听诊模式
@property (retain, nonatomic) UserInfoTwoView                   *viewPowerOnDefaultVolume;//开机默认音量
@property (retain, nonatomic) UserInfoTwoView                   *viewAutoOffTime;//自动关机时间
@property (retain, nonatomic) UserInfoTwoView                  *viewBatteryVersion;//电池型号设置
@property (retain, nonatomic) UserInfoTwoView                  *viewRecordDefaultType;//录音默认类型
@property (retain, nonatomic) ItemSwitchView                    *viewFiltrationSwitch;//默认滤波
@property (retain, nonatomic) UserInfoTwoView                  *viewRecordDuration;//录音时长
@property (retain, nonatomic) ItemSwitchView                    *viewAuscultationSequence;//录音顺序(听诊顺序)开关
@property (retain, nonatomic) UserInfoTwoView                  *viewNoInfoEnterItem;//录音顺序设置
@property (retain, nonatomic) UserInfoTwoView                  *viewRemoteRecordDuration;//教学/远程听诊时长

@end

@implementation DeviceManagerSettingView

- (void)actionSwitchChangeCallback:(Boolean)value tag:(NSInteger)tag{
    Boolean bRecording =  (self.recordingState == recordingState_ing || self.recordingState == recordingState_pause);
    if (tag == 1) {
        [self.settingData setObject:[@(value) stringValue] forKey:@"auto_connect_echometer"];
    } else if(tag == 3) {
       if (bRecording) {
            [kAppWindow makeToast:@"录音模式进行中，该设置不会马上生效，需要重新进入录音界面" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        }
        if (self.bStandart) {
             [kAppWindow makeToast:@"标准录音模式进行中，该设置不会马上生效，需要重新进入标准录音界面" duration:showToastViewWarmingTime position:CSToastPositionCenter];
         }
        [self.settingData setObject:[@(value) stringValue] forKey:@"auscultation_sequence"];
    } else if (tag == 2) {
        if ( self.recordingState) {
             [kAppWindow makeToast:@"录音模式进行中，该设置不会马上生效，需要重新进入录音界面" duration:showToastViewWarmingTime position:CSToastPositionCenter];
         }
        [self.settingData setObject:[@(value) stringValue] forKey:@"is_filtration_record"];
    }
    [self.settingData writeToFile:self.filePath atomically:YES];
}

- (void)actionClickCommnitCallback:(NSInteger)time tag:(NSInteger)tag{
    NSString *value = @"";
    Boolean saveDictionary = NO;
    if (tag == 1) {
        if(time<1 || time>30000000){
            [kAppWindow makeToast:@"范围值为：0-30000000" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        value = [NSString stringWithFormat:@"%li分钟", time];
        [[HHBlueToothManager shareManager] setAutoOffTime:(int)(time*60)];
        self.viewAutoOffTime.info = value;
        saveDictionary = NO;
    } else if(tag == 2) {
        
        value = [NSString stringWithFormat:@"%li秒", time];
        if (time < record_time_minimum || time > record_time_maximum) {
            NSString *message = [NSString stringWithFormat:@"录音时长为%i-%i秒", record_time_minimum, record_time_maximum];
            [kAppWindow makeToast:message duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        self.viewRecordDuration.info = value;
        [self.settingData setObject:[@(time) stringValue] forKey:@"record_duration"];
        saveDictionary = YES;
    } else if(tag == 3) {
        value = [NSString stringWithFormat:@"%li秒", time];
        if (time < record_time_minimum || time > record_time_maximum) {
            NSString *message = [NSString stringWithFormat:@"录音时长为%i-%i秒", record_time_minimum, record_time_maximum];
            [kAppWindow makeToast:message duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        self.viewRemoteRecordDuration.info = value;
        [self.settingData setObject:[@(time) stringValue] forKey:@"remote_record_duration"];
        saveDictionary = YES;
    }
    //[self.arrayValue replaceObjectAtIndex:tag withObject:value];
    if (saveDictionary) {
        [self.settingData writeToFile:self.filePath atomically:YES];
    }
}

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    Boolean saveDictionary = NO;
    NSString *value =@"";
    if (tag == 1) {
        value = index == 0 ? @"开" : @"关";
     
        self.viewStethoscopeBtState.info = value;
        saveDictionary = NO;
    } else if(tag == 2) {
        NSArray *positionModeSeqArray = [[Constant shareManager] positionModeSeqArray];
        value = [positionModeSeqArray objectAtIndex:index];
        [[HHBlueToothManager shareManager] setModeSeq:(int)(index+1)];
        self.viewPowerOnDefaultMode.info = value;
        saveDictionary = NO;
    } else if(tag == 3) {
        NSArray *positionVolumesArray = [[Constant shareManager] positionVolumesArray];
        value = [positionVolumesArray objectAtIndex:index];
        [[HHBlueToothManager shareManager] setDefaultVolume:(int)(index + 1)];
        self.viewPowerOnDefaultVolume.info = value;
        saveDictionary = NO;
    } else if(tag == 4) {
        value = (index == 0) ? @"干电池" : @"充电电池";
        NSInteger result = (index == 1) ? 0 : 1;
        [self.settingData setObject:[@(result) stringValue] forKey:@"battery_version"];
        self.viewBatteryVersion.info = value;
        saveDictionary = YES;
    } else if(tag == 5) {
        value = (index == 0) ? @"心音" : @"肺音";
        saveDictionary = YES;
        [self.settingData setObject:[@(index + 1) stringValue] forKey:@"quick_record_default_type"];
        self.viewRecordDefaultType.info = value;
    }
   // [self.arrayValue replaceObjectAtIndex:tag withObject:value];
    if(saveDictionary) {
        [self.settingData writeToFile:self.filePath atomically:YES];
    }
    
}


- (NSString *)getNumberFromStr:(NSString *)str{
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return[[str componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = WHITECOLOR;
        self.filePath =  [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
        self.settingData = [NSMutableDictionary dictionary];
        [self setupView];
        [self reloadView];
    }
    return self;
}

- (void)reloadView{
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:self.filePath];
    
    [self.settingData addEntriesFromDictionary:data];
    
    NSString *deviceMode = [[HHBlueToothManager shareManager] getModelName];//获取设备信息
    NSInteger powerOnDefaultMode = [[HHBlueToothManager shareManager] getModeSeq];//开机默认模式
    NSInteger powerOnDefaultVolume = [[HHBlueToothManager shareManager] getDefaultVolume];//开机默认音量
    NSString *powerOnDefaultVolumeString = [[Constant shareManager] positionVolumesString:powerOnDefaultVolume - 1];
    NSInteger getAutoOffTime = [[HHBlueToothManager shareManager] getAutoOffTime];//自动关机时间
    NSString *getAutoOffTimeString = [NSString stringWithFormat:@"%li分钟", getAutoOffTime/60];
    NSString  *autoConnectString = self.settingData[@"auto_connect_echometer"];//自动连接
    NSString *recordDurationString = [NSString stringWithFormat:@"%@秒", self.settingData[@"record_duration"]];//录音时长
    NSString *remoteRecordDuration = [NSString stringWithFormat:@"%@秒", self.settingData[@"remote_record_duration"]];//远程录音时长
    NSString *auscultationSequenceString = self.settingData[@"auscultation_sequence"];//录音顺序开关
    NSInteger batteryVersion = [self.settingData[@"battery_version"] integerValue];//电池型号
    NSString *batteryVersionString = @"";
    if (batteryVersion == dry_battery) {
        batteryVersionString = @"干电池";
    } if (batteryVersion == charge_battery) {
        batteryVersionString = @"充电电池";
    }
    Boolean stehoscopeBtState = [[HHBlueToothManager shareManager] getAdvStartState];//听诊器蓝牙默认状态
    NSString *stehoscopeBtStateString = stehoscopeBtState ? @"开" : @"关";
    NSInteger filtration = [self.settingData[@"is_filtration_record"] integerValue];//滤波状态
    Boolean bOpenFiltration = filtration == open_filtration ? YES : NO;
    NSString *openFiltrationString = [@(bOpenFiltration) stringValue];
    NSInteger quickRecordDefaultType = [self.settingData[@"quick_record_default_type"] integerValue];//快速录音默认类型
    NSString *quickRecordDefaultTypeString = @"";
    if (quickRecordDefaultType == heart_sounds) {
        quickRecordDefaultTypeString = @"心音";
    } else if (quickRecordDefaultType == lung_sounds) {
        quickRecordDefaultTypeString = @"肺音";
    }
   
    NSString *powerOnDefaultModelString = @"";
    if (powerOnDefaultMode == Heart_filter_mode) {
        powerOnDefaultModelString = @"心音过滤模式";
    } else if(powerOnDefaultMode == Lung_filter_mode) {
        powerOnDefaultModelString = @"肺音过滤模式";
    } else if(powerOnDefaultMode == Heart_Lung_filter_mode) {
        powerOnDefaultModelString = @"心肺音过滤模式";
    }
    if ([deviceMode isEqualToString:POPULAR3_btName]) {
        NSString *deviceFirmwareVersion = [[HHBlueToothManager shareManager] getFirmwareVersion];
        NSString *newFirmwareVersion = @"Vx.1.2";
        CGFloat height = 0;
        
        self.viewAutoOffTime.hidden = NO;
        self.viewAutoConnect.hidden = NO;
        self.viewStethoscopeBtState.hidden = NO;
        self.viewPowerOnDefaultMode.hidden = NO;
        self.viewPowerOnDefaultVolume.hidden = NO;
        self.viewBatteryVersion.hidden = NO;
        self.viewRecordDefaultType.hidden = NO;
        self.viewFiltrationSwitch.hidden = NO;
        self.viewRecordDuration.hidden = NO;
        self.viewAuscultationSequence.hidden = NO;
        self.viewNoInfoEnterItem.hidden = NO;
        self.viewRemoteRecordDuration.hidden = NO;
        
        if ([self checkDeviceVersion:deviceFirmwareVersion newFirmwareVersion:newFirmwareVersion]){
            self.viewPowerOnDefaultMode.hidden = YES;
            self.viewFiltrationSwitch.hidden = YES;
            self.viewPowerOnDefaultMode.sd_layout.heightIs(0);
            self.viewFiltrationSwitch.sd_layout.heightIs(0);
            [self.viewPowerOnDefaultMode updateLayout];
            [self.viewFiltrationSwitch updateLayout];
            NSInteger teaching_role = [[NSUserDefaults standardUserDefaults] integerForKey:@"teach_role"];
            if (teaching_role != Student_role) {
                self.viewRemoteRecordDuration.height = YES;
                self.viewRemoteRecordDuration.sd_layout.heightIs(0);
                [self.viewRemoteRecordDuration updateLayout];
                height = Ratio50 * 9;
            } else {
                height = Ratio50 * 10;
                self.viewRemoteRecordDuration.sd_layout.heightIs(50);
                [self.viewRemoteRecordDuration updateLayout];
            }
        } else {
            self.viewPowerOnDefaultMode.sd_layout.heightIs(Ratio50);
            self.viewFiltrationSwitch.sd_layout.heightIs(Ratio50);
            [self.viewPowerOnDefaultMode updateLayout];
            [self.viewFiltrationSwitch updateLayout];
        }
        height = Ratio50 * 12;
        self.viewAutoConnect.value = autoConnectString;
        self.viewStethoscopeBtState.info = stehoscopeBtStateString;
        self.viewPowerOnDefaultMode.info = powerOnDefaultModelString;
        self.viewPowerOnDefaultVolume.info = powerOnDefaultVolumeString;
        self.viewAutoOffTime.info = getAutoOffTimeString;
        self.viewBatteryVersion.info = batteryVersionString;
        
        self.viewRecordDefaultType.info = quickRecordDefaultTypeString;
        self.viewFiltrationSwitch.value = openFiltrationString;
        self.viewRecordDuration.info = recordDurationString;
        
        self.viewAuscultationSequence.value = auscultationSequenceString;
        self.viewNoInfoEnterItem.info = @"";
        self.viewRemoteRecordDuration.info = remoteRecordDuration;
        self.contentSize = CGSizeMake(screenW, height);
        
        self.viewAutoOffTime.sd_layout.topSpaceToView(self.viewPowerOnDefaultVolume, 0);
        [self.viewAutoOffTime updateLayout];
    } else if ([deviceMode isEqualToString:POP3_btName]) {
        self.viewAutoConnect.value = autoConnectString;
        self.viewAutoOffTime.info = getAutoOffTimeString;
        self.viewAutoOffTime.sd_layout.topSpaceToView(self.viewAutoConnect, 0);
        [self.viewAutoOffTime updateLayout];
        self.viewStethoscopeBtState.hidden = YES;
        self.viewPowerOnDefaultMode.hidden = YES;
        self.viewPowerOnDefaultVolume.hidden = YES;
        self.viewBatteryVersion.hidden = YES;
        self.viewRecordDefaultType.hidden = YES;
        self.viewFiltrationSwitch.hidden = YES;
        self.viewRecordDuration.hidden = YES;
        self.viewAuscultationSequence.hidden = YES;
        self.viewNoInfoEnterItem.hidden = YES;
        self.viewRemoteRecordDuration.hidden = YES;
    }
    [self setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (Boolean)checkDeviceVersion:(NSString *)deviceFirmwareVerson newFirmwareVersion:(NSString *)newFirmwareVersion{
    NSArray *deviceFirmwareArray = [deviceFirmwareVerson componentsSeparatedByString:@"."];
    NSString *deviceFirmwareNumberString = [NSString stringWithFormat:@"%@%@", deviceFirmwareArray[1], deviceFirmwareArray[2]];
    NSInteger deviceFirmwareNumber = [deviceFirmwareNumberString integerValue];
    NSArray *newFirmwareArray = [newFirmwareVersion componentsSeparatedByString:@"."];
    NSString *newFirmwareString = [NSString stringWithFormat:@"%@%@", newFirmwareArray[1], newFirmwareArray[2]];
    NSInteger newFirmwareNumber = [newFirmwareString integerValue];
    if(newFirmwareNumber > deviceFirmwareNumber) {
        return YES;
    }
    return NO;
}

- (void)setupView {
    [self addSubview:self.viewAutoConnect];
    [self addSubview:self.viewStethoscopeBtState];
    [self addSubview:self.viewPowerOnDefaultMode];
    [self addSubview:self.viewPowerOnDefaultVolume];
    [self addSubview:self.viewAutoOffTime];
    [self addSubview:self.viewBatteryVersion];
    [self addSubview:self.viewRecordDefaultType];
    [self addSubview:self.viewFiltrationSwitch];
    [self addSubview:self.viewRecordDuration];
    [self addSubview:self.viewAuscultationSequence];
    [self addSubview:self.viewNoInfoEnterItem];
    [self addSubview:self.viewRemoteRecordDuration];
    
    self.viewAutoConnect.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self, 0).heightIs(Ratio50);
    self.viewStethoscopeBtState.sd_layout.leftEqualToView(self.viewAutoConnect).rightEqualToView(self.viewAutoConnect).topSpaceToView(self.viewAutoConnect, 0).heightIs(Ratio50);
    self.viewPowerOnDefaultMode.sd_layout.leftEqualToView(self.viewAutoConnect).rightEqualToView(self.viewAutoConnect).topSpaceToView(self.viewStethoscopeBtState, 0).heightIs(Ratio50);
    self.viewPowerOnDefaultVolume.sd_layout.leftEqualToView(self.viewAutoConnect).rightEqualToView(self.viewAutoConnect).topSpaceToView(self.viewPowerOnDefaultMode, 0).heightIs(Ratio50);
    self.viewAutoOffTime.sd_layout.leftEqualToView(self.viewAutoConnect).rightEqualToView(self.viewAutoConnect).topSpaceToView(self.viewPowerOnDefaultVolume, 0).heightIs(Ratio50);
    self.viewBatteryVersion.sd_layout.leftEqualToView(self.viewAutoConnect).rightEqualToView(self.viewAutoConnect).topSpaceToView(self.viewAutoOffTime, 0).heightIs(Ratio50);
    self.viewRecordDefaultType.sd_layout.leftEqualToView(self.viewAutoConnect).rightEqualToView(self.viewAutoConnect).topSpaceToView(self.viewBatteryVersion, 0).heightIs(Ratio50);
    self.viewFiltrationSwitch.sd_layout.leftEqualToView(self.viewAutoConnect).rightEqualToView(self.viewAutoConnect).topSpaceToView(self.viewRecordDefaultType, 0).heightIs(Ratio50);
    self.viewRecordDuration.sd_layout.leftEqualToView(self.viewAutoConnect).rightEqualToView(self.viewAutoConnect).topSpaceToView(self.viewFiltrationSwitch, 0).heightIs(Ratio50);
    self.viewAuscultationSequence.sd_layout.leftEqualToView(self.viewAutoConnect).rightEqualToView(self.viewAutoConnect).topSpaceToView(self.viewRecordDuration, 0).heightIs(Ratio50);
    self.viewNoInfoEnterItem.sd_layout.leftEqualToView(self.viewAutoConnect).rightEqualToView(self.viewAutoConnect).topSpaceToView(self.viewAuscultationSequence, 0).heightIs(Ratio50);
    self.viewRemoteRecordDuration.sd_layout.leftEqualToView(self.viewAutoConnect).rightEqualToView(self.viewAutoConnect).topSpaceToView(self.viewNoInfoEnterItem, 0).heightIs(Ratio50);
}


- (ItemSwitchView *)viewAutoConnect{
    if (!_viewAutoConnect) {
        _viewAutoConnect = [[ItemSwitchView alloc] initWithFrame:CGRectZero title:@"APP自动连接听诊器"];
        _viewAutoConnect.tag = 1;
        _viewAutoConnect.delegate = self;
    }
    return _viewAutoConnect;
}

- (UserInfoTwoView *)viewStethoscopeBtState{
    if (!_viewStethoscopeBtState) {
        _viewStethoscopeBtState = [[UserInfoTwoView alloc] initWithFrame:CGRectZero title:@"听诊器蓝牙默认状态"];
        __weak typeof(self) wself = self;
        _viewStethoscopeBtState.tapBlock = ^{
            TTActionSheet *sheet = [TTActionSheet showActionSheet:@[@"开", @"关"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
            sheet.tag = 1;
            sheet.delegate = wself;
            [sheet showInView:kAppWindow];
        };
    }
    return _viewStethoscopeBtState;
}

- (UserInfoTwoView *)viewPowerOnDefaultMode{
    if (!_viewPowerOnDefaultMode) {
        _viewPowerOnDefaultMode = [[UserInfoTwoView alloc] initWithFrame:CGRectZero title:@"听诊器开机默认模式"];
        __weak typeof(self) wself = self;
        _viewPowerOnDefaultMode.tapBlock = ^{
            TTActionSheet *sheet = [TTActionSheet showActionSheet:[[Constant shareManager] positionModeSeqArray] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
            sheet.tag = 2;
            sheet.delegate = wself;
            [sheet showInView:kAppWindow];
        };
    }
    return _viewPowerOnDefaultMode;
}

- (UserInfoTwoView *)viewPowerOnDefaultVolume{
    if (!_viewPowerOnDefaultVolume) {
        _viewPowerOnDefaultVolume = [[UserInfoTwoView alloc] initWithFrame:CGRectZero title:@"听诊器开机默认音量"];
        __weak typeof(self) wself = self;
        _viewPowerOnDefaultVolume.tapBlock = ^{
            TTActionSheet *sheet = [TTActionSheet showActionSheet:[[Constant shareManager] positionVolumesArray] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
            sheet.tag = 3;
            sheet.delegate = wself;
            [sheet showInView:kAppWindow];
        };
    }
    return _viewPowerOnDefaultVolume;
}

- (UserInfoTwoView *)viewAutoOffTime{
    if (!_viewAutoOffTime) {
        _viewAutoOffTime = [[UserInfoTwoView alloc] initWithFrame:CGRectZero title:@"听诊器自动关机"];
        __weak typeof(self) wself = self;
        _viewAutoOffTime.tapBlock = ^{
            HHPopEditView *editView = [[HHPopEditView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
            editView.unit = @"分钟";
            editView.delegate = wself;
            editView.tag = 1;
            editView.defaultNumber = [wself getNumberFromStr:wself.viewAutoOffTime.info];
            [kAppWindow addSubview:editView];
        };
    }
    return _viewAutoOffTime;
}

- (UserInfoTwoView *)viewBatteryVersion{
    if (!_viewBatteryVersion) {
        _viewBatteryVersion = [[UserInfoTwoView alloc] initWithFrame:CGRectZero title:@"电池型号设置"];
        __weak typeof(self) wself = self;
        _viewBatteryVersion.tapBlock = ^{
            TTActionSheet *sheet = [TTActionSheet showActionSheet:@[@"干电池", @"充电电池"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
            sheet.tag = 4;
            sheet.delegate = wself;
            [sheet showInView:kAppWindow];
        };
    }
    return _viewBatteryVersion;
}

- (UserInfoTwoView *)viewRecordDefaultType{
    if (!_viewRecordDefaultType) {
        _viewRecordDefaultType = [[UserInfoTwoView alloc] initWithFrame:CGRectZero title:@"录音默认类型"];
        __weak typeof(self) wself = self;
        _viewRecordDefaultType.tapBlock = ^{
            TTActionSheet *sheet = [TTActionSheet showActionSheet:@[@"心音", @"肺音"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
            sheet.tag = 5;
            sheet.delegate = wself;
            [sheet showInView:kAppWindow];
        };
    }
    return _viewRecordDefaultType;
}

- (ItemSwitchView *)viewFiltrationSwitch{
    if (!_viewFiltrationSwitch) {
        _viewFiltrationSwitch = [[ItemSwitchView alloc] initWithFrame:CGRectZero title:@"默认滤波"];
        _viewFiltrationSwitch.tag = 2;
        _viewFiltrationSwitch.delegate = self;
    }
    return _viewFiltrationSwitch;
}

- (UserInfoTwoView *)viewRecordDuration{
    if (!_viewRecordDuration) {
        _viewRecordDuration = [[UserInfoTwoView alloc] initWithFrame:CGRectZero title:@"录音时长"];
        __weak typeof(self) wself = self;
        _viewRecordDuration.tapBlock = ^{
            if (wself.recordingState == recordingState_ing || wself.recordingState == recordingState_pause) {
                [kAppWindow makeToast:@"正在录音中，不可以修改" duration:showToastViewWarmingTime position:CSToastPositionCenter];
                return;
            }
            HHPopEditView *editView = [[HHPopEditView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
            editView.unit = @"秒";
            editView.tag = 2;
            editView.delegate = wself;
            editView.defaultNumber = [wself getNumberFromStr:wself.viewRecordDuration.info];
            [kAppWindow addSubview:editView];
        };
    }
    return _viewRecordDuration;
}

- (ItemSwitchView *)viewAuscultationSequence{
    if (!_viewAuscultationSequence) {
        _viewAuscultationSequence = [[ItemSwitchView alloc] initWithFrame:CGRectZero title:@"录音顺序开关"];
        _viewAuscultationSequence.tag = 3;
        _viewAuscultationSequence.delegate = self;
    }
    return _viewAuscultationSequence;
}

- (UserInfoTwoView *)viewNoInfoEnterItem{
    if (!_viewNoInfoEnterItem) {
        _viewNoInfoEnterItem = [[UserInfoTwoView alloc] initWithFrame:CGRectZero title:@"录音顺序设置"];
        __weak typeof(self) wself = self;
        _viewNoInfoEnterItem.tapBlock = ^{
            RecordSequenceVC *recordOrder = [[RecordSequenceVC alloc] init];
            recordOrder.settingData = wself.settingData;
            UIViewController *currentVC = [Tools currentViewController];
            [currentVC.navigationController pushViewController:recordOrder animated:YES];
        };
    }
    return _viewNoInfoEnterItem;
}

- (UserInfoTwoView *)viewRemoteRecordDuration{
    if (!_viewRemoteRecordDuration) {
        _viewRemoteRecordDuration = [[UserInfoTwoView alloc] initWithFrame:CGRectZero title:@"远程会诊录音最大时长"];
        __weak typeof(self) wself = self;
        _viewRemoteRecordDuration.tapBlock = ^{
            HHPopEditView *editView = [[HHPopEditView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
            editView.unit = @"秒";
            editView.tag = 3;
            editView.delegate = wself;
            editView.defaultNumber = [wself getNumberFromStr:wself.viewRemoteRecordDuration.info];
            [kAppWindow addSubview:editView];
        };
    }
    return _viewRemoteRecordDuration;
}


@end
