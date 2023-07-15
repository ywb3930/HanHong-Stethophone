//
//  TTLoginManager.h
//  NIM
//
//  Created by amao on 5/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHLoginData : NSObject
/**
* 账号
*/
@property (copy, nonatomic) NSString *area;
/** 头像
*
*/
@property (copy, nonatomic) NSString *avatar;

/**
* 昵称
*/
@property (copy, nonatomic) NSString *name;

/**
* token
*/
@property (copy, nonatomic) NSString *token;
/**
* phone
*/
@property (copy, nonatomic) NSString *phone;
/*
* 用户id
*/
@property (assign, nonatomic) long  userID;
/**
* version
*/
@property (copy, nonatomic) NSString *info_modifiable;

@property (copy, nonatomic) NSString *birthday;

@property (copy, nonatomic) NSString *company;
@property (copy, nonatomic) NSString *department;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *org;
@property (assign, nonatomic) NSInteger role;
@property (assign, nonatomic) NSInteger sex;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *academy;//院校
@property (copy, nonatomic) NSString *major;//专业
@property (copy, nonatomic) NSString *class_;//班级
@property (copy, nonatomic) NSString *number;//学号
@end

@interface HHLoginManager: NSObject

+ (instancetype)sharedManager;
@property (nonatomic,strong)    HHLoginData   *currentHHLoginData;
@property (nonatomic, assign) BOOL  bNetworkStatus;
@property (nonatomic, assign) BOOL  bShowAlert;

@property (nonatomic, strong) UIView *statusBar;
-(void)initStatusBar;
@end
