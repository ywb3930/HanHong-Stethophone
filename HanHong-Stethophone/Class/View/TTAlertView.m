//
//  TTAlertView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/19.
//

#import "TTAlertView.h"

@interface TTAlertView()

@property (retain, nonatomic) NSString                  *title;
@property (retain, nonatomic) NSString                  *message;

@end

@implementation TTAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message{
    self = [super init];
    if(self) {
        
    }
    return self;
}

@end
