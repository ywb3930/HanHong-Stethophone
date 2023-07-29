//
//  Constant.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/28.
//

#import "Constant.h"
#import "UpdateDeviceVC.h"
#import "OrgModel.h"
#import "PrivacyPermission.h"

NSString *const EarPhone_btName = @"EARPHONE_ER001";
NSString *const DS88_btName = @"DS88";

#define Not_activate  0
/**已激活*/
#define Already_activate  1
/**无法激活*/
#define Unable_to_activate  2

@implementation Constant

+(instancetype)shareManager{
    static Constant *cs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cs = [[Constant alloc] init];
//        Reachability *reachability = [Reachability reachabilityForInternetConnection];
//
//        // 如果你希望在网络状态发生变化时接收通知，可以注册通知
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
//        [reachability startNotifier];
    });
    return cs;
}

- (void)networkStatusChanged:(NSNotification *)notification {
    Reachability *reachability = (Reachability *)notification.object;
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    if (networkStatus != NotReachable) {
        // 设备有可用的网络连接
        // 执行相关操作
        self.bNetworkConnected = YES;
    } else {
        // 设备无可用网络连接
        // 执行相关操作
        self.bNetworkConnected = NO;
    }
}

- (NSString *)getPlistFilepathByName:(NSString *)plistName{
    NSString *resultUserPath = [HHFileLocationHelper getAppDocumentPath:self.userInfoPath];
    return [resultUserPath stringByAppendingPathComponent:plistName];
}

//根据tag获取听诊位置
- (NSString *)positionTagPositionCn:(NSString *)tag{
    if ([tag isEqualToString:@"M"]) {
        return @"二尖瓣听诊区";
    } else if ([tag isEqualToString:@"P"]) {
        return @"肺动脉瓣听诊区";
    } else if ([tag isEqualToString:@"A"]) {
        return @"主动脉瓣听诊区";
    } else if ([tag isEqualToString:@"E"]) {
        return @"主动脉瓣第二听诊区";
    } else if ([tag isEqualToString:@"T"]) {
        return @"三尖瓣听诊区";
    } else if ([tag isEqualToString:@"1"]) {
        return @"左肺尖";
    } else if ([tag isEqualToString:@"2"]) {
        return @"右肺尖";
    } else if ([tag isEqualToString:@"3"]) {
        return @"左上肺";
    } else if ([tag isEqualToString:@"4"]) {
        return @"右上肺";
    } else if ([tag isEqualToString:@"5"]) {
        return @"左前胸";
    } else if ([tag isEqualToString:@"6"]) {
        return @"右前胸";
    } else if ([tag isEqualToString:@"7"]) {
        return @"左下肺";
    } else if ([tag isEqualToString:@"8"]) {
        return @"右下肺";
    } else if ([tag isEqualToString:@"9"]) {
        return @"左侧胸";
    } else if ([tag isEqualToString:@"10"]) {
        return @"右侧胸";
    } else if ([tag isEqualToString:@"11"]) {
        return @"背左";
    } else if ([tag isEqualToString:@"12"]) {
        return @"背右";
    }
    return @"";
}

- (NSArray *)positionVolumesArray{
    return @[@"1级(最小)",@"2级",@"3级",@"4级",@"5级",@"6级",@"7级",@"8级",@"9级",@"10级(最大)"];
}

- (NSArray *)positionModeSeqArray{
    return @[@"心音过滤模式", @"肺音过滤模式", @"心肺音模式"];
}

- (NSString *)positionVolumesString:(NSInteger )idx{
    NSArray *data = [self positionVolumesArray];
    return [data objectAtIndex:idx];
}

- (NSString *)getRecordShareBrief{
    return [NSString stringWithFormat:@"%@record/share_brief/", REQUEST_URL];
}

- (NSString *)checkScanCode:(NSString *)scanCode{
    if (scanCode.length != 14) {
        return @"";
    }
    NSString *header = [scanCode substringToIndex:2];
    NSString *deviceName = @"";
    if ([header isEqualToString:@"DS"]) {
        deviceName = POPULAR3_btName;
    } else if ([header isEqualToString:@"EP"]) {
        deviceName = EarPhone_btName;
    } else if ([header isEqualToString:@"ST"]) {
        deviceName = POPULAR3_btName;
    } else if ([header isEqualToString:@"PO"]) {
        deviceName = POP3_btName;
    } else {
        return @"";
    }
    NSString *macStr = [scanCode substringFromIndex:2];
    if (![Tools checkLogisticsCode:macStr]) {
        return @"";
    }
    
    return deviceName;
}

- (NetworkStatus)getNetwordStatus{
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    return [reachability currentReachabilityStatus];
}

// 顶部安全区高度
- (CGFloat)dev_safeDistanceTop {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        return window.safeAreaInsets.top;
    } else if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        return window.safeAreaInsets.top;
    }
    return 0;
}

// 底部安全区高度
- (CGFloat)dev_safeDistanceBottom {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        return window.safeAreaInsets.bottom;
    } else if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        return window.safeAreaInsets.bottom;
    }
    return 0;
}


//顶部状态栏高度（包括安全区）
- (CGFloat)dev_statusBarHeight {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIStatusBarManager *statusBarManager = windowScene.statusBarManager;
        return statusBarManager.statusBarFrame.size.height;
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

// 导航栏高度
- (CGFloat)dev_navigationBarHeight {
    return 44.0f;
}

// 状态栏+导航栏的高度
- (CGFloat)dev_navigationFullHeight {
    return [self dev_statusBarHeight] + [self dev_navigationBarHeight];
}

// 底部导航栏高度
- (CGFloat)dev_tabBarHeight {
    return 49.0f;
}

// 底部导航栏高度（包括安全区）
- (CGFloat)dev_tabBarFullHeight {
    return [self dev_tabBarHeight] + [self dev_safeDistanceBottom];
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
    }
    
    
    return NO;
}

