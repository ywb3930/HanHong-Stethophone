//
//  BluetoothHelper.c
//  HanHong-Stethophone
//
//  Created by Eason on 2023/6/19.
//

#import "BluetoothHelper.h"
#import <mach/mach_time.h>

NSArray const *default_name_filter = @[@"POPULAR-3", @"POP-3"];

@implementation BluetoothHelper {
    
    CBCentralManager *centralManager;//搜索中心
    BOOL central_manager_valid;
    
    NSLock *lock;
    
    NSArray * search_filter;
    
    int scanMode;  // 1 search scan  , 2 connect scan
    NSTimer * scanTimer;
     
    CBPeripheral *device;//当前连接的设备
    CBCharacteristic * writeCharacteristic;
    CBCharacteristic * readCharacteristic;
    
    NSString *deviceMacAddr;
    BOOL deviceScanSuccess;
    BOOL deviceScanEnd;
    
    BOOL device_connecting;
    BOOL device_connect_error;
    
    BOOL abort_connect;
    BOOL connecting;
    BOOL connected;
    
    NSLock *ble_tx_mutex;
    NSMutableArray *ble_tx_pkt_list;
    NSMutableArray *ble_tx_ptr;
    int ble_tx_avaliable;
    BOOL ble_tx_running;
    
    NSLock *ble_rx_mutex;
    NSMutableArray *ble_rx_pkt_list;
    NSMutableArray *ble_rx_ptr;
    int ble_rx_avaliable;
    
}

-(instancetype)init{
    self = [super init];
    if (self) {
        
        [self initCentralManager];
        
        lock = [NSLock new];
        
        central_manager_valid = false;
        
        scanMode = 0;
        
        ble_tx_mutex = [NSLock new];
        ble_tx_pkt_list = [NSMutableArray array];
        ble_tx_ptr = [NSMutableArray new];
        ble_tx_avaliable = 0;
        ble_tx_running = false;
        
        ble_rx_mutex = [NSLock new];
        ble_rx_pkt_list = [NSMutableArray array];
        ble_rx_ptr = [NSMutableArray new];
        ble_rx_avaliable = 0;
    }
    return self;
}

-(void)initCentralManager{
    
    // 非后台模式
#if  __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_0
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             //蓝牙power没打开时alert提示框
                             [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey,
                             //重设centralManager恢复的IdentifierKey
                             @"babyBluetoothRestore",CBCentralManagerOptionRestoreIdentifierKey,
                             nil];
    
#else
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             //蓝牙power没打开时alert提示框
                             [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey,
                             nil];
#endif
    
    NSArray *backgroundModes = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"UIBackgroundModes"];
    if ([backgroundModes containsObject:@"bluetooth-central"]) {
        //后台模式
        centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
    }
    else {
        //非后台模式
        centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
    
    
}
 
-(BOOL)CheckAdapter
{
    return [centralManager state] == CBManagerStatePoweredOn;
}

//name_filter 如果为空，则默认所有类型的汉泓设备
-(BOOL)Search:(NSArray *) name_filter
{
    
    if ([centralManager state] != CBManagerStatePoweredOn) {
        NSLog(@"Search Failed, bluetooth not turn on");
        return NO;
    }
    
    
    [lock lock];
    
    do {
        
        if (scanMode == 1) {
            NSLog(@"Searching is already running");
            break;
        } else if (scanMode == 2) {
            NSLog(@"Connecting with scan, not allow to search");
            break;
        }
        
        scanMode = 1;
        
        if (self.searchDelegate && [self.searchDelegate  respondsToSelector:@selector(onSearchStart)]) {
            [self.searchDelegate onSearchStart];
        }
        
        NSLog(@"Search start");
        
        if (name_filter != NULL) {
            search_filter = [name_filter copy];
        } else {
            search_filter = [default_name_filter copy];
        }
        
        [centralManager scanForPeripheralsWithServices:nil options:nil];
        scanTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
        
        [lock unlock];
        return true;
        
    } while (0);
    
    [lock unlock];
    return false;
}

-(void)scanTimer:(NSTimer *)timer
{
    [self AbortSearch];
}

