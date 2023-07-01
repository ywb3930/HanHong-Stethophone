//
//  SelectOrgVC.h
//  HM-Stethophone
//  选择组织界面
//  Created by Eason on 2023/6/14.
//

#import <UIKit/UIKit.h>
#import "OrgModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SelectOrgVCDelegate <NSObject>

- (void)actionSelectItem:(OrgModel *)model;

@end

@interface SelectOrgVC : UIViewController
@property (weak, nonatomic) id<SelectOrgVCDelegate> delegate;
@property (assign, nonatomic) NSInteger             org_type;

@end

NS_ASSUME_NONNULL_END
