//
//  DeviceDefaultView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/19.
//

#import "DeviceDefaultView.h"

@interface DeviceDefaultView()

@property (retain, nonatomic) UILabel               *labelTitle;
@property (retain, nonatomic) UILabel               *labelDeviceName;
@property (retain, nonatomic) UILabel               *labelDeviceMac;
@property (retain, nonatomic) NSTimer               *timer;

@end

@implementation DeviceDefaultView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = WHITECOLOR;
        [self initView];
    }
    return self;
}

- (void)setDeviceModel:(BluetoothDeviceModel *)deviceModel{
    self.labelDeviceName.text = deviceModel.bluetoothDeviceName;
    self.labelDeviceMac.text = deviceModel.bluetoothDeviceMac;
}

//
//- (void)startTimer{
//    if(!self.timer){
//        self.timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(showTime:) userInfo:nil repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
//
//    } else {
//        [self.timer setFireDate:[NSDate distantPast]];
//    }
//}
//
//- (void)showTime:(NSTimer *)timer {
//    self.buttonBluetooth.selected = !self.buttonBluetooth.selected;
//}
//
//- (void)stopTimer{
//    [self.timer setFireDate:[NSDate distantFuture]];//停止时钟
//}

//- (void)removerTimer{
//    if (self.timer) {
//        [self.timer invalidate];
//        self.timer = nil;
//    }
//    
//}


- (void)initView{
    [self addSubview:self.labelTitle];
    [self addSubview:self.labelDeviceName];
    [self addSubview:self.labelDeviceMac];
    [self addSubview:self.buttonBluetooth];
    self.buttonBluetooth.sd_layout.centerYEqualToView(self).rightSpaceToView(self, Ratio8).heightIs(Ratio33).widthIs(Ratio33);
    self.labelTitle.sd_layout.leftSpaceToView(self, Ratio11).topSpaceToView(self, Ratio11).heightIs(Ratio22).rightSpaceToView(self.buttonBluetooth, Ratio18);
    self.labelDeviceName.sd_layout.leftEqualToView(self.labelTitle).topSpaceToView(self.labelTitle, 0).heightIs(Ratio22).rightEqualToView(self.labelTitle);
    self.labelDeviceMac.sd_layout.leftEqualToView(self.labelTitle).topSpaceToView(self.labelDeviceName, 0).heightIs(Ratio22).rightEqualToView(self.labelTitle);
}

- (UILabel *)labelTitle{
    if(!_labelTitle) {
        _labelTitle = [[UILabel  alloc] init];
        _labelTitle.font = Font15;
        _labelTitle.text = @"我的设备:";
        _labelTitle.textColor = MainBlack;
    }
    return _labelTitle;
}

- (UILabel *)labelDeviceName{
    if(!_labelDeviceName) {
        _labelDeviceName = [[UILabel  alloc] init];
        _labelDeviceName.font = Font15;
        _labelDeviceName.textColor = MainBlack;
    }
    return _labelDeviceName;
}

- (UILabel *)labelDeviceMac{
    if(!_labelDeviceMac) {
        _labelDeviceMac = [[UILabel  alloc] init];
        _labelDeviceMac.font = Font15;
        _labelDeviceMac.textColor = MainBlack;
    }
    return _labelDeviceMac;
}

- (HHBluetoothButton *)buttonBluetooth{
    if (!_buttonBluetooth) {
        _buttonBluetooth = [[HHBluetoothButton alloc] init];
        _buttonBluetooth.imageEdgeInsets = UIEdgeInsetsMake(Ratio5, Ratio5, Ratio5, Ratio5);
    }
    return _buttonBluetooth;
}
//
//- (UIButton *)buttonBluetooth{
//    if(!_buttonBluetooth) {
//        _buttonBluetooth = [[UIButton alloc] init];
//        [_buttonBluetooth setImage:[UIImage imageNamed:@"bluetooth_disconnect"] forState:UIControlStateNormal];
//        [_buttonBluetooth setImage:[UIImage imageNamed:@"bluetooth_connect"] forState:UIControlStateSelected];
//        //_buttonBluetooth.enabled = NO;
//        _buttonBluetooth.selected = NO;
//    }
//    return _buttonBluetooth;
//}

@end
