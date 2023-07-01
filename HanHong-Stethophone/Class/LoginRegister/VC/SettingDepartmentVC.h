//
//  SettingDepartmentVC.h
//  HM-Stethophone
//  选择医院部门界面
//  Created by Eason on 2023/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SettingDepartmentViewDelegate <NSObject>

- (void)actionSettingDepartmentCallback:(NSString *)string;

@end

@interface SettingDepartmentVC : UIViewController

@property (weak, nonatomic) id<SettingDepartmentViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
