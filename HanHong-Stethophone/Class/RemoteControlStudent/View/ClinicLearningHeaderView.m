//
//  ClinicLearningHeaderView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/10.
//

#import "ClinicLearningHeaderView.h"
#import "LabelTextFieldItemView.h"

@interface ClinicLearningHeaderView()

@property (retain, nonatomic) UILabel                       *labelRoomMessage;
@property (retain, nonatomic) LabelTextFieldItemView        *itemTeachingState;
@property (retain, nonatomic) LabelTextFieldItemView        *itemStarTime;
@property (retain, nonatomic) LabelTextFieldItemView        *itemLearnCount;
@property (retain, nonatomic) LabelTextFieldItemView        *itemMemberCount;
@property (retain, nonatomic) UILabel                       *labelRecordMessage;

@property (retain, nonatomic) UIView                        *viewLine1;
@property (retain, nonatomic) UIView                        *viewLine2;

@property (retain, nonatomic) UILabel                       *labelTeach;
@property (retain, nonatomic) UIImageView                   *imageViewTeach;
@property (retain, nonatomic) UILabel                       *labelTeachName;
@property (retain, nonatomic) UIImageView                   *imageViewTag;
@property (retain, nonatomic) UIImageView                   *imageViewOnLine;

@property (retain, nonatomic) UILabel                       *labelAddMember;


@end

@implementation ClinicLearningHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = WHITECOLOR;
        [self setupView];
    }
    return self;
}

- (void)setTeachAvatar:(NSString *)teachAvatar{
    if (![Tools isBlankString:teachAvatar]) {
        [self.imageViewTeach sd_setImageWithURL:[NSURL URLWithString:teachAvatar] placeholderImage:nil options:SDWebImageQueryMemoryData];
    }
    
}

- (void)setBOnline:(Boolean)bOnline{
    self.imageViewOnLine.hidden = !bOnline;
}

- (void)setTeachName:(NSString *)teachName{
    self.labelTeachName.text = teachName;
}

- (void)setRoomState:(NSString *)roomState{
    self.itemTeachingState.textFieldInfo.text = roomState;
}

- (void)setStartTime:(NSString *)startTime{
    self.itemStarTime.textFieldInfo.text = startTime;
}

- (void)setLearnCount:(NSString *)learnCount{
    self.itemLearnCount.textFieldInfo.text = learnCount;
}

- (void)setLearnMember:(NSString *)learnMember{
    self.itemMemberCount.textFieldInfo.text = learnMember;
}

- (void)setRoomMessage:(NSString *)roomMessage{
    self.labelRoomMessage.text = roomMessage;
}

- (void)setRecordMessage:(NSString *)recordMessage{
    self.labelRecordMessage.text = recordMessage;
}

- (void)setupView{
    [self addSubview:self.labelRoomMessage];
    [self addSubview:self.itemTeachingState];
    [self addSubview:self.itemStarTime];
    [self addSubview:self.itemLearnCount];
    [self addSubview:self.itemMemberCount];
    [self addSubview:self.labelRecordMessage];
    [self addSubview:self.viewLine1];
    
    [self addSubview:self.labelTeach];
    [self addSubview:self.imageViewTeach];
    [self addSubview:self.imageViewTag];
    [self addSubview:self.imageViewOnLine];
    [self addSubview:self.labelTeachName];
    [self addSubview:self.viewLine2];
    [self addSubview:self.labelAddMember];
    
    self.labelRoomMessage.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self, 0).heightIs(Ratio40);
    self.itemTeachingState.sd_layout.leftSpaceToView(self, Ratio11).rightSpaceToView(self, Ratio11).topSpaceToView(self.labelRoomMessage, 0).heightIs(Ratio33);
    self.itemStarTime.sd_layout.leftSpaceToView(self, Ratio11).rightSpaceToView(self, Ratio11).topSpaceToView(self.itemTeachingState, 0).heightIs(Ratio33);
    self.itemLearnCount.sd_layout.leftSpaceToView(self, Ratio11).rightSpaceToView(self, Ratio11).topSpaceToView(self.itemStarTime, 0).heightIs(Ratio33);
    self.itemMemberCount.sd_layout.leftSpaceToView(self, Ratio11).rightSpaceToView(self, Ratio11).topSpaceToView(self.itemLearnCount, 0).heightIs(Ratio33);
    self.labelRecordMessage.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self.itemMemberCount, 0).heightIs(Ratio40);
    
    self.viewLine1.sd_layout.leftSpaceToView(self, 0).topSpaceToView(self.labelRecordMessage, 0).rightSpaceToView(self, 0).heightIs(Ratio11);
    
    self.labelTeach.sd_layout.topSpaceToView(self.viewLine1, Ratio11).leftSpaceToView(self, Ratio11).heightIs(Ratio16).widthIs(Ratio99);
    self.imageViewTeach.sd_layout.centerXEqualToView(self).widthIs(Ratio55).heightIs(Ratio55).topEqualToView(self.labelTeach);
    self.labelTeachName.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio14).topSpaceToView(self.imageViewTeach, Ratio4);
    self.imageViewTag.sd_layout.rightEqualToView(self.imageViewTeach).bottomEqualToView(self.imageViewTeach).heightIs(Ratio12).widthIs(Ratio12);
    self.imageViewOnLine.sd_layout.rightEqualToView(self.imageViewTeach).topEqualToView(self.imageViewTeach).heightIs(Ratio15).widthIs(Ratio15);
    self.viewLine2.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio11).topSpaceToView(self.labelTeachName, Ratio22);
    self.labelAddMember.sd_layout.leftSpaceToView(self, Ratio11).heightIs(Ratio16).widthIs(Ratio135).topSpaceToView(self.viewLine2, Ratio11);
}

