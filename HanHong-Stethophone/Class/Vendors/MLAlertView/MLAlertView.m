//
//  MLAlertView.m
//  AlertView
//
//  Created by Admin on 2018/6/6.
//  Copyright © 2018年 mlb. All rights reserved.
//

#import "MLAlertView.h"
#import "UIView+MLExtension.h"
#import "NSString+AttributedString.h"

typedef void(^FinishBlock)(NSInteger index);

@interface MLAlertView ()

/** 选中按钮之后的回调block */
@property (nonatomic,   copy) FinishBlock finishBlock;



/** 最顶上的titleLabel */
@property (nonatomic, strong) UILabel *titleLabel;

@property (retain, nonatomic) UIView   *viewBg;

/** 副标题或描述 */
@property (nonatomic, strong) UILabel *messageLabel;

/** 副标题或描述的Alignment */
@property (nonatomic, assign) NSTextAlignment messageAlignment;

/** 副标题或描述的部分字体颜色 */
@property (nonatomic, assign) NSRange range;

/** 横线 */
@property (nonatomic, strong) UIView *lineView;

/** 接收装按钮文字数组的 */
@property (nonatomic, strong) NSArray *itemArr;

/** 接收传进来的titleString */
@property (nonatomic,   copy) NSString *titleString;

/** 接收传进来的messageString */
@property (nonatomic,   copy) NSString *messageString;

/** 装竖线的数组 */
@property (nonatomic, strong) NSMutableArray<UIView *> *btnLineArr;

/** 按钮数组 */
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttonArr;

@end

@implementation MLAlertView{
    /** 这里是可修改的一些基本属性 */
    CGFloat viewWith;//自身弹出alertView的宽度 屏幕宽*（0.5~0.9之间最佳）
    CGFloat viewTop;//title距离顶部的距离 适当调
    CGFloat viewLeftRight;//副标题或描述距离左右的距离 适当调
    CGFloat messageLabelFont;//副标题或描述的字体大小
    CGFloat messageLineSpace;//副标题或描述多行情况下上下两行间的行距 适当调
    CGFloat msgAndLineViewSpace;//副标题或描述与横线之间的距离 大于0 适当调
    CGFloat titleHeight;//titleLabel最顶上大标题占的高度 适当调
    CGFloat btnHeight;//底部按钮item占的高度 适当调
}

- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message andMessageAlignment:(NSTextAlignment)textAlignment andItem:(NSArray<NSString *> *)itemArr andMessageFontSize:(CGFloat)size andSelectBlock:(void(^)(NSInteger index))selectBlock{
    self = [super init];
    if (self) {
        //基本配置调用放最前面
        self.backgroundColor = HEXCOLOR(999999, 0.5);
        messageLabelFont = size;
        _finishBlock = selectBlock;
        _messageAlignment = textAlignment;
        _titleString = title;
        _messageString = message;
        _itemArr = itemArr;
        [self defaultValueMethod];
        [self setupView];
        
       
    }
    return self;
}

/*********基本配置 可根据自身UI风格适当修改**********/
/** 属性赋值配置不可删除 删除之后可能因为取不到值就蹦了 */
- (void)defaultValueMethod{
    viewTop = Ratio22;
    //副标题或描述的字体大小
    messageLabelFont = Ratio17;
    //副标题或描述多行情况下上下两行间的行距 可适当修改
    messageLineSpace = Ratio4;
    //副标题或描述与横线之间的距离 大于0 适当调
    msgAndLineViewSpace = Ratio18;
    //titleLabel最顶上大标题占的高度 可适当修改
    titleHeight = Ratio22;
    //底部按钮item占的高度 可适当修改
    btnHeight = Ratio44;
}

- (void)setupView{
    [self addSubview:self.viewBg];
    [self.viewBg addSubview:self.titleLabel];
    [self.viewBg addSubview:self.messageLabel];
    [self.viewBg addSubview:self.lineView];
    self.viewBg.sd_layout.leftSpaceToView(self, Ratio18).rightSpaceToView(self, Ratio18).centerYEqualToView(self).autoHeightRatio(0);
    if (!self.titleString.length && !self.messageString.length) {
        self.lineView.sd_layout.leftSpaceToView(self.viewBg, 0).rightSpaceToView(self.viewBg, 0).topSpaceToView(self.viewBg, Ratio50).heightIs(Ratio1);
        NSLog(@"没有title和message");
    }else if (self.titleString.length && !self.messageString.length) {
        self.titleLabel.sd_layout.leftSpaceToView(self.viewBg, 0).rightSpaceToView(self.viewBg, 0).topSpaceToView(self.viewBg, viewTop).heightIs(titleHeight);
        self.lineView.sd_layout.leftSpaceToView(self.viewBg, 0).rightSpaceToView(self.viewBg, 0).topSpaceToView(self.titleLabel, msgAndLineViewSpace).heightIs(Ratio1);
    } else if (!self.titleString.length && self.messageString.length) {
        self.messageLabel.sd_layout.leftSpaceToView(self.viewBg, Ratio18).rightSpaceToView(self.viewBg, Ratio18).topSpaceToView(self.viewBg, viewTop).autoHeightRatio(0);
        self.lineView.sd_layout.leftSpaceToView(self.viewBg, 0).rightSpaceToView(self.viewBg, 0).topSpaceToView(self.messageLabel, msgAndLineViewSpace).heightIs(Ratio1);
    } else {
        self.titleLabel.sd_layout.leftSpaceToView(self.viewBg, 0).rightSpaceToView(self.viewBg, 0).topSpaceToView(self.viewBg, viewTop).heightIs(titleHeight);
        self.messageLabel.sd_layout.leftSpaceToView(self.viewBg, Ratio18).rightSpaceToView(self.viewBg, 0).topSpaceToView(self.titleLabel, Ratio18).autoHeightRatio(0);
        self.lineView.sd_layout.leftSpaceToView(self.viewBg, 0).rightSpaceToView(self.viewBg, 0).topSpaceToView(self.messageLabel, msgAndLineViewSpace).heightIs(Ratio1);
    }
    [self.viewBg setupAutoHeightWithBottomView:self.lineView bottomMargin:btnHeight];
    if (!self.itemArr.count) {
        self.lineView.hidden = YES;
        NSLog(@"没有item点击事件，视图无法消失");
    }else{
        //只做最多3个按钮
        [self creatButtonWithCount:(self.itemArr.count > 3 ? 3 : self.itemArr.count)];
        
    }
    
}

