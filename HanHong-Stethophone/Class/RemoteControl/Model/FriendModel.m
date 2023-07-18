//
//  FriendModel.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/21.
//

#import "FriendModel.h"
@implementation FriendModel

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"userId": @"id", @"classs": @"class"};
}


@end
