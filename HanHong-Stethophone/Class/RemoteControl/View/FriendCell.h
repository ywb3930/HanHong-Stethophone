//
//  FriendCell.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/21.
//

#import <UIKit/UIKit.h>
#import "FriendModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol FriendCellDelegate <NSObject>

@optional
- (void)actionFriendDeneyCallback:(FriendModel *)model;
- (void)actionFriendApproveCallback:(FriendModel *)model;
- (void)actionAddFriendCallback:(FriendModel *)model;


@end

@interface FriendCell : UITableViewCell

@property (weak, nonatomic) id<FriendCellDelegate>  delegate;
@property (retain, nonatomic) FriendModel           *friendModel;
@property (retain, nonatomic) FriendModel           *searchModel;
@property (retain, nonatomic) FriendModel           *friendNewModel;
@property (assign, nonatomic) Boolean               bShowCheck;


@end

NS_ASSUME_NONNULL_END
