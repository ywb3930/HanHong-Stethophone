//
//  AFNetRequestManager.h
//  AAAATTT
//
//  Created by mac on 2019/6/6.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface AFNetRequestManager : NSObject

+ (instancetype)shareManager;
- (void)getRequestTest:(NSString *)url;
/**get请求*/
- (void)getRequest:(NSString *)url parameters:(id)parameters bToken:(BOOL)btoken success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;
/**post请求*/
- (void)postRequest:(NSString *)url parameters:(id)parameters bToken:(BOOL)btoken success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;
/**post请求 提交JSON数据*/
+ (void)request:(NSString *)url method:(NSString *)method jsonParameters:(id)parameters bVerify:(BOOL)verify success:(void (^)(id responseObject))success failure:(void (^)(NSError * error))failure;

/**图片上传*/
- (void)uploadImages:(NSString *)url images:(NSArray *)images andAssets:(NSArray *)assets parameters:(id)parameters  bToken:(BOOL)btoken progress:(void(^)(NSProgress *progress))progress success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;
/**指定资源位置上传其最新的内容，用于修改某个内容*/
- (void)putRequest:(NSString *)url parameters:(id)parameters bToken:(BOOL)btoken success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
/**图片上传 base64编码*/
- (void)uploadImages:(NSString *)url base64Parameters:(id)parameters bToken:(BOOL)btoken progress:(void (^)(NSProgress * progress))progress success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
/**请求服务器删除请求的URI所标识的资源，用于删除*/
- (void)deleteRequest:(NSString *)url parameters:(id)parameters bToken:(BOOL)btoken success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

- (void)uploadImages:(NSString *)url parameters:(id)parameters bToken:(BOOL)btoken  progress:(void (^)(NSProgress *progress))progress success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

- (void)postRequest:(NSString *)url parameters:(id)parameters bToken:(BOOL)btoken  progress:(void (^)(NSProgress *progress))progress success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

+ (void)noTokenRequest:(NSString *)url method:(NSString *)method jsonParameters:(id)parameters bVerify:(BOOL)verify success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure;

+ (void)postRequestFormUrlencoded:(NSString *)url parameters:(id)parameters bVerify:(BOOL)bverify success:(void (^)(id responseObject))success failure:(void (^)(NSError * error))failure;

+ (void)requestNoKey:(NSString *)url method:(NSString *)method jsonParameters:(NSString *)parameters bVerify:(BOOL)verify success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure;

@end

NS_ASSUME_NONNULL_END
