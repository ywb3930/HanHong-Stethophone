//
//  AusultaionView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/17.
//

#import "AusultaionView.h"

@interface AusultaionView()

@property (retain ,nonatomic) UILabel                       *labelTitle;
@property (retain, nonatomic) UILabel                       *labelHint;

@end

@implementation AusultaionView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = WHITECOLOR;
        [self initView];
    }
    return self;
}


- (void)setTitle:(NSString *)title{
    self.labelTitle.text = title;
}


- (void)initView{
    [self addSubview:self.labelTitle];
    [self addSubview:self.labelHint];
    self.labelTitle.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self, Ratio5).heightIs(Ratio16);
    self.labelHint.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self.labelTitle, Ratio5).autoHeightRatio(0);
   
}



- (UILabel *)labelTitle{
    if(!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.font = Font13;
        _labelTitle.textColor = MainBlack;
        _labelTitle.textAlignment = NSTextAlignmentCenter;
    }
    return _labelTitle;
}

- (UILabel *)labelHint{
    if(!_labelHint) {
        _labelHint = [[UILabel alloc] init];
        _labelHint.font = Font13;
        _labelHint.textColor = MainBlack;
        _labelHint.textAlignment = NSTextAlignmentCenter;
        _labelHint.numberOfLines = 0;
        _labelHint.text = @"请参照示意图，将设备放置于测量位置。准备好之后点击听诊器按键。";
    }
    return _labelHint;
}

@end
