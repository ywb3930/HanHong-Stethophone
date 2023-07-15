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
#import "TestVC.h"

//#import <UMCommon/UMCommon.h>
//#import <UMAPM/UMCrashConfigure.h>
//#import <UMAPM/UMLaunch.h>
//#import <UMCommonLog/UMCommonLogHeaders.h>
//#import <UMAPM/UMAPMConfig.h>

/**
 Andoird 问题
1.自动录音
2.心音选中，不录音，点击肺音，不选位置，按听诊器会开始录音
3.肺音正面选中 不录音，点击背面，正面的选中不取消
 iOS问题 暂停会诊卡死
 
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

- (Boolean)checkDeviceIsUpdate:(NSString *)nowVersions{
    NSString *appVersion = @"0.1.3";
    //@"V2.1.2"
    //当前版本
    NSString *version = [nowVersions substringFromIndex:1];
    
    NSArray *appVersionArr = [appVersion componentsSeparatedByString:@"."];
    NSArray *versionArr = [version componentsSeparatedByString:@"."];
    NSInteger appVersionInt1 = [appVersionArr[1] integerValue];
    NSInteger versionInt1 = [versionArr[1] integerValue];
    NSInteger appVersionInt2 = [appVersionArr[2] integerValue];
    NSInteger versionInt2 = [versionArr[2] integerValue];
    
    if (appVersionInt1 > versionInt1) {
        return YES;
    }else if ((appVersionInt1 == versionInt1) && (appVersionInt2 > versionInt2)) {
        return YES;
    }else if ((appVersionInt1 == versionInt1) && (appVersionInt2 == versionInt2)) {
        return YES;
    }
    
    
    
    return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch. 18902400417
    //[self checkDeviceIsUpdate:@"0.1.4"];
    [self checkNetConnect];
    LoginData = nil;
    [[ToolsCheckUpdate getInstance] actionToCheckUpdate:NO];
    
    //设置预定义DidFinishLaunchingEnd时间
    //[UMLaunch setPredefineLaunchType:UMPredefineLaunchType_DidFinishLaunchingEnd];
     
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];// 禁止触摸
    [SVProgressHUD setForegroundColor:MainColor];
    [SVProgressHUD setBorderWidth:Ratio1];
    [SVProgressHUD setBorderColor:ViewBackGroundColor];
    [SVProgressHUD setBackgroundColor:WHITECOLOR];
    
    [UINavigationBar appearance].backgroundColor = ViewBackGroundColor;
    [UINavigationBar appearance].tintColor = MainBlack;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:MainBlack,NSFontAttributeName:Font18}];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];//创建一个Window
    HHNavigationController *navigation = [[HHNavigationController alloc] initWithRootViewController:[[LoginVC alloc] init]];
    self.window.rootViewController = navigation;
//    }
    self.window.backgroundColor = UIColor.whiteColor;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginBroadcast:) name:login_broadcast object:nil];
 ////649e6e8cbd4b621232c434ed
    
//    applinks:eba4fc5d76acfd96108720a7aadb21c5.share2dlink.com
//    [WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
//        NSLog(@"WeChatSDK: %@", log);
//    }];
    [WXApi registerApp:@"wx97eae6a515b782d3" universalLink:@"https://www.hedelongcloud.com/auscultationassistant/"];
    //[self initTestUM];
    //在register之前打开log, 后续可以根据log排查问题
   

    //务必在调用自检函数前注册


//    //调用自检函数
//    [WXApi checkUniversalLinkReady:^(WXULCheckStep step, WXCheckULStepResult* result) {
//        NSLog(@"WeChatSDK = %@, %u, %@, %@", @(step), result.success, result.errorInfo, result.suggestion);
//    }];
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
//    view.backgroundColor = UIColor.redColor;
//
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
//    imageView.image = [UIImage imageNamed:@"hanhong_bg.jpg"];
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [view addSubview:imageView];
//
//    [kAppWindow addSubview:view];
    
    [NSThread sleepForTimeInterval:1.0];//设置启动页面时间

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    Boolean needUpdateApp = [[NSUserDefaults standardUserDefaults] boolForKey:@"needUpdateApp"];
    if (needUpdateApp) {
        [[ToolsCheckUpdate getInstance] actionToCheckUpdate:NO];
    }
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
    NSLog(@"43");
    if([req isKindOfClass:[LaunchFromWXReq class]]) {
        LaunchFromWXReq *wxReq = (LaunchFromWXReq *)req;
        WXMediaMessage *message = wxReq.message;
        NSString *messageExt = message.messageExt;
        messageExt = @"{\"share_type\": \"record\", \"share_code\": \"kdtMytTjVlLVMSfxeVDMnA==\"}";
        
        NSDictionary *data = [Tools jsonData2Dictionary:messageExt];
        
        [TTRequestManager recordShareBrief:data[@"share_code"] success:^(id  _Nonnull responseObject) {
            if ([responseObject[@"errorCode"] integerValue] == 0) {
                NSDictionary *data = responseObject[@"data"];
                ShareDataModel *model = [ShareDataModel yy_modelWithDictionary:data];
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
    [[AFNetRequestManager shareManager] getRequestTest:@"https://www.baidu.com"];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application
  supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.allowRotation) { // 如果设置了 allowRotation 属性，支持全屏
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait; // 默认全局不支持横屏
}


@end
