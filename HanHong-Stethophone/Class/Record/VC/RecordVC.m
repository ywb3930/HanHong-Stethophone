//
//  RecordVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import "RecordVC.h"
#import "DeviceManagerVC.h"
#import "QuickRecordVC.h"
#import "StandartRecordPatientInfoVC.h"
#import "MLAlertView.h"

@interface RecordVC ()

@property (retain, nonatomic) HHBluetoothButton             *bluetoothButton;
@property (retain, nonatomic) UIButton                      *buttonFast;
@property (retain, nonatomic) UIButton                      *buttonPip;

@end

@implementation RecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    [self initView];

}



- (Boolean)checkConnetState{
    CONNECT_STATE state = [[HHBlueToothManager shareManager] getConnectState];
    if (state == DEVICE_CONNECTING) {
        [self.view makeToast:@"设备连接中，请稍后" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    } else if (state == DEVICE_NOT_CONNECT) {
        [self.view makeToast:@"请先连接设备" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    } else if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
        [self.view makeToast:@"您连接的设备不是听诊区" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    return YES;
}

- (void)actionFastRecord:(UIButton *)button{
    if ([self checkConnetState]) {
        QuickRecordVC *quickRecord = [[QuickRecordVC alloc] init];
        [self.navigationController pushViewController:quickRecord animated:YES];
    }
}

- (void)actionStandertRecord:(UIButton *)button{
    //if ([self checkConnetState]) {
        StandartRecordPatientInfoVC *standartRecord = [[StandartRecordPatientInfoVC alloc] init];
        [self.navigationController pushViewController:standartRecord animated:YES];
   // }
}

- (void)initView{
    [self.view addSubview:self.bluetoothButton];
    self.bluetoothButton.sd_layout.rightSpaceToView(self.view, Ratio16).widthIs(Ratio22).heightIs(Ratio22).topSpaceToView(self.view, kStatusBarHeight + 23.f*screenRatio);
    
    [self.view addSubview:self.buttonFast];
    [self.view addSubview:self.buttonPip];
    self.buttonFast.sd_layout.leftSpaceToView(self.view, Ratio16).rightSpaceToView(self.view, Ratio16).topSpaceToView(self.view, kStatusBarHeight+128.f*screenRatio).heightIs(105.f*screenRatio);
    self.buttonPip.sd_layout.leftEqualToView(self.buttonFast).rightEqualToView(self.buttonFast).topSpaceToView(self.buttonFast, 20.f*screenRatio).heightIs(105.f*screenRatio);
}

- (HHBluetoothButton *)bluetoothButton{
    if(!_bluetoothButton) {
        _bluetoothButton = [[HHBluetoothButton alloc] init];
    }
    return _bluetoothButton;
}

- (UIButton *)buttonFast{
    if(!_buttonFast) {
        _buttonFast = [[UIButton alloc] init];
        _buttonFast.backgroundColor = MainColor;
        _buttonFast.layer.cornerRadius = Ratio8;
        [_buttonFast setTitle:@"快捷录音" forState:UIControlStateNormal];
        [_buttonFast setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _buttonFast.titleLabel.font = [UIFont systemFontOfSize:Ratio20 weight:UIFontWeightMedium];
        [_buttonFast addTarget:self action:@selector(actionFastRecord:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonFast;
}

- (UIButton *)buttonPip{
    if(!_buttonPip) {
        _buttonPip = [[UIButton alloc] init];
        _buttonPip.backgroundColor = AlreadyColor;
        _buttonPip.layer.cornerRadius = Ratio8;
        [_buttonPip setTitle:@"标准录音" forState:UIControlStateNormal];
        [_buttonPip setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _buttonPip.titleLabel.font = [UIFont systemFontOfSize:Ratio20 weight:UIFontWeightMedium];
        [_buttonPip addTarget:self action:@selector(actionStandertRecord:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonPip;
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.bluetoothButton star];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.bluetoothButton stop];
}


@end
