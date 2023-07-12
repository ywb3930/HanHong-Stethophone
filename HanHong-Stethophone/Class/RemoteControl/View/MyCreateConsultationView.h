//
//  MyCreateConsultationView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/20.
//

#import <UIKit/UIKit.h>
#import "ConsultationCell.h"


@protocol MyCreateConsultationViewDelegate <NSObject>

- (void)actionModifyConsultationCallback:(ConsultationModel *_Nullable)model;
- (void)actionTableViewCellClickCallback:(ConsultationModel *_Nullable)model;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MyCreateConsultationView : UITableView

@property (weak, nonatomic) id<MyCreateConsultationViewDelegate> createConsultationDelegate;

- (void)initData;
@end

NS_ASSUME_NONNULL_END
