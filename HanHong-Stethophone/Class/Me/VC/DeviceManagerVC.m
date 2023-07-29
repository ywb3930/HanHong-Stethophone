//
//  DeviceManagerVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/19.
//

#import "DeviceManagerVC.h"
#import "DeviceDefaultView.h"
#import "BluetoothDeviceModel.h"
#import "DeviceManagerItemCell.h"
#import "DeviceManagerSettingView.h"
#import "ScanTeachCodeVC.h"
#import "Constant.h"
#import "DeviceMessageVC.h"
#import "GuideVC.h"




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
@property (retain, nonatomic) UIActivityIndicatorView   *indicatorView;

@property (retain, nonatomic) UIButton                  *buttonGuide;
@property (assign, nonatomic) NSInteger                 loginType;
@property (assign, nonatomic) NSInteger                 searchState;
@property (retain, nonatomic) UIView                    *viewSearch;

@end

@implementation DeviceManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.defaultConnectPath = [[Constant shareManager] getPlistFilepathByName:@"connectDevice.plist"];
    self.loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"login_type"];
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
    if ([[HHBlueToothManager shareManager] getConnectState] == DEVICE_CONNECTED && [mac isEqualToString:self.deviceModel.bluetoothDeviceMac]) {
        [self.view makeToast:@"该设备已连接" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    BluetoothDeviceModel *model = [[BluetoothDeviceModel alloc] init];
    model.bluetoothDeviceName = deviceName;
    model.bluetoothDeviceMac = mac;
    NSString *uuid = [NSString stringWithFormat:@"4848%@", macStr];
    model.bluetoothDeviceUUID = [uuid lowercaseString];
    self.deviceModel = model;
    self.deviceDefaultView.hidden = NO;
    self.labelConnectRemind.hidden = YES;
    self.deviceDefaultView.deviceModel = model;
    //[self.deviceDefaultView startTimer];
    [[HHBlueToothManager shareManager] abortSearch];//停止搜索
    self.tableView.hidden = YES;
    self.deviceDefaultView.deviceModel = model;
    if([[HHBlueToothManager shareManager] getConnectState] == DEVICE_CONNECTED) {
        [[HHBlueToothManager shareManager] disconnect];
    }
    [[HHBlueToothManager shareManager] connent:model.bluetoothDeviceUUID];
    [self actionSaveBlueToothData];
    
}

- (void)actionSaveBlueToothData{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:self.deviceModel.bluetoothDeviceName forKey:@"bluetoothDeviceName"];
    [data setObject:self.deviceModel.bluetoothDeviceMac forKey:@"bluetoothDeviceMac"];
    [data setObject:self.deviceModel.bluetoothDeviceUUID forKey:@"bluetoothDeviceUUID"];
    [data writeToFile:self.defaultConnectPath atomically:YES];
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
        NSString *string5 = [NSString stringWithFormat:@"%@", [[HHBlueToothManager shareManager] getFirmwareVersion]];
        NSRange range = [string5 rangeOfString:@"."];
        string5 = [string5 substringFromIndex:range.location + 1];
        string5 = [NSString stringWithFormat:@"V%@", string5];
        
        NSString *pd = [[HHBlueToothManager shareManager] getProductionDate];
        DLog(@"ProductionDate = %@", pd);
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
        //[self.deviceDefaultView startTimer];
        DLog(@"bluetoothDeviceUUID 1 = %@", self.deviceModel.bluetoothDeviceUUID);
        [[HHBlueToothManager shareManager] connent:self.deviceModel.bluetoothDeviceUUID];
    }
    
}


- (void)actionRecieveBluetoothMessage:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    DEVICE_HELPER_EVENT event = [userInfo[@"event"] integerValue];
    NSObject *args1 = userInfo[@"args1"];
    NSObject *args2 = userInfo[@"args2"];
    if (event == SearchStart) {
        self.searchState = SearchStart;
    }  else if (event == SearchEnd) {
        self.searchState = SearchEnd;
    }
    __weak typeof(self) wself = self;
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [mainQueue addOperationWithBlock:^{
        if (event == SearchStart) {
            //wself.searchState = SearchStart;
            [wself.indicatorView startAnimating];
            wself.viewSearch.hidden = NO;
        } else if (event == SearchFound) {
            wself.labelTableViewTitle.text = @"已发现的设备：";
            [wself actionEventSearchFound:(NSString *)args1 device_mac:(NSString *)args2];
        } else if (event == DeviceConnected) {
            wself.tableView.hidden = YES;
            [wself reloadView];
        } else if (event == DeviceDisconnected) {
            wself.deviceManagerSettingView.hidden = YES;
        } else if (event == SearchEnd) {
            //wself.searchState = SearchEnd;
            wself.labelTableViewTitle.text = @"搜索已完成";
            [wself.indicatorView stopAnimating];
            wself.viewSearch.hidden = YES;
        }
    }];
}

