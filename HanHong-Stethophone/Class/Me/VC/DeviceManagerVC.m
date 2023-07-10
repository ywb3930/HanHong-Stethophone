//
//  DeviceManagerVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/19.
//

#import "DeviceManagerVC.h"
#import "DeviceDefaultView.h"
#import "BluetoothDeviceModel.h"
#import "DeviceManagerItemCell.h"
#import "DeviceManagerSettingView.h"
//#import "BluetoothHelper.h"
//#import "HanhongDevice.h"
#import "ScanTeachCodeVC.h"
#import "Constant.h"
#import "DeviceMessageVC.h"
#import "GuideVC.h"

#define Heart_filter_mode  1//心音过滤开关
#define Lung_filter_mode  2//肺音过滤开关
#define Heart_Lung_filter_mode  3//心肺音过滤开关


@interface DeviceManagerVC ()<UITableViewDelegate, UITableViewDataSource, ScanTeachCodeVCDelegate>

@property (retain, nonatomic) DeviceDefaultView         *deviceDefaultView;
@property (retain, nonatomic) NSMutableArray            *arrayData;
@property (retain, nonatomic) UITableView               *tableView;
@property (retain, nonatomic) DeviceManagerSettingView  *deviceManagerSettingView;
@property (retain, nonatomic) UILabel                   *labelConnectRemind;
@property (retain, nonatomic) NSMutableDictionary       *settingData;
@property (retain, nonatomic) NSString                  *defaultConnectPath;
@property (retain, nonatomic) BluetoothDeviceModel      *deviceModel;
@property (retain, nonatomic) UILabel                   *labelTableViewTitle;

@property (retain, nonatomic) UIButton                  *buttonGuide;

@end

@implementation DeviceManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.defaultConnectPath = [[Constant shareManager] getPlistFilepathByName:@"connectDevice.plist"];
    self.settingData = [NSMutableDictionary dictionary];
    self.deviceModel = [[BluetoothDeviceModel alloc] init];
    self.title = @"设备管理";
    self.view.backgroundColor = ViewBackGroundColor;
    self.arrayData = [NSMutableArray array];
    [self initNaviView];
    [self initView];
    
    if ([[HHBlueToothManager shareManager] getConnectState] == DEVICE_CONNECTED) {
        self.tableView.hidden = YES;
        [self reloadView];
        self.deviceDefaultView.buttonBluetooth.selected = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionRecieveBluetoothMessage:) name:HHBluetoothMessage object:nil];
}

