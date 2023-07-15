//
//  ShareDataModel.h
//  HanHong-Stethophone
//
//  Created by HanHong on 2023/7/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShareDataModel : NSObject

@property (retain, nonatomic) NSString                  *characteristics;
@property (retain, nonatomic) NSString                  *characteristics_simple;
@property (retain, nonatomic) NSString                  *name;
@property (retain, nonatomic) NSString                  *patient_diagnosis;
@property (retain, nonatomic) NSString                  *patient_symptom;
@property (retain, nonatomic) NSString                  *phone;
@property (retain, nonatomic) NSString                  *position;
@property (retain, nonatomic) NSString                  *position_tag;
@property (assign, nonatomic) NSInteger         record_length;
@property (assign, nonatomic) NSInteger         role;
@property (retain, nonatomic) NSString                  *role_name;
@property (retain, nonatomic) NSString                  *share_code;
@property (assign, nonatomic) NSInteger         type;
@property (assign, nonatomic) NSInteger         type_id;
@property (retain, nonatomic) NSString                  *url;

@end

NS_ASSUME_NONNULL_END
