//
//  HHBaseViewController.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/27.
//

#import "HHBaseViewController.h"

@interface HHBaseViewController ()<HHBluetoothButtonDelegate>

@property (retain, nonatomic) HHBluetoothButton              *buttonBluetooth;

@end

@implementation HHBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item0.width = Ratio11;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.buttonBluetooth];
    
    self.navigationItem.rightBarButtonItems = @[item0,item1];
    [self.buttonBluetooth star];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.buttonBluetooth stop];
}




- (HHBluetoothButton *)buttonBluetooth{
    if(!_buttonBluetooth) {
        _buttonBluetooth  = [[HHBluetoothButton alloc] init];
        _buttonBluetooth.bluetoothButtonDelegate = self;
    }
    return _buttonBluetooth;
}

- (void)actionClickBlueToothCallBack:(nonnull UIButton *)button {
    
}

@end
