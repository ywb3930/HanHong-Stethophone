//
//  RecordListCell.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import <UIKit/UIKit.h>
#import "RecordModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecordListCell : UITableViewCell

@property (retain, nonatomic) RecordModel       *recordModel;

@end

NS_ASSUME_NONNULL_END
