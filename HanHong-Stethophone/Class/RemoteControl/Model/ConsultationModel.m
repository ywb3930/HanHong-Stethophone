//
//  ConsultationModel.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/20.
//

#import "ConsultationModel.h"

@implementation ConsultationModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"members" : [FriendModel class]};
}

@end
