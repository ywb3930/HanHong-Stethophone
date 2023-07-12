//
//  RecordListCell.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import "RecordListCell.h"


@interface RecordListCell()

@property (retain, nonatomic) UIView            *viewBg;
@property (retain, nonatomic) UILabel           *lblTime;
@property (retain, nonatomic) UILabel           *lblName;
@property (retain, nonatomic) UILabel           *lblTag;
@property (retain, nonatomic) UILabel           *lblType;

@property (retain, nonatomic) UIView            *viewRecord;
@property (retain, nonatomic) UIButton          *buttonPlay;
@property (retain, nonatomic) UILabel           *lblTimeStart;
@property (retain, nonatomic) UILabel           *lblTimeEnd;

@property (retain, nonatomic) UISlider          *slider;

@property (retain, nonatomic) UIImageView       *imageViewShare;

@end

@implementation RecordListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self setupView];
    }
    return self;
}

- (void)actionClickPlay:(UIButton *)button{
    if(![[HHBlueToothManager shareManager] getConnectState]) {
        [kAppWindow makeToast:@"请先连接设备" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionRecordListCellItemClick:bSelected:idx:)]) {
        
        Boolean bPlaying = [self.delegate actionRecordListCellItemClick:self.recordModel bSelected:button.selected idx:self.idx];
        button.selected = bPlaying;
    }
}

- (void)setIdx:(NSInteger)idx{
    _idx= idx;
}

- (void)setPlayProgess:(float)playProgess{
    NSLog(@"progress = %f", playProgess / self.recordModel.record_length);
    self.slider.value = playProgess / self.recordModel.record_length;
}

- (void)setBStop:(Boolean)bStop{
    self.buttonPlay.selected = bStop;
}

- (void)setRecordModel:(RecordModel *)recordModel{
    _recordModel = recordModel;
    self.lblTime.text = recordModel.record_time;
    if (![Tools isBlankString:recordModel.patient_id]) {
        self.lblName.text = recordModel.patient_id;
    }
    
    if ([Tools isBlankString:recordModel.characteristics]) {
        self.lblTag.text = @"未标注";
    } else {
        NSArray *array = [Tools jsonData2Array:recordModel.characteristics];
        NSDictionary *dictionary = array[0];
        self.lblTag.text = dictionary[@"characteristic"];
    }
    //self.lblTag.text = [[Constant shareManager] positionTagPositionCn:recordModel.tag];
    if (recordModel.type_id == heart_sounds) {
        self.lblType.text = @"心音";
    } else if (recordModel.type_id == lung_sounds) {
        self.lblType.text = @"肺音";
    } else {
        self.lblType.text = @"";
    }
    if (recordModel.shared == 1) {
        self.imageViewShare.hidden = NO;
        self.imageViewShare.sd_layout.leftSpaceToView(self.viewBg, Ratio8).widthIs(Ratio18);
    } else {
        self.imageViewShare.hidden = YES;
        self.imageViewShare.sd_layout.leftSpaceToView(self.viewBg, 0).widthIs(0);
    }
    [self.imageViewShare updateLayout];
    self.lblTimeStart.text = @"00:00";
    self.lblTimeEnd.text = [Tools getMMSSFromSS:recordModel.record_length];
}

- (void)setupView{
    //self.contentView.backgroundColor = HEXCOLOR(0xE2E8F0, 1);
    [self.contentView addSubview:self.viewBg];
    self.viewBg.sd_layout.leftSpaceToView(self.contentView, 0).rightSpaceToView(self.contentView, 0).topSpaceToView(self.contentView, 0).bottomSpaceToView(self.contentView, Ratio9);
    
    [self.viewBg addSubview:self.imageViewShare];
    [self.viewBg addSubview:self.lblTime];
    [self.viewBg addSubview:self.lblName];
    [self.viewBg addSubview:self.lblTag];
    [self.viewBg addSubview:self.lblType];
    self.imageViewShare.sd_layout.leftSpaceToView(self.viewBg, 0).widthIs(0).heightIs(Ratio18).topSpaceToView(self.viewBg, Ratio11);
    self.lblTime.sd_layout.leftSpaceToView(self.imageViewShare, Ratio8).topSpaceToView(self.viewBg, Ratio11).widthIs(Ratio135 * 1.4).heightIs(Ratio17);
    self.lblName.sd_layout.centerYEqualToView(self.lblTime).rightSpaceToView(self.viewBg, Ratio11).heightIs(Ratio17).leftSpaceToView(self.lblTime, Ratio35);
    self.lblTag.sd_layout.leftSpaceToView(self.viewBg, Ratio8).widthIs(Ratio135).heightIs(Ratio17).bottomSpaceToView(self.viewBg, Ratio11);
    self.lblType.sd_layout.rightSpaceToView(self.viewBg, Ratio11).centerYEqualToView(self.lblTag).heightIs(Ratio17).widthIs(Ratio135);
    
    [self.viewBg addSubview:self.viewRecord];
    self.viewRecord.sd_layout.leftSpaceToView(self.viewBg, Ratio8).rightEqualToView(self.lblName).topSpaceToView(self.lblTime, Ratio9).bottomSpaceToView(self.lblTag, Ratio9);
    [self.viewRecord addSubview:self.buttonPlay];
    self.buttonPlay.sd_layout.leftSpaceToView(self.viewRecord, Ratio8).topSpaceToView(self.viewRecord, Ratio8).bottomSpaceToView(self.viewRecord, Ratio8).widthEqualToHeight();
    
    [self.viewRecord addSubview:self.lblTimeStart];
    [self.viewRecord addSubview:self.lblTimeEnd];
    self.lblTimeStart.sd_layout.leftSpaceToView(self.buttonPlay, Ratio8).centerYEqualToView(self.buttonPlay).heightIs(Ratio17).widthIs(Ratio33);
    self.lblTimeEnd.sd_layout.rightSpaceToView(self.viewRecord, Ratio11).centerYEqualToView(self.buttonPlay).heightIs(Ratio17).widthIs(Ratio33);
    
    [self.viewRecord addSubview:self.slider];
    self.slider.sd_layout.leftSpaceToView(self.lblTimeStart, Ratio5).rightSpaceToView(self.lblTimeEnd, Ratio5).heightIs(Ratio5).centerYEqualToView(self.lblTimeStart);
}



