//
//  HHBluetoothButton.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/29.
//

#import "HHBluetoothButton.h"
#import "DeviceManagerVC.h"

@interface HHBluetoothButton()

@property (retain, nonatomic) NSTimer           *timer;

@end

@implementation HHBluetoothButton

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupView];
        [self setTimer];
    }
    return self;
}

- (void)stop{
    self.timer.fireDate = [NSDate distantFuture];
}
- (void)star{
    self.timer.fireDate = [NSDate distantPast];
}

- (void)setTimer{
    if (!self.timer) {
        self.timer = [NSTimer timerWithTimeInterval:0.3f target:self selector:@selector(reloadButton) userInfo:nil repeats:YES];
    }
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self reloadButton];
}

- (void)reloadButton{
    CONNECT_STATE connect_state = [[HHBlueToothManager shareManager] getConnectState];
    if (connect_state == DEVICE_NOT_CONNECT) {//DeviceDisconnected
        [self Off];
    } else if (connect_state == DEVICE_CONNECTING) {
        [self toggle];
    } else if (connect_state == DEVICE_CONNECTED) {
        [self On];
    }
}

- (void)Off{
    self.selected = NO;
}

- (void)On{
    self.selected = YES;
}

- (void)toggle{
    self.selected = !self.selected;
}

//- (void)removeFromSuperview{
//    [self.timer invalidate];
//    self.timer = nil;
//}

- (void)actionClickBlueTooth:(UIButton *)button {
    if (self.bluetoothButtonDelegate && [self.bluetoothButtonDelegate respondsToSelector:@selector(actionClickBlueToothCallBack:)]) {
        [self.bluetoothButtonDelegate actionClickBlueToothCallBack:button];
    } else {
        UIViewController *currentVC = [Tools currentViewController];
        [self actionToDeviceManagerVC:currentVC];
    }
}

- (void)actionToDeviceManagerVC:(UIViewController *)viewController{
    DeviceManagerVC *deviceManager = [[DeviceManagerVC alloc] init];
    [viewController.navigationController pushViewController:deviceManager animated:YES];
}

- (void)setupView {
    [self setImage:[UIImage imageNamed:@"bluetooth_disconnect"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"bluetooth_connect"] forState:UIControlStateSelected];
    [self addTarget:self action:@selector(actionClickBlueTooth:) forControlEvents:UIControlEventTouchUpInside];
}

//- (void)dealloc{
//    [self.timer invalidate];
//    self.timer = nil;
//}

@end
