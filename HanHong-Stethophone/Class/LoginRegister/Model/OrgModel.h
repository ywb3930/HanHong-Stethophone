//
//  OrgModel.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OrgModel : NSObject<NSCoding>

@property (retain, nonatomic) NSString   *code;
@property (retain, nonatomic) NSString   *server_url;
@property (retain, nonatomic) NSString   *short_name;
@property (assign, nonatomic) NSInteger  type;
@property (retain, nonatomic) NSString   *name;
@property (retain, nonatomic) NSString   *avatar;


@end

NS_ASSUME_NONNULL_END
