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
#import "ToolsCheckUpdate.h"
#import "ShareAnnotationVC.h"
#import "LoginTypeVC.h"

//#import <UMCommon/UMCommon.h>
//#import <UMAPM/UMCrashConfigure.h>
//#import <UMAPM/UMLaunch.h>
//#import <UMCommonLog/UMCommonLogHeaders.h>
//#import <UMAPM/UMAPMConfig.h>

/**
 Andoird 问题
1.标准录音时，录音顺序开关打开，选择多个位置，自动录音时只显示第一个位置，不会自动跳到其它位置录音
2.心音选中，不录音，点击肺音，不选位置，按听诊器会开始录音
3.第一次画新选区时不会出现标注按钮
 iOS问题
1.远程会诊时，暂停会诊卡死
 */

@interface AppDelegate ()

@property (retain, nonatomic) ShareDataModel *shareDataModel;

@end

@implementation AppDelegate


- (void)loginBroadcast:(NSNotification *)userIfo{
    NSDictionary *data = userIfo.userInfo;
    [self actionSetRootView:data];
}

- (void)actionSetRootView:(NSDictionary *)data{
    if([data[@"type"] isEqualToString:@"1"]) {//登录成功
        self.window.rootViewController = [[HHTabBarController alloc] init];
        [self initBluetooth];
        if (self.shareDataModel) {
            if ([NSThread isMainThread]) {
                [self actionToShareAnnotationVC:self.shareDataModel];
               
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self actionToShareAnnotationVC:self.shareDataModel];
                   
                });
            }
            
        }
        
    } else if([data[@"type"] isEqualToString:@"0"]) {//退出登录
        if ([NSThread isMainThread]) {
            HHNavigationController *navigation = [[HHNavigationController alloc] initWithRootViewController:[[LoginVC alloc] init]];
            self.window.rootViewController = navigation;
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                HHNavigationController *navigation = [[HHNavigationController alloc] initWithRootViewController:[[LoginVC alloc] init]];
                self.window.rootViewController = navigation;
            });
        }
    }
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch. 18902400417
    [self checkNetConnect];
    LoginData = nil;
    [[ToolsCheckUpdate getInstance] actionToCheckUpdate:NO];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    //设置预定义DidFinishLaunchingEnd时间
    //[UMLaunch setPredefineLaunchType:UMPredefineLaunchType_DidFinishLaunchingEnd];
     
    
    [UINavigationBar appearance].backgroundColor = ViewBackGroundColor;
    [UINavigationBar appearance].tintColor = MainBlack;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:MainBlack,NSFontAttributeName:Font18}];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];//创建一个Window
    
    HHNavigationController *navigation = [[HHNavigationController alloc] initWithRootViewController:[[LoginVC alloc] init]];
    self.window.rootViewController = navigation;
    
    self.window.backgroundColor = UIColor.whiteColor;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginBroadcast:) name:login_broadcast object:nil];
 
    [WXApi registerApp:WXAppID universalLink:UniversalLink];
 
    
    [NSThread sleepForTimeInterval:2.0];//设置启动页面时间

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    NSLog(@"applicationDidBecomeActive");
    Boolean needUpdateApp = [[NSUserDefaults standardUserDefaults] boolForKey:@"needUpdateApp"];
    if (needUpdateApp) {
        [[ToolsCheckUpdate getInstance] actionToCheckUpdate:NO];
    }
}

