//
//  Constant.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/28.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Constant : NSObject<CLLocationManagerDelegate>

+(instancetype)shareManager;

@property (retain, nonatomic) NSString      *userInfoPath;//个人信息保存路径
@property (assign, nonatomic) Boolean       bNetworkConnected;
@property (assign, nonatomic) Boolean       bActivate;
@property (retain, nonatomic) NSMutableDictionary   *activateData;
@property (retain, nonatomic) NSString      *warrantyDate;
@property (nonatomic, strong) CLLocationManager *locationManager;


- (NSString *)getPlistFilepathByName:(NSString *)plistName;
- (NSArray *)positionModeSeqArray;
- (NSArray *)positionVolumesArray;
//根据tag获取听诊位置
- (NSString *)positionTagPositionCn:(NSString *)tag;
- (NSString *)positionVolumesString:(NSInteger )idx;
- (NSString *)getRecordShareBrief;
- (NSString *)checkScanCode:(NSString *)scanCode;
- (NetworkStatus)getNetwordStatus;

/** 顶部安全区高度 **/
- (CGFloat)dev_safeDistanceTop;

/** 底部安全区高度 **/
- (CGFloat)dev_safeDistanceBottom;

/** 顶部状态栏高度（包括安全区） **/
- (CGFloat)dev_statusBarHeight;

/** 导航栏高度 **/
- (CGFloat)dev_navigationBarHeight;

/** 状态栏+导航栏的高度 **/
- (CGFloat)dev_navigationFullHeight;

/** 底部导航栏高度 **/
- (CGFloat)dev_tabBarHeight;

/** 底部导航栏高度（包括安全区） **/
- (CGFloat)dev_tabBarFullHeight;

- (Boolean)checkDeviceIsUpdate:(NSString *)nowVersions;
- (void)upUpdateFirmware:(NSString *)firmwareVersionFirstStr imgMac:(NSString *)mac version:(NSString *)version;
- (void)getProductActivateState:(NSString *)uniqueId serialNumber:(NSString *)serialNumber;

@end

NS_ASSUME_NONNULL_END
