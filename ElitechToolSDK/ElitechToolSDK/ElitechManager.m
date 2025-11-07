//
//  ElitechManager.m
//  ElitechTool
//
//  Created by wuwu on 2025/10/27.
//

#import "ElitechManager.h"
#import "NSData+Util.h"
#import "ETNewProtocolWorker.h"
#import "ETBleScanData.h"
//#import "DeviceTypeDefine.h"


NSString * const ETDeviceCodeVgwmini = @"0003";
NSString * const ETDeviceTypeNameVgwmini = @"VGW-mini";


NSString* vgwMini_serviceUUID = @"FCFD";
NSString* vgwMini_recvCharacteristicsUUID = @"FCFD";
NSString* vgwMini_sendCharacteristicsUUID = @"FCFE";


@interface ElitechManager()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic,strong) CBCentralManager *centeralManager;


@end

@implementation ElitechManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = [NSPointerArray weakObjectsPointerArray];
//        _connectedPeripherals = [NSPointerArray weakObjectsPointerArray];
        _centeralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

+ (ElitechManager *)shared
{
    static ElitechManager *instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)addDelegate:(id<ElitechManagerDelegate>)delegate
{
    [self.delegates addPointer:nil];
    [self.delegates compact];
    [self.delegates addPointer:(__bridge void *)delegate];
}

- (void)removeDelegate:(id<ElitechManagerDelegate>)delegate
{
    NSUInteger index = [self.class et_indexOfPointer:(__bridge void *)delegate inArray:self.delegates];
    [self.delegates removePointerAtIndex:index];
}

//- (void)addConnectedPeripheral:(NSObject *)per
//{
//    [self.connectedPeripherals addPointer:(__bridge void *)per];
//    
//}

- (void)startScan
{
    [_centeralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScan
{
    [_centeralManager stopScan];
}

- (void)connect:(CBPeripheral *)peripheral
{
    [_centeralManager connectPeripheral:peripheral options:nil];
}

//断开连接
- (void)disconnect:(CBPeripheral *)peripheral
{
    [_centeralManager cancelPeripheralConnection:peripheral];
}

#pragma mark - other

+ (NSUInteger)et_indexOfPointer:(nullable void *)pointer inArray:(NSPointerArray *)pointerArray {
    if (!pointer) {
        return NSNotFound;
    }
    
    NSPointerArray *array = [pointerArray copy];
    for (NSUInteger i = 0; i < array.count; i++) {
        if ([array pointerAtIndex:i] == ((void *)pointer)) {
            return i;
        }
    }
    return NSNotFound;
}

#pragma mark - CBCentralManager代理函数
//本地蓝牙设备状态更新代理
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    for (id<ElitechManagerDelegate> obj in self.delegates) {
        if([obj respondsToSelector:@selector(elitechManagerDidUpdateState:)]) {
            [obj elitechManagerDidUpdateState:self];
        }
    }
    
}

//扫描信息代理
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSData *manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey];
    if (manufacturerData == nil || manufacturerData.length <2) {
        return;
    }
    
    NSData *deviceMode = [manufacturerData subdataWithRange:NSMakeRange(0, 2)];
    NSString *type = [NSData hexadecimalStringWithData:deviceMode];
    if ([type isEqualToString:ETDeviceCodeVgwmini]) {
        
        NSString *dName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
        
        ETBleScanData *scanData = [[ETBleScanData alloc] init];
        scanData.peripheral = peripheral;
        scanData.advertisementData = advertisementData;
        scanData.RSSI = RSSI;
        
        scanData.localName = dName;
        scanData.modeCode = type;
        scanData.modeName = ETDeviceTypeNameVgwmini;
        
        for (id<ElitechManagerDelegate> obj in self.delegates) {
            if([obj respondsToSelector:@selector(elitechManager:didDiscoverPeripheral:)]) {
                [obj elitechManager:self didDiscoverPeripheral:scanData];
            }
        }
    }
    
}

//外围蓝牙设备连接代理
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
//    [self addConnectedPeripheral:peripheral];
    
}

//外围蓝牙设备断开代理
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    for (id<ElitechManagerDelegate> obj in self.delegates) {
        if([obj respondsToSelector:@selector(elitechManager:didDisconnect:error:)]) {
            [obj elitechManager:self didDisconnect:peripheral error:error];
        }
    }
}

//连接外围设备失败代理
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    for (id<ElitechManagerDelegate> obj in self.delegates) {
        if([obj respondsToSelector:@selector(elitechManager:didConnect:result:)]) {
            [obj elitechManager:self didConnect:peripheral result:NO];
        }
    }
    
}

#pragma mark - CBPeripheral代理函数
//搜索服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (!error) {
        int count = (int)peripheral.services.count;
        
        for (int i=0; i<count; i++) {
            CBService *service = [peripheral.services objectAtIndex:i];
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
    
}

//扫描特征值
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (!error) {
        for (CBCharacteristic *character in service.characteristics) {
            if (character.properties & CBCharacteristicPropertyNotify) {
                [peripheral setNotifyValue:YES forCharacteristic:character];
            }
        }
        
    }
}

//通知状态更改
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error) {
        //通知已打开
        if (characteristic.isNotifying) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:vgwMini_recvCharacteristicsUUID]]) {
                for (id<ElitechManagerDelegate> obj in self.delegates) {
                    if([obj respondsToSelector:@selector(elitechManager:didConnect:result:)]) {
                        [obj elitechManager:self didConnect:peripheral result:YES];
                    }
                }
                
            }
        }
        else{
            [self disconnect:peripheral];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!characteristic.value) {
        return;
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:vgwMini_recvCharacteristicsUUID]])
    {
//        NSLog(@"接收---》%@",characteristic.value);
        for (id<ElitechManagerDelegate> obj in self.delegates) {
            if([obj respondsToSelector:@selector(elitechManager:didReceiveData:from:)]) {
                [obj elitechManager:self didReceiveData:characteristic.value from:peripheral];
            }
        }
    }
    
}


#pragma mark - getter

- (BOOL)isScanning
{
    return _centeralManager.isScanning;
}

- (CBManagerState)state
{
    return _centeralManager.state;
}

@end
