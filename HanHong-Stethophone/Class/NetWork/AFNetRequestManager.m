//
//  AFNetRequestManager.m
//  AAAATTT
//
//  Created by mac on 2019/6/6.
//  Copyright © 2019 mac. All rights reserved.
//

#import "AFNetRequestManager.h"


@implementation AFNetRequestManager

+ (instancetype)shareManager{
    static AFNetRequestManager *arm = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arm = [[AFNetRequestManager alloc] init];
    });
    return arm;
}

#pragma mark - 设置请求的配置
- (void)setRequestWithManager:(AFHTTPSessionManager *)manager bToken:(BOOL)btoken bGet:(BOOL)bget{
    //30s超时
    manager.requestSerializer.timeoutInterval = 10;
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    AFSecurityPolicy *securiryPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securiryPolicy setValidatesDomainName:NO];
    manager.securityPolicy = securiryPolicy;
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    if (![[Reachability reachabilityForInternetConnection] isReachable] && bget){
        manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/plain", @"text/json", @"text/javascript", nil];
    
    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", @"PUT", nil];
}
- (void)getRequestTest:(NSString *)url{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self setRequestWithManager:manager bToken:NO bGet:YES];
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
//http://www.aaaa.html?token=AAAAAAAAA&platform=IOS &version=1.0.1
#pragma mark - get请求 btoken 是否需要token
- (void)getRequest:(NSString *)url parameters:(id)parameters bToken:(BOOL)btoken success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self setRequestWithManager:manager bToken:btoken bGet:YES];
    [manager GET:url parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self actionLogOut:responseObject])return;
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [self disposeError:error];
    }];
//    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        success(responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        failure(error);
//        [self disposeError:error];
//    }];
}

#pragma mark - post请求 提交JSON数据 verify 是否需要加密验证
+ (void)request:(NSString *)url method:(NSString *)method jsonParameters:(id)parameters bVerify:(BOOL)verify success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    NSError *error;
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:method URLString:url parameters:nil error:nil];
/*
 [manager.securityPolicy setAllowInvalidCertificates:YES];
 AFSecurityPolicy *securiryPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
 [securiryPolicy setValidatesDomainName:NO];
 manager.securityPolicy = securiryPolicy;
 
 */
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    AFSecurityPolicy *securiryPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securiryPolicy setValidatesDomainName:NO];
    manager.securityPolicy = securiryPolicy;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    
    if (![[Reachability reachabilityForInternetConnection] isReachable] && [method isEqualToString:METHOD_GET]){
        request.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    }


    
    [request setHTTPBody:jsonData];
    request.timeoutInterval = 10.0f;
     __weak typeof(self) wself = self;
    NSURLSessionDataTask *dt = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            failure(error);
            [wself disposeErrorAdd:error];
        }else{
            if([self actionLogOut:responseObject])return;
            success(responseObject);
        }
    }];
    [dt resume];
}


#pragma mark - post请求 提交JSON数据 verify 是否需要加密验证
+ (void)noTokenRequest:(NSString *)url method:(NSString *)method jsonParameters:(id)parameters bVerify:(BOOL)verify success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    NSError *error;
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:method URLString:url parameters:nil error:nil];
    //设置请求头
    AFSecurityPolicy *securiryPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securiryPolicy setValidatesDomainName:YES];
    manager.securityPolicy = securiryPolicy;

    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    if (![[Reachability reachabilityForInternetConnection] isReachable] && [method isEqualToString:METHOD_GET]){
        request.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    }
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    __weak typeof(self) wself = self;
    NSURLSessionDataTask *dt = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            failure(error);
            [wself disposeErrorAdd:error];
        }else{
            if([self actionLogOut:responseObject])return;
            success(responseObject);
        }
    }];
    [dt resume];
}

