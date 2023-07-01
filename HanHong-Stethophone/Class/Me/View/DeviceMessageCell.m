//
//  DeviceMessageCell.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/29.
//

#import "DeviceMessageCell.h"

@interface DeviceMessageCell()

@property (retain, nonatomic) UILabel           *labelTitle;
@property (retain, nonatomic) UILabel           *labelMessage;

@end

@implementation DeviceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    self.labelTitle.text = title;
}

- (void)setMessage:(NSString *)message{
    self.labelMessage.text = message;
}

- (void)setupView{
    [self.contentView addSubview:self.labelTitle];
    [self.contentView addSubview:self.labelMessage];
    self.labelTitle.sd_layout.leftSpaceToView(self.contentView, Ratio11).centerYEqualToView(self.contentView).heightIs(Ratio15).widthIs(Ratio44);
    [self.labelTitle setSingleLineAutoResizeWithMaxWidth:screenW/2];   self.labelMessage.sd_layout.leftSpaceToView(self.labelTitle, 0).centerYEqualToView(self.contentView).rightSpaceToView(self.contentView, Ratio11).autoHeightRatio(0);
    [self setupAutoHeightWithBottomView:self.labelMessage bottomMargin:Ratio11];
}

- (UILabel *)labelTitle{
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textColor = MainBlack;
        _labelTitle.font = Font13;
    }
    return _labelTitle;
}

- (UILabel *)labelMessage{
    if (!_labelMessage) {
        _labelMessage = [[UILabel alloc] init];
        _labelMessage.textColor = MainBlack;
        _labelMessage.font = Font13;
    }
    return _labelMessage;
}


@end
