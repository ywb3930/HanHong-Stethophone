//
//  ToolsCheckUpdate.h
//  LiteraryCreation
//
//  Created by Zhilun on 2020/9/15.
//  Copyright © 2020 Zhilun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToolsCheckUpdate : NSObject

+ (instancetype)getInstance;
- (void)actionToCheckUpdate:(Boolean)bShowToast;

@end

NS_ASSUME_NONNULL_END
