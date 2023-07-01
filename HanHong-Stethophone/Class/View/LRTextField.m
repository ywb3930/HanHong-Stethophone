//
//  LRTextField.m
//  TimeTolls
//
//  Created by mac on 2019/11/15.
//  Copyright © 2019 mac. All rights reserved.
//

#import "LRTextField.h"

@implementation LRTextField

- (void)setPlaceholder:(NSString *)placeholder{
    self.attributedPlaceholder = [Tools setAttring:placeholder andColor:nil andFont:nil];
}

-(CGRect)leftViewRectForBounds:(CGRect)bounds{
    CGRect textRect = [super leftViewRectForBounds:bounds];
    textRect.origin.x += Ratio9;
    return textRect;
}

-(CGRect)rightViewRectForBounds:(CGRect)bounds{
    CGRect textRect = [super rightViewRectForBounds:bounds];
    textRect.origin.x -= Ratio9;
    return textRect;
}

//text位置添加左边距
- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    int margin = Ratio9;
    CGRect inset = CGRectMake(rect.origin.x + margin, rect.origin.y, rect.size.width - margin, rect.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect rect = [super editingRectForBounds:bounds];
    int margin = Ratio9;
    CGRect inset = CGRectMake(rect.origin.x + margin, rect.origin.y, rect.size.width - margin, rect.size.height);
    return inset;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end
