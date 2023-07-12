//
//  AnnotationInfoVC.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^AnnotationInfoResultBlock)(NSString *selectValue);

@interface AnnotationInfoVC : UIViewController

@property (assign, nonatomic) NSInteger         soundType;
@property (nonatomic, copy) AnnotationInfoResultBlock resultBlock;

@end

NS_ASSUME_NONNULL_END