- (void)actionScanCodeResultCallback:(NSString *)scanCodeResult{
    NSString *deviceName = [[Constant shareManager] checkScanCode:scanCodeResult];
    if ([Tools isBlankString:deviceName]) {
        [self.view makeToast:@"无效二维码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *macStr = [scanCodeResult substringFromIndex:2];
    NSString *mac = [Tools converDataToMacStr:macStr];
    BluetoothDeviceModel *model = [[BluetoothDeviceModel alloc] init];
    model.bluetoothDeviceName = deviceName;
    model.bluetoothDeviceMac = mac;
    model.bluetoothDeviceUUID = macStr;
    self.deviceModel = model;
    [[HHBlueToothManager shareManager] abortSearch];//停止搜索
    self.tableView.hidden = YES;
    self.deviceDefaultView.deviceModel = model;
    if([[HHBlueToothManager shareManager] getConnectState] == DEVICE_CONNECTED) {
        [[HHBlueToothManager shareManager] disconnect];
    }
    [[HHBlueToothManager shareManager] actionConnectToBluetoothMacAddress:model.bluetoothDeviceUUID];
    NSLog(@"bluetoothDeviceUUID 2 = %@", self.deviceModel.bluetoothDeviceUUID);
}

- (void)actionTapDeviceDefault:(UITapGestureRecognizer *)tap{
    if ([[HHBlueToothManager shareManager] getConnectState] == DEVICE_CONNECTED) {
        DEVICE_MODEL deviceModel = [[HHBlueToothManager shareManager] getDeviceType];
        NSString *string1 = @"";
        if (deviceModel == STETHOSCOPE) {
            string1 = @"电子听诊器";
        } else {
            string1 = @"电子听诊耳机";
        }
        NSString *string2 = [NSString stringWithFormat:@"%@", self.deviceModel.bluetoothDeviceName];
        NSString *string3 = [[HHBlueToothManager shareManager] getSerialNumber];
        NSString *firmwareVersion = [[HHBlueToothManager shareManager] getFirmwareVersion];
        NSArray *stringUrlOne = [firmwareVersion componentsSeparatedByString:@"."];
        NSString *string4 = [stringUrlOne objectAtIndex:0];
        NSString *string5 = [NSString stringWithFormat:@"V%@", [[HHBlueToothManager shareManager] getBootloaderVersion]];
        NSString *pd = [[HHBlueToothManager shareManager] getProductionDate];
        NSLog(@"ProductionDate = %@", pd);
        NSString *pd1 = [pd substringWithRange:NSMakeRange(0, 4)];
        NSString *pd2 = [pd substringWithRange:NSMakeRange(4, 2)];
        NSString *pd3 = [pd substringWithRange:NSMakeRange(6, 2)];
        NSString *string6 = [NSString stringWithFormat:@"%@-%@-%@", pd1, pd2, pd3];
        NSString *string7 = @"3年";
        NSString *string8 = @"注册人地址：佛山市顺德区大良新窖居委会兴业路5号C栋3-4楼";
        NSString *string9 = @"广东汉泓医疗科技有限公司";
        NSString *string10 = @"+86-(0757)-22252389";
        NSString *string11 = @"www.hanhongmed.com";
        DeviceMessageVC *deviceMessage = [[DeviceMessageVC alloc] init];
        deviceMessage.arrayData = @[string1, string2, string3, string4, string5, string6, string7, string8, string9, string10, string11];
        [self.navigationController pushViewController:deviceMessage animated:YES];
    } else {
        [self.deviceDefaultView startTimer];
        NSLog(@"bluetoothDeviceUUID 1 = %@", self.deviceModel.bluetoothDeviceUUID);
        [[HHBlueToothManager shareManager] actionConnectToBluetoothMacAddress:self.deviceModel.bluetoothDeviceUUID];
    }
    
}

- (void)actionRecieveBluetoothMessage:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    DEVICE_HELPER_EVENT event = [userInfo[@"event"] integerValue];
    NSObject *args1 = userInfo[@"args1"];
    NSObject *args2 = userInfo[@"args2"];
    if (event == SearchFound) {
        self.labelTableViewTitle.text = @"已发现设备";
        [self onSearchFound:(NSString *)args1 device_mac:(NSString *)args2];
    } else if (event == DeviceConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.hidden = YES;
            [self reloadView];
        });
        
    }
}


