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

- (void)getRequest:(NSString *)url parameters:(id)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;

+ (void)request:(NSString *)url method:(NSString *)method jsonParameters:(id)parameters success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure;

+ (void)downLoadFileWithUrl:(NSString *)url path:(NSString*)path  downloadProgress:(void (^)(NSProgress *downloadProgress))progress successBlock:(void (^)(NSURL *url))success fileDownloadFail:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
