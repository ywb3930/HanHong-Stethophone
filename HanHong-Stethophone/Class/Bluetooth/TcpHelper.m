//
//  TcpHelper.m
//  HanHong-Stethophone
//
//  Created by Eason on 2023/7/1.
//

#import "TcpHelper.h"

@implementation TcpHelper
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    
    NSLock *connection_mutex;
    
    BOOL connection_enabled;
    BOOL connection_running;
    NSThread *connection_thread;
    
    NSLock *tcp_rx_mutex;
    NSMutableArray *tcp_rx_pkt_list;
    NSMutableArray *tcp_rx_ptr;
    int tcp_rx_avaliable;
    
    
    BOOL connected;
    BOOL connect_error;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        connection_mutex = [NSLock new];
        tcp_rx_mutex = [NSLock new];
        tcp_rx_pkt_list = [NSMutableArray array];
        tcp_rx_ptr = [NSMutableArray array];
        tcp_rx_avaliable = 0;
        
        connection_enabled = false;
        connection_running = false;
        connected = false;
        connect_error = false;
    }
    return self;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) {
            
        case NSStreamEventOpenCompleted:
            if (aStream == outputStream) {
                connected = true;
                
                
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            if (aStream == outputStream) {
                //NSLog(@"NSStream Has Space Event");
            }
            break;
        case NSStreamEventHasBytesAvailable:
            if (aStream == inputStream) {
                
                // 读取数据
                uint8_t buffer[1024];
                NSInteger bytesRead = [inputStream read:buffer maxLength:sizeof(buffer)];
                if (bytesRead > 0) {
                    
                    [tcp_rx_mutex lock];
                    
                    NSData *pkt = [NSData dataWithBytes:buffer length:bytesRead];
                    
                    [tcp_rx_pkt_list addObject:pkt];
                    [tcp_rx_ptr addObject:@(0)];
                    tcp_rx_avaliable += bytesRead;
                    
                    [tcp_rx_mutex unlock];
                }
                
            }
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"NSStream Error Event");
            //连接失败
            connect_error = true;
            connection_enabled = false;
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"NSStream End Event");
            connected = false;
            connection_enabled = false;
            break;
        default:
            break;
    }
}

