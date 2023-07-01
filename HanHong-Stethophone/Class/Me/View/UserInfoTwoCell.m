//
//  UserInfoTwoCell.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/15.
//

#import "UserInfoTwoCell.h"

@interface UserInfoTwoCell()

@property (retain, nonatomic) UILabel               *labelTitle;
@property (retain, nonatomic) UIView                *viewLine;
@property (retain, nonatomic) UILabel               *labelInfo;

@end

@implementation UserInfoTwoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setTitleFont:(UIFont *)titleFont{
    self.labelTitle.font = titleFont;
}

- (void)setInfoFont:(UIFont *)infoFont{
    self.labelInfo.font = infoFont;
}

- (void)setTitle:(NSString *)title{
    self.labelTitle.text = title;
}

- (void)setInfo:(NSString *)info{
    _info = info;
    self.labelInfo.text = info;
}

- (void)setupView{
    [self.contentView addSubview:self.labelTitle];
    [self.contentView addSubview:self.labelInfo];
    [self.contentView addSubview:self.viewLine];
    
    self.labelTitle.sd_layout.leftSpaceToView(self.contentView, Ratio11).topSpaceToView(self.contentView, 0).bottomSpaceToView(self.contentView, 0).widthIs(Ratio33);
    [self.labelTitle setSingleLineAutoResizeWithMaxWidth:screenW/2];
    self.labelInfo.sd_layout.leftSpaceToView(self.labelTitle, Ratio11).rightSpaceToView(self.contentView, Ratio11).topSpaceToView(self.contentView, 0).bottomSpaceToView(self.contentView, 0);
    self.viewLine.sd_layout.leftSpaceToView(self.contentView, Ratio11).bottomSpaceToView(self.contentView, 0).rightSpaceToView(self.contentView, 0).heightIs(Ratio1);
}


- (UILabel *)labelTitle{
    if(!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.font = Font15;
        _labelTitle.textColor = MainBlack;
    }
    return _labelTitle;
}

- (UILabel *)labelInfo{
    if(!_labelInfo) {
        _labelInfo = [[UILabel alloc] init];
        _labelInfo.font = Font15;
        _labelInfo.textColor = MainGray;
        _labelInfo.textAlignment = NSTextAlignmentRight;
    }
    return _labelInfo;
}


-(UIView *)viewLine{
    if(!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = HEXCOLOR(0xF5F5F5, 1);
    }
    return _viewLine;
}

@end
