//
//  WaveFullView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/5.
//

#import "WaveFullView.h"


@interface WaveFullView()

@property (retain, nonatomic) RecordModel           *recordModel;
@property (retain, nonatomic) NSMutableArray        *arrayRowNumber;
@property (assign, nonatomic) NSInteger             rowCount;
@property (assign, nonatomic) CGFloat               rowWidth;
@property (assign, nonatomic) CGFloat               viewWidth;
@property (assign, nonatomic) CGFloat               viewHeight;

@end

@implementation WaveFullView

- (instancetype)initWithFrame:(CGRect)frame recordModel:(RecordModel *)recordModel{
    self = [super initWithFrame:frame];
    if (self) {
        self.recordModel = recordModel;
        [self initData];
        [self initLabel];
    }
    return self;;
}

- (void)initData{
    self.rowCount = self.recordModel.record_length * 5;
    self.viewHeight = screenW - 2 *  kNavBarHeight - Ratio22;
    self.rowWidth = self.viewHeight / 8.f;
    self.viewWidth = self.rowCount * self.rowWidth;
    
}

- (void)initLabel{
    for(int i = 1; i < self.recordModel.record_length + 1; i++) {
        UILabel *label = [[UILabel alloc] init];
        [self addSubview:label];
        label.textColor = WHITECOLOR;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = Font13;
        label.text = [NSString stringWithFormat:@"%i.0", i];
        label.sd_layout.centerXIs(i * self.rowWidth * 5 - Ratio10).widthIs(Ratio44).heightIs(Ratio13).bottomSpaceToView(self, Ratio3);
    }
    

}


- (void)drawRect:(CGRect)rect{
    [self drawLine];
}
- (void)drawLine{
    for (NSInteger i = 0; i < 9; i++) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        //2.设置当前上下问路径
        //设置起始点
        if (i == 8) {
            CGContextSetLineWidth(context, Ratio1);
            CGContextMoveToPoint(context, 0, 8 * self.rowWidth  - Ratio1);
            //增加点
            CGContextAddLineToPoint(context, self.viewWidth, 8 * self.rowWidth  - Ratio1);
        } else {
            CGContextMoveToPoint(context, 0,  i * self.rowWidth);
            //增加点
            CGContextAddLineToPoint(context, self.viewWidth,  i * self.rowWidth);
            CGContextSetLineWidth(context, Ratio0_5);
        }
        
        //关闭路径
        CGContextClosePath(context);
        
        if(i == 8) {
            [[UIColor whiteColor] setStroke];
        } else {
            [HEXCOLOR(0xFFFFFF, 0.2) setStroke];
        }

        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    for (NSInteger i = 0; i < self.rowCount; i++) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        //2.设置当前上下问路径
        //设置起始点
        if (i == 0 ) {
            CGContextMoveToPoint(context, Ratio1, 0);
            //增加点
            CGContextAddLineToPoint(context, Ratio1, self.viewHeight);
            CGContextSetLineWidth(context, Ratio1);
        } else if (i % 5 == 0 ) {
            CGContextMoveToPoint(context, i * self.rowWidth, 0);
            //增加点
            CGContextAddLineToPoint(context, i * self.rowWidth, self.viewHeight);
            CGContextSetLineWidth(context, Ratio1);
        } else {
            CGContextMoveToPoint(context,  i * self.rowWidth,  0);
            //增加点
            CGContextAddLineToPoint(context, i * self.rowWidth, self.viewHeight);
            CGContextSetLineWidth(context, Ratio0_5);
        }
        
        //关闭路径
        CGContextClosePath(context);
        if(i == 0) {
            [[UIColor whiteColor] setStroke];
        } else {
            [HEXCOLOR(0xFFFFFF, 0.2) setStroke];
        }
        
        
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
}


@end
