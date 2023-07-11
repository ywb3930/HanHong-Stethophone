//
//  PasswordItemView.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PasswordItemView : UIView

@property (strong, nonatomic) UITextField       *textFieldPass;
- (instancetype)initWithTitle:(NSString *)title bMust:(Boolean)bMust placeholder:(NSString *)placeholder;

@end

NS_ASSUME_NONNULL_END
