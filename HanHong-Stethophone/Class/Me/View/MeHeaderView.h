//
//  MeHeaderView.h
//  HM-Stethophone
//  我的界面头部
//  Created by Eason on 2023/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeHeaderView : UITableViewHeaderFooterView

@property (retain, nonatomic) UIImageView           *imageViewHeadView;
@property (retain, nonatomic) UILabel               *labelName;
@property (retain, nonatomic) UILabel               *labelUserId;

@end

NS_ASSUME_NONNULL_END
