//
//  DeviceDefaultView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/19.
//

#import <UIKit/UIKit.h>
#import "BluetoothDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceDefaultView : UIView

@property (retain, nonatomic) BluetoothDeviceModel        *deviceModel;
@property (retain, nonatomic) HHBluetoothButton           *buttonBluetooth;
//- (void)startTimer;
//- (void)stopTimer;
//- (void)removerTimer;

@end

NS_ASSUME_NONNULL_END
