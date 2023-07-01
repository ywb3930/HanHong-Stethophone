//
//  UserInfoTwoCell.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserInfoTwoCell : UITableViewCell

@property (retain, nonatomic) NSString           *title;
@property (retain, nonatomic) NSString            *info;
@property (retain, nonatomic) UIFont              *titleFont;
@property (retain, nonatomic) UIFont              *infoFont;

@end

NS_ASSUME_NONNULL_END
