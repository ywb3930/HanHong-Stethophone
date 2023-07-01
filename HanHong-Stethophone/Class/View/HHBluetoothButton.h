//
//  HHBluetoothButton.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//如果点击按钮后需要做其他事 采用这个代理
@protocol HHBluetoothButtonDelegate <NSObject>

- (void)actionClickBlueToothCallBack:(UIButton *)button;

@end

@interface HHBluetoothButton : UIButton

@property (weak, nonatomic) id<HHBluetoothButtonDelegate>     bluetoothButtonDelegate;
- (void)actionToDeviceManagerVC:(UIViewController *)viewController;
- (void)stop;
- (void)star;

@end

NS_ASSUME_NONNULL_END
