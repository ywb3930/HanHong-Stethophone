//
//  UserInfoTwoView.h
//  HanHong-Stethophone
//
//  Created by HanHong on 2023/7/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^UserInfoTwoViewTapBlock)(void);

@interface UserInfoTwoView : UIView

@property (retain, nonatomic) NSString           *title;
@property (retain, nonatomic) NSString            *info;
@property (retain, nonatomic) UIFont              *titleFont;
@property (retain, nonatomic) UIFont              *infoFont;

@property (nonatomic, copy) UserInfoTwoViewTapBlock tapBlock;
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
