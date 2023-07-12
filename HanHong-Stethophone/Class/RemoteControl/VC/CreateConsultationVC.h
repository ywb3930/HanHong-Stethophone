//
//  CreateConsultationVC.h
//  HanHong-Stethophone
//  创建和修改会诊
//  Created by Hanhong on 2023/6/21.
//

#import <UIKit/UIKit.h>
#import "ConsultationModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CreateConsultationDelegate <NSObject>

@optional
-(void)actionCreateConsultationSuccessCallback:(Boolean)bModify;

@end

@interface CreateConsultationVC : UIViewController

@property (weak, nonatomic) id<CreateConsultationDelegate> delegate;
@property (assign, nonatomic) Boolean                       bModify;//是否是修改会诊室
@property (retain, nonatomic) ConsultationModel             *consultationModel;

@end

NS_ASSUME_NONNULL_END
