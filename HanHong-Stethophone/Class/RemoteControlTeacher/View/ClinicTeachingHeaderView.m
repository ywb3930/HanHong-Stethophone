//
//  ClinicTeachingHeaderView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/10.
//

#import "ClinicTeachingHeaderView.h"


@interface ClinicTeachingHeaderView()

@property (retain, nonatomic) UILabel               *labelRoomCode;
@property (retain, nonatomic) UIImageView           *imageViewRoomCode;
@property (retain, nonatomic) UIButton              *buttonStartTeach;
@property (retain, nonatomic) UIButton              *buttonStopTeach;
@property (retain, nonatomic) UILabel               *labelRoomMessage;
@property (retain, nonatomic) UIView                *viewLine1;
@property (retain, nonatomic) UIView                *viewLine2;
@property (retain, nonatomic) UILabel               *labelRecordMessage;


@property (retain, nonatomic) UIButton              *buttonSaveRecord;
@property (retain, nonatomic) UILabel               *labelSaveRecord;

@property (retain, nonatomic) UILabel               *labelAddStudent;

@end

@implementation ClinicTeachingHeaderView

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

- (void)setRoomMessage:(NSString *)roomMessage{
    self.labelRoomMessage.text = roomMessage;
}

- (void)setRecordMessage:(NSString *)recordMessage{
    self.labelRecordMessage.text = recordMessage;
}

- (void)setClassroomState:(NSInteger)classroomState{
    CALayer *startTeachLayer = self.buttonStartTeach.layer;
    CALayer *stopTeachLayer = self.buttonStopTeach.layer;
    if(classroomState == 0) {//未开始
        self.buttonStartTeach.backgroundColor = AlreadyColor;
        self.buttonStopTeach.backgroundColor = HEXCOLOR(0xBCBCBC, 1);
        stopTeachLayer.borderWidth = Ratio1;
        stopTeachLayer.borderColor = ColorF5F5F5.CGColor;
    } else if(classroomState == 1) {//已开始
        self.buttonStartTeach.backgroundColor = HEXCOLOR(0xBCBCBC, 1);
        self.buttonStopTeach.backgroundColor = AlreadyColor;
        startTeachLayer.borderWidth = Ratio1;
        startTeachLayer.borderColor = ColorF5F5F5.CGColor;
    } else if(classroomState == 2) {//已结束
        self.buttonStartTeach.backgroundColor = HEXCOLOR(0xBCBCBC, 1);
        self.buttonStopTeach.backgroundColor = HEXCOLOR(0xBCBCBC, 1);
        startTeachLayer.borderWidth = Ratio1;
        startTeachLayer.borderColor = ColorF5F5F5.CGColor;
        stopTeachLayer.borderWidth = Ratio1;
        stopTeachLayer.borderColor = ColorF5F5F5.CGColor;
    }
}

-(void)setHistoryModel:(TeachingHistoryModel *)historyModel{

    self.classroomState = historyModel.class_state;
    NSString *roomScanCode = [NSString stringWithFormat:@"%@/%li", historyModel.server_url, historyModel.classroom_id];
    self.imageViewRoomCode.image = [Tools generateQRCodeWithString:roomScanCode Size:screenW/3];
    
}


- (void)setupView{
    [self addSubview:self.labelRoomCode];
    self.labelRoomCode.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self, Ratio22).heightIs(Ratio20);
    
    [self addSubview:self.imageViewRoomCode];
    self.imageViewRoomCode.sd_layout.centerXEqualToView(self).widthIs(screenW/3).heightIs(screenW/3).topSpaceToView(self.labelRoomCode, Ratio22);
    [self addSubview:self.buttonStopTeach];
    [self addSubview:self.buttonStartTeach];
    self.buttonStartTeach.sd_layout.centerYEqualToView(self.imageViewRoomCode).widthIs(screenW/3 - Ratio44).leftSpaceToView(self, Ratio22).heightIs(screenW/3 - Ratio44);
    self.buttonStopTeach.sd_layout.centerYEqualToView(self.imageViewRoomCode).widthIs(screenW/3 - Ratio44).rightSpaceToView(self, Ratio22).heightIs(screenW/3 - Ratio44);
    
    [self addSubview:self.labelRoomMessage];
    [self addSubview:self.viewLine1];
    self.labelRoomMessage.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio20).topSpaceToView(self.imageViewRoomCode, Ratio22);
    self.viewLine1.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio11).topSpaceToView(self.labelRoomMessage, Ratio22);
    
    [self addSubview:self.labelRecordMessage];
    [self addSubview:self.heartFilterLungView];
    self.labelRecordMessage.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio20).topSpaceToView(self.viewLine1, Ratio11);
    self.heartFilterLungView.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self.labelRecordMessage, Ratio22).heightIs(Ratio33);
    
    CGFloat sWidth = [Tools widthForString:@"我想同步保存录音文件" fontSize:Ratio10 andHeight:Ratio20];
    [self addSubview:self.labelSaveRecord];
    self.labelSaveRecord.sd_layout.centerXIs(screenW/2+Ratio10).heightIs(Ratio20).widthIs(sWidth+Ratio1).topSpaceToView(self.heartFilterLungView, Ratio3);
    [self addSubview:self.buttonSaveRecord];
    self.buttonSaveRecord.sd_layout.rightSpaceToView(self.labelSaveRecord, 0).widthIs(Ratio20).heightIs(Ratio20).centerYEqualToView(self.labelSaveRecord);
    
    [self addSubview:self.viewLine2];
    self.viewLine2.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self.labelSaveRecord, Ratio11).heightIs(Ratio11);
    
    [self addSubview:self.labelAddStudent];
    self.labelAddStudent.sd_layout.leftSpaceToView(self, Ratio11).topSpaceToView(self.viewLine2, Ratio11).heightIs(Ratio16).rightSpaceToView(self, Ratio11);
}


