//
//  ClinicLearningHeaderView.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/10.
//

#import <UIKit/UIKit.h>

@protocol ClinicLearningHeaderViewDelegate <NSObject>

- (Boolean)actionHeartLungButtonClickCallback:(NSInteger)idx;
- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ClinicLearningHeaderView : UICollectionReusableView

@property (weak, nonatomic) id<ClinicLearningHeaderViewDelegate>   delegate;
@property (retain, nonatomic) NSString              *roomState;
@property (retain, nonatomic) NSString              *startTime;
@property (retain, nonatomic) NSString              *learnCount;
@property (retain, nonatomic) NSString              *learnMember;
@property (retain, nonatomic) NSString              *roomMessage;
@property (retain, nonatomic) NSString              *recordMessage;
@property (retain, nonatomic) NSString              *teachName;
@property (retain, nonatomic) NSString              *teachAvatar;
@property (assign, nonatomic) Boolean               bOnline;


@end

NS_ASSUME_NONNULL_END
