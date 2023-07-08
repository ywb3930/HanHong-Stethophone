//
//  RemoteControlDetailVC.h
//  HanHong-Stethophone
//  远程会诊详情界面
//  Created by 袁文斌 on 2023/6/24.
//

#import <UIKit/UIKit.h>
#import "HHBaseRecordVC.h"
#import "ConsultationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RemoteControlDetailVC : HHBaseRecordVC

@property (retain, nonatomic) ConsultationModel    *consultationModel;


@end

NS_ASSUME_NONNULL_END
