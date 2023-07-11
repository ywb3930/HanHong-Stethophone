//
//  AppDelegate.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import <UIKit/UIKit.h>
#import <WXApi.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (retain, nonatomic) UIWindow *window;
@property (nonatomic,assign)BOOL allowRotation;


@end

