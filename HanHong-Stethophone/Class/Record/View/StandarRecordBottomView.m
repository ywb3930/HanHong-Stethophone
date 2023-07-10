//
//  StandarRecordBottomView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/30.
//

#import "StandarRecordBottomView.h"

@interface StandarRecordBottomView()


@property (retain, nonatomic) UIView                    *viewBottom;
@property (retain, nonatomic) UILabel                   *labelCollectLocation;
@property (retain, nonatomic) YYLabel                   *labelFiler;
@property (retain, nonatomic) UILabel                   *labelMessage;
@property (retain, nonatomic) UIView                    *viewLine;

@end

@implementation StandarRecordBottomView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = WHITECOLOR;
        [self setupView];
    }
    return self;
}

- (void)setIndex:(NSInteger)index{
    if (index == 0) {
        //self.
        self.labelStartRecord.hidden = NO;
    } else {
        self.labelStartRecord.hidden = YES;
    }
}

- (void)setRecordMessage:(NSString *)recordMessage{
    self.labelStartRecord.text = recordMessage;
}

- (void)setupView{
    [self addSubview:self.viewLine];
    self.viewLine.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self, 0).heightIs(Ratio8);
    [self addSubview:self.labelCollectLocation];
    
    self.labelCollectLocation.sd_layout.leftSpaceToView(self, Ratio11).rightSpaceToView(self, 0).topSpaceToView(self.viewLine, Ratio10).heightIs(Ratio16);
    
    [self addSubview:self.readyRecordView];
    self.readyRecordView.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self.labelCollectLocation, -Ratio11).heightIs(125.f*screenRatio);
    
    [self addSubview:self.labelStartRecord];
    self.labelStartRecord.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self.readyRecordView, 0).heightIs(Ratio18);
    
    [self addSubview:self.labelFiler];
    CGFloat width = [Tools widthForString:@"打开滤波/关闭滤波" fontSize:Ratio15 andHeight:Ratio16];
    self.labelFiler.sd_layout.widthIs(width).heightIs(Ratio16).topSpaceToView(self.labelStartRecord, Ratio10).centerXEqualToView(self);
    
    [self filterGrayString:@"关闭滤波" blueString:@"打开滤波"];
    
    [self addSubview:self.labelMessage];
    self.labelMessage.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self.labelFiler, Ratio10).heightIs(Ratio18);
}

- (UIView *)viewLine{
    if (!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine;
}

- (void)setPositionName:(NSString *)positionName{
    self.labelCollectLocation.text = positionName;
}


- (UILabel *)labelCollectLocation{
    if(!_labelCollectLocation) {
        _labelCollectLocation = [[UILabel alloc] init];
        _labelCollectLocation.text = @"准备选择采集的位置";
        _labelCollectLocation.textColor = UIColor.redColor;
        _labelCollectLocation.font = [UIFont systemFontOfSize:Ratio16];
    }
    return _labelCollectLocation;
}

- (UILabel *)labelStartRecord{
    if(!_labelStartRecord) {
        _labelStartRecord = [[UILabel alloc] init];
        _labelStartRecord.text = @"按听诊器录音键可以开始录音";
        _labelStartRecord.textColor = UIColor.redColor;
        _labelStartRecord.font = [UIFont systemFontOfSize:Ratio16];
        _labelStartRecord.textAlignment = NSTextAlignmentCenter;
    }
    return _labelStartRecord;
}

- (ReadyRecordView *)readyRecordView{
    if(!_readyRecordView) {
        _readyRecordView = [[ReadyRecordView alloc] init];
    }
    return _readyRecordView;
}

- (YYLabel *)labelFiler{
    if(!_labelFiler) {
        _labelFiler = [[YYLabel alloc] init];
    }
    return _labelFiler;
}

- (void)filterGrayString:(NSString *)grayString blueString:(NSString *)blueString{
    NSString *title = @"打开滤波/关闭滤波";
    NSMutableAttributedString* atext=[[NSMutableAttributedString alloc]initWithString:title];
    NSRange grayRange=[[atext string] rangeOfString:grayString];
    NSRange blueRange=[[atext string] rangeOfString:blueString];
    atext.yy_font = Font15;
    atext.yy_color = MainColor;
    atext.yy_alignment = NSTextAlignmentCenter;
    [atext yy_setTextHighlightRange:grayRange color:MainNormal backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(actionHeartLungFilterChange:)]) {
            Boolean result = [grayString containsString:@"打开滤波"];
            Boolean change = [self.delegate actionHeartLungFilterChange:result ? open_filtration : close_filtration];
            if (change) {
                NSLog(@"change = %i", change);
                [self filterGrayString:blueString blueString:grayString];
            }
        }
        
    }];
    [atext yy_setTextHighlightRange:blueRange color:MainColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(actionHeartLungFilterChange:)]) {
            Boolean result = [blueString containsString:@"打开滤波"];
            Boolean change = [self.delegate actionHeartLungFilterChange:result ? open_filtration : close_filtration];
            if (change) {
                NSLog(@"change = %i", change);
                [self filterGrayString:grayString blueString:blueString];
            }
        }
    }];
    self.labelFiler.attributedText = atext;
    
}

- (UILabel *)labelMessage{
    if(!_labelMessage) {
        _labelMessage = [[UILabel alloc] init];
        _labelMessage.text = @"无线信号弱，音频数据丢失";
        _labelMessage.textColor = UIColor.redColor;
        _labelMessage.textAlignment = NSTextAlignmentCenter;
        _labelMessage.font = Font18;
        _labelMessage.hidden = YES;
    }
    return _labelMessage;
}


@end
