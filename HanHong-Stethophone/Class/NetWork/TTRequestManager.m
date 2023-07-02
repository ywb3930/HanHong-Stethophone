//
//  TTRequestManager.m
//  TT
//
//  Created by mac on 2019/8/5.
//  Copyright © 2019 ZhiLun. All rights reserved.
//

#import "TTRequestManager.h"
@implementation TTRequestManager

+(instancetype)shareManager{
    static TTRequestManager *arm = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arm = [[TTRequestManager alloc] init];
    });
    return arm;
}


/********************* GET   请求   ***************************/
/***
获取验证码
*/
+ (void)userSmsVerCodeLogin:(NSMutableDictionary *)params success:(void (^)(id _Nonnull))completion failure:(void (^)(NSError * _Nonnull))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/sms_ver_code_login",REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/***
 获取注册验证码
 */
+(void)userSmsVerCodeRegister:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/sms_ver_code_register",REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/***
 获取修改密码验证码
 */
+(void)userSmsVerCodeModifyPassword:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/sms_ver_code_modify_password",REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 
 获取org清单
 **/
+ (void)orgList:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@org/list",REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}



/**
 用户注册
 */
+ (void)userRegister:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/register",REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 密码登录
 */
+ (void)userLogin:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/login", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
忘记密码
 */
+ (void)userForgetPassword:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/forget-password", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 修改（上传）头像
 */
+ (void)userModifyAvatar:(NSMutableDictionary *)params image:(UIImage *)image progress:(void (^)(NSProgress *  uploadProgress))progress success:(void (^)(id responseObject)) completion failure:(void (^)(NSError *error))failure{
    NSData *imageData = [Tools zipNSDataWithImage:image];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/plain", @"text/json", @"text/javascript",@"image/png", @"image/jpeg", nil];
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/modify-avatar", REQUEST_URL];
    [manager POST:requestUrl parameters:params headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imageDatas = imageData;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpeg", str];
        [formData appendPartWithFileData:imageDatas name:@"img_file" fileName:fileName mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
退出登录
 */
+ (void)userLogout:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/logout", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 修改用户信息
 */
+ (void)userModifyInfo:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/modify-info", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 修改密码
 */
+ (void)userModifyPassword:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/modify-password", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取修改手机验证码
 */
+ (void)userSmsVerCodeModifyPhone:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/sms_ver_code_modify_phone", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 修改注册手机
 */
+ (void)userModifyPhone:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/modify-phone", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 修改注册邮箱
 */
+ (void)userModifyEmail:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/modify-email", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
  获取Org信息
 */
+ (void)orgInfo:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@org/info", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 注销用户
 */
+ (void)userLogoff:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/logoff", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取邀请码
 */
+ (void)userInviteCode:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/invite_code", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}


/**
 获取我创建的会诊列表
 */
+ (void)meetingListCreated:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@meeting/list_created", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
  获取会诊列表（我参与的）
 */
+ (void)meetingListParticipated:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@meeting/list_participated", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取好友列表
 */
+ (void)friendGetFriends:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@friend/get-friends", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取好友请求列表
 */
+ (void)friendGetRequests:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@friend/get-requests", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 删除好友
 */
+ (void)friendDelete:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@friend/delete", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 搜索好友
 */
+ (void)friendSearch:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@friend/search", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}
/**
好友请求通过
*/
+ (void)friendApprove:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@friend/approve", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}


/**
好友请求不通过
*/
+ (void)friendDeney:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@friend/deney", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 请求好友
 */
+ (void)friendRequest:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@friend/reuqest", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 删除会诊
 */
+ (void)meetingDeleteMeeting:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@meeting/delete_meeting", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 创建会诊
 */
+ (void)meetingEditMeeting:(NSMutableDictionary *)params path:(NSString *)path success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;{
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", REQUEST_URL, path];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}


/**
 获取会议室
 */
+ (void)meetingGetMeetingroom:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@meeting/get_meetingroom", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取计划列表
 */
+ (void)planList:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@plan/list", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取教学记录
 */
+ (void)teachingGetHistory:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@teaching/get_history", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取教室
 */
+ (void)teachingGetClassroom:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@teaching/get_classroom", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取教学学生列表
 */
+ (void)teachingGetStudents:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@teaching/get_students", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取标本列表
 */
+ (void)recordList:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@record/list", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取音频分类
 */
+ (void)recordTypes:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@record/type", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取录音位置清单
 */
+ (void)recordPositions:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@record/positions", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取音频特征分类
 */
+ (void)recordCharacteristics:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@record/characteristics", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 获取可上传空间
 */
+ (void)recordSpace:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@record/space", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 上传录音标本
 */
+ (void)recordAdd:(NSMutableDictionary *)params recordData:(NSData *)recordData progress:(void (^)(NSProgress *  uploadProgress))progress success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/plain", @"text/json", @"text/javascript",@"image/png", @"image/jpeg", nil];
    NSString *requestUrl = [NSString stringWithFormat:@"%@user/modify-avatar", REQUEST_URL];
    [manager POST:requestUrl parameters:params headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.wav", str];
        [formData appendPartWithFileData:recordData name:@"record_file" fileName:fileName mimeType:@"text/html"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    
//    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
//        completion(responseObject);
//    } failure:^(NSError * _Nonnull error) {
//        failure(error);
//    }];
}
/**
 修改录音标本
 */

+ (void)recordModify:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@record/modify", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 删除录音标本
 */
+ (void)recordDelete:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@record/delete", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}
/**
 录音标本分享设置
 */
+ (void)recordShare:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@record/share", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 收藏列表
 */
+ (void)recordFavoriteList:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@record/favorite_list", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 收藏删除
 */
+ (void)recordFavoriteDelete:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure{
    NSString *requestUrl = [NSString stringWithFormat:@"%@record/favorite_delete", REQUEST_URL];
    [AFNetRequestManager noTokenRequest:requestUrl method:METHOD_POST jsonParameters:params bVerify:NO success:^(id _Nonnull responseObject) {
        completion(responseObject);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

@end
