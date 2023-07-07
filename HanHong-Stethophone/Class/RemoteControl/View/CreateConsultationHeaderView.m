//
//  CreateConsultationHeaderView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/21.
//

#import "CreateConsultationHeaderView.h"

@interface CreateConsultationHeaderView()

@property (retain, nonatomic) UILabel                   *labelMinute;
@property (retain, nonatomic) UIView                    *viewLine;
@property (retain, nonatomic) UILabel                   *labelTitle;

@end

@implementation CreateConsultationHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = WHITECOLOR;
        [self setupView];
    }
    return self;
}

- (void)setConsultationModel:(ConsultationModel *)consultationModel{
    self.itemTitleView.textFieldInfo.text = consultationModel.title;
    self.itemTimeView.labelInfo.text = consultationModel.begin_time;
    self.itemTimeView.labelInfo.textColor = MainBlack;
    NSInteger duration = [Tools insertStarTimeo:consultationModel.begin_time andInsertEndTime:consultationModel.end_time];
    duration = (duration == 0) ? 1 : duration;
    self.itemDurationView.textFieldInfo.text = [@(duration) stringValue];
}

- (void)actionTapStartTimeItem:(UITapGestureRecognizer *)tap{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionItemStartTimeClickCallback)]) {
        [self.delegate actionItemStartTimeClickCallback];
    }
}

- (void)setupView{
    [self addSubview:self.itemTitleView];
    [self addSubview:self.itemTimeView];
    [self addSubview:self.itemDurationView];
    [self addSubview:self.labelMinute];
    [self addSubview:self.viewLine];
    [self addSubview:self.labelTitle];
    
    self.itemTitleView.sd_layout.leftSpaceToView(self, Ratio11).rightSpaceToView(self, Ratio11).topSpaceToView(self, Ratio11).heightIs(Ratio33);
    self.itemTimeView.sd_layout.leftEqualToView(self.itemTitleView).rightEqualToView(self.itemTitleView).heightIs(Ratio33).topSpaceToView(self.itemTitleView, Ratio5);
    self.itemDurationView.sd_layout.leftEqualToView(self.itemTitleView).topSpaceToView(self.itemTimeView, Ratio10).widthIs(screenW - Ratio66).heightIs(Ratio33);
    self.labelMinute.sd_layout.rightEqualToView(self.itemTitleView).heightIs(Ratio33).centerYEqualToView(self.itemDurationView).leftSpaceToView(self.itemDurationView, 0);
    
    self.viewLine.sd_layout.topSpaceToView(self.itemDurationView, Ratio8).leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio8);
    self.labelTitle.sd_layout.leftSpaceToView(self, Ratio11).heightIs(Ratio55).rightSpaceToView(self, 0).topSpaceToView(self.viewLine, 0);
}


- (LabelTextFieldItemView *)itemTitleView{
    if (!_itemTitleView) {
        _itemTitleView = [[LabelTextFieldItemView alloc] initWithTitle:@"会诊标题" bMust:NO placeholder:@"请输入会诊标题"];
    }
    return _itemTitleView;
}

- (RightDirectionView *)itemTimeView{
    if (!_itemTimeView) {
        _itemTimeView = [[RightDirectionView alloc] initWithTitle:@"开始时间"];
        _itemTimeView.labelInfo.text = @"请选择开始时间";
        _itemTimeView.labelInfo.textColor = HEXCOLOR(0xBBBBBB, 1);
        
        _itemTimeView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapStartTimeItem:)];
        [_itemTimeView addGestureRecognizer:tapView];
    }
    return _itemTimeView;
}

- (LabelTextFieldItemView *)itemDurationView{
    if (!_itemDurationView) {
        _itemDurationView = [[LabelTextFieldItemView alloc] initWithTitle:@"时长" bMust:NO placeholder:@"请输入会诊时长"];
        _itemDurationView.hiddenLine = YES;
        _itemDurationView.textFieldInfo.keyboardType = UIKeyboardTypeNumberPad;

        
    }
    return _itemDurationView;
}

- (UILabel *)labelMinute{
    if (!_labelMinute) {
        _labelMinute = [[UILabel alloc] init];
        _labelMinute.text = @"分钟";
        _labelMinute.textColor = MainBlack;
        _labelMinute.textAlignment = NSTextAlignmentRight;
        _labelMinute.font = Font15;
    }
    return _labelMinute;
}

- (UILabel *)labelTitle{
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.text = @"邀请专家组成员";
        _labelTitle.font = Font15;
        _labelTitle.textColor = MainBlack;
    }
    return _labelTitle;
}


- (UIView *)viewLine{
    if (!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine;
}


@end