- (void)setMessageFont:(UIFont *)messageFont{
    _messageLabel.font = messageFont;
}


#pragma mark - creatUI lazy

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = Font18;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = self.titleString;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textColor = MainGray;
        _messageLabel.font = [UIFont systemFontOfSize:messageLabelFont];
        _messageLabel.textAlignment = self.messageAlignment;
        _messageLabel.numberOfLines = 0;
        //_messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
        //[_messageLabel sizeToFit];
        
        _messageLabel.text = self.messageString;

    }
    return _messageLabel;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = LineBorderColor;
    }
    return _lineView;
}

- (NSMutableArray *)buttonArr{
    if (!_buttonArr) {
        _buttonArr = [NSMutableArray array];
    }
    return _buttonArr;
}

- (NSMutableArray *)btnLineArr{
    if (!_btnLineArr) {
        _btnLineArr = [NSMutableArray array];
    }
    return _btnLineArr;
}


- (void)creatButtonWithCount:(NSInteger)btncount{
    CGFloat btnW = (screenW - Ratio36)/btncount;
    
    for (int  i = 0; i < btncount; i ++) {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:self.itemArr[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.viewBg addSubview:button];
        [button addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonArr addObject:button];
        button.tag = 10+i;
        //WithFrame:CGRectMake(btnW*i, btnY, btnW, btnH)
        button.sd_layout.leftSpaceToView(self.viewBg, btnW*i).bottomSpaceToView(self.viewBg, 0).heightIs(btnHeight).widthIs(btnW);
    }
    
    if (btncount > 1) {
        for (int i = 1; i < btncount; i ++) {
            UIView *btnLineView = [[UIView alloc] init];
            btnLineView.backgroundColor = LineBorderColor;
            [self.viewBg addSubview:btnLineView];
            [self.btnLineArr addObject:btnLineView];
            btnLineView.sd_layout.leftSpaceToView(self.viewBg, btnW*i).bottomSpaceToView(self.viewBg, 0).widthIs(Ratio1).heightIs(btnHeight);
        }
    }
    
}

#pragma mark - buttonAction

- (void)cancelButtonAction:(UIButton *)btn{
    [self removeFromSuperview];
    if (self.finishBlock) {
        self.finishBlock(btn.tag-10);
    }
}



#pragma mark - data

- (void)setTitleString:(NSString *)titleString{
    self.titleLabel.text = titleString;
}

- (void)setMessageString:(NSString *)messageString{
    self.messageLabel.text = messageString;
    
}

- (void)setLineViewColor:(UIColor *)lineViewColor{
    _lineViewColor = lineViewColor;
    _lineView.backgroundColor = lineViewColor;
    
    for (int i = 0; i < self.btnLineArr.count; i ++) {
        UIView *btnLineView = self.btnLineArr[i];
        btnLineView.backgroundColor = lineViewColor;
    }
}

- (void)setItemTitleColorArr:(NSArray<UIColor *> *)itemTitleColorArr{
    _itemTitleColorArr = itemTitleColorArr;
    if (self.buttonArr.count < 1) {
        NSLog(@"没有item");
        return;
    }
    if (itemTitleColorArr.count < 1) {
        NSLog(@"没有颜色");
        return;
    }
    
    if (self.buttonArr.count > self.itemTitleColorArr.count) {
        for (int i = 0; i < itemTitleColorArr.count; i ++) {
            UIButton *button = self.buttonArr[i];
            [button setTitleColor:self.itemTitleColorArr[i] forState:UIControlStateNormal];
        }
    }else{
        for (int i = 0; i < self.buttonArr.count; i ++) {
            UIButton *button = self.buttonArr[i];
            [button setTitleColor:self.itemTitleColorArr[i] forState:UIControlStateNormal];
        }
    }
}

- (void)setButtonFont:(UIFont *)buttonFont{
    for (int i = 0; i < self.buttonArr.count; i ++) {
        UIButton *button = self.buttonArr[i];
        button.titleLabel.font = buttonFont;
    }
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont{
    self.titleLabel.font = titleLabelFont;
    
}

- (void)setTitleLabelColor:(UIColor *)titleLabelColor{
    self.titleLabel.textColor = titleLabelColor;
}

- (void)setMessageLabelColor:(UIColor *)messageLabelColor{
    self.messageLabel.textColor = messageLabelColor;
    
}

- (void)messageLabelTextColorWith:(NSRange)range andColor:(UIColor *)color{
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithAttributedString:self.messageLabel.attributedText];
    [attri addAttribute:NSForegroundColorAttributeName value:color range:range];
    self.messageLabel.attributedText = attri;
}

- (UIView *)viewBg{
    if (!_viewBg) {
        _viewBg = [[UIView alloc] init];
        _viewBg.backgroundColor = WHITECOLOR;
        _viewBg.layer.cornerRadius = Ratio10;
        _viewBg.clipsToBounds = YES;
    }
    return _viewBg;
}

- (void)dealloc{
    NSLog(@"-----dealloc----");
}

@end