- (void)upUpdateFirmware:(NSString *)firmwareVersionFirstStr imgMac:(NSString *)mac version:(NSString *)version{
    NSString *firmwareVersion = @"";
    if ([firmwareVersionFirstStr isEqualToString:@"1"]) {
        firmwareVersion = @"Popular-3_V1_1_3";
    } else if ([firmwareVersionFirstStr isEqualToString:@"2"]) {
        firmwareVersion = @"Popular-3_V2_1_3";
    } else if ([firmwareVersionFirstStr isEqualToString:@"3"]) {
        firmwareVersion = @"Popular-3_V3_1_3";
    }
    NSString *filepath = [[NSBundle mainBundle]pathForResource:firmwareVersion ofType:@"zip"];
   
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [mainQueue addOperationWithBlock:^{
        UIViewController *currentVC = [Tools currentViewController];
        UpdateDeviceVC *updateDevice = [[UpdateDeviceVC alloc] init];
        updateDevice.filepath = filepath;
        updateDevice.mac = mac;
        updateDevice.version = version;
        [currentVC.navigationController pushViewController:updateDevice animated:YES];
    }];
    
}

- (void)getProductActivateState:(NSString *)uniqueId serialNumber:(NSString *)serialNumber{
    self.bActivate = NO;
    NSInteger login_type = [[NSUserDefaults standardUserDefaults] integerForKey:@"login_type"];
    NSString *org = @"hanhong";
    if (login_type != login_type_personal) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"orgModelLogin"];
        OrgModel *orgModel = (OrgModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        org = orgModel.code;
    }
    NSDictionary *data = [LoginData yy_modelToJSONObject];
    self.activateData = [NSMutableDictionary dictionaryWithDictionary:data];
    [self.activateData removeObjectForKey:@"avatar"];
    [self.activateData removeObjectForKey:@"userID"];
    [self.activateData removeObjectForKey:@"info_modifiable"];
    [self.activateData removeObjectForKey:@"token"];
    self.activateData[@"org_code"] = org;
    self.activateData[@"model"] = [[HHBlueToothManager shareManager] getModelName];
    self.activateData[@"unique_id"] = uniqueId;
    self.activateData[@"serial_number"] = serialNumber;
    self.activateData[@"production_date"] = [[HHBlueToothManager shareManager] getProductionDate];
    self.activateData[@"mac"] = [[HHBlueToothManager shareManager] getMac];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"unique_id"] = uniqueId;
    params[@"serial_number"] = serialNumber;
    
    [TTRequestManager productActivateState:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            NSDictionary *data = responseObject[@"data"];
            [self actionAfterGetActiveState:data];
            
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)actionAfterGetActiveState:(NSDictionary *)data{
    NSInteger activate_state = [data[@"activate_state"] integerValue];
    if (activate_state == Not_activate) {
        if ([Tools isLocationEnabled]) {
            [self actionToLocation];
        } else {
            [[PrivacyPermission sharedInstance]accessPrivacyPermissionWithType:PrivacyPermissionTypeLocation completion:^(BOOL response, PrivacyPermissionAuthorizationStatus status) {
                DLog(@"response:%d \n status:%ld",response,status);
                [self actionToLocation];
            }];
        }
    } else if (activate_state == Already_activate) {
        self.warrantyDate = data[@"warranty_date"];
    }
}

- (void)actionToLocation{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization]; // 请求定位权限
    
    // 开始定位
    [self.locationManager startUpdatingLocation];
}
//2 Linker command failed with exit code 1 (use -v to see invocation)


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];
    // 在这里获取到经纬度数据之后，可以进行进一步的操作
    CLLocation *location = [locations lastObject];
    __weak typeof(self) wself = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error == nil && placemarks.count > 0) {
                // 获取到位置信息
            double latitude = location.coordinate.latitude;
            double longitude = location.coordinate.longitude;
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            
            // 解析位置信息
            NSString *address = [NSString stringWithFormat:@"%@%@%@%@",
                                 placemark.country, placemark.administrativeArea, placemark.locality, placemark.thoroughfare];
            
            DLog(@"当前地址：%@", address);
            [wself productActivate:address gps_lng:longitude gps_lat:latitude];
        } else {
            DLog(@"地理编码失败，错误信息：%@", error.localizedDescription);
        }
    }];
    
    

   
}

- (void)productActivate:(NSString *)address gps_lng:(double)gps_lng gps_lat:(double)gps_lat{
    if(self.bActivate)return;
    self.bActivate = YES;
    NSData *addressData = [address dataUsingEncoding:NSUTF8StringEncoding];
    if (addressData.length > 256) {
        address = [address substringToIndex:address.length - 1];
    }
    self.activateData[@"address"] = address;
    self.activateData[@"gps_lng"] = [@(gps_lng) stringValue];
    self.activateData[@"gps_lat"] = [@(gps_lat) stringValue];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"unique_id"] = [self.activateData objectForKey:@"unique_id"];
    params[@"serial_number"] = [self.activateData objectForKey:@"serial_number"];
    params[@"activate_code"] = [Tools convertToJsonData:self.activateData];
    [TTRequestManager productActivate:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            NSDictionary *data = responseObject[@"data"];
            [self actionAfterGetProductActivateData:data];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)actionAfterGetProductActivateData:(NSDictionary *)data{
    NSInteger activate_state = [data[@"activate_state"] integerValue];
    if (activate_state == Already_activate) {
        self.warrantyDate = data[@"warranty_date"];
    }
}

@end
