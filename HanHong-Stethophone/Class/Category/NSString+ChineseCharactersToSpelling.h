//
//  NSString+ChineseCharactersToSpelling.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/21.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface NSString (ChineseCharactersToSpelling)

+(NSString *)lowercaseSpellingWithChineseCharacters:(NSString *)chinese;

@end

NS_ASSUME_NONNULL_END
