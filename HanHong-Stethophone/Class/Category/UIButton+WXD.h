//
//  UIButton+WXD.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/11.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface UIButton (WXD)
/**
 *  为按钮添加点击间隔 eventTimeInterval秒
 */
@property (nonatomic, assign) NSTimeInterval eventTimeInterval;
@end
NS_ASSUME_NONNULL_END
