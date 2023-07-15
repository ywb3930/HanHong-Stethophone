//
//  RemoteControlDetailHeaderView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/7.
//

#import "RemoteControlDetailHeaderView.h"
#import "LabelTextFieldItemView.h"
#import "HeartFilterLungView.h"

@interface RemoteControlDetailHeaderView()<HeartFilterLungViewDelegate, UITextFieldDelegate>


@property (retain, nonatomic) UILabel               *labelTitle;
@property (retain, nonatomic) LabelTextFieldItemView      *itemTitle;
@property (retain, nonatomic) LabelTextFieldItemView      *itemStartTime;
@property (retain, nonatomic) LabelTextFieldItemView      *itemDuration;
@property (retain, nonatomic) UILabel                       *labelRecordMessage;
 
@property (retain, nonatomic) UIView                *viewLine1;
@property (retain, nonatomic) UIView                *viewLine2;
@property (retain, nonatomic) UIView                *viewLine3;
@property (retain, nonatomic) UILabel               *labelPatient;
@property (retain, nonatomic) UIImageView           *imageViewPatient;
@property (retain, nonatomic) UILabel               *labelPatientName;
@property (retain, nonatomic) UIImageView           *imageViewTag;
@property (retain, nonatomic) UIImageView           *imageViewOnLine;
@property (retain, nonatomic) UIView                *viewRecord;
@property (retain, nonatomic) HeartFilterLungView   *heartFilterLungView;
@property (retain, nonatomic) UIButton              *buttonSaveRecord;
@property (retain, nonatomic) UILabel               *labelSaveRecord;
@property (retain, nonatomic) UILabel               *labelMembers;
@property (retain, nonatomic) UIButton              *buttonConsultation;

@end

@implementation RemoteControlDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = WHITECOLOR;
        [self setupView];
        if (self.syncSaveBlock) {
            self.syncSaveBlock(self.buttonSaveRecord.selected);
        }
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self endEditing:YES];
    return YES;
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


- (void)setTitleMessage:(NSString *)titleMessage{
    self.labelTitle.text = titleMessage;
}

- (void)setBShowStartButton:(Boolean)bShowStartButton{
    self.buttonConsultation.hidden = !bShowStartButton;
}

- (void)setRecordMessage:(NSString *)recordMessage{
    self.labelRecordMessage.hidden = NO;
    self.labelRecordMessage.text = recordMessage;
}

- (void)setBCollector:(Boolean)bCollector{
    if (bCollector) {
        self.buttonConsultation.hidden = NO;
        self.imageViewOnLine.hidden = NO;
        self.viewRecord.hidden = NO;
        self.viewLine3.hidden = NO;
        self.viewRecord.sd_layout.heightIs(Ratio90);
        self.viewLine3.sd_layout.heightIs(Ratio11);
        [self.viewRecord updateLayout];
        [self.viewLine3 updateLayout];
    } else {
        self.buttonConsultation.hidden = YES;
        self.imageViewOnLine.hidden = YES;
        self.viewRecord.hidden = YES;
        self.viewLine3.hidden = YES;
        self.viewRecord.sd_layout.heightIs(0);
        self.viewLine3.sd_layout.heightIs(0);
        [self.viewRecord updateLayout];
        [self.viewLine3 updateLayout];
    }
}

- (void)setBStartRecord:(Boolean)bStartRecord{
    self.buttonConsultation.selected = bStartRecord;
}

- (void)setUserModel:(FriendModel *)userModel{
    self.labelPatientName.text = userModel.name;
    NSString *avatar = userModel.avatar;
    if(![Tools isBlankString:avatar]) {
        [self.imageViewPatient sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:nil options:SDWebImageQueryMemoryData];
    }
    self.imageViewOnLine.hidden = !userModel.bOnLine;
}

- (void)setConsultationModel:(ConsultationModel *)consultationModel{
    NSInteger delTime = [Tools insertStarTimeo:consultationModel.begin_time andInsertEndTime:consultationModel.end_time];
    delTime = (delTime == 0) ? 1 : delTime;
    self.itemDuration.textFieldInfo.text = [NSString stringWithFormat:@"%li分钟", (long)delTime];
    self.itemStartTime.textFieldInfo.text =consultationModel.begin_time;
    self.itemTitle.textFieldInfo.text = consultationModel.title;
    
}

- (void)actionButtonConsultationClick:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionConsultationButtonClick:)]) {
        [self.delegate actionConsultationButtonClick:!button.selected];
    }
}