+ (void)requestNoKey:(NSString *)url method:(NSString *)method jsonParameters:(NSString *)parameters bVerify:(BOOL)verify success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    NSError *error = nil;
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:method URLString:url parameters:nil error:nil];

    [manager.securityPolicy setAllowInvalidCertificates:YES];
    AFSecurityPolicy *securiryPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securiryPolicy setValidatesDomainName:NO];
    manager.securityPolicy = securiryPolicy;

    NSData *jsonData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    
    if (![[Reachability reachabilityForInternetConnection] isReachable] && [method isEqualToString:METHOD_GET]){
        request.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    }
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //joinString    __NSCFString *    @""    0x0000600002786b80
    //sign    __NSCFString *    @"e74ae4a8144af2c600e1e285ff2baed6"    0x0000600000681140
    [request setHTTPBody:jsonData];
    request.timeoutInterval = 10.0f;
     __weak typeof(self) wself = self;
    NSURLSessionDataTask *dt = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            failure(error);
            [wself disposeErrorAdd:error];
        }else{
            if([self actionLogOut:responseObject])return;
            success(responseObject);
        }
    }];
    [dt resume];
}

#pragma mark - put请求
- (void)putRequest:(NSString *)url parameters:(id)parameters bToken:(BOOL)btoken success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self setRequestWithManager:manager bToken:btoken bGet:NO];
    [manager PUT:url parameters:parameters headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self actionLogOut:responseObject])return;
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self disposeError:error];
        failure(error);
    }];
}

#pragma mark - post请求
- (void)postRequest:(NSString *)url parameters:(id)parameters bToken:(BOOL)btoken success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self setRequestWithManager:manager bToken:btoken bGet:NO];
    [manager POST:url parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self actionLogOut:responseObject])return;
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self disposeError:error];
        failure(error);
    }];
    
}


+ (void)postRequestFormUrlencoded:(NSString *)url parameters:(id)parameters bVerify:(BOOL)bverify success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    //NSError *error;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    //设置请求头


    //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    if (![[Reachability reachabilityForInternetConnection] isReachable]){
        manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    }
    

    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:url parameters:parameters headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self actionLogOut:responseObject])return;
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self disposeErrorAdd:error];
        failure(error);
    }];
}

#pragma mark - post请求
- (void)postRequest:(NSString *)url parameters:(id)parameters bToken:(BOOL)btoken  progress:(void (^)(NSProgress * _Nonnull))progress success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self setRequestWithManager:manager bToken:btoken bGet:NO];
    [manager POST:url parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString *key in parameters) {
            [formData appendPartWithFormData:parameters[key] name:key];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self actionLogOut:responseObject])return;
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self disposeError:error];
        failure(error);
    }];
}


#pragma mark - 图片上传
- (void)uploadImages:(NSString *)url images:(NSArray *)images andAssets:(NSArray *)assets parameters:(id)parameters bToken:(BOOL)btoken  progress:(void (^)(NSProgress * _Nonnull))progress success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self setRequestWithManager:manager bToken:btoken bGet:NO];
    [manager POST:url parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (UIImage *image in images) {
             //压缩图片
             NSData *data = [Tools zipNSDataWithImage:image];//UIImageJPEGRepresentation(image, 0.4);
             //多张图片是需要在name中加“[]”，单张上传时不用
             [formData appendPartWithFileData:data name:@"files" fileName:[NSString stringWithFormat:@"%@.jpg",[NSDate date]] mimeType:@"image/jpeg"];
         }
         PHAsset *asset = [assets objectAtIndex:0];
        
         if (asset.mediaType == PHAssetMediaTypeVideo) {
             NSString *outPath = [assets objectAtIndex:1];
             NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:outPath]];
             [formData appendPartWithFileData:data name:@"files" fileName:[NSString stringWithFormat:@"%@.mp4",[NSDate date]] mimeType:@"application/octet-stream"];
         }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self actionLogOut:responseObject])return;
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self disposeError:error];
        failure(error);
    }];
}

#pragma mark - 图片上传
- (void)uploadImages:(NSString *)url base64Parameters:(id)parameters bToken:(BOOL)btoken  progress:(void (^)(NSProgress * _Nonnull))progress success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self setRequestWithManager:manager bToken:btoken bGet:NO];
    [manager POST:url parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString *key in parameters) {
            [formData appendPartWithFormData:parameters[key] name:key];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self actionLogOut:responseObject])return;
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self disposeError:error];
        failure(error);
    }];
}

