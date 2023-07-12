//
//  ConsultationCell.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/20.
//

#import "ConsultationCell.h"

@interface ConsultationCell()

@property (retain, nonatomic) UILabel               *labelTitle;
@property (retain, nonatomic) UILabel               *labelStartTime;
@property (retain, nonatomic) UILabel               *labelDuration;
@property (retain, nonatomic) UILabel               *labelMemberTitle;
@property (retain, nonatomic) YYLabel               *labelMember;
@property (retain, nonatomic) UIView                *viewLine;
@property (assign, nonatomic) NSInteger             width;

@end

@implementation ConsultationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setModel:(ConsultationModel *)model{
    self.labelTitle.text = [NSString stringWithFormat:@"标题：%@", model.title];
    self.labelStartTime.text = [NSString stringWithFormat:@"开始时间：%@", model.begin_time];
    NSInteger delTime = [Tools insertStarTimeo:model.begin_time andInsertEndTime:model.end_time];
    delTime = (delTime == 0) ? 1 : delTime;
    self.labelDuration.text = [NSString stringWithFormat:@"会诊时长：%ld分钟", (long)delTime];
    NSString *name = @"";
    for (FriendModel *member in model.members) {
        name = [NSString stringWithFormat:@"%@%@、", name, member.name];
    }
    name = [name substringToIndex:name.length - 1];
//
//
    NSMutableAttributedString *attributeMember = [[NSMutableAttributedString alloc] initWithString:name];
    attributeMember.yy_font = Font15;
    attributeMember.yy_color = MainBlack;
    attributeMember.yy_lineSpacing = Ratio2;
    
    CGSize introSize = CGSizeMake(screenW - Ratio25 - self.width, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:attributeMember];
    CGFloat introHeight = layout.textBoundingSize.height;
    self.labelMember.attributedText = attributeMember;
    self.labelMember.sd_layout.heightIs(introHeight);
    [self.labelMember updateLayout];
}


- (void)setupView{
    [self.contentView addSubview:self.labelTitle];
    [self.contentView addSubview:self.labelStartTime];
    [self.contentView addSubview:self.labelDuration];
    [self.contentView addSubview:self.labelMemberTitle];
    [self.contentView addSubview:self.labelMember];
    [self.contentView addSubview:self.viewLine];
    self.labelTitle.sd_layout.leftSpaceToView(self.contentView, Ratio11).topSpaceToView(self.contentView, Ratio8).heightIs(Ratio15).rightSpaceToView(self.contentView, Ratio11);
    self.labelStartTime.sd_layout.leftEqualToView(self.labelTitle).rightEqualToView(self.labelTitle).topSpaceToView(self.labelTitle, Ratio5).heightIs(Ratio15);
    self.labelDuration.sd_layout.leftEqualToView(self.labelTitle).rightEqualToView(self.labelTitle).topSpaceToView(self.labelStartTime, Ratio5).heightIs(Ratio15);
    
    self.width = [Tools widthForString:@"专家组成员：" fontSize:Ratio13 andHeight:Ratio15];
    self.labelMemberTitle.sd_layout.leftEqualToView(self.labelTitle).heightIs(Ratio15).topSpaceToView(self.labelDuration, Ratio5).widthIs(self.width+Ratio3);
    self.labelMember.sd_layout.leftSpaceToView(self.labelMemberTitle, 0).heightIs(Ratio15).topSpaceToView(self.labelDuration, Ratio3).rightSpaceToView(self.contentView, Ratio11);
    self.viewLine.sd_layout.leftEqualToView(self.labelTitle).rightEqualToView(self.labelTitle).topSpaceToView(self.labelMember, Ratio8).heightIs(Ratio1);
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
    
    
    
}

- (UILabel *)labelTitle{
    if (!_labelTitle) {
        _labelTitle = [self setupLabel];
    }
    return _labelTitle;
}

- (UILabel *)labelStartTime{
    if (!_labelStartTime) {
        _labelStartTime = [self setupLabel];
    }
    return _labelStartTime;
}

- (UILabel *)labelDuration{
    if (!_labelDuration) {
        _labelDuration = [self setupLabel];
    }
    return _labelDuration;
}

- (UILabel *)labelMemberTitle{
    if (!_labelMemberTitle) {
        _labelMemberTitle = [self setupLabel];
        _labelMemberTitle.text = @"专家组成员：";
    }
    return _labelMemberTitle;
}

- (YYLabel *)labelMember{
    if (!_labelMember) {
        _labelMember = [[YYLabel alloc] init];
        _labelMember.numberOfLines = 0;
    }
    return _labelMember;
}

- (UIView *)viewLine{
    if (!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine;
}

- (UILabel *)setupLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = Font13;
    label.textColor = MainBlack;
    return label;
}

@end
