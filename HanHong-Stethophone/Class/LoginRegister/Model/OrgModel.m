//
//  OrgModel.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/14.
//

#import "OrgModel.h"

@implementation OrgModel
/**
 @property (retain, nonatomic) NSString   *code;
 @property (retain, nonatomic) NSString   *server_url;
 @property (retain, nonatomic) NSString   *short_name;
 @property (assign, nonatomic) NSInteger  type;
 @property (retain, nonatomic) NSString   *name;
 @property (retain, nonatomic) NSString   *avatar;
 */

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.code forKey:@"code"];
    [aCoder encodeObject:self.server_url forKey:@"server_url"];
    [aCoder encodeObject:self.short_name forKey:@"short_name"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.code = [aDecoder decodeObjectForKey:@"code"];
        self.server_url = [aDecoder decodeObjectForKey:@"server_url"];
        self.short_name = [aDecoder decodeObjectForKey:@"short_name"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
    }
    return self;
}

@end
