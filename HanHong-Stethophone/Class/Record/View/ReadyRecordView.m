//
//  ReadyRecordView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/17.
//

#import "ReadyRecordView.h"

@interface ReadyRecordView()


@property (retain, nonatomic) UILabel               *labelRecordNumber;
@property (retain, nonatomic) UIProgressView        *progressView;
@property (retain, nonatomic) UILabel               *labelStartTime;
@property (retain, nonatomic) UILabel               *labelEndTime;

@end

@implementation ReadyRecordView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        [self initView];
    }
    return self;
}

- (void)setStartTime:(NSString *)startTime{
    self.labelStartTime.text = startTime;
}

- (void)setRecordTime:(float)recordTime{
    _recordTime = recordTime;
    NSString *recordTimeString = [Tools getMMSSFromSS:(NSInteger)recordTime];
    self.labelStartTime.text = recordTimeString;
    self.labelReadyRecord.text = [NSString stringWithFormat:@"正在录音%@", recordTimeString];
}

- (void)setStop:(Boolean)stop{
    NSString *recordTimeString = [Tools getMMSSFromSS:(NSInteger)self.recordTime];
    if (stop) {
        self.labelReadyRecord.text = [NSString stringWithFormat:@"录音已暂停%@", recordTimeString];
    } else {
        self.labelReadyRecord.text = [NSString stringWithFormat:@"正在录音%@", recordTimeString];
    }
}

- (void)setRecordCode:(NSString *)recordCode{
    self.labelRecordNumber.text = [NSString stringWithFormat:@"当前录音编号：%@", recordCode];
}

- (void)setDuration:(NSInteger)duration{
    NSString *result = [Tools getMMSSFromSS:duration];
    self.labelEndTime.text = result;
}

- (void)initView{
    [self addSubview:self.labelReadyRecord];
    self.labelReadyRecord.sd_layout.leftSpaceToView(self, 0).heightIs(Ratio20).rightSpaceToView(self, 0).topSpaceToView(self, Ratio22);
    [self addSubview:self.labelRecordNumber];
    self.labelRecordNumber.sd_layout.leftSpaceToView(self, 0).heightIs(Ratio18).rightSpaceToView(self, 0).topSpaceToView(self.labelReadyRecord, Ratio15);
    
    [self addSubview:self.progressView];
    self.progressView.sd_layout.leftSpaceToView(self, Ratio22).rightSpaceToView(self, Ratio22).heightIs(Ratio33).topSpaceToView(self.labelRecordNumber, Ratio15);
    
    [self addSubview:self.labelStartTime];
    [self addSubview:self.labelEndTime];
    self.labelStartTime.sd_layout.leftSpaceToView(self, Ratio22).topSpaceToView(self.progressView, Ratio8).widthIs(Ratio99).heightIs(Ratio15);
    self.labelEndTime.sd_layout.rightSpaceToView(self, Ratio22).topSpaceToView(self.progressView, Ratio8).widthIs(Ratio99).heightIs(Ratio15);
}


- (UILabel *)labelReadyRecord{
    if(!_labelReadyRecord) {
        _labelReadyRecord = [[UILabel alloc] init];
        _labelReadyRecord.textColor = MainColor;
        _labelReadyRecord.text = @"准备录音";
        _labelReadyRecord.font = Font18;
        _labelReadyRecord.textAlignment = NSTextAlignmentCenter;
    }
    return _labelReadyRecord;
}

- (UILabel *)labelRecordNumber{
    if(!_labelRecordNumber) {
        _labelRecordNumber = [[UILabel alloc] init];
        _labelRecordNumber.textColor = MainNormal;
        _labelRecordNumber.text = @"当前录音编号：--";
        _labelRecordNumber.font = Font11;
        _labelRecordNumber.textAlignment = NSTextAlignmentCenter;
    }
    return _labelRecordNumber;
}

- (UILabel *)labelStartTime{
    if(!_labelStartTime) {
        _labelStartTime = [[UILabel alloc] init];
        _labelStartTime.textColor = MainNormal;
        _labelStartTime.font = Font15;
        _labelStartTime.text = @"00:00";
    }
    return _labelStartTime;
}

- (UILabel *)labelEndTime{
    if(!_labelEndTime) {
        _labelEndTime = [[UILabel alloc] init];
        _labelEndTime.textColor = MainNormal;
        _labelEndTime.font = Font15;
        _labelEndTime.textAlignment = NSTextAlignmentRight;
        //_labelEndTime.text = @"01:00";
    }
    return _labelEndTime;
}

- (void)setProgress:(float)progress{
    _progressView.progress = progress;
}



- (UIProgressView *)progressView{
    if(!_progressView) {
        _progressView = [[UIProgressView alloc] init];
    }
    return _progressView;
}


@end
