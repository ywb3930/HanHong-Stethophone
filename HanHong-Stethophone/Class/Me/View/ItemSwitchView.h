//
//  ItemSwitchView.h
//  HanHong-Stethophone
//
//  Created by HanHong on 2023/7/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol ItemSwitchViewDelegaete <NSObject>

- (void)actionSwitchChangeCallback:(Boolean)value tag:(NSInteger)tag;

@end

@interface ItemSwitchView : UIView

@property (weak, nonatomic) id<ItemSwitchViewDelegaete> delegate;
@property (retain, nonatomic) NSString                  *title;
@property (retain, nonatomic) NSString                  *value;
@property (retain, nonatomic) UISwitch              *switchButton;

- (instancetype)initWithFrame:(CGRect)frame title:(nullable NSString *)title;

@end
NS_ASSUME_NONNULL_END