- (UIView *)viewBg{
    if(!_viewBg) {
        _viewBg = [[UIView alloc] init];
        _viewBg.backgroundColor = WHITECOLOR;
        _viewBg.layer.cornerRadius = Ratio9;
        _viewBg.clipsToBounds = YES;
        _viewBg.layer.borderWidth = Ratio1;
        _viewBg.layer.borderColor = ViewBackGroundColor.CGColor;
    }
    return _viewBg;
}

- (UILabel *)lblTime{
    if(!_lblTime){
        _lblTime = [[UILabel alloc] init];
        _lblTime.font = Font12;
        _lblTime.textColor = MainBlack;
    }
    return _lblTime;
}

- (UILabel *)lblName{
    if(!_lblName){
        _lblName = [[UILabel alloc] init];
        _lblName.font = Font12;
        _lblName.textColor = MainBlack;
        _lblName.textAlignment = NSTextAlignmentRight;
    }
    return _lblName;
}

- (UILabel *)lblTag{
    if(!_lblTag){
        _lblTag = [[UILabel alloc] init];
        _lblTag.font = Font12;
        _lblTag.textColor = MainBlack;
    }
    return _lblTag;
}

- (UILabel *)lblType{
    if(!_lblType){
        _lblType = [[UILabel alloc] init];
        _lblType.font = Font12;
        _lblType.textColor = MainBlack;
        _lblType.textAlignment = NSTextAlignmentRight;
    }
    return _lblType;
}

- (UIView *)viewRecord{
    if(!_viewRecord){
        _viewRecord = [[UIView alloc] init];
        _viewRecord.backgroundColor = HEXCOLOR(0xF4F4F4, 1);
        _viewRecord.layer.cornerRadius = Ratio5;
    }
    return _viewRecord;
}

- (UIButton *)buttonPlay{
    if(!_buttonPlay) {
        _buttonPlay = [[UIButton alloc] init];
        [_buttonPlay setImage:[UIImage imageNamed:@"start_play"] forState:UIControlStateNormal];
        [_buttonPlay setImage:[UIImage imageNamed:@"pause_play"] forState:UIControlStateSelected];
        [_buttonPlay addTarget:self action:@selector(actionClickPlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonPlay;
}

- (UILabel *)lblTimeStart{
    if(!_lblTimeStart){
        _lblTimeStart = [[UILabel alloc] init];
        _lblTimeStart.textColor = MainColor;
        _lblTimeStart.font = Font12;
    }
    return _lblTimeStart;
}

- (UILabel *)lblTimeEnd{
    if(!_lblTimeEnd){
        _lblTimeEnd = [[UILabel alloc] init];
        _lblTimeEnd.textColor = MainColor;
        _lblTimeEnd.font = Font12;
        _lblTimeEnd.textAlignment = NSTextAlignmentRight;
    }
    return _lblTimeEnd;
}

- (UISlider *)slider{
    if(!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.minimumValue = 0;
        _slider.tintColor = HEXCOLOR(0x1CBBCB, 1);
        //_slider.minimumValueImage = [UIImage imageNamed:@"already_dot"];
        [_slider setThumbImage:[UIImage imageNamed:@"already_dot"] forState:UIControlStateNormal];
    }
    return _slider;
}

- (UIImageView *)imageViewShare{
    if (!_imageViewShare) {
        _imageViewShare = [[UIImageView alloc] init];
        _imageViewShare.image = [UIImage imageNamed:@"share"];
        _imageViewShare.hidden = YES;
    }
    return _imageViewShare;
}

@end
