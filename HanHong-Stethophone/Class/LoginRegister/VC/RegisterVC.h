//
//  RegisterVC.h
//  HM-Stethophone
//  注册界面
//  Created by Eason on 2023/6/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RegisterVC : UIViewController

@property (assign, nonatomic) NSInteger         loginType;
@property (assign, nonatomic) NSInteger         teachRole;
@property (retain, nonatomic) NSString          *org;

@end

NS_ASSUME_NONNULL_END
