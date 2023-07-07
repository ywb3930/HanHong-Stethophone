//
//  Member.m
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/28.
//
#import "Member.h"

@implementation Member {
    
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(instancetype)init:(int) role user_id:(int)user_id user_name:(NSString *)user_name user_phone:(NSString *)user_phone user_avatar:(NSString *)user_avatar
{
    self = [super init];
    if (self) {
        self.role = role;
        self.user_id = user_id;
        self.user_name = user_name;
        self.user_phone = user_phone;
        self.user_avatar = user_avatar;
    }
    return self;
}
  
@end
