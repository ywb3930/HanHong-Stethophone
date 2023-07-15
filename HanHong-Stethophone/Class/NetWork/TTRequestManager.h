//
//  TTRequestManager.h
//  TT
//
//  Created by mac on 2019/8/5.
//  Copyright © 2019 ZhiLun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTRequestManager : NSObject

+(instancetype)shareManager;


/***
 获取登录验证码
 */
+(void)userSmsVerCodeLogin:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/***
 获取注册验证码
 */
+(void)userSmsVerCodeRegister:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/***
 获取修改密码验证码
 */
+(void)userSmsVerCodeModifyPassword:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 用户注册
 */
+ (void)userRegister:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 
 获取org清单
 **/
+ (void)orgList:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;


/**
 密码登录
 */
+ (void)userLogin:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;


/**
忘记密码
 */
+ (void)userForgetPassword:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 修改（上传）头像
 */
+ (void)userModifyAvatar:(NSMutableDictionary *)params image:(UIImage *)image progress:(void (^)(NSProgress *  uploadProgress))progress success:(void (^)(id responseObject)) completion failure:(void (^)(NSError *error))failure;

/**
退出登录
 */
+ (void)userLogout:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;


/**
 修改用户信息
 */
+ (void)userModifyInfo:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 修改密码
 */
+ (void)userModifyPassword:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取修改手机验证码
 */
+ (void)userSmsVerCodeModifyPhone:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 修改注册手机
 */
+ (void)userModifyPhone:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 修改注册邮箱
 */
+ (void)userModifyEmail:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
  获取Org信息
 */
+ (void)orgInfo:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 注销用户
 */
+ (void)userLogoff:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取邀请码
 */
+ (void)userInviteCode:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取我创建的会诊列表
 */
+ (void)meetingListCreated:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
  获取会诊列表（我参与的）
 */
+ (void)meetingListParticipated:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取好友列表
 */
+ (void)friendGetFriends:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取好友请求列表
 */
+ (void)friendGetRequests:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 删除好友
 */
+ (void)friendDelete:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 搜索好友
 */
+ (void)friendSearch:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;


/**
 好友请求通过
 */
+ (void)friendApprove:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 好友请求不通过
 */
+ (void)friendDeney:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 请求好友
 */
+ (void)friendRequest:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 删除会诊
 */
+ (void)meetingDeleteMeeting:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 编辑会诊 包括 修改 和 新增
 */
+ (void)meetingEditMeeting:(NSMutableDictionary *)params path:(NSString *)path success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取会议室
 */
+ (void)meetingGetMeetingroom:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取计划列表
 */
+ (void)planList:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取教学记录
 */
+ (void)teachingGetHistory:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取教室
 */
+ (void)teachingGetClassroom:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取教学学生列表
 */
+ (void)teachingGetStudents:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取标本列表
 */
+ (void)recordList:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取音频分类
 */
+ (void)recordTypes:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取录音位置清单
 */
+ (void)recordPositions:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取音频特征分类
 */
+ (void)recordCharacteristics:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取可上传空间
 */
+ (void)recordSpace:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 上传录音标本
 */
+ (void)recordAdd:(NSMutableDictionary *)params recordData:(NSData *)recordData progress:(void (^)(NSProgress *  uploadProgress))progress success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 修改录音标本
 */
+ (void)recordModify:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 删除录音标本
 */
+ (void)recordDelete:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 录音标本分享设置
 */
+ (void)recordShare:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 收藏列表
 */
+ (void)recordFavoriteList:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 收藏删除
 */
+ (void)recordFavoriteDelete:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取APP要求（检测APP更新）
 */
+ (void)appsRequirements:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 获取分享的内容
 */
+ (void)recordShareBrief:(NSString *)share_code success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;

/**
 收藏分享
 */
+ (void)recordShareFavorite:(NSString *)share_code params:(NSMutableDictionary *)params success:(void (^)(id responseObject))completion failure:(void (^)(NSError *error))failure;


@end

NS_ASSUME_NONNULL_END
