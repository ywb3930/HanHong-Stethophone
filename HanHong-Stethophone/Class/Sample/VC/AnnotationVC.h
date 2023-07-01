//
//  AnnotationVC.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/27.
//

#import <UIKit/UIKit.h>
#import "HHBaseViewController.h"
#import "RecordModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnnotationVC : HHBaseViewController

@property (retain, nonatomic) RecordModel           *recordModel;

@end

NS_ASSUME_NONNULL_END
