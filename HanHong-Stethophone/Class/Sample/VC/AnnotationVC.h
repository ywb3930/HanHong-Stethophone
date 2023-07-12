//
//  AnnotationVC.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/27.
//

#import <UIKit/UIKit.h>
#import "BaseRecordPlayVC.h"

typedef void(^AnnotationVCRecordModelChangeResultBlock)(RecordModel * _Nullable record);
NS_ASSUME_NONNULL_BEGIN

@interface AnnotationVC : BaseRecordPlayVC

@property (assign, nonatomic) NSInteger               saveLocation;//0 本地 1 云
@property (nonatomic, copy) AnnotationVCRecordModelChangeResultBlock resultBlock;


@end

NS_ASSUME_NONNULL_END
