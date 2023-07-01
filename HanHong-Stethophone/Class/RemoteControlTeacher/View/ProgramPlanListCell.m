//
//  ProgramPlanListCell.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/26.
//

#import "ProgramPlanListCell.h"

@interface ProgramPlanListCell()

@property (retain, nonatomic) UIView                *viewBg;
@property (retain, nonatomic) UILabel               *labelTitle;
@property (retain, nonatomic) UILabel               *labelDay;
@property (retain, nonatomic) UILabel               *labelDuration;

@end

@implementation ProgramPlanListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = ViewBackGroundColor;
        [self setupView];
    }
    return self;
}

- (void)setModel:(ProgramModel *)model{
    //1992-06-11 13:14:10
    self.labelTitle.text = model.program_title;
    NSString *startTime = [Tools convertTimestampToStringYMDHMS:model.startTime];
    NSString *endTime = [Tools convertTimestampToStringYMDHMS:model.endTime];
    self.labelDay.text = [startTime substringToIndex:10];
    NSString *startHM = [startTime substringWithRange:NSMakeRange(11, 5)];
    NSString *endHM = [endTime substringWithRange:NSMakeRange(11, 5)];
    self.labelDuration.text = [NSString stringWithFormat:@"%@-%@", startHM, endHM];
}

- (void)setupView{
    [self.contentView addSubview:self.viewBg];
    [self.viewBg addSubview:self.labelTitle];
    [self.viewBg addSubview:self.labelDay];
    [self.viewBg addSubview:self.labelDuration];
    
    self.viewBg.sd_layout.leftSpaceToView(self.contentView, Ratio22).rightSpaceToView(self.contentView, Ratio22).topSpaceToView(self.contentView, Ratio6).bottomSpaceToView(self.contentView, Ratio6);
    self.labelDay.sd_layout.centerYEqualToView(self.viewBg).rightSpaceToView(self.viewBg, Ratio18).heightIs(Ratio18).widthIs(Ratio99);
    self.labelTitle.sd_layout.leftSpaceToView(self.viewBg, Ratio18).topSpaceToView(self.viewBg, Ratio11).heightIs(Ratio16).rightSpaceToView(self.labelDay, Ratio18);
    self.labelDuration.sd_layout.leftEqualToView(self.labelTitle).heightIs(Ratio15).rightEqualToView(self.labelTitle).bottomSpaceToView(self.viewBg, Ratio11);
}

- (UIView *)viewBg{
    if (!_viewBg) {
        _viewBg = [[UIView alloc] init];
        _viewBg.backgroundColor = WHITECOLOR;
        _viewBg.layer.cornerRadius = Ratio5;
    }
    return _viewBg;
}

- (UILabel *)labelTitle{
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textColor = MainBlack;
        _labelTitle.font = Font15;
    }
    return _labelTitle;
}

-(UILabel *)labelDuration{
    if (!_labelDuration) {
        _labelDuration = [[UILabel alloc] init];
        _labelDuration.font = Font13;
        _labelDuration.textColor = MainGray;
        _labelDuration.textAlignment = NSTextAlignmentLeft;
    }
    return _labelDuration;
}


-(UILabel *)labelDay{
    if (!_labelDay) {
        _labelDay = [[UILabel alloc] init];
        _labelDay.font = Font13;
        _labelDay.textColor = MainGray;
        _labelDay.textAlignment = NSTextAlignmentRight;
    }
    return _labelDay;
}

@end
