//
//  RecordModel.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/27.
//

#import "RecordModel.h"

@implementation RecordModel

- (instancetype)init{
    self = [super init];
    if (self) {
        _user_id = @"";//用户ID
        _patient_id = @"";//患者编号
        _patient_area = @"";//地区 1为标准录音
        _position_tag = @"";//听诊位置
        _patient_symptom = @"";//病症
        _patient_diagnosis = @"";//诊断
        _patient_birthday = @"";//出生日期
        _patient_height = @"";//身高
        _patient_weight = @"";// 体重
        _characteristics = @"";//特征标注 病理者
        _record_time = @"";//录音时间
        _file_path = @"";//本地路径
        _oss_name = @"";//OSS文件名
        _tag = @"";//文件名
        _modify_time = @"";//修改时间
        _create_time = @"";//上传时间
        _url = @"";//
        _share_code = @"";
    }
    return self;
}

@end
