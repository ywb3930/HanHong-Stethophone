//
//  AppDelegate.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import "AppDelegate.h"
#import "HHTabBarController.h"
#import "LoginVC.h"
#import "HHNavigationController.h"
#import "HHCalendarManager.h"
#import "HHFileLocationHelper.h"
#import <CoreTelephony/CTCellularData.h>


#import <UMCommon/UMCommon.h>
#import <UMAPM/UMCrashConfigure.h>
#import <UMAPM/UMLaunch.h>
#import <UMCommonLog/UMCommonLogHeaders.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)loginBroadcast:(NSNotification *)userIfo{
    NSDictionary *data = userIfo.userInfo;
    if([data[@"type"] isEqualToString:@"1"]) {//登录成功
        self.window.rootViewController = [[HHTabBarController alloc] init];
    } else if([data[@"type"] isEqualToString:@"0"]) {//退出登录
        HHNavigationController *navigation = [[HHNavigationController alloc] initWithRootViewController:[[LoginVC alloc] init]];
        self.window.rootViewController = navigation;
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self checkNetConnect];
    
    [UMLaunch beginLaunch:@"intUmeng"];
    
    [UMConfigure initWithAppkey:@"649e6e8cbd4b621232c434ed" channel:@"App Store"];
    [UMCommonLogManager setUpUMCommonLogManager];
    [UMLaunch endLaunch:@"intUmeng"];
    NSLog(@"UMAPM version:%@",[UMCrashConfigure getVersion]);
    
    //设置预定义DidFinishLaunchingEnd时间
    [UMLaunch setPredefineLaunchType:UMPredefineLaunchType_DidFinishLaunchingEnd];
     
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];// 禁止触摸
    [SVProgressHUD setForegroundColor:MainColor];
    [SVProgressHUD setBorderWidth:Ratio1];
    [SVProgressHUD setBorderColor:ViewBackGroundColor];
    
    [UINavigationBar appearance].backgroundColor = ViewBackGroundColor;
    [UINavigationBar appearance].tintColor = MainBlack;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:MainBlack,NSFontAttributeName:Font18}];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];//创建一个Window
    if(LoginData) {
        [self getUserData];
        self.window.rootViewController = [[HHTabBarController alloc] init];
    } else {
        HHNavigationController *navigation = [[HHNavigationController alloc] initWithRootViewController:[[LoginVC alloc] init]];
        self.window.rootViewController = navigation;
    }
    self.window.backgroundColor = UIColor.whiteColor;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginBroadcast:) name:login_broadcast object:nil];
    
    return YES;
}

- (void)getUserData{
    NSString *pathUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"pathUser"];
    [Constant shareManager].userInfoPath = pathUser;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkNetConnect{
    [[AFNetRequestManager shareManager] getRequestTest:@"https://www.baidu.com"];
}


@end
