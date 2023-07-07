//
//  MemberList.h
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/28.
//

#ifndef MemberList_h
#define MemberList_h


#import <Foundation/Foundation.h>
#import "Member.h"

@interface MemberList : NSObject
{
    
}

@property (strong, atomic) NSMutableArray *members;

-(instancetype)initWithMembers:(NSArray<Member *> *)members;
-(int)count;
-(void)addMember:(Member *)new_member;
-(void)removeMember:(Member *)remove_member;
-(void)clear;

@end
#endif /* MemberList_h */