-(void)Connect:(NSString *)domain_or_ip port:(int)port
{
    [self Disconnect];
       
    [tcp_rx_mutex lock];

    [tcp_rx_pkt_list removeAllObjects];
    [tcp_rx_ptr removeAllObjects];
    tcp_rx_avaliable = 0;

    [tcp_rx_mutex unlock];
     
    [connection_mutex lock];
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)domain_or_ip, (UInt32)port, &readStream, &writeStream);
        
    if (!CFWriteStreamOpen(writeStream)) {
        @throw [NSException exceptionWithName:@"TcpHelper" reason:@"Tcp Connect Error" userInfo:nil];
    }
     
    inputStream = (__bridge_transfer NSInputStream *)readStream;
    outputStream = (__bridge_transfer NSOutputStream *)writeStream;
      
    inputStream.delegate = self;
    outputStream.delegate = self;
    
    connection_enabled = true;
    connection_running = true;
    
    connection_thread = [[NSThread alloc] initWithBlock:^{
        
        @autoreleasepool {
            
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            
            [self->inputStream scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
            [self->outputStream scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
            
            [self->inputStream open];
            [self->outputStream open];
            
            while (self->connection_enabled) {
                [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            
            [self->inputStream close];
            [self->outputStream close];
            
            [self->inputStream removeFromRunLoop:runLoop forMode:NSDefaultRunLoopMode];
            [self->outputStream removeFromRunLoop:runLoop forMode:NSDefaultRunLoopMode];
            
            self->connection_running = false;
            
        }
    }];
    
    [connection_thread start];
    
    [connection_mutex unlock];
    
    while (true) {
        
        if (connected) {
            return;
        }
        
        if (connect_error) {
            @throw [NSException exceptionWithName:@"TcpHelper" reason:@"Tcp Connect Failed" userInfo:nil];
        }
        
        [NSThread sleepForTimeInterval:0.01];
        
    }
    
}
 

-(void)Disconnect
{
    [connection_mutex lock];
    if (!connection_enabled) {
        [connection_mutex unlock];
        return;
    }
    connection_enabled = false;
     
    while(connection_running) {
        [NSThread sleepForTimeInterval:0.01];
    }
     
    inputStream.delegate = nil;
    inputStream = nil;
 
    outputStream.delegate = nil;
    outputStream = nil;
    
    [connection_mutex unlock];
}

-(void)WriteBytes:(NSData *)tcp_data
{
    @try{
        if (!connected) {
            @throw [NSException exceptionWithName:@"TcpHelper" reason:@"Tcp not connect" userInfo:nil];
        }
         
        int send_length = (int)tcp_data.length;
        int offset = 0;
        int send_count = 0;
        const unsigned char *send_ptr = (const unsigned char *)tcp_data.bytes;
        
        do {
            int send_size = (int)[outputStream write:(send_ptr + offset) maxLength:(send_length - offset)];
            send_count += send_size;
            offset += send_size;
        } while(connected && send_count != send_length);
            
        if (!connected) {
            @throw [NSException exceptionWithName:@"TcpHelper" reason:@"Tcp disconnected" userInfo:nil];
        }
    }
    @catch(NSException *e) {
        NSLog(@"Tcp Write Bytes Exception %@ %@", e.name, e.reason);
        @throw e;
    }
}

-(BOOL)ReadBytes:(NSMutableData *)tcp_data len:(int)len timeout:(float)timeout
{
//    @try {
         
        int rx_avaliable = 0;
        int off = 0;
        
        NSDate *startTime = [NSDate date];
        
        while (connected) {
            
            rx_avaliable = tcp_rx_avaliable;
            if (rx_avaliable >= len) {
                break;
            }
            
            NSDate *currentTime = [NSDate date];
            
            NSTimeInterval elapsedTime = [currentTime timeIntervalSinceDate:startTime];
            
            if (elapsedTime >= timeout)  {//10S
                break;
            }
            
            [NSThread sleepForTimeInterval:0.01];
        }
        
        if (rx_avaliable >= len) {
            
            @try {
                
                [tcp_rx_mutex lock];
                
                tcp_rx_avaliable -= len;
                
                while(len > 0) {
                    
                    NSData * data =  (NSData *)tcp_rx_pkt_list[0];
                    long ptr = [(NSNumber *)tcp_rx_ptr[0] integerValue];
                    
                    long avaliable = data.length - ptr;
                    
                    const void *copy_pos = [data bytes] + ptr;
                    
                    if (len >= avaliable) {
                        [tcp_data replaceBytesInRange:NSMakeRange(off, avaliable) withBytes:copy_pos length:avaliable];
                        off += avaliable;
                        len -= avaliable;
                        [tcp_rx_pkt_list removeObjectAtIndex:0];
                        [tcp_rx_ptr removeObjectAtIndex:0];
                    } else {
                        [tcp_data replaceBytesInRange:NSMakeRange(off, len) withBytes:copy_pos length:len];
                        long new_ptr = ptr + len;
                        [tcp_rx_ptr replaceObjectAtIndex:0 withObject:@(new_ptr)];
                        len = 0;
                    }
                    
                    
                }
                
                [tcp_rx_mutex unlock];
                
            } @catch (NSException *exception) {
                  
                [tcp_rx_mutex unlock];

                NSLog(@"tcp_readbytes error1, %@ %@", exception.name, exception.reason);
              
                @throw [NSException exceptionWithName:@"tcp_readbytes" reason:@"" userInfo:nil];
                
            }
            
        } else {
            
            //NSLog(@"tcp_readbytes timeout");
            
            @throw [NSException exceptionWithName:@"tcp_readbytes" reason:@"" userInfo:nil];
             
        }
        
//    } @catch (NSException *exception) {
//
//        //NSLog(@"tcp_readbytes error2, %@ %@", exception.name, exception.reason);
//
//        @throw [NSException exceptionWithName:@"tcp_readbytes" reason:@"" userInfo:nil];
//
//    }
}





@end