- (void)AbortSearch
{
    
    [lock lock];
    
    if (scanMode != 1) {
        [lock unlock];
        return;
    }
    
    [centralManager stopScan];
    [scanTimer invalidate];
    scanTimer = nil;
    
    scanMode = 0;
    
    if (self.searchDelegate && [self.searchDelegate  respondsToSelector:@selector(onSearchFinished)]) {
        [self.searchDelegate  onSearchFinished];
    }
    
    NSLog(@"Search End");
    
    [lock unlock];
    
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    if (central.state == CBManagerStatePoweredOn) {
        central_manager_valid = YES;
    } else {
        central_manager_valid = NO;
    }
}

//发现到的设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI
{
    if (scanMode == 1) { //Search Mode
        
        for (NSString * filter in search_filter) {
            
            if ([peripheral.name hasPrefix:filter]) {
                
                NSString * macStr = @"";
                NSData *AdvData = (NSData *)advertisementData[@"kCBAdvDataManufacturerData"];
                if (AdvData.length > 0) {
                    macStr = [BluetoothHelper convertDataToHexStr:advertisementData[@"kCBAdvDataManufacturerData"]];
                    
                    NSLog(@"Search found %@ %@", peripheral.name, macStr);
                    
                    if (self.searchDelegate && [self.searchDelegate  respondsToSelector:@selector(onSearchFound:device_mac:)]) {
                        [self.searchDelegate  onSearchFound:peripheral.name device_mac:macStr];
                    }
                }
            }
        }
    } else if (scanMode == 2) {  //Connect Mode
        
        for (NSString * filter in default_name_filter) {
            
            if ([peripheral.name hasPrefix:filter]) {
                
                NSString * macStr = @"";
                NSData *AdvData = (NSData *)advertisementData[@"kCBAdvDataManufacturerData"];
                if (AdvData.length > 0) {
                    macStr = [BluetoothHelper convertDataToHexStr:advertisementData[@"kCBAdvDataManufacturerData"]];
                    
                    NSLog(@"Connect Search found %@ %@", peripheral.name, macStr);
                    
                    if ([macStr isEqualToString:deviceMacAddr]) {
                        
                        device = peripheral;
                        deviceScanSuccess = true;
                        deviceScanEnd = true;
                        
                        NSLog(@"Connect Target found");
                    }
                    
                    
                }
            }
            
        }
    }
}

-(BOOL)Connect:(NSString *)macAddr
{
    [self AbortSearch];
    
    [lock lock];
    
    if (scanMode != 0) {
        [lock unlock];
        return false;
    }
    
    if (connected || connecting) {
        
        [lock unlock];
        
        return false;
    }
    
    if ([centralManager state] != CBManagerStatePoweredOn) {
        
        [lock unlock];
        
        return false;
    }
    
    connected = false;
    connecting = true;
    
    abort_connect = false;
    
    //Scan first
    
    scanMode = 2;
    
    [lock unlock];
    
    deviceScanEnd = false;
    deviceScanSuccess = false;
    
    deviceMacAddr = [macAddr copy];
    
    NSLog(@"Connect Search Start");
    
    [centralManager scanForPeripheralsWithServices:nil options:nil];
    
    NSDate *scan_start_time = [NSDate date];
    
    //Wait for scan
    while(!abort_connect && !deviceScanEnd) {
        
        NSDate *currentTime = [NSDate date];
        NSTimeInterval elapsedTime = [currentTime timeIntervalSinceDate:scan_start_time];
        
        if (elapsedTime >= 10.0) {
            break;
        }
        
        [NSThread sleepForTimeInterval:0.01];
    }
    
    scanMode = 0;
    
    [centralManager stopScan];
    
    NSLog(@"Connect Search End");
    
    if (abort_connect || !deviceScanSuccess) {
        
        //Scan failed or abort connect
        connecting = false;
        
        return false;
    }
    
    //Start to connect
    device_connecting = true;
    device_connect_error = false;
    
    device.delegate = self;
    [centralManager connectPeripheral:device options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey : @true}];
    
    //Wait for connect
    while(!abort_connect && device_connecting) {
        [NSThread sleepForTimeInterval:0.01];
    }
    
    if (abort_connect || device_connect_error) {
        
        //Cancel connect
        [centralManager cancelPeripheralConnection:device];
        
        //Wait if connecting
        while(device_connecting) {
            [NSThread sleepForTimeInterval:0.01];
        }
        
        connecting = false;
        
        return false;
        
    } else {
        
        [ble_tx_pkt_list removeAllObjects];
        [ble_tx_ptr removeAllObjects];
        ble_tx_avaliable = 0;
        ble_tx_running = false;
        
        [ble_rx_pkt_list removeAllObjects];
        [ble_rx_ptr removeAllObjects];
        ble_rx_avaliable = 0;
        
        connecting = false;
        connected = true;
        
    }
    
    return connected;
    
}

