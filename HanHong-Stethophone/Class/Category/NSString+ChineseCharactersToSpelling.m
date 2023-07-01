//
//  NSString+ChineseCharactersToSpelling.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/21.
//

#import "NSString+ChineseCharactersToSpelling.h"

@implementation NSString (ChineseCharactersToSpelling)

+(NSString *)lowercaseSpellingWithChineseCharacters:(NSString *)chinese {
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:chinese];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    //返回小写拼音
    return [str lowercaseString];
}

@end
