//
//  InteriorHeaderView.m
//  HuiGaiChe
//
//  Created by Zhilun on 2020/8/8.
//  Copyright © 2020 Zhilun. All rights reserved.
//

#import "InteriorHeaderView.h"

@interface InteriorHeaderView()

@property (retain, nonatomic) UILabel           *lblTitle;

@end

@implementation InteriorHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        //self.contentView.backgroundColor = ColorF5F5F5;
        [self setupView];
    }
    return self;
}


- (void)setTitle:(NSString *)title{
    _lblTitle.text = title;
}

- (void)setupView{
    self.backgroundColor = UIColor.orangeColor;
    [self.contentView addSubview:self.lblTitle];
    self.lblTitle.sd_layout.leftSpaceToView(self.contentView, Ratio18).topSpaceToView(self.contentView, 0).rightSpaceToView(self.contentView, 0).bottomSpaceToView(self.contentView, 0);
}

- (UILabel *)lblTitle{
    if (!_lblTitle) {
        _lblTitle = [[UILabel alloc] init];
        _lblTitle.font = Font13;
        _lblTitle.textColor = MainNormal;
    }
    return _lblTitle;
}


- (void)configWithProgress:(double)progress {
    static NSMutableArray<NSNumber *> *textColorDiffArray;
    static NSMutableArray<NSNumber *> *bgColorDiffArray;
    static NSArray<NSNumber *> *selectTextColorArray;
    static NSArray<NSNumber *> *selectBgColorArray;
    
    if (textColorDiffArray.count == 0) {
        UIColor *selectTextColor = MainColor;
        UIColor *textColor = MainGray;
        UIColor *selectBgColor = ColorF5F5F5;
        UIColor *bgColor = ColorF5F5F5;
        
        selectTextColorArray = [self getRGBArrayByColor:selectTextColor];
        NSArray<NSNumber *> *textColorArray = [self getRGBArrayByColor:textColor];
        selectBgColorArray = [self getRGBArrayByColor:selectBgColor];
        NSArray<NSNumber *> *bgColorArray = [self getRGBArrayByColor:bgColor];
        
        textColorDiffArray = @[].mutableCopy;
        bgColorDiffArray = @[].mutableCopy;
        for (int i = 0; i < 3; i++) {
            double textDiff = selectTextColorArray[i].doubleValue - textColorArray[i].doubleValue;
            [textColorDiffArray addObject:@(textDiff)];
            double bgDiff = selectBgColorArray[i].doubleValue - bgColorArray[i].doubleValue;
            [bgColorDiffArray addObject:@(bgDiff)];
        }
    }
    
    NSMutableArray<NSNumber *> *textColorNowArray = @[].mutableCopy;
    NSMutableArray<NSNumber *> *bgColorNowArray = @[].mutableCopy;
    for (int i = 0; i < 3; i++) {
        double textNow = selectTextColorArray[i].doubleValue - progress * textColorDiffArray[i].doubleValue;
        [textColorNowArray addObject:@(textNow)];
        
        double bgNow = selectBgColorArray[i].doubleValue - progress * bgColorDiffArray[i].doubleValue;
        [bgColorNowArray addObject:@(bgNow)];
    }
    
    UIColor *textColor = [self getColorWithRGBArray:textColorNowArray];
    self.lblTitle.textColor = textColor;
    UIColor *bgColor = [self getColorWithRGBArray:bgColorNowArray];
    self.contentView.backgroundColor = bgColor;
}


- (NSArray<NSNumber *> *)getRGBArrayByColor:(UIColor *)color
{
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    double components[3];
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
    double r = components[0];
    double g = components[1];
    double b = components[2];
    return @[@(r),@(g),@(b)];
}

- (UIColor *)getColorWithRGBArray:(NSArray<NSNumber *> *)array {
    return [UIColor colorWithRed:array[0].doubleValue green:array[1].doubleValue blue:array[2].doubleValue alpha:1];
}


@end
