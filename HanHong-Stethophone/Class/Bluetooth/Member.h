//
//  Member.h
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/28.
//

#ifndef Member_h
#define Member_h

#import <Foundation/Foundation.h>

@interface Member : NSObject

@property (assign, nonatomic) int role;
@property (assign, nonatomic) int user_id;
@property (copy, nonatomic) NSString *user_name;
@property (copy, nonatomic) NSString *user_phone;
@property (copy, nonatomic) NSString *user_avatar;

-(instancetype)init:(int) role user_id:(int)user_id user_name:(NSString *)user_name user_phone:(NSString *)user_phone user_avatar:(NSString *)user_avatar;

@end

#endif /* Member_h */
