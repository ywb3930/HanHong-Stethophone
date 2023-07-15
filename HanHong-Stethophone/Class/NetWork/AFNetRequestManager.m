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
- (void)setRequestWithManager:(AFHTTPSessionManager *)manager{
    //30s超时
    manager.requestSerializer.timeoutInterval = 10;
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    AFSecurityPolicy *securiryPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securiryPolicy setValidatesDomainName:NO];
    manager.securityPolicy = securiryPolicy;
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    if (![[Reachability reachabilityForInternetConnection] isReachable]){
        manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/plain", @"text/json", @"text/javascript", nil];
    
    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", @"PUT", nil];
}

- (void)getRequest:(NSString *)url parameters:(id)parameters success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self setRequestWithManager:manager];
    [manager GET:url parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self actionLogOut:responseObject])return;
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [self disposeError:error];
    }];
}

- (void)getRequestTest:(NSString *)url{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self setRequestWithManager:manager];
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}




#pragma mark - post请求 提交JSON数据 verify 是否需要加密验证
+ (void)request:(NSString *)url method:(NSString *)method jsonParameters:(id)parameters success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
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

+ (void)downLoadFileWithUrl:(NSString *)url path:(NSString*)path  downloadProgress:(void (^)(NSProgress *downloadProgress))progress successBlock:(void (^)(NSURL *url))success fileDownloadFail:(void (^)(NSError * error))failure{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:path];
        //return [NSURL URLWithString:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"完成cache：%@",filePath);
        NSHTTPURLResponse *response1 = (NSHTTPURLResponse *)response;
        NSInteger statusCode = [response1 statusCode];
        if (statusCode == 200) {
            success(filePath);
        }else{
            failure(error);
        }
    }];
    [task resume];
   
 
}

@end
