//
//  BtHelper.h
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/19.
//

#ifndef BtHelper_h
#define BtHelper_h


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSArray const *default_name_filter;

@protocol SearchDelegate <NSObject>

@optional
-(void)onSearchStart;

@optional
-(void)onSearchFinished;

@required
-(void)onSearchFound:(NSString *)device_name device_mac:(NSString *)device_mac;

@end


@interface BluetoothHelper : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate> {
    
}

@property (weak, nonatomic) id<SearchDelegate > searchDelegate;

-(BOOL)CheckAdapter;

-(BOOL)Search:(NSArray *) name_filter;
-(void)AbortSearch;


-(BOOL)Connect:(NSString *)macAddr;
-(void)Disconnect;
-(NSString *)ReadLine: (BOOL)end_with_lf;
-(NSString *)WaitResponse:(NSString *)target;
-(NSData *)ReadBytes: (int)length;
-(void)WriteStr:(NSString *)str;
-(void)WriteBytes:(NSData *)data;

+(NSString *)convertDataToHexStr:(NSData *)data;


@end


#endif /* BtHelper_h */
