//
//  FriendBookVC.h
//  HanHong-Stethophone
//  师友录界面
//  Created by 袁文斌 on 2023/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FriendBookVCDelegate <NSObject>

@optional

- (void)actionSelectModelCallback:(NSMutableArray *)array;

@end

@interface FriendBookVC : UIViewController

@property (weak, nonatomic) id<FriendBookVCDelegate>    delegate;
@property (assign, nonatomic) Boolean                   bAdd;
@property (retain, nonatomic) NSArray                   *selectModel;

@end

NS_ASSUME_NONNULL_END