- (void)onSearchFound:(NSString *)device_name device_mac:(NSString *)device_mac{
    NSString *mac = [Tools converDataToMacStr:device_mac];
    for (BluetoothDeviceModel *model in self.arrayData) {
        if ([model.bluetoothDeviceUUID isEqualToString:device_mac]) {
            return;
        }
    }
    BluetoothDeviceModel *model = [[BluetoothDeviceModel alloc] init];
    model.bluetoothDeviceName = device_name;
    model.bluetoothDeviceMac = mac;
    model.bluetoothDeviceUUID = device_mac;
    [self.arrayData addObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.arrayData.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)actionToSearch:(UIBarButtonItem *)item{
    if ([[HHBlueToothManager shareManager] getConnectState] == DEVICE_CONNECTED) {
        self.deviceManagerSettingView.hidden = YES;
        self.tableView.hidden = NO;
        self.deviceDefaultView.buttonBluetooth.selected = NO;
        [[HHBlueToothManager shareManager] disconnect];
    }
    
    self.labelTableViewTitle.text = @"搜索设备中...";
    [[HHBlueToothManager shareManager] actionSearchBluetoothList];
}

- (void)reloadView{
    NSString *filePath =  [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    if (!data) {
        [self.settingData setObject:[@(NO) stringValue] forKey:@"auto_connect_echometer"];//自动连接
        [self.settingData setObject:[@(NO) stringValue] forKey:@"auscultation_sequence"];//录音顺序开关
        [self.settingData setObject:@"15" forKey:@"record_duration"];//录音时长
        [self.settingData setObject:@"60" forKey:@"remote_record_duration"];//远程录音时长
        [self.settingData setObject:@"1" forKey:@"battery_version"];//电池信号
        [self.settingData setObject:[@(open_filtration) stringValue] forKey:@"is_filtration_record"];//滤波
        [self.settingData setObject:[@(heart_sounds) stringValue] forKey:@"quick_record_default_type"];//快速录音类型
        [self.settingData writeToFile:filePath atomically:YES];
    } else {
        [self.settingData addEntriesFromDictionary:data];
    }
    [self.deviceDefaultView stopTimer];
    NSString *deviceMode = [[HHBlueToothManager shareManager] getDeviceMessage];//获取设备信息
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
        NSArray *arrayTitle = @[@"自动连接", @"听诊器蓝牙默认状态", @"开机默认模式", @"开机默认音量", @"自动关机", @"电池型号设置", @"默认录音类型", @"默认滤波",@"录音时长", @"录音顺序开关", @"录音顺序设置", @"远程会诊录音最大时长"];
        NSArray *arrayType = @[@"0", @"1", @"1", @"1", @"1", @"1", @"1", @"0", @"1", @"0", @"1", @"1"];
        NSArray *arrayDefault = @[autoConnectString, stehoscopeBtStateString, powerOnDefaultModelString, powerOnDefaultVolumeString, getAutoOffTimeString, batteryVersionString, quickRecordDefaultTypeString, openFiltrationString, recordDurationString,auscultationSequenceString, @"", remoteRecordDuration];
        self.deviceManagerSettingView.arrayType = arrayType;
        self.deviceManagerSettingView.arrayTitle = arrayTitle;
        self.deviceManagerSettingView.arrayValue = [NSMutableArray arrayWithArray:arrayDefault];
        self.deviceManagerSettingView.settingData = self.settingData;
        [self.deviceManagerSettingView reloadData];
    } else if ([deviceMode isEqualToString:POP3_btName]) {
        
    }
    
    self.deviceManagerSettingView.hidden  = NO;
    self.deviceDefaultView.buttonBluetooth.selected = YES;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BluetoothDeviceModel *model = self.arrayData[indexPath.row];
    [[HHBlueToothManager shareManager] actionConnectToBluetoothMacAddress:model.bluetoothDeviceUUID];
    self.deviceModel = model;
    
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:model.bluetoothDeviceName forKey:@"bluetoothDeviceName"];
    [data setObject:model.bluetoothDeviceMac forKey:@"bluetoothDeviceMac"];
    [data setObject:model.bluetoothDeviceUUID forKey:@"bluetoothDeviceUUID"];
    [data writeToFile:self.defaultConnectPath atomically:YES];
    self.deviceDefaultView.hidden = NO;
    self.labelConnectRemind.hidden = YES;
    self.deviceDefaultView.deviceModel = model;
    [self.deviceDefaultView startTimer];
    //[Tools showWithStatus:[NSString stringWithFormat:@"正在连接设备%@", model.bluetoothDeviceName]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceManagerItemCell *itemCell = (DeviceManagerItemCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceManagerItemCell class])];
    BluetoothDeviceModel *model = self.arrayData[indexPath.row];
    itemCell.name = model.bluetoothDeviceName;
    itemCell.mac = model.bluetoothDeviceMac;
    return itemCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 46.f*screenRatio;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Ratio33;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, Ratio33)];
  
    //view.backgroundColor = UIColor.redColor;
    
    [view addSubview:self.labelTableViewTitle];
    return view;
}

- (UILabel *)labelTableViewTitle{
    if (!_labelTableViewTitle) {
        _labelTableViewTitle = [[UILabel alloc] initWithFrame:CGRectMake(Ratio11, 0, screenW - Ratio11, Ratio33)];
        _labelTableViewTitle.font = Font15;
        _labelTableViewTitle.textColor = MainBlack;
    }
    return _labelTableViewTitle;
}

