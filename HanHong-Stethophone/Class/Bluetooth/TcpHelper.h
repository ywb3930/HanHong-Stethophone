//
//  TcpHelper.h
//  HanHong-Stethophone
//
//  Created by Eason on 2023/7/1.
//

#ifndef TcpHelper_h
#define TcpHelper_h

#import <Foundation/Foundation.h>

@interface TcpHelper : NSObject<NSStreamDelegate>

-(void)Connect:(NSString *)domain_or_ip port:(int)port;
-(void)WriteBytes:(NSData *)tcp_data;
-(void)ReadBytes:(NSMutableData *)tcp_data len:(int)len timeout:(float)timeout;
-(void)Disconnect;

@end

#endif /* TcpHelper_h */