- (void)setupView{
    [self addSubview:self.labelTitle];
    self.labelTitle.sd_layout.leftSpaceToView(self, Ratio11).rightSpaceToView(self, Ratio11).topSpaceToView(self, 0).heightIs(Ratio44);
    [self addSubview:self.itemTitle];
    self.itemTitle.sd_layout.leftSpaceToView(self, Ratio11).rightSpaceToView(self, Ratio11).topSpaceToView(self.labelTitle, 0).heightIs(Ratio33);
    
    [self addSubview:self.itemStartTime];
    self.itemStartTime.sd_layout.leftSpaceToView(self, Ratio11).rightSpaceToView(self, Ratio11).topSpaceToView(self.itemTitle, Ratio5).heightIs(Ratio33);
    [self addSubview:self.itemDuration];
    self.itemDuration.sd_layout.leftSpaceToView(self, Ratio11).rightSpaceToView(self, Ratio11).topSpaceToView(self.itemStartTime, Ratio5).heightIs(Ratio33);
    [self addSubview:self.labelRecordMessage];
    self.labelRecordMessage.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self.itemDuration, 0).heightIs(Ratio44);
    
    [self addSubview:self.viewLine1];
    self.viewLine1.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self.labelRecordMessage, 0).heightIs(Ratio11);
    
    [self addSubview:self.labelPatient];
    self.labelPatient.sd_layout.topSpaceToView(self.viewLine1, Ratio11).leftSpaceToView(self, Ratio11).heightIs(Ratio16).widthIs(Ratio99);
    
    
    
    [self addSubview:self.imageViewPatient];
    self.imageViewPatient.sd_layout.centerXEqualToView(self).widthIs(Ratio55).heightIs(Ratio55).topEqualToView(self.labelPatient);
    [self addSubview:self.labelPatientName];
    self.labelPatientName.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio14).topSpaceToView(self.imageViewPatient, Ratio4);
    [self addSubview:self.imageViewTag];
    self.imageViewTag.sd_layout.rightEqualToView(self.imageViewPatient).bottomEqualToView(self.imageViewPatient).heightIs(Ratio12).widthIs(Ratio12);
    [self addSubview:self.buttonConsultation];
    self.buttonConsultation.sd_layout.topSpaceToView(self.labelPatient, 0).rightSpaceToView(self, Ratio11).widthIs(Ratio88).heightIs(Ratio33);
    
    [self addSubview:self.imageViewOnLine];
    self.imageViewOnLine.sd_layout.rightEqualToView(self.imageViewPatient).topEqualToView(self.imageViewPatient).heightIs(Ratio15).widthIs(Ratio15);
    
    [self addSubview:self.viewLine2];
    self.viewLine2.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio11).topSpaceToView(self.labelPatientName, Ratio22);
    
    [self addSubview:self.viewRecord];
    self.viewRecord.hidden = YES;
    self.viewRecord.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self.viewLine2, 0).heightIs(0);
    [self.viewRecord addSubview:self.heartFilterLungView];
    self.heartFilterLungView.sd_layout.leftSpaceToView(self.viewRecord, 0).rightSpaceToView(self.viewRecord, 0).heightIs(Ratio44).topSpaceToView(self.viewRecord, Ratio22);
    CGFloat sWidth = [Tools widthForString:@"我想同步保存录音文件" fontSize:Ratio10 andHeight:Ratio20];
    [self.viewRecord addSubview:self.labelSaveRecord];
    self.labelSaveRecord.sd_layout.centerXIs(screenW/2+Ratio10).heightIs(Ratio20).widthIs(sWidth+Ratio1).topSpaceToView(self.heartFilterLungView, -Ratio3);
    [self.viewRecord addSubview:self.buttonSaveRecord];
    self.buttonSaveRecord.sd_layout.rightSpaceToView(self.labelSaveRecord, 0).widthIs(Ratio20).heightIs(Ratio20).centerYEqualToView(self.labelSaveRecord);
    
    [self addSubview:self.viewLine3];
    self.viewLine3.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(0).topSpaceToView(self.viewRecord, 0);
    self.viewLine3.hidden = YES;
    
    [self addSubview:self.labelMembers];
    self.labelMembers.sd_layout.leftSpaceToView(self, Ratio11).heightIs(Ratio16).widthIs(Ratio135).topSpaceToView(self.viewLine3, Ratio11);
    
    
}

- (UILabel *)labelTitle{
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textColor = MainColor;
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        _labelTitle.font = Font18;
    }
    return _labelTitle;
}

- (LabelTextFieldItemView *)itemTitle{
    if (!_itemTitle) {
        _itemTitle = [[LabelTextFieldItemView alloc] initWithTitle:@"会诊标题" bMust:NO placeholder:@""];
        _itemTitle.textFieldInfo.enabled = NO;
        _itemTitle.textFieldInfo.delegate = self;
        _itemTitle.textFieldInfo.returnKeyType = UIReturnKeyDone;
    }
    return _itemTitle;
}

