//
//  BeInviteConsultationView.h
//  HanHong-Stethophone
//  被邀请的会诊
//  Created by 袁文斌 on 2023/6/20.
//

#import <UIKit/UIKit.h>
#import "ConsultationCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BeInviteConsultationViewDelegate <NSObject>

- (void)actionTableViewCellClickCallback:(ConsultationModel *_Nullable)model;


@end

@interface BeInviteConsultationView : UITableView

@property (weak, nonatomic) id<BeInviteConsultationViewDelegate> beInviteConsultationViewDelegate;
@property (assign, nonatomic) Boolean           bLoadData;
- (void)initData;
@end

NS_ASSUME_NONNULL_END
