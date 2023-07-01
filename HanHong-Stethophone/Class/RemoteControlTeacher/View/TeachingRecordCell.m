//
//  TeachingRecordCell.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/26.
//

#import "TeachingRecordCell.h"

@interface TeachingRecordCell()

@property (retain, nonatomic) UILabel               *labelNumber;
@property (retain, nonatomic) UILabel               *labelDate;
@property (retain, nonatomic) UILabel               *labelTeachStatus;
@property (retain, nonatomic) UILabel               *labelLearnCount;
@property (retain, nonatomic) UILabel               *labelLearnMember;

@end

@implementation TeachingRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    [self.contentView addSubview:self.labelNumber];
    [self.contentView addSubview:self.labelDate];
    [self.contentView addSubview:self.labelTeachStatus];
    [self.contentView addSubview:self.labelLearnCount];
    [self.contentView addSubview:self.labelLearnMember];
    self.labelNumber.sd_layout.centerYEqualToView(self.contentView).leftSpaceToView(self.contentView, 0).heightIs(Ratio22).widthIs(Ratio44);
    self.labelLearnMember.sd_layout.centerYEqualToView(self.contentView).rightSpaceToView(self.contentView, 0).heightIs(Ratio22).widthIs(Ratio60);
    self.labelLearnCount.sd_layout.centerYEqualToView(self.contentView).rightSpaceToView(self.labelLearnMember, 0).heightIs(Ratio22).widthIs(Ratio60);
    self.labelTeachStatus.sd_layout.centerYEqualToView(self.contentView).rightSpaceToView(self.labelLearnCount, 0).heightIs(Ratio22).widthIs(Ratio60);
    self.labelDate.sd_layout.leftSpaceToView(self.labelNumber, 0).rightSpaceToView(self.labelTeachStatus, 0).heightIs(Ratio22).centerYEqualToView(self.contentView);
}

- (void)setNumber:(NSInteger)number{
    self.labelNumber.text = [@(number + 1) stringValue];
}

- (void)setTeachingHistoryModel:(TeachingHistoryModel *)teachingHistoryModel{
    self.labelDate.text = [teachingHistoryModel.class_begin_time substringToIndex:10];
    self.labelLearnCount.text = [@(teachingHistoryModel.teaching_times) stringValue];
    self.labelLearnMember.text = [@(teachingHistoryModel.number_of_learners) stringValue];
    
    NSInteger state = teachingHistoryModel.state;
    NSString *state_str = (state == 1) ? @"进行中" : (state == 2 ? @"已结束" : @"未开始");
    self.labelTeachStatus.text = state_str;
}


- (UILabel *)labelNumber{
    if (!_labelNumber) {
        _labelNumber = [self setLabel];
    }
    return _labelNumber;
}

- (UILabel *)labelDate{
    if (!_labelDate) {
        _labelDate = [self setLabel];
    }
    return _labelDate;
}

- (UILabel *)labelTeachStatus{
    if (!_labelTeachStatus) {
        _labelTeachStatus = [self setLabel];
        
    }
    return _labelTeachStatus;
}

- (UILabel *)labelLearnCount{
    if (!_labelLearnCount) {
        _labelLearnCount = [self setLabel];
        
    }
    return _labelLearnCount;
}

- (UILabel *)labelLearnMember{
    if (!_labelLearnMember) {
        _labelLearnMember = [self setLabel];
        
    }
    return _labelLearnMember;
}

- (UILabel *)setLabel{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = MainBlack;
    label.font = Font13;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

@end