-(void)Disconnect{
    abort_connect = true;
    if (device) {
        //Disconnect
        [centralManager cancelPeripheralConnection:device];
        
        device = nil;
        readCharacteristic = nil;
        writeCharacteristic = nil;
    }
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    NSLog(@"Device didDisconnectPeripheral");
    
    if (readCharacteristic) {
        [peripheral setNotifyValue:NO forCharacteristic:readCharacteristic];
    }
    
    connected = false;
    
    if (device_connecting) {
        device_connect_error = true;
        device_connecting = false;
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"Device didConnectPeripheral");
    
    [peripheral discoverServices:nil]; //查找服务
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    NSLog(@"Device didDiscoverServices");
    
    if (error) {
        device_connect_error = true;
        device_connecting = false;
        return;
    }
    
    BOOL service_found = false;
    for (CBService *s in peripheral.services) {
        if([s.UUID isEqual:[CBUUID UUIDWithString:@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"]]){
            service_found = true;
            [peripheral discoverCharacteristics:nil forService:s];
            break;
        }
    }
    if(!service_found){
        device_connect_error = true;
        device_connecting = false;
    }
}

-(void)setNotifyValue:(BOOL)flag forCharacteristic:(CBCharacteristic*)c{
    [device setNotifyValue:flag forCharacteristic:c];
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    NSLog(@"Device didDiscoverCharacteristicsForService");
    
    if (error) {
        device_connect_error = true;
        device_connecting = false;
        return;
    }
    
    for (CBCharacteristic *c in service.characteristics){
        CBCharacteristicProperties properties = c.properties;
        if (properties & CBCharacteristicPropertyWrite) {
            writeCharacteristic = c;
        }else if (properties & CBCharacteristicPropertyNotify) {
            readCharacteristic = c;
            [peripheral setNotifyValue:YES forCharacteristic:c];
        }else if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
            writeCharacteristic = c;
        }else if (properties & CBCharacteristicPropertyIndicate) {
            
        }
    }
    
    if (!writeCharacteristic || !readCharacteristic) {
        device_connect_error = true;
    }
    
    //连接过程结束
    device_connecting = false;
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    if (characteristic != readCharacteristic) {
        return;
    }
    
    if (characteristic.value.length == 0) {
        return;
    }
    
    [self ble_recv:characteristic.value];
}

-(void)ble_send
{
    @try {
        
        [ble_tx_mutex lock];
        
        do {
            
            if (ble_tx_avaliable == 0) {
                ble_tx_running = false;
                break;
            }
            
            int len;
            
            if (ble_tx_avaliable >= 244) {
                len = 244;
            } else {
                len = ble_tx_avaliable;
            }
            
            ble_tx_avaliable -= len;
            
            NSMutableData *ble_tx_data = [NSMutableData dataWithLength:len];
            
            int off = 0;
            while(len > 0) {
                NSData *data = (NSData *)ble_tx_pkt_list[0];
                long ptr = [(NSNumber *)ble_tx_ptr[0] integerValue];
                long avaliable = data.length - ptr;
                
                const void *copy_pos = [data bytes] + ptr;
                if (len >= avaliable) {
                    [ble_tx_data replaceBytesInRange:NSMakeRange(off, avaliable) withBytes:copy_pos length:avaliable];
                    off += avaliable;
                    len -= avaliable;
                    [ble_tx_pkt_list removeObjectAtIndex:0];
                    [ble_tx_ptr removeObjectAtIndex:0];
                } else {
                    [ble_tx_data replaceBytesInRange:NSMakeRange(off, len) withBytes:copy_pos length:len];
                    long new_ptr = ptr + len;
                    [ble_tx_ptr replaceObjectAtIndex:0 withObject:@(new_ptr)];
                    len = 0;
                }
            }
            
            NSData *tx_data = [NSData dataWithData:ble_tx_data];
            
            ble_tx_data = nil;
            
            [device writeValue:tx_data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
              
        } while(0);
        
        [ble_tx_mutex unlock];
          
        if (ble_tx_running){
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.003 * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                @try {
                    [self ble_send];
                }
                @catch (NSException *e) {
                    
                }
            });
        }
        
    } @catch (NSException *exception) {
        
        [ble_tx_mutex unlock];

        NSLog(@"ble_send error, %@ %@", exception.name, exception.reason);
      
    }
}