- (UILabel *)labelRoomMessage{
    if (!_labelRoomMessage) {
        _labelRoomMessage = [[UILabel alloc] init];
        _labelRoomMessage.font = Font18;
        _labelRoomMessage.textAlignment = NSTextAlignmentCenter;
        _labelRoomMessage.textColor = MainColor;
    }
    return _labelRoomMessage;
}

- (LabelTextFieldItemView *)itemTeachingState{
    if (!_itemTeachingState) {
        _itemTeachingState = [[LabelTextFieldItemView alloc] initWithTitle:@"教学状态" bMust:NO placeholder:@""];
        _itemTeachingState.textFieldInfo.enabled = NO;
    }
    return _itemTeachingState;
}

- (LabelTextFieldItemView *)itemStarTime{
    if (!_itemStarTime) {
        _itemStarTime = [[LabelTextFieldItemView alloc] initWithTitle:@"开始时间" bMust:NO placeholder:@""];
        _itemStarTime.textFieldInfo.enabled = NO;
    }
    return _itemStarTime;
}


- (LabelTextFieldItemView *)itemLearnCount{
    if (!_itemLearnCount) {
        _itemLearnCount = [[LabelTextFieldItemView alloc] initWithTitle:@"教学次数" bMust:NO placeholder:@""];
        _itemLearnCount.textFieldInfo.enabled = NO;
    }
    return _itemLearnCount;
}

- (LabelTextFieldItemView *)itemMemberCount{
    if (!_itemMemberCount) {
        _itemMemberCount = [[LabelTextFieldItemView alloc] initWithTitle:@"学习人数" bMust:NO placeholder:@""];
        _itemMemberCount.textFieldInfo.enabled = NO;
    }
    return _itemMemberCount;
}

- (UILabel *)labelRecordMessage{
    if (!_labelRecordMessage) {
        _labelRecordMessage = [[UILabel alloc] init];
        _labelRecordMessage.font = Font18;
        _labelRecordMessage.textAlignment = NSTextAlignmentCenter;
        _labelRecordMessage.textColor = UIColor.redColor;
    }
    return _labelRecordMessage;
}

- (UIView *)viewLine2{
    if (!_viewLine2) {
        _viewLine2 = [[UIView alloc] init];
        _viewLine2.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine2;
}

- (UIView *)viewLine1{
    if (!_viewLine1) {
        _viewLine1 = [[UIView alloc] init];
        _viewLine1.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine1;
}


- (UILabel *)labelTeach{
    if (!_labelTeach) {
        _labelTeach = [[UILabel alloc] init];
        _labelTeach.text = @"教授端：";
        _labelTeach.font = Font15;
        _labelTeach.textColor = MainBlack;
    }
    return _labelTeach;
}

- (UIImageView *)imageViewTeach{
    if (!_imageViewTeach) {
        _imageViewTeach = [[UIImageView alloc] init];
        _imageViewTeach.layer.cornerRadius = Ratio4;
        _imageViewTeach.clipsToBounds = YES;
        _imageViewTeach.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageViewTeach;
}

- (UILabel *)labelTeachName{
    if (!_labelTeachName) {
        _labelTeachName = [[UILabel alloc] init];
        
        _labelTeachName.font = Font13;
        _labelTeachName.textAlignment = NSTextAlignmentCenter;
    }
    return _labelTeachName;
}

- (UIImageView *)imageViewTag{
    if (!_imageViewTag) {
        _imageViewTag = [[UIImageView alloc] init];
        _imageViewTag.image = [UIImage imageNamed:@"collection_state"];
        //_imageViewTag.hidden = YES;
    }
    return _imageViewTag;
}

- (UIImageView *)imageViewOnLine{
    if (!_imageViewOnLine) {
        _imageViewOnLine = [[UIImageView alloc] init];
        _imageViewOnLine.image = [UIImage imageNamed:@"on_line"];
        _imageViewOnLine.hidden = YES;
    }
    return _imageViewOnLine;
}

- (UILabel *)labelAddMember{
    if (!_labelAddMember) {
        _labelAddMember = [[UILabel alloc] init];
        _labelAddMember.text = @"已加入学员：";
        _labelAddMember.font = Font15;
        _labelAddMember.textColor = MainBlack;
    }
    return _labelAddMember;
}


- (Boolean)actionHeartLungButtonClickCallback:(NSInteger)idx{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionHeartLungButtonClickCallback:)]) {
        return [self.delegate actionHeartLungButtonClickCallback:idx];
    }
    return YES;
}

- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionHeartLungFilterChange:)]) {
        return [self.delegate actionHeartLungFilterChange:filterModel];
    }
    return YES;
}


@end
