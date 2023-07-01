//
//  RegisterItemView.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RegisterItemView : UIView

@property (retain, nonatomic) UITextField       *textFieldInfo;
@property (assign, nonatomic) Boolean           hiddenLine;
- (instancetype)initWithTitle:(NSString *)title bMust:(Boolean)bMust  placeholder:(NSString *)placeholder;

@end

NS_ASSUME_NONNULL_END