-(void)ble_write:(NSData *)data
{
    @try {
        [ble_tx_mutex lock];
        
        [ble_tx_pkt_list addObject:data];
        [ble_tx_ptr addObject:@(0)];
        ble_tx_avaliable += data.length;
        if (ble_tx_running) {
            
            [ble_tx_mutex unlock];
            
            return;
        }
        
        ble_tx_running = true;
        
        [ble_tx_mutex unlock];
        
        [self ble_send];
        
    } @catch (NSException *exception) {
        
        [ble_tx_mutex unlock];

        NSLog(@"ble_write error, %@ %@", exception.name, exception.reason);
        
        @throw [NSException exceptionWithName:@"ble_write" reason:@"" userInfo:nil];
        
    }
}

-(void)ble_recv:(NSData *)data
{
    if (!data) return;
    
    [ble_rx_mutex lock];
    
    [ble_rx_pkt_list addObject:data];
    [ble_rx_ptr addObject:@(0)];
    ble_rx_avaliable += data.length;
    
    [ble_rx_mutex unlock];
}


-(unsigned char)ble_readbyte{
    
    @try {
         
        int rx_avaliable = 0;
        
        NSDate *startTime = [NSDate date];
        
        while (connected) {
           
            rx_avaliable = ble_rx_avaliable;
            
            if (rx_avaliable > 0) {
                break;
            }
            
            NSDate *currentTime = [NSDate date];
            
            NSTimeInterval elapsedTime = [currentTime timeIntervalSinceDate:startTime];
            
            if (elapsedTime >= 10.0)  {//10S
                break;
            }

            [NSThread sleepForTimeInterval:0.01];
        }
        
        if (rx_avaliable > 0) {
            
            unsigned char byte;
            
            @try {
                [ble_rx_mutex lock];
                
                ble_rx_avaliable -= 1;
                NSData * data =  (NSData *)ble_rx_pkt_list[0];
                long ptr = [(NSNumber *)ble_rx_ptr[0] integerValue];
                byte = ((const unsigned char *)data.bytes)[ptr];
                long new_ptr = ptr + 1;
                if (new_ptr == data.length) {
                    [ble_rx_pkt_list removeObjectAtIndex:0];
                    [ble_rx_ptr removeObjectAtIndex:0];
                } else {
                    [ble_rx_ptr replaceObjectAtIndex:0 withObject:@(new_ptr)];
                    
                }
                
                [ble_rx_mutex unlock];
                
                return byte;
                
            } @catch (NSException *exception) {
                  
                [ble_rx_mutex unlock];

                NSLog(@"ble_readbyte error, %@ %@", exception.name, exception.reason);
              
                @throw [NSException exceptionWithName:@"ble_readbyte" reason:@"" userInfo:nil];
                
            }
            
        } else {
            
            NSLog(@"ble_readbyte timeout");
            
            @throw [NSException exceptionWithName:@"ble_readbyte" reason:@"" userInfo:nil];
             
        }
        
    } @catch (NSException *exception) {
        
        NSLog(@"ble_readbyte error, %@ %@", exception.name, exception.reason);
      
        @throw [NSException exceptionWithName:@"ble_readbyte" reason:@"" userInfo:nil];
        
    }
    
}