#pragma mark - delete请求
- (void)deleteRequest:(NSString *)url parameters:(id)parameters bToken:(BOOL)btoken success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self setRequestWithManager:manager bToken:btoken bGet:NO];
    [manager DELETE:url parameters:parameters headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self actionLogOut:responseObject])return;
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self disposeError:error];
        failure(error);
    }];
}

- (BOOL)actionLogOut:(id)responseObject{
    if ([responseObject[@"errorCode"] integerValue] == 63004) {
        [kAppWindow makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
            [Tools logout:@""];
        }];
        
        return YES;
    }
    return NO;
}

+ (BOOL)actionLogOut:(id)responseObject{
    NSInteger errorCode = [responseObject[@"errorCode"] integerValue];
    if (errorCode == 63004 || errorCode == 63003) {
        [kAppWindow makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
            [Tools logout:@""];
        }];
        [SVProgressHUD dismiss];
        return YES;
    }
    return NO;
}

- (void)uploadImages:(NSString *)url parameters:(id)parameters bToken:(BOOL)btoken  progress:(void (^)(NSProgress * _Nonnull))progress success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self setRequestWithManager:manager bToken:btoken bGet:NO];
    [manager POST:url parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString *key in parameters) {
            [formData appendPartWithFormData:parameters[key] name:key];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1009"]) {
            [Tools logout:@""];
        }
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self disposeError:error];
        failure(error);
    }];
}

- (void)disposeError:(NSError *)error{
    [SVProgressHUD dismiss];
    if(error.code == -1009 || error.code == -1008){
        [kAppWindow makeToast:@"😰 网络好像有点问题" duration:showToastViewErrorTime position:CSToastPositionCenter];
        return;
    }
    if(error.code == -1004 || error.code == -1001){
        [kAppWindow makeToast:@"😰 无法连接到服务器" duration:showToastViewErrorTime position:CSToastPositionCenter];
        return;
    }
    NSData *data = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    ///字符串再生成NSData
    NSData * jsondata = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    //再解析
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableLeaves error:nil];
    NSString *message = [jsonDict objectForKey:@"message"];
    
    if (error.code == -1011 || error.code == 1007 ||  error.code == 1008 || error.code == 1009 || [message isEqualToString:@"登录无效或已在别处登录过"] || [message isEqualToString:@"TOKEN无效"] || [message isEqualToString:@"账号不存在"] || [message isEqualToString:@"未登录"]) {
        [Tools logout:message];
    } else if(![Tools isBlankString:message]){
        [kAppWindow makeToast:message duration:showToastViewErrorTime position:CSToastPositionCenter];
    }
}

+ (void)disposeErrorAdd:(NSError *)error{
    [SVProgressHUD dismiss];
    if(error.code == -1009 || error.code == -1008){
        [kAppWindow makeToast:@"😰 网络好像有点问题" duration:showToastViewErrorTime position:CSToastPositionCenter];
        return;
    }
    if(error.code == -1004 || error.code == -1001){
        [kAppWindow makeToast:@"😰 无法连接到服务器" duration:showToastViewErrorTime position:CSToastPositionCenter];
        return;
    }
    NSData *data = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    ///字符串再生成NSData
    NSData * jsondata = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    //再解析
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableLeaves error:nil];
    NSString *message = [jsonDict objectForKey:@"message"];
    
    if (error.code == -1011 || error.code == 1007 ||  error.code == 1008 || error.code == 1009 || [message isEqualToString:@"登录无效或已在别处登录过"] || [message isEqualToString:@"TOKEN无效"] || [message isEqualToString:@"账号不存在"] || [message isEqualToString:@"未登录"]) {
        [Tools logout:message];
    } else  if(![Tools isBlankString:message]){
        [kAppWindow makeToast:message duration:showToastViewErrorTime position:CSToastPositionCenter];
    }
}

@end
