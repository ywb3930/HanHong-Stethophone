//
//  TTNavigationController.m
//  HuiGaiChe
//
//  Created by Zhilun on 2020/4/24.
//  Copyright © 2020 Zhilun. All rights reserved.
//

#import "HHNavigationController.h"

@interface HHNavigationController ()

@end

@implementation HHNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -kStatusBarHeight, screenW, kStatusBarHeight)];
    view.backgroundColor = ViewBackGroundColor;
    [self.navigationBar addSubview:view];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count != 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (BOOL)shouldAutorotate{
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

@end
