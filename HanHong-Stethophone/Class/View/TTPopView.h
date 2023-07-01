//
//  TTPopView.h
//  ZuSanJiao
//
//  Created by Zhilun on 2020/8/14.
//  Copyright © 2020 Zhilun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TTPopViewDelegate <NSObject>

- (void)actionSelectedInfoCallBack:(NSString *)info row:(NSInteger)row tag:(NSInteger)tag;

@end

@interface TTPopView : UIView

@property (weak, nonatomic) id<TTPopViewDelegate>   delegate;
- (void)setWidth:(CGFloat)width listInfo:(NSArray *)listInfos;

@end

NS_ASSUME_NONNULL_END
