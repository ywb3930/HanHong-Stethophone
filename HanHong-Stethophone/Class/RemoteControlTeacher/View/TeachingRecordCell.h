//
//  TeachingRecordCell.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/26.
//

#import <UIKit/UIKit.h>
#import "TeachingHistoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TeachingRecordCell : UITableViewCell

@property (retain, nonatomic) TeachingHistoryModel   *teachingHistoryModel;
@property (assign, nonatomic) NSInteger             number;

@end

NS_ASSUME_NONNULL_END