- (UILabel *)labelRoomCode{
    if (!_labelRoomCode) {
        _labelRoomCode = [[UILabel alloc] init];
        _labelRoomCode.text = @"教室码";
        _labelRoomCode.textAlignment = NSTextAlignmentCenter;
        _labelRoomCode.textColor = MainColor;
        _labelRoomCode.font = Font18;
    }
    return _labelRoomCode;
}

- (UIButton *)buttonStartTeach{
    if (!_buttonStartTeach) {
        _buttonStartTeach = [[UIButton alloc] init];
        [_buttonStartTeach setTitle:@"开始\r\n教学" forState:UIControlStateNormal];
        [_buttonStartTeach setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        _buttonStartTeach.layer.cornerRadius = Ratio5;
        _buttonStartTeach.titleLabel.font = Font15;
        _buttonStartTeach.titleLabel.numberOfLines = 0;
        //_buttonStartTeach.backgroundColor = HEXCOLOR(0xBBBBBB, 1);
        _buttonStartTeach.tag = 1;
        [_buttonStartTeach addTarget:self action:@selector(actionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonStartTeach;
}

- (UIButton *)buttonStopTeach{
    if (!_buttonStopTeach) {
        _buttonStopTeach = [[UIButton alloc] init];
        [_buttonStopTeach setTitle:@"结束\r\n教学" forState:UIControlStateNormal];
        [_buttonStopTeach setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        _buttonStopTeach.layer.cornerRadius = Ratio5;
        _buttonStopTeach.titleLabel.font = Font15;
        _buttonStopTeach.titleLabel.numberOfLines = 0;
        //_buttonStopTeach.backgroundColor = MainColor;
        _buttonStopTeach.tag = 2;
        [_buttonStopTeach addTarget:self action:@selector(actionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonStopTeach;
}

- (void)actionButtonClick:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionButtonClickCallback:)]) {
        [self.delegate actionButtonClickCallback:button.tag == 1 ? YES : NO];
    }
}


- (UIImageView *)imageViewRoomCode{
    if (!_imageViewRoomCode) {
        _imageViewRoomCode = [[UIImageView alloc] init];
    }
    return _imageViewRoomCode;
}

- (UILabel *)labelRoomMessage{
    if (!_labelRoomMessage) {
        _labelRoomMessage = [[UILabel alloc] init];
        _labelRoomMessage.textColor = MainColor;
        _labelRoomMessage.textAlignment = NSTextAlignmentCenter;
        _labelRoomMessage.font = Font18;
    }
    return _labelRoomMessage;
}

- (UILabel *)labelRecordMessage{
    if (!_labelRecordMessage) {
        _labelRecordMessage = [[UILabel alloc] init];
        _labelRecordMessage.textColor = UIColor.redColor;
        _labelRecordMessage.textAlignment = NSTextAlignmentCenter;
        _labelRecordMessage.font = Font18;
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

- (UIView *)viewLine2{
    if (!_viewLine2) {
        _viewLine2 = [[UIView alloc] init];
        _viewLine2.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine2;
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

- (void)actionCilckSaveRecord:(UIButton *)button{
    button.selected = !button.selected;
    if (self.syncSaveBlock) {
        self.syncSaveBlock(self.buttonSaveRecord.selected);
    }
}

- (void)actionTapLavelSaveRecord:(UITapGestureRecognizer *)tap{
    self.buttonSaveRecord.selected = !self.buttonSaveRecord.selected;
    if (self.syncSaveBlock) {
        self.syncSaveBlock(self.buttonSaveRecord.selected);
    }
}

- (UILabel *)labelAddStudent{
    if (!_labelAddStudent) {
        _labelAddStudent = [[UILabel alloc] init];
        _labelAddStudent.text = @"已加入学员：";
        _labelAddStudent.textColor = MainBlack;
        _labelAddStudent.font = Font15;
    }
    return _labelAddStudent;
}


@end
