//
//  ProgramPlanListVC.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/26.
//

#import <UIKit/UIKit.h>
#import "ProgramPlanListCell.h"

NS_ASSUME_NONNULL_BEGIN
//0 删除。1 修改
typedef void(^ProgramPlanListItemChangeBlock)(ProgramModel   *model,NSInteger tag);

@interface ProgramPlanListVC : UIViewController

@property (copy, nonatomic) ProgramPlanListItemChangeBlock          itemChangeBlock;
@property (retain, nonatomic) NSMutableArray               *programListData;

@end

NS_ASSUME_NONNULL_END
