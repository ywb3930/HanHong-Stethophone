//
//  TTActionSheet.h
//  TimeTolls
//
//  Created by mac on 2019/11/30.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TTActionSheetDelegate <NSObject>

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag;

@end

@interface TTActionSheet : UIView

@property (weak, nonatomic) id<TTActionSheetDelegate> delegate;

@property (retain, nonatomic) UIColor *viewBackgroundColor;
@property (retain, nonatomic) UIColor *itemTitleColor;
@property (retain, nonatomic) UIColor *itemBackgroundColor;
@property (retain, nonatomic) UIColor *cancelTitleColor;

+ (instancetype)showActionSheet:(NSArray *)items cancelTitle:(NSString *)title andItemColor:(UIColor *)itemTitleColor andItemBackgroundColor:(UIColor *)itemBackgroundColor andCancelTitleColor:(UIColor *)cancelTitleColor andViewBackgroundColor:(UIColor *)viewBackgroundColor;
- (void)showInView:(nullable UIView *)view;
@end

NS_ASSUME_NONNULL_END
