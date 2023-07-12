//
//  CreateConsultationHeaderView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/21.
//

#import <UIKit/UIKit.h>
#import "RightDirectionView.h"
#import "LabelTextFieldItemView.h"
#import "ConsultationModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CreateConsultationHeaderViewDelegate <NSObject>

@optional
- (void)actionItemStartTimeClickCallback;

@end

@interface CreateConsultationHeaderView : UICollectionReusableView

@property (weak, nonatomic) id<CreateConsultationHeaderViewDelegate> delegate;
@property (retain, nonatomic) RightDirectionView        *itemTimeView;
@property (retain, nonatomic) LabelTextFieldItemView          *itemTitleView;
@property (retain, nonatomic) LabelTextFieldItemView          *itemDurationView;
@property (retain, nonatomic) ConsultationModel         *consultationModel;

@end

NS_ASSUME_NONNULL_END