-(void)ble_readbytes:(NSMutableData *)ble_data offset:(int)off length:(int)len
{
    @try {
        
        
        int rx_avaliable = 0;
        
        NSDate *startTime = [NSDate date];
        
        while (connected) {
            
            rx_avaliable = ble_rx_avaliable;
            if (rx_avaliable > len) {
                break;
            }
            
            NSDate *currentTime = [NSDate date];
            
            NSTimeInterval elapsedTime = [currentTime timeIntervalSinceDate:startTime];
            
            if (elapsedTime >= 10.0)  {//10S
                break;
            }
            
            [NSThread sleepForTimeInterval:0.01];
        }
        
        if (rx_avaliable >= len) {
            
            @try {
                
                [ble_rx_mutex lock];
                
                ble_rx_avaliable -= len;
                
                while(len > 0) {
                    
                    NSData * data =  (NSData *)ble_rx_pkt_list[0];
                    long ptr = [(NSNumber *)ble_rx_ptr[0] integerValue];
                    
                    long avaliable = data.length - ptr;
                    
                    const void *copy_pos = [data bytes] + ptr;
                    
                    if (len >= avaliable) {
                        [ble_data replaceBytesInRange:NSMakeRange(off, avaliable) withBytes:copy_pos length:avaliable];
                        off += avaliable;
                        len -= avaliable;
                        [ble_rx_pkt_list removeObjectAtIndex:0];
                        [ble_rx_ptr removeObjectAtIndex:0];
                    } else {
                        [ble_data replaceBytesInRange:NSMakeRange(off, len) withBytes:copy_pos length:len];
                        long new_ptr = ptr + len;
                        [ble_rx_ptr replaceObjectAtIndex:0 withObject:@(new_ptr)];
                        len = 0;
                    }
                    
                    
                }
                
                [ble_rx_mutex unlock];
                
            } @catch (NSException *exception) {
                  
                [ble_rx_mutex unlock];

                NSLog(@"ble_readbytes error, %@ %@", exception.name, exception.reason);
              
                @throw [NSException exceptionWithName:@"ble_readbytes" reason:@"" userInfo:nil];
                
            }
            
        } else {
            
            NSLog(@"ble_readbytes timeout");
            
            @throw [NSException exceptionWithName:@"ble_readbytes" reason:@"" userInfo:nil];
             
        }
        
    } @catch (NSException *exception) {
        
        NSLog(@"ble_readbytes error, %@ %@", exception.name, exception.reason);
      
        @throw [NSException exceptionWithName:@"ble_readbytes" reason:@"" userInfo:nil];
        
    }
    
}

-(NSString *)ReadLine:(BOOL)end_with_lf
{
    NSMutableString *str = [NSMutableString new];
    @try {
        do {
            unsigned char recv_byte;
            recv_byte = [self ble_readbyte];
            
            if (recv_byte <='\0' || recv_byte == '\n') {
                continue;
            }
            
            [str appendFormat:@"%c", recv_byte];
            
            if (recv_byte == '\r') {
                //\n
                if (end_with_lf) {
                    recv_byte = [self ble_readbyte];
                }
                
                return [NSString stringWithFormat:@"%@", str];
                
            }
             
        } while(connected);
        
        @throw [NSException exceptionWithName:@"ReadLine" reason:@"" userInfo:nil];
         
    } @catch (NSException *exception) {
            
        @throw exception;
    }
}

-(NSString *)WaitResponse:(NSString *)target
{
    NSString *line;
    
    do {
        line = [self ReadLine:true];
        if ([line containsString:target]) {
            return line;
        }
    } while (true);
}

-(NSData *) ReadBytes:(int)length
{
    NSMutableData *data = [NSMutableData dataWithLength:length];
    
    if (connected)
    {
        @try {
            [self ble_readbytes:data offset:0 length:length];
        }
        @catch (NSException *exception) {
            @throw exception;
        }
        
        NSData *ret_data = [NSData dataWithData:data];
        
        data = nil;
        
        return ret_data;
    } else {
        @throw [NSException exceptionWithName:@"ReadBytes" reason:@"" userInfo:nil];
    }
}

-(void)WriteStr:(NSString *)str
{
    @try {
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [self ble_write:data];
    }
    @catch(NSException *exception)
    {
        @throw exception;
    }
}

-(void)WriteBytes:(NSData *)data
{
    @try {
        [self ble_write:data];
    } @catch (NSException *exception) {
        @throw exception;
    } 
}

+ (NSString *)convertDataToHexStr:(NSData *)data
{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:[NSString stringWithFormat:@"%@",hexStr]];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    NSString *ret_string = [NSString stringWithString:string];
     
    string = nil;
    
    return ret_string;
}

@end


