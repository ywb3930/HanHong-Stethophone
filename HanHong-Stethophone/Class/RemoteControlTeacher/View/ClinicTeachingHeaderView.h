//
//  ClinicTeachingHeaderView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/10.
//

#import <UIKit/UIKit.h>
#import "TeachingHistoryModel.h"
#import "HeartFilterLungView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ClinicTeachingHeaderDelegate <NSObject>

- (void)actionButtonClickCallback:(Boolean)start;
- (Boolean)actionHeartLungButtonClickCallback:(NSInteger)idx;
- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel;

@end

typedef void(^ClinicTeachingHeaderSyncSaveBlock)(Boolean bSyncSave);

@interface ClinicTeachingHeaderView : UICollectionReusableView<HeartFilterLungViewDelegate>

@property (weak, nonatomic) id<ClinicTeachingHeaderDelegate>        delegate;
@property (nonatomic, copy) ClinicTeachingHeaderSyncSaveBlock           syncSaveBlock;
@property (retain, nonatomic) TeachingHistoryModel              *historyModel;
@property (retain, nonatomic) NSString                          *recordMessage;
@property (retain, nonatomic) NSString                          *roomMessage;
@property (retain, nonatomic) HeartFilterLungView   *heartFilterLungView;
@property (assign, nonatomic) NSInteger                         classroomState;

@end

NS_ASSUME_NONNULL_END
