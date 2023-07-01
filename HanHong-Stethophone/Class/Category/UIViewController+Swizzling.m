//
//  UIViewController+Swizzling.m
//  NIM
//
//  Created by chris on 15/6/15.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "UIViewController+Swizzling.h"
#import "SwizzlingDefine.h"
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)
@implementation UIViewController (Swizzling)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzling_exchangeMethod([UIViewController class] ,@selector(viewWillAppear:), @selector(swizzling_viewWillAppear:));
        swizzling_exchangeMethod([UIViewController class] ,@selector(viewDidAppear:), @selector(swizzling_viewDidAppear:));
        swizzling_exchangeMethod([UIViewController class] ,@selector(viewWillDisappear:), @selector(swizzling_viewWillDisappear:));
        swizzling_exchangeMethod([UIViewController class] ,@selector(viewDidLoad),    @selector(swizzling_viewDidLoad));
        swizzling_exchangeMethod([UIViewController class], @selector(initWithNibName:bundle:), @selector(swizzling_initWithNibName:bundle:));
    });
}

#pragma mark - ViewDidLoad
- (void)swizzling_viewDidLoad{
    if (self.navigationController) {
        UIImage *buttonNormal = [[UIImage imageNamed:@"icon_back_normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.navigationController.navigationBar setBackIndicatorImage:buttonNormal];
        [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:buttonNormal];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backItem;
    }
    [self swizzling_viewDidLoad];
}


#pragma mark - InitWithNibName:bundle:
//如果希望vchidesBottomBarWhenPushed为NO的话，请在vc init方法之后调用vc.hidesBottomBarWhenPushed = NO;
- (instancetype)swizzling_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    id instance = [self swizzling_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (instance) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return instance;
}

#pragma mark - ViewWillAppear
static char UIFirstResponderViewAddress;

- (void)swizzling_viewWillAppear:(BOOL)animated{
//    [self swizzling_viewWillAppear:animated];
//    if (self.parentViewController == self.navigationController)
//    {
//        if ([self swizzling_isUseClearBar] && self.navigationController)
//        {
//            [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//            [self.navigationController.navigationBar setShadowImage:[UIImage new]];
//        }
//        else
//        {
//            [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//            [self.navigationController.navigationBar setShadowImage:nil];
//        }
//    }
}

#pragma mark - ViewDidAppear
- (void)swizzling_viewDidAppear:(BOOL)animated{
    [self swizzling_viewDidAppear:animated];
    UIView *view = objc_getAssociatedObject(self, &UIFirstResponderViewAddress);
    [view becomeFirstResponder];
}


#pragma mark - ViewWillDisappear

- (void)swizzling_viewWillDisappear:(BOOL)animated{

}

#pragma mark - Private
- (BOOL)swizzling_isUseClearBar
{
    SEL  sel = NSSelectorFromString(@"useClearBar");
    BOOL use = NO;
    if ([self respondsToSelector:sel]) {
        SuppressPerformSelectorLeakWarning(use = (BOOL)[self performSelector:sel]);
    }
    return use;
}


@end
