//
//  UserInfoOneCell.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/15.
//

#import "UserInfoOneCell.h"

@interface UserInfoOneCell()

@property (retain, nonatomic) UILabel               *labelTitle;
@property (retain, nonatomic) UIImageView           *imageViewRight;
@property (retain, nonatomic) UIView                *viewLine;
@property (retain, nonatomic) UIImageView           *imageViewInfo;

@end

@implementation UserInfoOneCell

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

- (void)setAvatar:(NSString *)avatar{
    //_avatar = avatar;
    [self.imageViewInfo sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"avatar"] options:SDWebImageQueryMemoryData];
    self.imageViewInfo.sd_imageTransition = SDWebImageTransition.fadeTransition;
}

- (void)setupView{
    [self.contentView addSubview:self.labelTitle];
    [self.contentView addSubview:self.imageViewInfo];
    [self.contentView addSubview:self.viewLine];
    
    self.labelTitle.sd_layout.leftSpaceToView(self.contentView, Ratio11).topSpaceToView(self.contentView, 0).bottomSpaceToView(self.contentView, 0).widthIs(Ratio33);
    [self.labelTitle setSingleLineAutoResizeWithMaxWidth:Ratio135];
    self.imageViewInfo.sd_layout.centerYEqualToView(self.contentView).widthIs(Ratio36).heightIs(Ratio36).rightSpaceToView(self.contentView, Ratio11);
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

-(UIImageView *)imageViewInfo{
    if(!_imageViewInfo) {
        _imageViewInfo = [[UIImageView alloc] init];
        _imageViewInfo.layer.cornerRadius = Ratio4;
        _imageViewInfo.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageViewInfo;
}


-(UIView *)viewLine{
    if(!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = ColorF5F5F5;
    }
    return _viewLine;
}

@end
