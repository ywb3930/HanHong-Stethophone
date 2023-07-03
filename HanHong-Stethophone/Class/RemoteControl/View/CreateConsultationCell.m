//
//  CreateConsultationCell.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/21.
//

#import "CreateConsultationCell.h"

@interface CreateConsultationCell()

@property (retain, nonatomic) UIImageView               *imageViewHead;
@property (retain, nonatomic) UILabel                   *labelName;
@property (retain, nonatomic) UIImageView               *imageViewTag;

@end

@implementation CreateConsultationCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setModel:(FriendModel *)model{
    [self.imageViewHead sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:nil options:SDWebImageQueryMemoryData];
    self.labelName.hidden = NO;
    self.labelName.text = model.name;
    self.imageViewTag.hidden = !model.bCollect;
}

- (void)setImage:(UIImage *)image{
    self.imageViewHead.image = image;
    self.labelName.hidden = YES;
    self.imageViewTag.hidden = YES;
}

- (void)setupView{
    [self.contentView addSubview:self.imageViewHead];
    [self.contentView addSubview:self.labelName];
    [self.contentView addSubview:self.imageViewTag];
    CGFloat width = (screenW - Ratio66)/5 - Ratio10;
    self.imageViewHead.sd_layout.leftSpaceToView(self.contentView, Ratio5).rightSpaceToView(self.contentView, Ratio5).topSpaceToView(self.contentView, Ratio5).heightIs(width);
    self.imageViewTag.sd_layout.topSpaceToView(self.contentView, 0).rightSpaceToView(self.contentView, 0).widthIs(Ratio15).heightIs(Ratio15);
    self.labelName.sd_layout.leftSpaceToView(self.contentView, 0).rightSpaceToView(self.contentView, 0).topSpaceToView(self.imageViewHead, Ratio5).heightIs(Ratio15);
}

- (UIImageView *)imageViewHead{
    if (!_imageViewHead) {
        _imageViewHead = [[UIImageView alloc] init];
        _imageViewHead.contentMode = UIViewContentModeScaleAspectFill;
        _imageViewHead.layer.cornerRadius = Ratio5;
        _imageViewHead.clipsToBounds = YES;
    }
    return _imageViewHead;
}

- (UILabel *)labelName{
    if (!_labelName) {
        _labelName = [[UILabel alloc] init];
        _labelName.textColor = MainBlack;
        _labelName.font = Font13;
        _labelName.textAlignment = NSTextAlignmentCenter;
        _labelName.hidden = YES;
    }
    return _labelName;
}

- (UIImageView *)imageViewTag{
    if (!_imageViewTag) {
        _imageViewTag = [[UIImageView alloc] init];
        _imageViewTag.hidden = YES;
        _imageViewTag.image = [UIImage imageNamed:@"collection_state"];
    }
    return _imageViewTag;
}



@end
