//
//  RecordModel.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordModel : NSObject

@property (assign, nonatomic) NSInteger         id;
@property (retain, nonatomic) NSString          *user_id;//用户ID
@property (retain, nonatomic) NSString          *patient_id;//患者编号
@property (retain, nonatomic) NSString          *patient_area;//地区
@property (assign, nonatomic) NSInteger         record_mode;// 录音方式 0为快速录音 1为标准录音
@property (assign, nonatomic) NSInteger         type_id;// 音频类别 心音 肺音 之类
@property (assign, nonatomic) NSInteger         record_filter;//心肺音滤波开启状态：0 无开滤波 全频模式，1 打开了 滤波 心肺模式
@property (retain, nonatomic) NSString          *position_tag;//听诊位置
@property (assign, nonatomic) NSInteger         patient_posture;//录音时的姿势
@property (retain, nonatomic) NSString          *patient_symptom;//病症
@property (retain, nonatomic) NSString          *patient_diagnosis;//诊断
@property (assign, nonatomic) NSInteger         patient_sex;//性别
@property (retain, nonatomic) NSString          *patient_birthday;//出生日期
@property (retain, nonatomic) NSString          *patient_height;//身高
@property (retain, nonatomic) NSString          *patient_weight;// 体重
@property (retain, nonatomic) NSString          *characteristics;//特征标注 病理者
@property (retain, nonatomic) NSString          *record_time;//录音时间
@property (assign, nonatomic) NSInteger         record_length;//录音时长 秒
@property (retain, nonatomic) NSString          *file_path;//本地路径
@property (retain, nonatomic) NSString          *oss_name;//OSS文件名
@property (retain, nonatomic) NSString          *tag;//文件名
@property (retain, nonatomic) NSString          *modify_time;//修改时间
@property (assign, nonatomic) NSInteger         shared;//设置为全局分享
@property (retain, nonatomic) NSString          *create_time;//上传时间

@property (retain, nonatomic) NSString          *url;//


@end

NS_ASSUME_NONNULL_END


