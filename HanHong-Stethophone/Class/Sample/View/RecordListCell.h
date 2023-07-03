//
//  RecordListCell.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import <UIKit/UIKit.h>
#import "RecordModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RecordListCellDelegate <NSObject>

- (Boolean)actionRecordListCellItemClick:(RecordModel *)model bSelected:(Boolean)bSelected idx:(NSInteger)idx;

@end

@interface RecordListCell : UITableViewCell

@property (weak, nonatomic) id<RecordListCellDelegate> delegate;
@property (retain, nonatomic) RecordModel       *recordModel;
@property (assign, nonatomic) float           playProgess;
@property (assign, nonatomic) Boolean         bStop;
@property (assign, nonatomic) NSInteger           idx;

@end

NS_ASSUME_NONNULL_END
