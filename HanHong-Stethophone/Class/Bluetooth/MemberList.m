//
//  MemberList.m
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/28.
//
#import "MemberList.h"

@implementation MemberList
{
    NSLock *lock;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        lock = [NSLock new];
        self.members = [NSMutableArray array];
    }
    
    return self;
}

-(instancetype)initWithMembers:(NSArray<Member *> *)members
{
    self = [super init];
    if (self)
    {
        lock = [NSLock new];
        self.members = [NSMutableArray array];
        
        if (members != NULL) {
            for (Member *member in members) {
                [self.members addObject:member];
            }
        }
    }
    
    return self;
}

-(int)count
{
    return (int)self.members.count;
}

-(void)addMember:(Member *)new_member
{
    [lock lock];
    BOOL exist = false;
    for (Member *member in self.members) {
        if ((member.role == new_member.role) && [member.user_phone isEqualToString:new_member.user_phone]) {
           exist = true;
        }
    }
    if (!exist) {
        [self.members addObject:new_member];
    }
    [lock unlock];
}

-(void)removeMember:(Member *)remove_member
{
    [lock lock];
    Member *exist_member = NULL;
    for (Member *member in self.members) {
        if ((member.role == remove_member.role) && [member.user_phone isEqualToString:remove_member.user_phone]) {
            exist_member = member;
            break;
        }
    }
    if (exist_member != NULL) {
        [self.members removeObject:exist_member];
    }
    [lock unlock];
    
}

-(void)clear
{
    [lock lock];
    
    [self.members removeAllObjects];
    
    [lock unlock];
}

@end
