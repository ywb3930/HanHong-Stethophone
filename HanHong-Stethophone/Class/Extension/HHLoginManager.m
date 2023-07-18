//
//  HHLoginManager.m
//  NIM
//
//  Created by amao on 5/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "HHLoginManager.h"
#import "HHFileLocationHelper.h"

#define PAGESIZE  10

#define HMArea                              @"aear"//账号
#define HMAvatar                            @"avatar"//头像
#define HMName                              @"name"//昵称
#define HMToken                             @"token"
#define HMPhone                             @"phone"
#define HMBirthday                          @"birthday"
#define HMCompany                           @"company"
#define HMDepartment                        @"department"
#define HMEmail                             @"email"
#define HMUserID                            @"userID"
#define HMInfo_modifiable                   @"info_modifiable"
#define HMOrg                               @"org"
#define HMRole                              @"role"
#define HMSex                               @"sex"
#define HMTitle                             @"title"
#define HMAcademy                           @"academy"
#define HMMajor                             @"major"
#define HMClass_                            @"class_"
#define HMNumber                            @"number"

@interface HHLoginData ()<NSCoding>



@end

@implementation HHLoginData

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"userID" : @"id"
    };
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _area = @"";
        _avatar = @"";
        _name = @"";
        _token = @"";
        _phone = @"";
        _birthday = @"";
        _company = @"";
        _department = @"";
        _email = @"";
       // _id = [aDecoder decodeDoubleForKey:HMId];
        _info_modifiable = @"";
        _org = @"";
        //_role = [aDecoder decodeIntegerForKey:HMRole];
        //_sex = [aDecoder decodeIntegerForKey:HMSex];
        _title = @"";
        _academy = @"";
        _major = @"";
        _class_ = @"";
        _number = @"";
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _area = [aDecoder decodeObjectForKey:HMArea];
        _avatar = [aDecoder decodeObjectForKey:HMAvatar];
        _name = [aDecoder decodeObjectForKey:HMName];
        _token = [aDecoder decodeObjectForKey:HMToken];
        _phone = [aDecoder decodeObjectForKey:HMPhone];
        _birthday = [aDecoder decodeObjectForKey:HMBirthday];
        _company = [aDecoder decodeObjectForKey:HMCompany];
        _department = [aDecoder decodeObjectForKey:HMDepartment];
        _email = [aDecoder decodeObjectForKey:HMEmail];
        _userID = [aDecoder decodeDoubleForKey:HMUserID];
        _info_modifiable = [aDecoder decodeObjectForKey:HMInfo_modifiable];
        _org = [aDecoder decodeObjectForKey:HMOrg];
        _role = [aDecoder decodeIntegerForKey:HMRole];
        _sex = [aDecoder decodeIntegerForKey:HMSex];
        _title = [aDecoder decodeObjectForKey:HMTitle];
        _academy = [aDecoder decodeObjectForKey:HMAcademy];
        _major = [aDecoder decodeObjectForKey:HMMajor];
        _class_ = [aDecoder decodeObjectForKey:HMClass_];
        _number = [aDecoder decodeObjectForKey:HMNumber];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if (_area.length) {
        [encoder encodeObject:_area forKey:HMArea];
    } else {
        [encoder encodeObject:@"" forKey:HMArea];
    }
    
    if (_avatar.length) {
        [encoder encodeObject:_avatar forKey:HMAvatar];
    } else {
        [encoder encodeObject:@"" forKey:HMAvatar];
    }
    
    if (_name.length) {
        [encoder encodeObject:_name forKey:HMName];
    } else {
        [encoder encodeObject:@"" forKey:HMName];
    }
    
    if (_token.length) {
        [encoder encodeObject:_token forKey:HMToken];
    } else {
        [encoder encodeObject:@"" forKey:HMToken];
    }
    
    if (_phone.length) {
        [encoder encodeObject:_phone forKey:HMPhone];
    } else {
        [encoder encodeObject:@"" forKey:HMPhone];
    }
    
    if (_company.length) {
        [encoder encodeObject:_company forKey:HMCompany];
    } else {
        [encoder encodeObject:@"" forKey:HMCompany];
    }
    
    if (_birthday.length) {
        [encoder encodeObject:_birthday forKey:HMBirthday];
    } else {
        [encoder encodeObject:@"" forKey:HMBirthday];
    }
    
    if (_department.length) {
        [encoder encodeObject:_department forKey:HMDepartment];
    } else {
        [encoder encodeObject:@"" forKey:HMDepartment];
    }
    
    
    
    if (_email.length) {
        [encoder encodeObject:_email forKey:HMEmail];
    } else {
        [encoder encodeObject:@"" forKey:HMEmail];
    }
    
    if (_info_modifiable.length) {
        [encoder encodeObject:_info_modifiable forKey:HMInfo_modifiable];
    } else {
        [encoder encodeObject:@"" forKey:HMInfo_modifiable];
    }
    
    if (_org.length) {
        [encoder encodeObject:_org forKey:HMOrg];
    } else {
        [encoder encodeObject:@"" forKey:HMOrg];
    }
    
    if (_academy.length) {
        [encoder encodeObject:_academy forKey:HMAcademy];
    } else {
        [encoder encodeObject:@"" forKey:HMAcademy];
    }
    
    if (_major.length) {
        [encoder encodeObject:_major forKey:HMMajor];
    } else {
        [encoder encodeObject:@"" forKey:HMMajor];
    }
    
    if (_class_.length) {
        [encoder encodeObject:_class_ forKey:HMClass_];
    } else {
        [encoder encodeObject:@"" forKey:HMClass_];
    }
    
    if (_number.length) {
        [encoder encodeObject:_number forKey:HMNumber];
    } else {
        [encoder encodeObject:@"" forKey:HMNumber];
    }
    
    //[encoder encodeInteger:_org forKey:HMOrg];
    [encoder encodeInteger:_sex forKey:HMSex];
    [encoder encodeInteger:_role forKey:HMRole];
    [encoder encodeDouble:_userID forKey:HMUserID];
    
    if (_title.length) {
        [encoder encodeObject:_title forKey:HMTitle];
    } else {
        [encoder encodeObject:@"" forKey:HMTitle];
    }
}
@end

