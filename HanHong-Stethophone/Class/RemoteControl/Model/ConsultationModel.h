//
//  ConsultationModel.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/20.
//

#import <Foundation/Foundation.h>
#import "ConsultationModel.h"
#import "FriendModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConsultationModel : NSObject


@property (assign, nonatomic) long              meetingroom_id;
@property (retain, nonatomic) NSArray<FriendModel *>      *members;
@property (retain, nonatomic) NSString          *creator_avatar;
@property (assign, nonatomic) long              collector_id;
@property (retain, nonatomic) NSString          *server_url;
@property (retain, nonatomic) NSString          *title;
@property (assign, nonatomic) long              creator_id;
@property (retain, nonatomic) NSString          *creator_name;
@property (assign, nonatomic) long              creator_role;
@property (retain, nonatomic) NSString          *creator_phone;
@property (retain, nonatomic) NSString          *create_time;
@property (retain, nonatomic) NSString          *begin_time;
@property (retain, nonatomic) NSString          *end_time;

@end

NS_ASSUME_NONNULL_END
