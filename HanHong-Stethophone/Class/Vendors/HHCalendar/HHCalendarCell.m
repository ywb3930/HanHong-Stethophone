//
//  HHCalendarCell.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/25.
//

#import "HHCalendarCell.h"

@interface HHCalendarCell()

@property (retain, nonatomic) UIView                *viewBg;
@property (retain, nonatomic) UILabel               *labelDay;
@property (assign, nonatomic) CGFloat               width;


@end

@implementation HHCalendarCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.width = (screenW-Ratio44)/7;
        [self setupView];
    }
    return self;
}

- (void)setCalendarDayModel:(HHCalendarDayModel *)calendarDayModel{
    self.labelDay.textColor = MainBlack;
    if (calendarDayModel.dayValue <= 0 ) {
        self.labelDay.hidden = YES;
        self.viewBg.layer.borderWidth = Ratio1;
        self.viewBg.layer.borderColor = UIColor.clearColor.CGColor;
        self.viewBg.hidden = YES;
    } else {
        self.labelDay.text = [@(calendarDayModel.dayValue) stringValue];
        self.labelDay.hidden = NO;
        if (calendarDayModel.bCurrentDay) {
            self.viewBg.layer.borderWidth = Ratio1;
            self.viewBg.layer.borderColor = MainColor.CGColor;
            self.viewBg.hidden = NO;
        } else {
            self.viewBg.layer.borderWidth = Ratio1;
            self.viewBg.layer.borderColor = UIColor.clearColor.CGColor;
            self.viewBg.hidden = YES;
        }
        if (calendarDayModel.modelList.count > 0) {
            self.viewBg.backgroundColor = ColorDAECFD;
            self.viewBg.hidden = NO;
            self.labelDay.textColor = WHITECOLOR;
        } else {
            self.viewBg.backgroundColor = UIColor.clearColor;
        }
    }
}

- (void)setupView {
    [self.contentView addSubview:self.viewBg];
    [self.contentView addSubview:self.labelDay];
    self.viewBg.sd_layout.leftSpaceToView(self.contentView, Ratio2).topSpaceToView(self.contentView, Ratio2).rightSpaceToView(self.contentView, Ratio2).bottomSpaceToView(self.contentView, Ratio2);
    self.labelDay.sd_layout.leftSpaceToView(self.contentView, 0).topSpaceToView(self.contentView, 0).rightSpaceToView(self.contentView, 0).bottomSpaceToView(self.contentView, 0);
}

- (UILabel *)labelDay{
    if (!_labelDay) {
        _labelDay = [[UILabel alloc] init];
        _labelDay.textAlignment = NSTextAlignmentCenter;
        _labelDay.font = Font15;
        _labelDay.textColor = MainBlack;
        _labelDay.backgroundColor = UIColor.clearColor;
    }
    return _labelDay;
}

- (UIView *)viewBg{
    if (!_viewBg) {
        _viewBg = [[UIView alloc] init];
        _viewBg.layer.cornerRadius = (self.width-Ratio4)/2;
        _viewBg.hidden = YES;
        _viewBg.clipsToBounds = YES;
    }
    return _viewBg;
}

@end
