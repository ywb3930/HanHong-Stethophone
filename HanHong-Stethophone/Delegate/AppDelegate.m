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
    
    
    [UMLaunch beginLaunch:@"intUmeng"];
    
    [UMConfigure initWithAppkey:@"649e6e8cbd4b621232c434ed" channel:@"App Store"];
    [UMCommonLogManager setUpUMCommonLogManager];
    [UMLaunch endLaunch:@"intUmeng"];
    [WXApi registerApp:@"" universalLink:@""];
    
    return YES;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSString *url_string = url.absoluteString;
    if ([url_string containsString:@"state=wechatLogin"] || [url_string containsString:@"state=bindWechat"] || [url_string containsString:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }else{
        //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
        return YES;
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSString *urlString = url.absoluteString;

    if ([urlString containsString:@"state=wechatLogin"] || [urlString containsString:@"state=bindWechat"]) {
        return [WXApi handleOpenURL:url delegate:self];
    } else{
        //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
        return YES;
    }
}

-(void)onResp:(BaseResp *)resp{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        NSString *code = authResp.code;
        NSString *string = [authResp.state stringByRemovingPercentEncoding];
        NSDictionary *info = [Tools jsonData2Dictionary:string];
        if(authResp.errCode == 0){
            
        }
        
        [SVProgressHUD dismiss];
        DDLogDebug(@"code = %@",code);
    }  else if([resp isKindOfClass:[SendMessageToWXResp class]]){
        SendMessageToWXResp *sendMessageToWXResp = (SendMessageToWXResp *)resp;
        if (sendMessageToWXResp.errCode == 0){
            DDLogDebug(@"分享成功");
        } else {
            DDLogError(@"分享失败");
        }
    }
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