-(void)applicationWillTerminate:(UIApplication *)application{
    [[HHBlueToothManager shareManager] disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    NSLog(@"applicationDidEnterBackground");
}

//- (void)initTestUM{
//    [UMLaunch beginLaunch:@"intUmeng"];
//    //初始化友盟SDK
//    UMAPMConfig* config = [UMAPMConfig defaultConfig];
//    config.crashAndBlockMonitorEnable = YES;
//    config.launchMonitorEnable = YES;
//    config.memMonitorEnable = YES;
//    config.oomMonitorEnable = YES;
//    config.networkEnable = YES;
//    [UMCrashConfigure setAPMConfig:config];
//    [UMConfigure initWithAppkey:@"649e6e8cbd4b621232c434ed" channel:@"App Store"];
//    //设置启动模块自定义函数开始
//    [UMLaunch endLaunch:@"intUmeng"];
//    NSLog(@"UMAPM version:%@",[UMCrashConfigure getVersion]);
//
//    //设置预定义DidFinishLaunchingEnd时间
//    [UMLaunch setPredefineLaunchType:UMPredefineLaunchType_DidFinishLaunchingEnd];
//}

- (void)initBluetooth{
    NSString *defaultConnectPath = [[Constant shareManager] getPlistFilepathByName:@"connectDevice.plist"];
    NSString *deviceManagerPath =  [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    
    NSDictionary *dataBluetooth = [NSDictionary dictionaryWithContentsOfFile:defaultConnectPath];
    NSDictionary *deviceManage = [NSDictionary dictionaryWithContentsOfFile:deviceManagerPath];
    Boolean autoConnect = [deviceManage[@"auto_connect_echometer"] boolValue];
    if (dataBluetooth && autoConnect) {
        NSString *bluetoothDeviceUUID = [dataBluetooth objectForKey:@"bluetoothDeviceUUID"];
        [[HHBlueToothManager shareManager] connent:bluetoothDeviceUUID];
        NSLog(@"bluetoothDeviceUUID 4 = %@", bluetoothDeviceUUID);
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSString *url_string = url.absoluteString;
    NSLog(@"url_string = %@", url_string);
    if ([url_string containsString:@"state=wechatLogin"] || [url_string containsString:@"state=bindWechat"] || [url_string containsString:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }else{
        //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
        return YES;
    }
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler{
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}


- (void)onReq:(BaseReq *)req{
    if([req isKindOfClass:[LaunchFromWXReq class]]) {
        LaunchFromWXReq *wxReq = (LaunchFromWXReq *)req;
        WXMediaMessage *message = wxReq.message;
        NSString *messageExt = message.messageExt;
        messageExt = [messageExt stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSDictionary *data = [Tools jsonData2Dictionary:messageExt];
        [TTRequestManager recordShareBrief:data[@"share_code"] success:^(id  _Nonnull responseObject) {
            if ([responseObject[@"errorCode"] integerValue] == 0) {
                NSDictionary *data = responseObject[@"data"];
                ShareDataModel *model = [ShareDataModel yy_modelWithDictionary:data];
                NSLog(@"url = %@", model.url);
                if ([NSThread isMainThread]) {
                    [self actionToShareAnnotationVC:model];
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self actionToShareAnnotationVC:model];
                    });
                }
            }
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }
}

- (void)actionToShareAnnotationVC:(ShareDataModel *)model{

    if (LoginData == nil) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:record_share_before_login object:nil userInfo:@{@"model" : model}];
        self.shareDataModel = model;
    } else {
        ShareAnnotationVC *shareAnnotation = [[ShareAnnotationVC alloc] init];
        shareAnnotation.shareDataModel = model;
        UIViewController *currentVC = [Tools currentViewController];
        [currentVC.navigationController pushViewController:shareAnnotation animated:YES];
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
        
        [Tools hiddenWithStatus];
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
//eba4fc5d76acfd96108720a7aadb21c5.share2dlink.com
//www.hedelongcloud.com
- (void)getUserData{
    NSString *pathUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"pathUser"];
    [Constant shareManager].userInfoPath = pathUser;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkNetConnect{
    //[[AFNetRequestManager shareManager] getRequestTest:@"https://www.baidu.com"];
    [[Constant shareManager] getNetwordStatus];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application
  supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.allowRotation) { // 如果设置了 allowRotation 属性，支持全屏
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait; // 默认全局不支持横屏
}


@end