- (void)actionEventSearchFound:(NSString *)device_name device_mac:(NSString *)device_mac{
    NSString *macSub4 = [device_mac substringFromIndex:4];
    NSString *mac = [Tools converDataToMacStr:macSub4];
    for (BluetoothDeviceModel *model in self.arrayData) {
        if ([model.bluetoothDeviceUUID isEqualToString:device_mac]) {
            return;
        }
    }
    DLog(@"device_mac = %@, mac = %@", device_mac, mac);
    BluetoothDeviceModel *model = [[BluetoothDeviceModel alloc] init];
    model.bluetoothDeviceName = device_name;
    model.bluetoothDeviceMac = mac;
    model.bluetoothDeviceUUID = device_mac;
    [self.arrayData addObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.arrayData.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)actionToSearch:(UIBarButtonItem *)item{
    if(self.searchState == SearchStart) {
        [self.view makeToast:@"正在搜索设备中，请勿重复点击" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    __weak typeof(self) wself = self;
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [mainQueue addOperationWithBlock:^{
        CONNECT_STATE state = [[HHBlueToothManager shareManager] getConnectState];
        wself.deviceManagerSettingView.hidden = YES;
        wself.tableView.hidden = NO;
        wself.deviceDefaultView.buttonBluetooth.selected = NO;
        [[HHBlueToothManager shareManager] disconnect];
        wself.labelTableViewTitle.text = @"搜索设备中......";
        if (state == DEVICE_NOT_CONNECT) {
            [[HHBlueToothManager shareManager] search];

        } else {
            [wself performSelector:@selector(searchBluetooth) withObject:nil afterDelay:1.0f];
        }
    }];
    
    
}

- (void)searchBluetooth{
     [[HHBlueToothManager shareManager] search];
}

- (void)reloadView{
    [self.deviceManagerSettingView reloadView];
    self.deviceManagerSettingView.hidden  = NO;
    self.deviceDefaultView.buttonBluetooth.selected = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BluetoothDeviceModel *model = self.arrayData[indexPath.row];
    if ([[HHBlueToothManager shareManager] getConnectState] == DeviceConnected && [self.deviceModel.bluetoothDeviceUUID isEqualToString:model.bluetoothDeviceUUID]) {
        [self.view makeToast:@"该设备已连接" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    
    [[HHBlueToothManager shareManager] connent:model.bluetoothDeviceUUID];
    self.deviceModel = model;
    
    self.deviceDefaultView.hidden = NO;
    self.labelConnectRemind.hidden = YES;
    self.deviceDefaultView.deviceModel = model;
    [self actionSaveBlueToothData];
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
        _labelTableViewTitle.text = @"";
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
    self.buttonGuide.sd_layout.centerYEqualToView(self.view).rightSpaceToView(self.view, Ratio11).heightIs(48.f*screenRatio).widthIs(108.f*screenRatio);
    
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
    [self.view addSubview:self.viewSearch];
    self.viewSearch.sd_layout.centerXEqualToView(self.view).topSpaceToView(self.view, kNavBarAndStatusBarHeight + Ratio77).widthIs(Ratio66).heightIs(Ratio55);
    
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

- (UIView *)viewSearch{
    if (!_viewSearch) {
        _viewSearch = [[UIView alloc] init];
        _viewSearch.backgroundColor = ViewBackGroundColor;
        _viewSearch.layer.cornerRadius = Ratio5;
        _viewSearch.clipsToBounds = YES;
        _viewSearch.hidden = YES;
        [_viewSearch addSubview:self.indicatorView];
        
        UILabel *label = [[UILabel alloc] init];
        [_viewSearch addSubview:label];
        label.text = @"设备搜索中";
        label.font = [UIFont systemFontOfSize:Ratio10];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = MainNormal;
        label.sd_layout.bottomSpaceToView(_viewSearch, Ratio5).heightIs(Ratio12).rightSpaceToView(_viewSearch, 0).leftSpaceToView(_viewSearch, 0);
    }
    return _viewSearch;
}

- (UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _indicatorView.center = CGPointMake(Ratio33, Ratio22);
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
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

- (void)dealloc{
    [[HHBlueToothManager shareManager] abortSearch];
}

- (void)initNaviView{
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"histroy_search"] style:UIBarButtonItemStylePlain target:self action:nil];
    item1.action = @selector(actionToSearch:);
    item1.imageInsets = UIEdgeInsetsMake(0, Ratio5, 0, Ratio5);
    
    
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"peopleScanicon"] style:UIBarButtonItemStylePlain target:self action:nil];
    item2.action = @selector(actionToScanView:);
    self.navigationItem.rightBarButtonItems = @[item1,item2];
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
    scanTeachCode.message = @"将二维码放置在框架中";
    [self.navigationController pushViewController:scanTeachCode animated:YES];
}

@end
