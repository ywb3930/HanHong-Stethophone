//
//  ClinicTeachingHeaderView.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/10.
//

#import <UIKit/UIKit.h>
#import "TeachingHistoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ClinicTeachingHeaderDelegate <NSObject>

- (void)actionButtonClickCallback:(Boolean)start;
- (Boolean)actionHeartLungButtonClickCallback:(NSInteger)idx;
- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel;

@end

typedef void(^ClinicTeachingHeaderSyncSaveBlock)(Boolean bSyncSave);

@interface ClinicTeachingHeaderView : UICollectionReusableView

@property (weak, nonatomic) id<ClinicTeachingHeaderDelegate>        delegate;
@property (nonatomic, copy) ClinicTeachingHeaderSyncSaveBlock           syncSaveBlock;
@property (retain, nonatomic) TeachingHistoryModel              *historyModel;
@property (retain, nonatomic) NSString                          *recordMessage;
@property (retain, nonatomic) NSString                          *roomMessage;

@property (assign, nonatomic) NSInteger                         classroomState;

@end

NS_ASSUME_NONNULL_END
