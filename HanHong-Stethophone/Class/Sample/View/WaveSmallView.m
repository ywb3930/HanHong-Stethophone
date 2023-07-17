//
//  WaveSmallView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/4.
//

#import "WaveSmallView.h"

#define  ViewHeight     Ratio135
#define  smalllineCount         7

@interface WaveSmallView()

@property (retain, nonatomic) RecordModel           *recordModel;
@property (retain, nonatomic) NSMutableArray        *arrayRowNumber;
@property (assign, nonatomic) NSInteger             rowCount;
//@property (assign, nonatomic) Boolean               bSingeLine;



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
        label.sd_layout.bottomSpaceToView(self, Ratio2).centerXIs((i+1) * width - Ratio11).heightIs(Ratio15).widthIs(Ratio44);
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


- (void)getArrayData:(NSInteger)x count:(NSInteger)count{
    //NSMutableArray *array = [NSMutableArray array];
    NSInteger num = count / 8;
    NSInteger f = ceil(num / (float)x) * x;
    NSLog(@"11");
    NSInteger number =  count/f;
    for (NSInteger i = 0; i < number; i++) {
        [self.arrayRowNumber addObject:[@((i+1)*f) stringValue]];
    }
    int last = [[self.arrayRowNumber lastObject] intValue];
    if (count - last < f / 2) {
        [self.arrayRowNumber replaceObjectAtIndex:number - 1 withObject:[@(count) stringValue]];
    } else {
        [self.arrayRowNumber addObject:[@(count) stringValue]];
    }
    self.rowCount = self.arrayRowNumber.count;
}


- (void)initData{
    NSInteger duration = self.recordModel.record_length;
    self.arrayRowNumber = [NSMutableArray array];
    if (duration <= 10) {
        for (NSInteger i = 0; i < duration; i++) {
            [self.arrayRowNumber addObject:[@(i) stringValue]];
        }
        self.rowCount = self.arrayRowNumber.count;
    } else if (duration <= 50) {
        [self getArrayData:5 count:duration];
    } else if (duration <= 100) {
        [self getArrayData:10 count:duration];
    }  else if (duration <= 500) {
        [self getArrayData:50 count:duration];
    } else if (duration <= 1000) {
        [self getArrayData:100 count:duration];
    }else {
        [self getArrayData:500 count:duration];
    }
    
    
//    NSInteger duration = self.recordModel.record_length;
//    self.arrayRowNumber = [NSMutableArray array];
//    if (duration <= 8) {
//        self.rowCount = duration;
//        for (NSInteger i = 1; i <= duration; i++) {
//            [self.arrayRowNumber addObject:[@(i) stringValue]];
//        }
//        self.bSingeLine = NO;
//    } else {
//        NSInteger interval = ceil(duration/8.f);
//        if(duration % interval == 0) {
//            self.rowCount = duration / interval;
//            for (NSInteger i = 1; i < self.rowCount; i++) {
//                [self.arrayRowNumber addObject:[@(i * interval) stringValue]];
//            }
//            self.bSingeLine = NO;
//        } else {
//            self.rowCount = duration / interval;
//            NSMutableArray *a = [NSMutableArray array];
//            for (NSInteger i = 0; i < self.rowCount; i++) {
//                [a addObject:[@(duration - i * interval) stringValue]];
//            }
//            self.bSingeLine = YES;
//            [self.arrayRowNumber addObjectsFromArray:[[a reverseObjectEnumerator] allObjects]];
//        }
//    }
    
}

- (void)drawRect:(CGRect)rect{
    [self drawLine];
}

- (void)drawLine{
    CGFloat height = ViewHeight/(smalllineCount - 1);
    for (NSInteger i = 0; i < (smalllineCount - 1); i++) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        //2.设置当前上下问路径
        //设置起始点
        if (i == smalllineCount) {
            CGContextSetLineWidth(context, Ratio1);
            CGContextMoveToPoint(context, 0, height * (1 + i) - Ratio2);
            //增加点
            CGContextAddLineToPoint(context, screenW - Ratio22, height * (1 + i) - Ratio2);
        } else {
            CGContextMoveToPoint(context, 0, height * (1 + i));
            //增加点
            CGContextAddLineToPoint(context, screenW - Ratio22, height * (1 + i));
            CGContextSetLineWidth(context, Ratio0_5);
        }
        
        //关闭路径
        CGContextClosePath(context);
        
        if(i == smalllineCount) {
            [[UIColor whiteColor] setStroke];
        } else {
            [HEXCOLOR(0xFFFFFF, 0.2) setStroke];
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
            CGContextAddLineToPoint(context, Ratio1, Ratio135);
        } else {
            CGContextMoveToPoint(context, width * i, 0);
            //增加点
            CGContextAddLineToPoint(context, width * i, Ratio135);
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
