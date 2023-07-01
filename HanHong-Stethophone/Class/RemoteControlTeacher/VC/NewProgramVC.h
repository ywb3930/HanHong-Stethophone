//
//  NewProgramVC.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/25.
//

#import <UIKit/UIKit.h>
#import "ProgramModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NewProgramVCDelgate <NSObject>

- (void)actionEditProgramCallback:(ProgramModel *)model;
- (void)actionDeleteProgramCallback:(ProgramModel *)model;

@end

@interface NewProgramVC : UIViewController

@property (weak, nonatomic) id<NewProgramVCDelgate> delegate;
@property (retain, nonatomic) NSString              *selectTime;
@property (assign, nonatomic) Boolean               bCreate;
@property (retain, nonatomic) ProgramModel          *programModel;

@end

NS_ASSUME_NONNULL_END