- (UIView *)viewLine2{
    if (!_viewLine2) {
        _viewLine2 = [[UIView alloc] init];
        _viewLine2.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine2;
}

- (UIView *)viewLine3{
    if (!_viewLine3) {
        _viewLine3 = [[UIView alloc] init];
        _viewLine3.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine3;
}

- (UIView *)viewRecord{
    if(!_viewRecord) {
        _viewRecord = [[UIView alloc] init];
    }
    return _viewRecord;
}

- (LabelTextFieldItemView *)itemStartTime{
    if (!_itemStartTime) {
        _itemStartTime = [[LabelTextFieldItemView alloc] initWithTitle:@"开始时间" bMust:NO placeholder:@""];
        _itemStartTime.textFieldInfo.enabled = NO;
    }
    return _itemStartTime;
}

- (LabelTextFieldItemView *)itemDuration{
    if (!_itemDuration) {
        _itemDuration = [[LabelTextFieldItemView alloc] initWithTitle:@"会诊时长" bMust:NO placeholder:@""];
        _itemDuration.textFieldInfo.enabled = NO;
    }
    return _itemDuration;
}

- (UILabel *)labelRecordMessage{
    if (!_labelRecordMessage) {
        _labelRecordMessage = [[UILabel alloc] init];
        _labelRecordMessage.textColor = UIColor.redColor;
        _labelRecordMessage.textAlignment = NSTextAlignmentCenter;
        _labelRecordMessage.font = Font18;
        //_labelRecordMessage.text = @"开始录音";
    }
    return _labelRecordMessage;
}

- (UIView *)viewLine1{
    if (!_viewLine1) {
        _viewLine1 = [[UIView alloc] init];
        _viewLine1.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine1;
}

- (UILabel *)labelPatient{
    if (!_labelPatient) {
        _labelPatient = [[UILabel alloc] init];
        _labelPatient.text = @"患者端：";
        _labelPatient.font = Font15;
        _labelPatient.textColor = MainBlack;
    }
    return _labelPatient;
}

- (UIImageView *)imageViewPatient{
    if (!_imageViewPatient) {
        _imageViewPatient = [[UIImageView alloc] init];
        _imageViewPatient.layer.cornerRadius = Ratio4;
        _imageViewPatient.clipsToBounds = YES;
        _imageViewPatient.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageViewPatient;
}

- (UILabel *)labelPatientName{
    if (!_labelPatientName) {
        _labelPatientName = [[UILabel alloc] init];
        
        _labelPatientName.font = Font13;
        _labelPatientName.textAlignment = NSTextAlignmentCenter;
    }
    return _labelPatientName;
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

- (HeartFilterLungView *)heartFilterLungView{
    if (!_heartFilterLungView) {
        _heartFilterLungView = [[HeartFilterLungView alloc] init];
        _heartFilterLungView.delegate = self;
    }
    return _heartFilterLungView;
}

- (UIButton *)buttonSaveRecord{
    if(!_buttonSaveRecord) {
        _buttonSaveRecord = [[UIButton alloc] init];
        [_buttonSaveRecord setImage:[UIImage imageNamed:@"check_false"] forState:UIControlStateNormal];
        [_buttonSaveRecord setImage:[UIImage imageNamed:@"check_true"] forState:UIControlStateSelected];
        [_buttonSaveRecord addTarget:self action:@selector(actionCilckSaveRecord:) forControlEvents:UIControlEventTouchUpInside];
        _buttonSaveRecord.imageEdgeInsets = UIEdgeInsetsMake(Ratio3, Ratio3, Ratio3, Ratio3);
    }
    return _buttonSaveRecord;
}

- (UILabel *)labelSaveRecord{
    if (!_labelSaveRecord) {
        _labelSaveRecord = [[UILabel alloc] init];
        _labelSaveRecord.text = @"我想同步保存录音文件";
        _labelSaveRecord.font = [UIFont systemFontOfSize:Ratio10];
        _labelSaveRecord.textAlignment = NSTextAlignmentCenter;
        _labelSaveRecord.textColor = MainBlack;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapLavelSaveRecord:)];
        [_labelSaveRecord addGestureRecognizer:tapGesture];
    }
    return _labelSaveRecord;
}

- (void)actionTapLavelSaveRecord:(UITapGestureRecognizer *)tap{
    self.buttonSaveRecord.selected = !self.buttonSaveRecord.selected;
    if (self.syncSaveBlock) {
        self.syncSaveBlock(self.buttonSaveRecord.selected);
    }
}

- (void)actionCilckSaveRecord:(UIButton *)button{
    button.selected = !button.selected;
    if (self.syncSaveBlock) {
        self.syncSaveBlock(self.buttonSaveRecord.selected);
    }
}

- (UILabel *)labelMembers{
    if (!_labelMembers) {
        _labelMembers = [[UILabel alloc] init];
        _labelMembers.text = @"专家组成员：";
        _labelMembers.font = Font15;
        _labelMembers.textColor = MainBlack;
    }
    return _labelMembers;
}

- (UIButton *)buttonConsultation{
    if (!_buttonConsultation) {
        _buttonConsultation = [[UIButton alloc] init];
        [_buttonConsultation setTitle:@"开始会诊" forState:UIControlStateNormal];
        [_buttonConsultation setTitle:@"暂停会诊" forState:UIControlStateSelected];
        [_buttonConsultation setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        _buttonConsultation.backgroundColor = MainColor;
        _buttonConsultation.layer.cornerRadius = Ratio4;
        _buttonConsultation.titleLabel.font = Font15;
        _buttonConsultation.hidden = YES;
        [_buttonConsultation addTarget:self action:@selector(actionButtonConsultationClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonConsultation;
}

@end
