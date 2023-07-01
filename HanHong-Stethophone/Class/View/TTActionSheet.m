//
//  TTActionSheet.m
//  TimeTolls
//
//  Created by mac on 2019/11/30.
//  Copyright © 2019 mac. All rights reserved.
//

#import "TTActionSheet.h"
#define ITEM_HEIGHT Ratio44

@interface TTActionSheet()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) UIVisualEffectView              *effectView;
@property (retain, nonatomic) NSArray                       *items;
@property (retain, nonatomic) NSString                      *cancelTitle;
@property (retain, nonatomic) UIView                        *viewBg;


@end

@implementation TTActionSheet

+ (instancetype)showActionSheet:(NSArray *)items cancelTitle:(NSString *)title andItemColor:(UIColor *)itemTitleColor andItemBackgroundColor:(UIColor *)itemBackgroundColor andCancelTitleColor:(UIColor *)cancelTitleColor andViewBackgroundColor:(UIColor *)viewBackgroundColor{
    TTActionSheet *sheet = [[TTActionSheet alloc] initWithActionItems:items cancelButtonTitle:title andItemColor:itemTitleColor andItemBackgroundColor:itemBackgroundColor andCancelTitleColor:cancelTitleColor andViewBackgroundColor:viewBackgroundColor];
    return sheet;
}

- (instancetype)initWithActionItems:(NSArray *)items cancelButtonTitle:(NSString *)title  andItemColor:(UIColor *)itemTitleColor andItemBackgroundColor:(UIColor *)itemBackgroundColor andCancelTitleColor:(UIColor *)cancelTitleColor andViewBackgroundColor:(UIColor *)viewBackgroundColor{
    self = [super init];
    if (self) {
        self.items = [NSMutableArray arrayWithArray:items];
        self.cancelTitle = title;
        self.itemTitleColor = itemTitleColor;
        self.itemBackgroundColor = itemBackgroundColor;
        self.viewBackgroundColor = viewBackgroundColor;
        self.cancelTitleColor = cancelTitleColor;
        [self layoutView];
    }
    return self;
}

- (void)layoutView{
    
//    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
//    self.effectView = effectView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    self.viewBg = [UIView new];
    self.viewBg.backgroundColor = self.viewBackgroundColor;
    [self addSubview:self.viewBg];
    
    UILabel *lblCancel = [[UILabel alloc] init];
    lblCancel.textColor = self.cancelTitleColor;
    lblCancel.text = self.cancelTitle;
    lblCancel.font = Font15;
    lblCancel.backgroundColor = self.itemBackgroundColor;
    lblCancel.textAlignment = NSTextAlignmentCenter;
    [self.viewBg addSubview:lblCancel];
    
    CGFloat viewHeight = (1+self.items.count)*ITEM_HEIGHT+Ratio9+self.items.count;
    self.viewBg.sd_layout.bottomSpaceToView(self, 0).leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(viewHeight+kBottomSafeHeight);
    lblCancel.sd_layout.bottomSpaceToView(self.viewBg, kBottomSafeHeight).leftSpaceToView(self.viewBg, 0).rightSpaceToView(self.viewBg, 0).heightIs(ITEM_HEIGHT);
    
    UIView *viewBottom = [UIView new];
    viewBottom.backgroundColor = self.itemBackgroundColor;
    [self.viewBg addSubview:viewBottom];
    viewBottom.sd_layout.bottomSpaceToView(self.viewBg, 0).leftSpaceToView(self.viewBg, 0).rightSpaceToView(self.viewBg, 0).heightIs(kBottomSafeHeight);
    
    UIView *lastItem = lblCancel;
    for (NSInteger i = self.items.count - 1; i >= 0; i--) {
        UIButton *btnItem = [[UIButton alloc] init];
        [btnItem setTitleColor:self.itemTitleColor forState:UIControlStateNormal];
        [btnItem setTitle:self.items[i] forState:UIControlStateNormal];
        btnItem.tag = i + 1;
        btnItem.backgroundColor = self.itemBackgroundColor;
        [self.viewBg addSubview:btnItem];
        btnItem.sd_layout.bottomSpaceToView(lastItem, 0).leftSpaceToView(self.viewBg, 0).rightSpaceToView(self.viewBg, 0).heightIs(ITEM_HEIGHT);
        lastItem = btnItem;
        btnItem.titleLabel.font = Font15;
        [btnItem addTarget:self action:@selector(actionSelectItem:) forControlEvents:UIControlEventTouchUpInside];
        //if(i != self.items.count - 1) {
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = HEXCOLOR(0xF5F5F1, 1);
            [self.viewBg addSubview:line];
            line.sd_layout.leftSpaceToView(self.viewBg, 0).rightSpaceToView(self.viewBg, 0).heightIs(Ratio1).topSpaceToView(btnItem, 0);
        //}
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat radius = Ratio9; // 圆角大小
        UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight; // 圆角位置，全部位置
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.viewBg.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.viewBg.bounds;
        maskLayer.path = path.CGPath;
        self.viewBg.layer.mask = maskLayer;
    });
    
}

- (void)actionSelectItem:(UIButton *)btn{
    [self removeActionSheet];
    if(self.delegate && [self.delegate respondsToSelector:@selector(actionSelectItem:tag:)]){
        [self.delegate actionSelectItem:btn.tag-1 tag:self.tag];
    }
}

#pragma mark - Action
- (void)tap:(UITapGestureRecognizer *)tap
{
    switch (tap.state) {
        case UIGestureRecognizerStateEnded:{
            [self removeActionSheet];
        }
            break;
        default:
            break;
    }
}


- (void)removeActionSheet
{
    __weak __typeof (self) weakSelf = self;
    CGFloat height = self.viewBg.height + kBottomSafeHeight;
    if (self.viewBg.height > screenH*.5f) {
        height = screenH * .5f - Ratio30; // 30是毫无意义的只是不想让他超出屏幕一半高度而已
    }
    [UIView animateWithDuration:.3f delay:.1f usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.viewBg.transform = CGAffineTransformMakeTranslation(0, height);
        weakSelf.backgroundColor = UIColor.clearColor;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}


- (void)showInView:(UIView *)view
{
    if (!view) view = [UIApplication sharedApplication].keyWindow;
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self layoutIfNeeded];
    
    CGFloat height = self.viewBg.height;
    if (@available(iOS 11.0, *)) {
        height += [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    if (self.viewBg.height > screenH*.5f) {
        height = screenH * .5f - Ratio30;
    }
    [self.viewBg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    self.viewBg.transform = CGAffineTransformMakeTranslation(0, height);

    __weak __typeof (self) weakSelf = self;
    [UIView animateWithDuration:.3f delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.backgroundColor = HEXCOLOR(0x111111, 0.5);
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3f animations:^{
        }];
    }];
}

@end
