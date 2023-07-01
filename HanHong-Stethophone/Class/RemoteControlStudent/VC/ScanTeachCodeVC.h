//
//  ScanTeachCodeVC.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ScanTeachCodeVCDelegate <NSObject>

- (void)scanCodeResultCallback:(NSString *)scanCodeResult;

@end

@interface ScanTeachCodeVC : UIViewController

@property (weak, nonatomic) id<ScanTeachCodeVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