@interface HHLoginManager ()
@property (nonatomic,copy)  NSString    *filepath;
@end

@implementation HHLoginManager

+ (instancetype)sharedManager
{
    static HHLoginManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filepath = [[HHFileLocationHelper getAppDocumentPath] stringByAppendingPathComponent:@"nim_sdk_HM_login_data"];
        instance = [[HHLoginManager alloc] initWithPath:filepath];
    });
    return instance;
}

- (instancetype)initWithPath:(NSString *)filepath
{
    if (self = [super init])
    {
        _filepath = filepath;
        [self readData];
    }
    return self;
}



- (void)setCurrentHHLoginData:(HHLoginData *)currentHHLoginData
{
    _currentHHLoginData = currentHHLoginData;
    [self saveData];
}

//从文件中读取和保存用户名密码,建议上层开发对这个地方做加密,DEMO只为了做示范,所以没加密
- (void)readData
{
    NSString *filepath = [self filepath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
        _currentHHLoginData = [object isKindOfClass:[HHLoginData class]] ? object : nil;
    }
}

- (void)saveData
{
    NSData *data = [NSData data];
    if (_currentHHLoginData) {
        data = [NSKeyedArchiver archivedDataWithRootObject:_currentHHLoginData];
    }
    [data writeToFile:[self filepath] atomically:YES];
}

- (void)initStatusBar
{
    if (@available(iOS 13.0, *)) {
        UIWindow *keyWindow = [UIApplication sharedApplication].windows[0];
        self.statusBar = [[UIView alloc] initWithFrame:keyWindow.windowScene.statusBarManager.statusBarFrame];
        [keyWindow addSubview:self.statusBar];
    } else {
        // Fallback on earlier versions
    }
}

@end
