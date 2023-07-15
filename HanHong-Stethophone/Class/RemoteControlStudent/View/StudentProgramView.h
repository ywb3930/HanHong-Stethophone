//
//  StudentProgramView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^StudentProgramViewDataBlock)(NSMutableArray *arrayData, CGFloat   maxY);
//0 删除。1 修改
typedef void(^StudentProgramItemChangeBlock)(ProgramModel   *model,NSInteger tag);


@interface StudentProgramView : UIView

@property (nonatomic, copy) StudentProgramItemChangeBlock         itemChangeBlock;
@property (nonatomic, copy) StudentProgramViewDataBlock           dataBlock;
@property (retain, nonatomic) NSDate *currentDate;
- (void)initData:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
