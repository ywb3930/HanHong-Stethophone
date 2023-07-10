//
//  HHDBHelper.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/1.
//

#import <Foundation/Foundation.h>
#import "ProgramModel.h"
#import "PatientModel.h"
#import "RecordModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface HHDBHelper : NSObject

+ (instancetype)shareInstance;
/*******计划*/
- (void)addProgramItem:(ProgramModel *)model;
- (Boolean)deleteProgramItem:(NSInteger)programId;
- (Boolean)updateProgramItem:(ProgramModel *)model;
- (NSMutableArray *)selectAllProgramData:(long)startTime endTime:(long)endTime;


// 增加记录
- (Boolean)addRecordItem:(RecordModel *)model;
//删除 根据录音时间
- (Boolean)deleteRecordItemInTime:(NSString *)record_time;
//查询记录
- (NSMutableArray *)selectRecord:(Boolean)mode_select mode:(NSInteger)mode typeSelect:(Boolean)type_select type:(NSInteger)type;
//更新记录
- (Boolean)updateRecordItem:(NSString *)fileName record:(RecordModel *)recordModel;
//修改病理音类型 标注
- (Boolean)updateRecordCharacteristicsItem:(NSString *)fileName  characteristics:(NSString *)characteristics;
                                                                                  
/**
 查询患者ID是否存在
 */
- (Boolean)checkPatientIDIsExist:(NSString *)patientId;

/**
 添加数据
 */
- (Boolean)addPatientItemData:(PatientModel *)patientModel;

/**
 删除数据
 */
- (void)deletePatientItemData:(NSString *)patient_id;

/**
 删除数据
 */
- (void)deleteAllPatientData;

/**
 查询所有记录
 */
- (NSMutableArray *)selectAllPatientHistory;
                                                                                  
@end

NS_ASSUME_NONNULL_END
