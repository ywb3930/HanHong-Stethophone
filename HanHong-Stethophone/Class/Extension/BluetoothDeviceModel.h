//
//  BluetoothDeviceModel.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BluetoothDeviceModel : NSObject

@property (retain, nonatomic) NSString          *bluetoothDeviceName;
@property (retain, nonatomic) NSString          *bluetoothDeviceMac;
@property (retain, nonatomic) NSString          *bluetoothDeviceUUID;

@end

NS_ASSUME_NONNULL_END
