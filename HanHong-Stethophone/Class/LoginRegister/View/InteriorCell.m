//
//  InteriorCell.m
//  HuiGaiChe
//
//  Created by Zhilun on 2020/5/11.
//  Copyright © 2020 Zhilun. All rights reserved.
//

#import "InteriorCell.h"

@interface InteriorCell()
//商品图片
@property (retain, nonatomic) UIImageView     *imageViewProduct;
//商品名称
@property (retain, nonatomic) UILabel         *labelName;

@end

@implementation InteriorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setModel:(OrgModel *)model{
    [_imageViewProduct sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"logo_icon"] options:SDWebImageQueryMemoryData];
    _imageViewProduct.sd_imageTransition = SDWebImageTransition.fadeTransition;
    _labelName.text = model.name;
}


- (void)setupView{
    [self.contentView addSubview:self.imageViewProduct];
    [self.contentView addSubview:self.labelName];
    
    self.imageViewProduct.sd_layout.leftSpaceToView(self.contentView, Ratio11).centerYEqualToView(self.contentView).widthIs(Ratio36).heightIs(Ratio36);
    self.labelName.sd_layout.leftSpaceToView(self.imageViewProduct, Ratio6).centerYEqualToView(self.contentView).heightIs(Ratio18).rightSpaceToView(self.contentView, Ratio18);
    

}

- (UIImageView *)imageViewProduct{
    if (!_imageViewProduct) {
        _imageViewProduct = [[UIImageView alloc] init];
        _imageViewProduct.layer.cornerRadius = Ratio2;
        _imageViewProduct.contentMode = UIViewContentModeScaleAspectFill;
        _imageViewProduct.clipsToBounds = YES;
    }
    return _imageViewProduct;
}

- (UILabel *)labelName{
    if (!_labelName) {
        _labelName = [[UILabel alloc] init];
        _labelName.font = Font13;
        _labelName.textColor = MainBlack;
    }
    return _labelName;
}


@end
