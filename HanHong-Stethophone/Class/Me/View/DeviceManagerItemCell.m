//
//  DeviceManagerItemCell.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/19.
//

#import "DeviceManagerItemCell.h"

@interface DeviceManagerItemCell()

@property (retain, nonatomic) UILabel               *labelDeviceName;
@property (retain, nonatomic) UILabel               *labelDeviceMac;
@property (retain, nonatomic) UIView                *viewLine;


@end

@implementation DeviceManagerItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setName:(NSString *)name{
    self.labelDeviceName.text = name;
}

- (void)setMac:(NSString *)mac{
    self.labelDeviceMac.text = mac;
}

- (void)setupView{
    [self.contentView addSubview:self.labelDeviceName];
    [self.contentView addSubview:self.labelDeviceMac];
    [self.contentView addSubview:self.viewLine];
    self.labelDeviceName.sd_layout.leftSpaceToView(self.contentView, Ratio11).topSpaceToView(self.contentView, Ratio5).heightIs(Ratio18).rightSpaceToView(self.contentView, Ratio11);
    self.labelDeviceMac.sd_layout.leftEqualToView(self.labelDeviceName).topSpaceToView(self.labelDeviceName, 0).heightIs(Ratio16).rightEqualToView(self.labelDeviceName);
    self.viewLine.sd_layout.leftEqualToView(self.labelDeviceName).rightSpaceToView(self.contentView, 0).bottomSpaceToView(self.contentView, 0).heightIs(Ratio1);
}

- (UILabel *)labelDeviceName{
    if(!_labelDeviceName) {
        _labelDeviceName = [[UILabel  alloc] init];
        _labelDeviceName.font = Font15;
        _labelDeviceName.textColor = MainBlack;
    }
    return _labelDeviceName;
}

- (UILabel *)labelDeviceMac{
    if(!_labelDeviceMac) {
        _labelDeviceMac = [[UILabel  alloc] init];
        _labelDeviceMac.font = Font15;
        _labelDeviceMac.textColor = MainBlack;
    }
    return _labelDeviceMac;
}

- (UIView *)viewLine{
    if(!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine;
}

@end
