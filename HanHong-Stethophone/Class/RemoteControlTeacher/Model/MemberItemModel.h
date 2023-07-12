//
//  MemberItemModel.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/11.
//

#import <Foundation/Foundation.h>
#import "Member.h"

NS_ASSUME_NONNULL_BEGIN

@interface MemberItemModel : NSObject

@property (retain, nonatomic) Member            *member;
@property (assign, nonatomic) Boolean           bOnline;//是否在线
@property (assign, nonatomic) Boolean           bConnect;//是否连接设备

@end

NS_ASSUME_NONNULL_END
