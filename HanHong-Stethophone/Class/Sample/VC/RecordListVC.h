//
//  RecordListVC.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import <UIKit/UIKit.h>
#import "RecordListCell.h"
#import "BaseRecordPlayVC.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RecordListVCDelegate <NSObject>

//type:0 修改 1：新增 2:删除
- (void)actionRecordListItemChange:(RecordModel *)model type:(NSInteger)type fromIndex:(NSInteger)fromIndex;

@end

@interface RecordListVC : BaseRecordPlayVC

@property (weak, nonatomic) id<RecordListVCDelegate>     delegate;
@property (assign, nonatomic) NSInteger idx;//0 本地， 1 云， 2 收藏
@property (retain, nonatomic) NSString  *string;//0 本地， 1 云， 2 收藏
@property (assign, nonatomic) Boolean bLoadData;//是否已加载数据

- (void)initView;
- (void)initCollectData;
- (void)initCouldData;
- (void)initLocalData;
- (void)addCouldRecordItem:(RecordModel *)model;

@end

NS_ASSUME_NONNULL_END
