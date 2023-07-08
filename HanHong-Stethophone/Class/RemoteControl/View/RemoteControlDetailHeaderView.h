//
//  RemoteControlDetailHeaderView.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/7.
//

#import <UIKit/UIKit.h>
#import "ConsultationModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RemoteControlDetailHeaderViewDelegate <NSObject>

- (void)actionConsultationButtonClick:(Boolean)start;
- (Boolean)actionHeartLungButtonClickCallback:(NSInteger)idx;
- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel;

@end

typedef void(^RemoteControlDetailHeaderSyncSaveBlock)(Boolean bSyncSave);

@interface RemoteControlDetailHeaderView : UICollectionReusableView

@property (weak, nonatomic) id<RemoteControlDetailHeaderViewDelegate>  delegate;
@property (nonatomic, copy) RemoteControlDetailHeaderSyncSaveBlock syncSaveBlock;
@property (retain, nonatomic) ConsultationModel         *consultationModel;
@property (retain, nonatomic) FriendModel           *userModel;
@property (assign, nonatomic) Boolean               bCollector;//是否是采集者
@property (retain, nonatomic) NSString              *titleMessage;
@property (retain, nonatomic) NSString              *recordMessage;
@property (assign, nonatomic) Boolean               bStartRecord;//是已开始录音，用于显示按钮
//@property (assign, nonatomic) Boolean               bOnline;//是否是在线状态

@end

NS_ASSUME_NONNULL_END
