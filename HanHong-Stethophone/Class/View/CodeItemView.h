//
//  CodeItemView.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CodeItemViewDelegate <NSObject>

- (void)actionGetCode:(UIButton *)button;

@end

@interface CodeItemView : UIView

@property (weak, nonatomic) id<CodeItemViewDelegate>        delegate;
@property (retain, nonatomic) UITextField       *textFieldCode;
- (instancetype)initWithTitle:(NSString *)title bMust:(Boolean)bMust placeholder:(NSString *)placeholder;
- (void)deallocView;
- (void)showTimer;

@end

NS_ASSUME_NONNULL_END
