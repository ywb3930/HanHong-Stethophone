//
//  UpdateDeviceVC.m
//  HanHong-Stethophone
//
//  Created by HanHong on 2023/7/13.
//

#import "UpdateDeviceVC.h"

@import iOSDFULibrary;

@interface UpdateDeviceVC ()<DFUServiceDelegate, DFUProgressDelegate, DFUPeripheralSelectorDelegate, LoggerDelegate, CBCentralManagerDelegate>

@property (retain, nonatomic) YYLabel                   *labelMessage;
@property (retain, nonatomic) DFUFirmware               *selectedFirmeare;
@property (retain, nonatomic) CBCentralManager          *centralManager;
@property (retain, nonatomic) CBPeripheral              *currentPeripheral;
@property (retain, nonatomic) DFUServiceController      *controller;
@property (retain, nonatomic) DFUServiceInitiator       *dfuInitiator;
@property (assign, nonatomic) Boolean                   bUpdate;
@property (retain, nonatomic) MBProgressHUD             *hud;

@end

@implementation UpdateDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    self.title = @"固件更新";
    self.bUpdate = NO;
    
    [self.view addSubview:self.labelMessage];
    self.labelMessage.sd_layout.topSpaceToView(self.view, screenH/3).leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).heightIs(Ratio44);
    self.labelMessage.text = [NSString stringWithFormat:@"听诊器固件版本低，正在更新固件，请勿关闭听诊器\r\n最新版本%@", @"V1.3"];
    self.centralManager = [[HHBlueToothManager shareManager] getCentralManager];
    self.currentPeripheral = [[HHBlueToothManager shareManager] currentPeripheral];
    [self initData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionRecieveBluetoothMessage:) name:HHBluetoothMessage object:nil];
    [[HHBlueToothManager shareManager] disconnect];
}
//接收蓝牙广播通知
- (void)actionRecieveBluetoothMessage:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    DEVICE_HELPER_EVENT event = [userInfo[@"event"] integerValue];
    NSObject *args1 = userInfo[@"args1"];
    NSObject *args2 = userInfo[@"args2"];
    [self actionDeviceHelperEvent:event args1:args1 args2:args2];
}

- (void)actionDeviceHelperEvent:(DEVICE_HELPER_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2 {
    if (event == DeviceDisconnected && !self.bUpdate) {
        DLog(@"Device didDisconnectPeripheral 1");
        self.bUpdate = YES;
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            self.hud = [MBProgressHUD showHUDAddedTo:kAppWindow animated:YES];
            //[SVProgressHUD showWithStatus:@"正在断开设备"];
            //[SVProgressHUD showProgress:0 status:@"升级中当前进度：0%"];
            //[self performSelector:@selector(delayedMethod) withObject:nil afterDelay:1.0];
            [self performSelector:@selector(delayedMethod) withObject:nil afterDelay:2.0];
        }];
    }
}

- (void)delayedMethod{
    self.controller = [self.dfuInitiator start];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)initData{
    NSError *firmeError = nil;
    NSURL *url = [NSURL fileURLWithPath:self.filepath];
    self.selectedFirmeare = [[DFUFirmware alloc] initWithUrlToZipFile:url error:&firmeError];
    
    
    self.dfuInitiator = [[DFUServiceInitiator alloc] initWithCentralManager:self.centralManager target:self.currentPeripheral];
    self.dfuInitiator = [self.dfuInitiator withFirmware:self.selectedFirmeare];
    self.dfuInitiator.delegate = self;
    self.dfuInitiator.progressDelegate = self;
    self.dfuInitiator.logger = self;
    
    self.dfuInitiator.alternativeAdvertisingNameEnabled = NO;
    self.dfuInitiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = YES;
}



-(void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond{
    float currentPro = ((float)progress / (float)totalParts)/100;
//    DLog(@"currentPro===%f",currentPro);
    int cprogress = currentPro*100;
    DLog(@"dfuProgressDidChangeFor: cprogress = %i", cprogress);
    self.hud.mode = MBProgressHUDModeDeterminate;
    [MBProgressHUD HUDForView:kAppWindow].progress = currentPro;
    self.hud.label.text = [NSString stringWithFormat:@"升级中当前进度：%i%%", cprogress];
   // [SVProgressHUD showProgress:currentPro status:[NSString stringWithFormat:@"升级中当前进度：%i%%", cprogress]];
    //[SVProgressHUD showProgress:currentPro];
}
-(void)logWith:(enum LogLevel)level message:(NSString *)message{
    DLog(@"log===%ld:%@",level,message);
}
-(void)dfuStateDidChangeTo:(enum DFUState)state{
    DLog(@"dfuStateDidChangeTo");
    
    DLog(@"升级状态==%ld",state);
   if (state == DFUStateStarting){
       DLog(@"开始DFUStateStarting");
       
   }else if(state == DFUStateUploading){
       DLog(@"上传中DFUStateUploading");
   }else if(state == DFUStateConnecting){
       DLog(@"连接中DFUStateConnectingg");
   }else if(state == DFUStateDisconnecting){
       DLog(@"断开DFUStateDisconnecting");
   }else if(state == DFUStateCompleted){
       __weak typeof(self) wself = self;
       NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
       [mainQueue addOperationWithBlock:^{
           wself.labelMessage.text = @"升级完成";
           wself.labelMessage.sd_layout.centerYIs(0.4*screenH);
           [wself.labelMessage updateLayout];
           wself.labelMessage.font = Font20;
           [Tools hiddenWithStatus];
           //重新连接蓝牙
           [wself performSelector:@selector(delayedMethodReconnect) withObject:nil afterDelay:1.0];
       }];
       
   }
}

- (void)delayedMethodReconnect{
    [[HHBlueToothManager shareManager] initDevice];
    [[HHBlueToothManager shareManager] connent:self.mac];
}

-(void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString *)message{
    DLog(@"dfuError: message = %@", message);
    self.labelMessage.text = @"升级失败，请重新连接设备升级";
    self.bUpdate = NO;

}
//message    _TtCs15__StringStorage *    "[Callback] Central Manager did update state to: Powered ON"    0x0000000283990cc0

- (YYLabel *)labelMessage{
    if (!_labelMessage) {
        _labelMessage = [[YYLabel alloc] init];
        _labelMessage.textAlignment = NSTextAlignmentCenter;
        _labelMessage.numberOfLines = 0;
        _labelMessage.textColor = MainBlack;
        _labelMessage.font = Font13;
    }
    return _labelMessage;
}


- (NSArray<CBUUID *> * _Nullable)filterByHint:(CBUUID * _Nonnull)dfuServiceUUID {
    return nil;
}

- (BOOL)select:(CBPeripheral * _Nonnull)peripheral advertisementData:(NSDictionary<NSString *,id> * _Nonnull)advertisementData RSSI:(NSNumber * _Nonnull)RSSI hint:(NSString * _Nullable)name {
    return YES;
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
}

@end


