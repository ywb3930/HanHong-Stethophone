//
//  InteriorHeaderView.h
//  HuiGaiChe
//
//  Created by Zhilun on 2020/8/8.
//  Copyright © 2020 Zhilun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InteriorHeaderView : UITableViewHeaderFooterView

@property (retain, nonatomic) NSString              *title;
- (void)configWithProgress:(double)progress;

@end

NS_ASSUME_NONNULL_END
