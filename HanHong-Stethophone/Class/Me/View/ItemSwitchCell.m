//
//  ItemSwitchCell.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/19.
//

#import "ItemSwitchCell.h"

@interface ItemSwitchCell()

@property (retain, nonatomic) UILabel               *labelTitle;

@property (retain, nonatomic) UIView                *viewLine;

@end

@implementation ItemSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self setupView];
    }
    return self;
}

- (void)actionSwitchChange:(UISwitch *)switchBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionSwitchChangeCallback:cell:)]) {
        [self.delegate actionSwitchChangeCallback:switchBtn.isOn cell:self];
    }
}

- (void)setTitle:(NSString *)title{
    self.labelTitle.text = title;
}

- (void)setValue:(NSString *)value{
    self.switchButton.on = [value boolValue];
}

- (void)setupView{
    [self.contentView addSubview:self.switchButton];
    [self.contentView addSubview:self.labelTitle];
    self.switchButton.sd_layout.centerYEqualToView(self.contentView).heightIs(Ratio22).widthIs(Ratio33).rightSpaceToView(self.contentView, Ratio11);
    self.labelTitle.sd_layout.leftSpaceToView(self.contentView, Ratio11).centerYEqualToView(self.contentView).rightSpaceToView(self.switchButton, Ratio11).heightIs(Ratio22);
    [self.contentView addSubview:self.viewLine];
    self.viewLine.sd_layout.leftEqualToView(self.labelTitle).rightEqualToView(self.switchButton).heightIs(Ratio1).bottomSpaceToView(self.contentView, 0);
}

- (UILabel *)labelTitle{
    if(!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textColor = MainBlack;
        _labelTitle.font = Font15;
    }
    return _labelTitle;
}

- (UISwitch *)switchButton{
    if(!_switchButton) {
        _switchButton = [[UISwitch alloc] init];
        [_switchButton addTarget:self action:@selector(actionSwitchChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchButton;
}

- (UIView *)viewLine{
    if(!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine;
}

@end
