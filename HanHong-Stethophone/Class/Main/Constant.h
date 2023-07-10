//
//  Constant.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Constant : NSObject

+(instancetype)shareManager;

@property (retain, nonatomic) NSString      *userInfoPath;//个人信息保存路径

- (NSString *)getPlistFilepathByName:(NSString *)plistName;
- (NSArray *)positionModeSeqArray;
- (NSArray *)positionVolumesArray;
//根据tag获取听诊位置
- (NSString *)positionTagPositionCn:(NSString *)tag;
- (NSString *)positionVolumesString:(NSInteger )idx;
- (NSString *)getRecordShareBrief;
- (NSString *)checkScanCode:(NSString *)scanCode;


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


@end

NS_ASSUME_NONNULL_END
