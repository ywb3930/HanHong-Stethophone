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

@end

NS_ASSUME_NONNULL_END
