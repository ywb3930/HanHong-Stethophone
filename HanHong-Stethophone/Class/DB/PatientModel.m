//
//  PatientModel.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/27.
//

#import "PatientModel.h"

@implementation PatientModel

- (instancetype)init{
    self = [super init];
    if (self) {
        _patient_id = @"";//患者编号
        _patient_area = @"";//地区 1为标准录音
        _patient_symptom = @"";//病症
        _patient_diagnosis = @"";//诊断
        _patient_birthday = @"";//出生日期
        _patient_height = @"";//身高
        _patient_weight = @"";// 体重
    }
    return self;
}

@end
