//
//  TeachingProgramView.h
//  HanHong-Stethophone
//  教学计划
//  Created by Hanhong on 2023/6/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TeachingProgramViewDataBlock)(NSMutableArray *arrayData, CGFloat   maxY);
//0 删除。1 修改
typedef void(^TeachingProgramItemChangeBlock)(ProgramModel   *model,NSInteger tag);


@interface TeachingProgramView : UIView

@property (retain, nonatomic) NSDate *currentDate;
@property (nonatomic, copy) TeachingProgramViewDataBlock           dataBlock;
@property (nonatomic, copy) TeachingProgramItemChangeBlock         itemChangeBlock;
- (void)initData:(NSDate *)date;


@end

NS_ASSUME_NONNULL_END