- (void)initView{
    [self.view addSubview:self.deviceDefaultView];
    [self.view addSubview:self.labelConnectRemind];
    self.deviceDefaultView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).heightIs(Ratio88);
    self.labelConnectRemind.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).heightIs(Ratio88);
    [self.view addSubview:self.tableView];
    self.tableView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.deviceDefaultView, Ratio8).bottomSpaceToView(self.view, 0);

    [self.view addSubview:self.buttonGuide];
    self.buttonGuide.sd_layout.centerYEqualToView(self.view).rightSpaceToView(self.view, Ratio11).heightIs(Ratio40).widthIs(Ratio90);
    
    [self.view addSubview:self.deviceManagerSettingView];
    self.deviceManagerSettingView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.deviceDefaultView, Ratio8).bottomSpaceToView(self.view, 0);
    self.deviceManagerSettingView.hidden = YES;
    
    
    
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:self.defaultConnectPath];
    if (!data) {
        
        self.labelConnectRemind.hidden = NO;
        self.deviceDefaultView.hidden = YES;
    } else {
        NSString *bluetoothDeviceName = [data objectForKey:@"bluetoothDeviceName"];
        NSString *bluetoothDeviceMac = [data objectForKey:@"bluetoothDeviceMac"];
        NSString *bluetoothDeviceUUID = [data objectForKey:@"bluetoothDeviceUUID"];
        self.deviceModel.bluetoothDeviceName = bluetoothDeviceName;
        self.deviceModel.bluetoothDeviceMac = bluetoothDeviceMac;
        self.deviceModel.bluetoothDeviceUUID = bluetoothDeviceUUID;
        self.labelConnectRemind.hidden = YES;
        self.deviceDefaultView.hidden = NO;
        self.deviceDefaultView.deviceModel = self.deviceModel;
    }
    
    
}

- (DeviceManagerSettingView *)deviceManagerSettingView{
    if(!_deviceManagerSettingView) {
        _deviceManagerSettingView = [[DeviceManagerSettingView alloc] init];
        _deviceManagerSettingView.recordingState = self.recordingState;
        _deviceManagerSettingView.bStandart = self.bStandart;
    }
    return _deviceManagerSettingView;
}

- (UITableView *)tableView{
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        //_tableView.style = UITableViewStyleGrouped;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;// = UITableViewSe;
        _tableView.backgroundColor = WHITECOLOR;
        [_tableView registerClass:[DeviceManagerItemCell class] forCellReuseIdentifier:NSStringFromClass([DeviceManagerItemCell class])];
    }
    return _tableView;
}


- (DeviceDefaultView *)deviceDefaultView{
    if (!_deviceDefaultView) {
        _deviceDefaultView = [[DeviceDefaultView alloc] init];
        _deviceDefaultView.hidden = YES;
        _deviceDefaultView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapDeviceDefault:)];
        [_deviceDefaultView addGestureRecognizer:tapGesture];
        
    }
    return _deviceDefaultView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)initNaviView{
    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item0.width = Ratio11;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"histroy_search"] style:UIBarButtonItemStylePlain target:self action:nil];
    item1.action = @selector(actionToSearch:);
    item1.imageInsets = UIEdgeInsetsMake(0, Ratio5, 0, Ratio5);
    
    
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"peopleScanicon"] style:UIBarButtonItemStylePlain target:self action:nil];
    item2.action = @selector(actionToScanView:);
    self.navigationItem.rightBarButtonItems = @[item0,item1,item2];
}

- (UILabel *)labelConnectRemind{
    if (!_labelConnectRemind) {
        _labelConnectRemind = [[UILabel alloc] init];
        _labelConnectRemind.textAlignment = NSTextAlignmentCenter;
        _labelConnectRemind.textColor = MainNormal;
        _labelConnectRemind.font = Font13;
        _labelConnectRemind.text = @"请扫码或点击搜索连接设备";
        _labelConnectRemind.hidden = YES;
    }
    return _labelConnectRemind;
}

- (UIButton *)buttonGuide{
    if (!_buttonGuide) {
        _buttonGuide = [[UIButton alloc] init];
        [_buttonGuide setImage:[UIImage imageNamed:@"connection_guide_btn"] forState:UIControlStateNormal];
        [_buttonGuide addTarget:self action:@selector(actionToGuide:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonGuide;
}

- (void)actionToGuide:(UIButton *)button{
    GuideVC *guidVC = [[GuideVC alloc] init];
    [self.navigationController pushViewController:guidVC animated:YES];
}

- (void)actionToScanView:(UIBarButtonItem *)item{
    ScanTeachCodeVC *scanTeachCode = [[ScanTeachCodeVC alloc] init];
    scanTeachCode.delegate = self;
    [self.navigationController pushViewController:scanTeachCode animated:YES];
}

- (void)dealloc{
    [self.deviceDefaultView removerTimer];
}

@end
