//
//  RightDirectionView.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RightDirectionView : UIView

@property (retain, nonatomic) UILabel           *labelInfo;
@property (retain, nonatomic) UILabel           *labelName;
- (instancetype)initWithTitle:(NSString *)title;
- (void)reloadView;

@end

NS_ASSUME_NONNULL_END
