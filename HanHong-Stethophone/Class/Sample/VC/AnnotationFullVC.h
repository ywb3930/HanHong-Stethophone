//
//  AnnotationFullVC.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/4.
//

#import <UIKit/UIKit.h>
#import "BaseRecordPlayVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^AnnotationFullResultBlock)(Boolean bArrayEqual);

@interface AnnotationFullVC : BaseRecordPlayVC

@property (assign, nonatomic) NSInteger                 saveLocation;//0 本地 1 云
@property (retain, nonatomic) NSMutableArray            *arrayCharacteristic;
@property (nonatomic, copy) AnnotationFullResultBlock   resultBlock;

@end

NS_ASSUME_NONNULL_END
