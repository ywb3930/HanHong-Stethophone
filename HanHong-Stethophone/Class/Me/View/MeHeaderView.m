//
//  MeHeaderView.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/15.
//

#import "MeHeaderView.h"

@interface MeHeaderView()

@end

@implementation MeHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

- (void)initView{
    [self.contentView addSubview:self.imageViewHeadView];
    [self.contentView addSubview:self.labelName];
    [self.contentView addSubview:self.labelUserId];
    self.imageViewHeadView.sd_layout.leftSpaceToView(self.contentView, Ratio22).topSpaceToView(self.contentView, kStatusBarHeight + Ratio11).widthIs(Ratio55).heightIs(Ratio55);
    self.labelName.sd_layout.leftSpaceToView(self.imageViewHeadView, Ratio8).heightIs(Ratio15).bottomSpaceToView(self.imageViewHeadView, -Ratio22).rightSpaceToView(self.contentView, Ratio11);
    self.labelUserId.sd_layout.leftSpaceToView(self.imageViewHeadView, Ratio8).heightIs(Ratio15).topSpaceToView(self.labelName, Ratio11).rightSpaceToView(self.contentView, Ratio11);
}

- (UIImageView *)imageViewHeadView{
    if(!_imageViewHeadView) {
        _imageViewHeadView = [[UIImageView alloc] init];
        _imageViewHeadView.layer.cornerRadius = Ratio5;
        _imageViewHeadView.clipsToBounds = YES;
        _imageViewHeadView.contentMode = UIViewContentModeScaleAspectFit;
        _imageViewHeadView.backgroundColor = HEXCOLOR(0x68686A, 1);
    }
    return _imageViewHeadView;
}

- (UILabel *)labelName{
    if(!_labelName) {
        _labelName = [[UILabel alloc] init];
        _labelName.textColor = MainBlack;
        _labelName.font = Font15;
    }
    return _labelName;
}

- (UILabel *)labelUserId{
    if(!_labelUserId) {
        _labelUserId = [[UILabel alloc] init];
        _labelUserId.textColor = MainNormal;
        _labelUserId.font = Font13;
    }
    return _labelUserId;
}

@end
