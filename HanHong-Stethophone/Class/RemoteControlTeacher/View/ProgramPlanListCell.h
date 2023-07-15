//
//  ProgramPlanListCell.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/26.
//

#import <UIKit/UIKit.h>
#import "ProgramModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProgramPlanListCell : UITableViewCell

@property (retain, nonatomic) ProgramModel              *model;
@property (assign, nonatomic) NSInteger                 iTag;

@end

NS_ASSUME_NONNULL_END
