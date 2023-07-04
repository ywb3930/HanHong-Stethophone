//
//  MLAlertView.h
//  AlertView
//
//  Created by Admin on 2018/6/6.
//  Copyright © 2018年 mlb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MLAlertViewResultBlock)(NSInteger index);

@interface MLAlertView : UIView

/**
 *  view创建方法
 *  @param title     大标题
 *  @param message   副标题或描述
 *  @param textAlignment   副标题或描述 的字体位置 如果没有设置副标题，则设置无效
 *  @param itemArr   按钮item数组 不设置则弹出view无法消失，按钮最多3个，多设置取前3
 */
- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message andMessageAlignment:(NSTextAlignment)textAlignment andItem:(NSArray<NSString *> *)itemArr andMessageFontSize:(CGFloat)size andSelectBlock:(void(^)(NSInteger index))selectBlock;

/** 大标题title的字体大小 */
@property (nonatomic, strong) UIFont * titleLabelFont;

/** 大标题title的字体颜色 */
@property (nonatomic, strong) UIColor * titleLabelColor;

/** 副标题或描述message的字体颜色 */
@property (nonatomic, strong) UIColor * messageLabelColor;

/** 按钮item的字体大小 */
@property (nonatomic, strong) UIFont * buttonFont;

@property (nonatomic, strong) UIFont * messageFont;

/** 横线和竖线的颜色 */
@property (nonatomic, strong) UIColor * lineViewColor;


/** 总共最多3个item 按顺序把颜色放数组里面就行了，没item设置无效，多设置按顺序取 */
@property (nonatomic, strong) NSArray<UIColor *> * itemTitleColorArr;

@property (nonatomic, strong) NSArray      *arrayStr;

@property (nonatomic,   copy) MLAlertViewResultBlock selectBlock;

/** bgView */
@property (nonatomic, strong) UIView * maskView;

/** 设置副标题某段文字的颜色 如果设置了副标题颜色messageLabelColor，必须放在前面，否则此处设置无效，会被messageLabelColor覆盖，如果没有副标题则此处设置无效 */
- (void)messageLabelTextColorWith:(NSRange)range andColor:(UIColor *)color;


@end
