//
//  RecordListVC.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordListVC : UIViewController

@property (assign, nonatomic) NSInteger idx;//0 本地， 1 云， 2 收藏
@property (assign, nonatomic) Boolean bLoadData;

- (void)initView;
- (void)initCollectData;
- (void)initCouldData;
- (void)initLocalData;

@end

NS_ASSUME_NONNULL_END
