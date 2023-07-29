//
//  HHDBHelper.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/1.
//

#import "HHDBHelper.h"

@implementation HHDBHelper
static FMDatabase *_db;




- (void)addProgramItem:(ProgramModel *)model{
    NSString *sql = [NSString stringWithFormat:@"insert into program(program_title,startTime,endTime,duration,system_calender_reminder) values('%@',%ld,%ld,%ld,'%@')",model.program_title, model.startTime, model.endTime, model.duration, model.system_calender_reminder];
    if([_db executeUpdate:sql]) {
        DLog(@"%@ success", sql);
    } else {
        DLog(@"%@ failure", sql);
    }
}

- (Boolean)deleteProgramItem:(NSInteger)programId{
    NSString *sql = [NSString stringWithFormat:@"delete from program where program_id = %ld", programId];
    return [_db executeUpdate:sql];
}

- (Boolean)updateProgramItem:(ProgramModel *)model{
    NSString *sql = [NSString stringWithFormat:@"update program set program_title = '%@',startTime = %ld,endTime = %ld,duration = %ld,system_calender_reminder = '%@' where program_id = %ld", model.program_title, model.startTime, model.endTime, model.duration, model.system_calender_reminder, model.program_id];
    return [_db executeUpdate:sql];
}

- (NSMutableArray *)selectAllProgramData:(long)startTime endTime:(long)endTime{
    NSString *sql = [NSString stringWithFormat:@"select * from program where startTime >= %ld and endTime <= %ld order by startTime asc", startTime, endTime];
    FMResultSet *set = [_db executeQuery:sql];
    NSMutableArray *data = [NSMutableArray array];
    while (set.next) {
        NSDictionary *dictionary = [set resultDictionary];
        ProgramModel *model = (ProgramModel *)[ProgramModel yy_modelWithDictionary:dictionary];
        [data addObject:model];
    }
    return data;
}







- (Boolean)addRecordItem:(RecordModel *)model{
    NSString *sql = [NSString stringWithFormat:@"insert into local_record(user_id, patient_id, patient_area, record_mode, type_id, record_filter, position_tag, patient_posture, patient_symptom, patient_diagnosis, patient_sex, patient_birthday, patient_height, patient_weight, characteristics, record_time, record_length, file_path, oss_name, tag, modify_time, shared, create_time) values('%@','%@','%@',%ld,%ld,%ld,'%@',%ld,'%@','%@',%ld,'%@','%@','%@','%@','%@',%ld,'%@','%@','%@','%@',%ld,'%@')", model.user_id, model.patient_id, model.patient_area, model.record_mode, model.type_id,model.record_filter, model.position_tag, model.patient_posture, model.patient_symptom, model.patient_diagnosis, model.patient_sex, model.patient_birthday, model.patient_height, model.patient_weight, model.characteristics, model.record_time, model.record_length, model.file_path, model.oss_name, model.tag, model.modify_time, model.shared, model.create_time];
    DLog(@"sql = %@", sql);
    return [_db executeUpdate:sql];
}

- (Boolean)deleteRecordItemInTime:(NSString *)record_time{
    NSString *sql = [NSString stringWithFormat:@"delete from local_record where record_time = '%@'", record_time];
    return [_db executeUpdate:sql];
}

//查询记录
- (NSMutableArray *)selectRecord:(Boolean)mode_select mode:(NSInteger)mode typeSelect:(Boolean)type_select type:(NSInteger)type{
    NSMutableString *condition = [NSMutableString string];
    if (mode_select || type_select) {
        [condition appendString:@" where "];
    }
    if (mode_select) {
        [condition appendFormat:@"record_mode = %li ", mode];
        if (type_select) {
            [condition appendFormat:@"and type_id = %li", type];
        }
    } else if (type_select) {
        [condition appendFormat:@"type_id = %ld", type];
    }
    NSMutableArray *data = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from local_record %@ order by id desc", condition];
    FMResultSet *set = [_db executeQuery:sql];
    while (set.next) {
        NSDictionary *dictionary = [set resultDictionary];
        RecordModel *model = (RecordModel *)[RecordModel yy_modelWithDictionary:dictionary];
        [data addObject:model];
    }
    return data;
}

- (Boolean)updateRecordItem:(NSString *)fileName record:(RecordModel *)recordModel{
    NSString *sql = [NSString stringWithFormat:@"update local_record set user_id = '%@', patient_id = '%@', patient_area = '%@', record_mode = %ld, type_id = %ld, record_filter = %ld, position_tag = '%@', patient_posture = %ld, patient_symptom = '%@', patient_diagnosis = '%@', patient_sex = %ld, patient_birthday = '%@', patient_height = '%@', patient_weight = '%@', characteristics = '%@', record_time = '%@', record_length = %ld, file_path = '%@', oss_name = '%@', tag = '%@', modify_time = '%@', shared = %ld, create_time = '%@' where tag = '%@'", recordModel.user_id, recordModel.patient_id, recordModel.patient_area, recordModel.record_mode, recordModel.type_id, recordModel.record_filter, recordModel.position_tag, recordModel.patient_posture, recordModel.patient_symptom, recordModel.patient_diagnosis, recordModel.patient_sex, recordModel.patient_birthday, recordModel.patient_height, recordModel.patient_weight, recordModel.characteristics, recordModel.record_time, recordModel.record_length,recordModel.file_path, recordModel.oss_name, recordModel.tag, recordModel.modify_time, recordModel.shared, recordModel.create_time, fileName];
    return [_db executeUpdate:sql];
}

