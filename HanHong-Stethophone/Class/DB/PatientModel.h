//
//  PatientModel.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PatientModel : NSObject

@property (retain, nonatomic) NSString                  *patient_id;//病人ID
@property (assign, nonatomic) NSInteger                 patient_sex;//病人性别
@property (retain, nonatomic) NSString                  *patient_birthday;//病人生日
@property (retain, nonatomic) NSString                  *patient_height;//病人身高
@property (retain, nonatomic) NSString                  *patient_weight;//病人体重
@property (retain, nonatomic) NSString                  *patient_symptom;//病症
@property (retain, nonatomic) NSString                  *patient_diagnosis;//诊断
@property (retain, nonatomic) NSString                  *patient_area;//病人地区

@end

NS_ASSUME_NONNULL_END
