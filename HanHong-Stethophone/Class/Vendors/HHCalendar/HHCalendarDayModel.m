//
//  HHCalendarDayModel.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/25.
//

#import "HHCalendarDayModel.h"

@implementation HHCalendarDayModel

- (instancetype)init{
    self = [super init];
    if (self) {
        self.modelList = [NSMutableArray array];
    }
    return self;
}

@end
