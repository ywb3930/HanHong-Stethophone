//
//  UIDevice+HanHong.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/11.
//

#import "UIDevice+HanHong.h"

@implementation UIDevice(HanHong)

// 输入要强制转屏的方向
//@param interfaceOrientation 转屏的方向
+(void)deviceMandatoryLandscapeWithNewOrientation:(UIInterfaceOrientation)interfaceOrientation {

    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];

    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];

    // 将输入的转屏方向（枚举）转换成Int类型
    int orientation = (int)interfaceOrientation;

    // 对象包装
    NSNumber *orientationTarget = [NSNumber numberWithInt:orientation];

    // 实现横竖屏旋转
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

@end
