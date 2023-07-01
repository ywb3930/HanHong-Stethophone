//
//  TTTabBarController.h
//  HuiGaiChe
//
//  Created by Zhilun on 2020/4/24.
//  Copyright © 2020 Zhilun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HHTabBarItem : NSObject

@property (nonatomic, strong) UIImage                   *normalImage;
@property (nonatomic, strong) UIImage                   *selectedImage;
@property (nonatomic, strong) NSString                  *title;
@property (nonatomic, strong) UIViewController          *controller;

@end

@interface HHTabBarController : UITabBarController

@property (nonatomic, strong) NSMutableArray *tabBarItems;
+ (instancetype)instance;

@end

NS_ASSUME_NONNULL_END
