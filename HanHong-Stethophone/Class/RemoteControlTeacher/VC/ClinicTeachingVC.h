//
//  ClinicTeachingVC.h
//  HanHong-Stethophone
//  临床教学
//  Created by 袁文斌 on 2023/6/25.
//

#import <UIKit/UIKit.h>
#import "HHBaseRecordVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClinicTeachingHistoryListBlock)(void);

@interface ClinicTeachingVC : HHBaseRecordVC

@property (nonatomic, copy) ClinicTeachingHistoryListBlock           historyListBlock;

@end

NS_ASSUME_NONNULL_END
