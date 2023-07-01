//
//  CreateConsultationCell.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/21.
//

#import <UIKit/UIKit.h>
#import "FriendModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CreateConsultationCell : UICollectionViewCell

@property (retain, nonatomic) UIImage               *image;
@property (retain, nonatomic) FriendModel           *model;

@end

NS_ASSUME_NONNULL_END
