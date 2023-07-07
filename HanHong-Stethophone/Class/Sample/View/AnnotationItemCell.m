//
//  AnnotationItemCell.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/6.
//

#import "AnnotationItemCell.h"

@interface AnnotationItemCell()

@property (retain, nonatomic) UILabel                   *labelInfo;
@property (retain, nonatomic) UIButton                  *buttonDelete;
@property (retain, nonatomic) UIView                    *viewLine;

@end

@implementation AnnotationItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = MainBlack;
        self.contentView.backgroundColor = MainBlack;
        [self setupView];
    }
    return self;
}

- (void)setRow:(NSInteger)row{
//    if (row == 0) {
//        self.viewLine.hidden = YES;
//        self.buttonDelete.hidden = YES;
//    } else {
        self.viewLine.hidden = NO;
        self.buttonDelete.hidden = NO;
//    }
}

- (void)setTitle:(NSString *)title{
    self.labelInfo.text = title;
}

- (void)setInfo:(NSDictionary *)info{
    NSString *string = [NSString stringWithFormat:@"%@ %@", info[@"time"], info[@"characteristic"]];
    self.labelInfo.text = [string stringByReplacingOccurrencesOfString:@"." withString:@":"];
}

- (void)setupView{
    [self.contentView addSubview:self.labelInfo];
    [self.contentView addSubview:self.buttonDelete];
    [self.contentView addSubview:self.viewLine];
    self.buttonDelete.sd_layout.rightSpaceToView(self.contentView, Ratio2).widthIs(Ratio24).heightIs(Ratio24);
    self.labelInfo.sd_layout.leftSpaceToView(self.contentView, Ratio11).centerYEqualToView(self.contentView).heightIs(Ratio17).rightSpaceToView(self.buttonDelete, Ratio11);
    self.viewLine.sd_layout.leftSpaceToView(self.contentView, 0).topSpaceToView(self.contentView, 0).heightIs(Ratio0_5).rightSpaceToView(self.contentView, 0);
}

- (void)actionToDelete:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionClickDeleteCallback:)]) {
        [self.delegate actionClickDeleteCallback:self];
    }
}


- (UIView *)viewLine{
    if (!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = HEXCOLOR(0xFFFFFF, 0.5);
    }
    return _viewLine;
}


- (UILabel *)labelInfo{
    if (!_labelInfo) {
        _labelInfo = [[UILabel alloc] init];
        _labelInfo.textColor = WHITECOLOR;
        _labelInfo.font = Font15;
    }
    return _labelInfo;
}

- (UIButton *)buttonDelete{
    if (!_buttonDelete) {
        CGFloat f5 = Ratio5;
        _buttonDelete = [[UIButton alloc] init];
        [_buttonDelete setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        _buttonDelete.imageEdgeInsets = UIEdgeInsetsMake(f5, f5, f5, f5);
        [_buttonDelete addTarget:self action:@selector(actionToDelete:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonDelete;
}

@end
