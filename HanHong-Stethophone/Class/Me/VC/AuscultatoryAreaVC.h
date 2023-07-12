//
//  AuscultatoryAreaVC.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AuscultatoryAreaVC : UIViewController

@property (assign, nonatomic) NSInteger                 idx;
@property (retain, nonatomic) NSMutableArray            *arraySelectButtons;
@property (retain, nonatomic) NSMutableDictionary       *settingData;
- (void)resetView;

@end

NS_ASSUME_NONNULL_END
