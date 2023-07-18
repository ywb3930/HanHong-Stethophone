//
//  FriendModel.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/21.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface FriendModel : NSObject


@property (retain, nonatomic) NSString              *area;
@property (retain, nonatomic) NSString              *avatar;
@property (retain, nonatomic) NSString              *birthday;
@property (retain, nonatomic) NSString              *company;
@property (retain, nonatomic) NSString              *department;
@property (retain, nonatomic) NSString              *email;
//@property (assign, nonatomic) long                  id;
@property (assign, nonatomic) long                  userId;
@property (retain, nonatomic) NSString              *name;
@property (retain, nonatomic) NSString              *phone;
@property (assign, nonatomic) NSInteger             role;
@property (assign, nonatomic) NSInteger             sex;
@property (assign, nonatomic) NSInteger             state;
@property (assign, nonatomic) NSInteger             type;
@property (retain, nonatomic) NSString              *title;
@property (retain, nonatomic) NSString              *academy;
@property (retain, nonatomic) NSString              *classs;
//@property (retain, nonatomic) NSString              *class;
@property (assign, nonatomic) Boolean               bSelected;//是否选中
@property (assign, nonatomic) Boolean               bOnLine;//是否在线
@property (assign, nonatomic) Boolean               bCollect;//是否是采集人
@property (assign, nonatomic) Boolean               bConnect;//是否连接设备
//@property (retain, nonatomic) NSString              *letter;



@end

NS_ASSUME_NONNULL_END
