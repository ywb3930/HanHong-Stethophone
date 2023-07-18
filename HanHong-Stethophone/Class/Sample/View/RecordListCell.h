//
//  RecordListCell.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RecordListCellDelegate <NSObject>

- (Boolean)actionRecordListCellItemClick:(RecordModel *)model bSelected:(Boolean)bSelected numberOfPage:(NSInteger)numberOfPage;

@end

@interface RecordListCell : UITableViewCell

@property (weak, nonatomic) id<RecordListCellDelegate> delegate;
@property (retain, nonatomic) RecordModel       *recordModel;
@property (assign, nonatomic) float           playProgess;
@property (assign, nonatomic) Boolean         bPlayButtonSelected;
@property (assign, nonatomic) NSInteger       numberOfPage;

@end

NS_ASSUME_NONNULL_END
