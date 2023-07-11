//
//  ClinicCell.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/10.
//

#import "ClinicCell.h"

@interface ClinicCell()

@property (retain, nonatomic) UIImageView               *imageViewHead;
@property (retain, nonatomic) UILabel                   *labelName;
@property (retain, nonatomic) UIImageView               *imageViewTag;
@property (retain, nonatomic) UIImageView               *imageViewOnLine;

@end

@implementation ClinicCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setItemModel:(MemberItemModel *)itemModel{
    Member *member = itemModel.member;
    [self.imageViewHead sd_setImageWithURL:[NSURL URLWithString:member.user_avatar] placeholderImage:nil options:SDWebImageQueryMemoryData];
    self.labelName.hidden = NO;
    self.labelName.text = member.user_name;
    self.imageViewTag.hidden = !itemModel.bConnect;
    self.imageViewOnLine.hidden = !itemModel.bOnline;
    if (itemModel.bConnect) {
        self.imageViewTag.hidden = NO;
        self.imageViewTag.image = [UIImage imageNamed:@"no_collection_state"];
    } else {
        self.imageViewTag.hidden = YES;
    }
}



- (void)setupView{
    [self.contentView addSubview:self.imageViewHead];
    [self.contentView addSubview:self.labelName];
    [self.contentView addSubview:self.imageViewTag];
    [self.contentView addSubview:self.imageViewOnLine];
    CGFloat width = (screenW - Ratio66)/5 - Ratio10;
    self.imageViewHead.sd_layout.leftSpaceToView(self.contentView, Ratio5).rightSpaceToView(self.contentView, Ratio5).topSpaceToView(self.contentView, Ratio5).heightIs(width);
    self.imageViewOnLine.sd_layout.topSpaceToView(self.contentView, 0).rightSpaceToView(self.contentView, 0).widthIs(Ratio15).heightIs(Ratio15);
    self.imageViewTag.sd_layout.bottomSpaceToView(self.contentView, Ratio15).rightSpaceToView(self.contentView, 0).widthIs(Ratio15).heightIs(Ratio15);
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


- (UIImageView *)imageViewOnLine{
    if (!_imageViewOnLine) {
        _imageViewOnLine = [[UIImageView alloc] init];
        _imageViewOnLine.image = [UIImage imageNamed:@"on_line"];
        _imageViewOnLine.hidden = YES;
    }
    return _imageViewOnLine;
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
