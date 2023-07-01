//
//  TeachingHistoryModel.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TeachingHistoryModel : NSObject

@property (retain, nonatomic) NSString              *class_begin_time;
@property (retain, nonatomic) NSString              *class_end_time;
@property (assign, nonatomic) long                  classroom_id;
@property (assign, nonatomic) long                  teacher_id;
@property (retain, nonatomic) NSString              *create_time;
@property (assign, nonatomic) NSInteger             number_of_learners;
@property (assign, nonatomic) NSInteger             state;
@property (assign, nonatomic) NSInteger             class_state;
@property (assign, nonatomic) NSInteger             teaching_times;
@property (retain, nonatomic) NSString              *server_url;

@end

NS_ASSUME_NONNULL_END
