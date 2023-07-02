//
//  Constant.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/28.
//

#import "Constant.h"

@implementation Constant

+(instancetype)shareManager{
    static Constant *cs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cs = [[Constant alloc] init];
    });
    return cs;
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
    return [NSString stringWithFormat:@"%@api/record/share_brief", REQUEST_URL];
}

@end