- (Boolean)updateRecordCharacteristicsItem:(NSString *)fileName  characteristics:(NSString *)characteristics{
    NSString *sql = [NSString stringWithFormat:@"update local_record set characteristics = '%@' where tag = '%@'", characteristics, fileName];
    return [_db executeUpdate:sql];
}


/**
 查询患者ID是否存在
 */
- (Boolean)checkPatientIDIsExist:(NSString *)patientId{
    NSString *sql = [NSString stringWithFormat:@"select count(patient_id) as countNum from patientHistory where patient_id = '%@'", patientId];
    FMResultSet *set = [_db executeQuery:sql];
    while ([set next]) {
        NSInteger count = [set intForColumn:@"countNum"];
        if (count > 0) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

/**
 添加数据
 */
- (Boolean)addPatientItemData:(PatientModel *)patientModel{
    if ([self checkPatientIDIsExist:patientModel.patient_id]) {
        [self deletePatientItemData:patientModel.patient_id];
    }
    NSString *sql = [NSString stringWithFormat:@"insert into patientHistory(patient_id, patient_sex, patient_birthday, patient_height, patient_weight, patient_symptom, patient_diagnosis, patient_area) values('%@', %ld, '%@', '%@', '%@', '%@', '%@', '%@')", patientModel.patient_id, patientModel.patient_sex, patientModel.patient_birthday, patientModel.patient_height, patientModel.patient_weight, patientModel.patient_symptom, patientModel.patient_diagnosis, patientModel.patient_area];
    return [_db executeUpdate:sql];
}

/**
 删除数据
 */
- (void)deletePatientItemData:(NSString *)patient_id{
    NSString *sql = [NSString stringWithFormat:@"delete from patientHistory where patient_id = '%@'", patient_id];
    BOOL success =  [_db executeUpdate:sql];
    DLog(@"%@", [@(success) stringValue]);
}
/**
 删除数据
 */
- (void)deleteAllPatientData{
    NSString *sql = [NSString stringWithFormat:@"delete from patientHistory"];
    [_db executeUpdate:sql];
}

- (PatientModel *)selectPatientItem:(NSString *)patient_id{
    NSMutableArray *data = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from patientHistory where patient_id = '%@'", patient_id];
    FMResultSet *set = [_db executeQuery:sql];
    while (set.next) {
        NSDictionary *dictionary = [set resultDictionary];
        PatientModel *model = (PatientModel *)[PatientModel yy_modelWithDictionary:dictionary];
        return model;
    }
    return nil;
}


/**
 查询所有记录
 */
- (NSMutableArray *)selectAllPatientHistory{
    NSMutableArray *data = [NSMutableArray array];
    NSString *sql = @"select * from patientHistory";
    FMResultSet *set = [_db executeQuery:sql];
    while (set.next) {
        NSDictionary *dictionary = [set resultDictionary];
        PatientModel *model = (PatientModel *)[PatientModel yy_modelWithDictionary:dictionary];
        [data addObject:model];
    }
    return data;
}




+ (instancetype)shareInstance{
    static HHDBHelper *dbHelp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbHelp = [[HHDBHelper alloc]init];
        
    });
    NSString *pathDB = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
    NSString *path = [NSString stringWithFormat:@"%@db/%@_%li.db", pathDB, LoginData.phone,LoginData.userID];//[
    DLog(@"db_path:%@",path);
    _db = [FMDatabase databaseWithPath:path];
    [_db open];
    /**
     program_id：数据库自动排序ID
     program_title：计划标题
     startTime：起始时间
     endTime：结束时间
     duration：时长（分钟）
     system_calender_reminder：存储接送记录提醒的内容数组
     */
    /**
     user_id:用户ID
     patient_id:患者编号
     patient_area:地区
     record_mode: 录音方式 0为快速录音 1为标准录音
     type_id: 音频类别 心音 肺音 之类
     record_filter:心肺音滤波开启状态：0 无开滤波 全频模式，1 打开了 滤波 心肺模式
     position_tag:听诊位置
     patient_posture:录音时的姿势
     patient_symptom:病症
     patient_diagnosis:诊断
     patient_sex:性别
     patient_birthday:出生日期
     patient_height:身高
     patient_weight: 体重
     characteristics:特征标注 病理者
     record_time:录音时间
     record_length:录音时长 秒
     file_path:本地路径
     oss_name:OSS文件名
     tag:文件名
     modify_time:修改时间
     shared:设置为全局分享
     create_time:上传时间
     */
    /**
     patient_id：病人ID
     patient_sex：病人性别
     patient_birthday：病人生日
     patient_height：病人身高
     patient_weight：病人体重
     patient_symptom：病症
     patient_diagnosis: 诊断
     patient_area: 病人地区
     */
    // 2.创表
    [_db executeUpdate:@"create table if not exists program(program_id integer primary key autoincrement, program_title text, startTime long, endTime long, duration integer, system_calender_reminder text);"];
    [_db executeUpdate:@"create table if not exists local_record(id integer primary key autoincrement, user_id text, patient_id text,patient_area text, record_mode integer,type_id integer,record_filter int,position_tag text,patient_posture integer,patient_symptom text,patient_diagnosis text,patient_sex integer,patient_birthday text,patient_height text,patient_weight text,characteristics text,record_time text,record_length integer,file_path text,oss_name text,tag text,modify_time text,shared integer,create_time text);"];
    [_db executeUpdate:@"create table if not exists patientHistory(id integer primary key autoincrement, patient_id text, patient_sex integer, patient_birthday text, patient_height text, patient_weight text, patient_symptom text, patient_diagnosis text, patient_area text);"];
    return dbHelp;
}






@end
