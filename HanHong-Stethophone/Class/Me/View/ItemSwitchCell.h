//
//  ItemSwitchCell.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ItemSwitchCellDelegaete <NSObject>

- (void)actionSwitchChangeCallback:(Boolean)value cell:(UITableViewCell *)cell;

@end

@interface ItemSwitchCell : UITableViewCell

@property (weak, nonatomic) id<ItemSwitchCellDelegaete> delegate;
@property (retain, nonatomic) NSString                  *title;
@property (retain, nonatomic) NSString                  *value;
@property (retain, nonatomic) UISwitch              *switchButton;

@end

NS_ASSUME_NONNULL_END
