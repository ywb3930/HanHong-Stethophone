//
//  ToolsCheckUpdate.m
//  LiteraryCreation
//
//  Created by Zhilun on 2020/9/15.
//  Copyright © 2020 Zhilun. All rights reserved.
//

#import "ToolsCheckUpdate.h"

@implementation ToolsCheckUpdate

static id _instance;
+ (instancetype)getInstance{
    @synchronized(self){
        if(_instance == nil){
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

- (void)actionToCheckUpdate:(Boolean)bShowToast{
    NSString *url = [[NSString alloc] initWithFormat:@"http://itunes.apple.com/lookup?id=%@",AppId];//替换为自己App的ID
    // 获取本地版本号
    
    [[AFNetRequestManager shareManager] getRequest:url parameters:@{} success:^(id  _Nonnull responseObject) {
        [self actionSuccessCallback:responseObject bShowToast:bShowToast];
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


- (void)actionSuccessCallback:(id)responseObject bShowToast:(Boolean)bShowToast{
    NSString * currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    NSArray * results = responseObject[@"results"];
    if (results && results.count>0)
    {
        NSDictionary * dic = results.firstObject;
        NSString * lineVersion = dic[@"version"];//版本号
        NSString * releaseNotes = dic[@"releaseNotes"];//更新说明
        if ([Tools isBlankString:releaseNotes]) {
            releaseNotes = @"";
        }
        //NSString * trackViewUrl = dic[@"trackViewUrl"];//链接
        //把版本号转换成数值
        NSArray * array1 = [currentVersion componentsSeparatedByString:@"."];
        NSInteger currentVersionInt = 0;
        if (array1.count == 3)//默认版本号1.0.0类型
        {
            currentVersionInt = [array1[0] integerValue]*100 + [array1[1] integerValue]*10 + [array1[2] integerValue];
        }
        NSArray * array2 = [lineVersion componentsSeparatedByString:@"."];
        NSInteger lineVersionInt = 0;
        if (array2.count == 3)
        {
            lineVersionInt = [array2[0] integerValue]*100 + [array2[1] integerValue]*10 + [array2[2] integerValue];
        }
        //线上版本大于本地版本
        if (lineVersionInt > currentVersionInt){
            [Tools showAlertView:[NSString stringWithFormat:@"发现新版本%@",lineVersion] andMessage:releaseNotes andTitles:@[@"取消", @"去更新"] andColors:@[MainGray, MainColor] sure:^{
                NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8",AppId];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:^(BOOL success) {
                    
                }];
            } cancel:^{
                
            }];
        } else if (bShowToast){
            [kAppWindow makeToast:@"暂无新版本" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        }
    }
}

@end
