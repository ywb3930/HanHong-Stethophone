//
//  WaveSmallView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/4.
//

#import "WaveSmallView.h"

#define  ViewHeight     Ratio150

@interface WaveSmallView()

@property (retain, nonatomic) RecordModel           *recordModel;
@property (retain, nonatomic) NSMutableArray        *arrayRowNumber;
@property (assign, nonatomic) NSInteger             rowCount;
@property (assign, nonatomic) Boolean               bSingeLine;



@end

@implementation WaveSmallView

- (instancetype)initWithFrame:(CGRect)frame recordModel:(RecordModel *)recordModel{
    self = [super initWithFrame:frame];
    if (self) {
        self.recordModel = recordModel;
        [self initData];
        [self initLabel];
    }
    return self;;
}




- (void)initLabel{
    CGFloat width = (screenW - Ratio22) / self.rowCount;
    for (NSInteger i = 0; i < self.rowCount; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.text = self.arrayRowNumber[i];
        label.font = Font13;
        label.textColor = WHITECOLOR;
        [label sizeToFit];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        label.sd_layout.bottomSpaceToView(self, Ratio5).centerXIs((i+1) * width - Ratio11).heightIs(Ratio15).widthIs(Ratio44);
    }
    UILabel *labelTop = [self getLabelVertical:@" 1"];
    UILabel *labelCenter = [self getLabelVertical:@" 0"];
    UILabel *labelBottom = [self getLabelVertical:@"-1"];
    [self addSubview:labelTop];
    [self addSubview:labelCenter];
    [self addSubview:labelBottom];
    labelTop.sd_layout.leftSpaceToView(self, Ratio3).topSpaceToView(self, Ratio3).widthIs(Ratio33).heightIs(Ratio15);
    labelCenter.sd_layout.centerYEqualToView(self).leftSpaceToView(self, Ratio3).widthIs(Ratio33).heightIs(Ratio15);
    labelBottom.sd_layout.leftSpaceToView(self, Ratio3).bottomSpaceToView(self, Ratio5).widthIs(Ratio33).heightIs(Ratio15);
    
}

- (UILabel *)getLabelVertical:(NSString *)name{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = Font13;
    label.textColor = WHITECOLOR;
    label.text = name;
    return label;
}

- (void)initData{
    NSInteger duration = self.recordModel.record_length;
    self.arrayRowNumber = [NSMutableArray array];
    if (duration <= 8) {
        self.rowCount = duration;
        for (NSInteger i = 1; i <= duration; i++) {
            [self.arrayRowNumber addObject:[@(i) stringValue]];
        }
        self.bSingeLine = NO;
    } else {
        NSInteger interval = ceil(duration/8.f);
        if(duration % interval == 0) {
            self.rowCount = duration / interval;
            for (NSInteger i = 1; i < self.rowCount; i++) {
                [self.arrayRowNumber addObject:[@(i * interval) stringValue]];
            }
            self.bSingeLine = NO;
        } else {
            self.rowCount = duration / interval;
            NSMutableArray *a = [NSMutableArray array];
            for (NSInteger i = 0; i < self.rowCount; i++) {
                [a addObject:[@(duration - i * interval) stringValue]];
            }
            self.bSingeLine = YES;
            [self.arrayRowNumber addObjectsFromArray:[[a reverseObjectEnumerator] allObjects]];
        }
    }
    
}

- (void)drawRect:(CGRect)rect{
    [self drawLine];
}

- (void)drawLine{
    CGFloat height = ViewHeight/8;
    for (NSInteger i = 0; i < 8; i++) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        //2.设置当前上下问路径
        //设置起始点
        if (i == 7) {
            CGContextSetLineWidth(context, Ratio1);
            CGContextMoveToPoint(context, 0, height * (1 + i) - Ratio1);
            //增加点
            CGContextAddLineToPoint(context, screenW - Ratio22, height * (1 + i) - Ratio1);
        } else {
            CGContextMoveToPoint(context, 0, height * (1 + i));
            //增加点
            CGContextAddLineToPoint(context, screenW - Ratio22, height * (1 + i));
            CGContextSetLineWidth(context, Ratio0_5);
        }
        
        //关闭路径
        CGContextClosePath(context);
        
        if(i == 7) {
            [[UIColor whiteColor] setStroke];
        } else {
            [HEXCOLOR(0xFFFFFF, 0.5) setStroke];
        }

        CGContextDrawPath(context, kCGPathFillStroke);
    }
    CGFloat width = (screenW - Ratio22) / self.rowCount;
    for (int i = 0; i < self.rowCount; i ++) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        //2.设置当前上下问路径
        //设置起始点
        if (i == 0) {
            CGContextSetLineWidth(context, Ratio1);
            CGContextMoveToPoint(context, Ratio1, 0);
            //增加点
            CGContextAddLineToPoint(context, Ratio1, Ratio150);
        } else {
            CGContextMoveToPoint(context, width * i, 0);
            //增加点
            CGContextAddLineToPoint(context, width * i, Ratio150);
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
