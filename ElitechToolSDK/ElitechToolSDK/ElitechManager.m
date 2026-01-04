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


NSString* const vgwMini_serviceUUID = @"FCFD";
NSString* const vgwMini_recvCharacteristicsUUID = @"FCFD";
NSString* const vgwMini_sendCharacteristicsUUID = @"FCFE";


/// 单个外设的重连信息模型（内部使用）
@interface PeripheralReconnectInfo : NSObject
/// 外设实例
@property (nonatomic, strong) CBPeripheral *peripheral;
/// 重连定时器
@property (nonatomic, strong) NSTimer *reconnectTimer;
/// 当前重试次数
@property (nonatomic, assign) NSInteger currentReconnectCount;
/// 最大重试次数
@property (nonatomic, assign) NSInteger maxReconnectTimes;
/// 重连间隔（秒）
@property (nonatomic, assign) NSTimeInterval reconnectInterval;
@end

@implementation PeripheralReconnectInfo
- (instancetype)init {
    if (self = [super init]) {
        self.maxReconnectTimes = 5;       // 每个设备默认最大重连10次
        self.reconnectInterval = 3.0;     // 每个设备默认3秒重试一次
        self.currentReconnectCount = 0;
    }
    return self;
}
@end


@interface ElitechManager()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic,strong) CBCentralManager *centeralManager;
/// 多设备重连信息字典（key：外设UUID字符串，value：PeripheralReconnectInfo）
@property (nonatomic, strong) NSMutableDictionary<NSString *, PeripheralReconnectInfo *> *peripheralReconnectDict;

@end

@implementation ElitechManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.peripheralReconnectDict = [NSMutableDictionary dictionary];
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

#pragma mark - 内部重连逻辑
/// 为指定外设启动重连
/// @param peripheral 目标外设
- (void)startReconnectForPeripheral:(CBPeripheral *)peripheral {
    NSString *uuidStr = peripheral.identifier.UUIDString;
    // 获取/创建该设备的重连信息
    PeripheralReconnectInfo *info = self.peripheralReconnectDict[uuidStr];
    if (!info) {
        info = [[PeripheralReconnectInfo alloc] init];
        info.peripheral = peripheral;
        self.peripheralReconnectDict[uuidStr] = info;
    }
    
    // 停止已有定时器，避免重复
    [info.reconnectTimer invalidate];
    
    // 重置重试次数
    info.currentReconnectCount = 0;
    
    // 启动独立的重连定时器
    info.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:info.reconnectInterval
                                                          target:self
                                                        selector:@selector(tryReconnectPeripheral:)
                                                        userInfo:uuidStr
                                                         repeats:YES];
    NSLog(@"为设备：%@（%@）启动自动重连，间隔%.1f秒，最大重试%ld次",
          peripheral.name ?: @"未知名称", uuidStr, info.reconnectInterval, (long)info.maxReconnectTimes);
}

/// 停止指定外设的重连
/// @param peripheralUUID 外设UUID字符串
- (void)stopReconnectForPeripheralUUID:(NSString *)peripheralUUID {
    PeripheralReconnectInfo *info = self.peripheralReconnectDict[peripheralUUID];
    [info.reconnectTimer invalidate];
    info.reconnectTimer = nil;
    info.currentReconnectCount = 0;
    NSLog(@"停止设备：%@ 的重连", peripheralUUID);
}

/// 尝试重连指定外设（定时器回调）
/// @param timer 定时器（userInfo存储外设UUID）
- (void)tryReconnectPeripheral:(NSTimer *)timer {
    NSString *uuidStr = timer.userInfo;
    if (!uuidStr) {
        [timer invalidate];
        return;
    }
    
    PeripheralReconnectInfo *info = self.peripheralReconnectDict[uuidStr];
    if (!info) {
        [timer invalidate];
        return;
    }
    
    // 检查重试次数是否超限
    if (info.currentReconnectCount >= info.maxReconnectTimes) {
        [self stopReconnectForPeripheralUUID:uuidStr];
        NSLog(@"设备：%@ 重连次数达上限（%ld次），停止重连", uuidStr, (long)info.maxReconnectTimes);
        return;
    }
    
    info.currentReconnectCount++;
    NSLog(@"设备：%@ 第%ld次尝试重连...", uuidStr, (long)info.currentReconnectCount);
    
    // 蓝牙未开启则跳过
    if (self.centeralManager.state != CBManagerStatePoweredOn) {
        NSLog(@"蓝牙未开启，跳过设备：%@ 本次重连", uuidStr);
        return;
    }
    
    // 有外设实例则直接连接，无则扫描
    if (info.peripheral) {
        [self.centeralManager connectPeripheral:info.peripheral options:nil];
    } else {
        [self.centeralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
    }
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
    
    if (central.state != CBManagerStatePoweredOn) {
        // 停止所有设备的重连定时器
        [self.peripheralReconnectDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull uuid, PeripheralReconnectInfo * _Nonnull info, BOOL * _Nonnull stop) {
            [info.reconnectTimer invalidate];
            info.reconnectTimer = nil;
        }];
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
    if (error) {
        PeripheralReconnectInfo *info = self.peripheralReconnectDict[peripheral.identifier.UUIDString];
        if (info && (info.currentReconnectCount >= info.maxReconnectTimes)) {
            for (id<ElitechManagerDelegate> obj in self.delegates) {
                if([obj respondsToSelector:@selector(elitechManager:didDisconnect:isReconnecting:error:)]) {
                    [obj elitechManager:self didDisconnect:peripheral isReconnecting:NO error:error];
                }
            }
        }
        else
        {
            [self startReconnectForPeripheral:peripheral];
            for (id<ElitechManagerDelegate> obj in self.delegates) {
                if([obj respondsToSelector:@selector(elitechManager:didDisconnect:isReconnecting:error:)]) {
                    [obj elitechManager:self didDisconnect:peripheral isReconnecting:YES error:error];
                }
            }
        }
    }
    else
    {
        for (id<ElitechManagerDelegate> obj in self.delegates) {
            if([obj respondsToSelector:@selector(elitechManager:didDisconnect:isReconnecting:error:)]) {
                [obj elitechManager:self didDisconnect:peripheral isReconnecting:NO error:nil];
            }
        }
    }
}

//连接外围设备失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    PeripheralReconnectInfo *info = self.peripheralReconnectDict[peripheral.identifier.UUIDString];
    if (info && (info.currentReconnectCount >= info.maxReconnectTimes)) {
        for (id<ElitechManagerDelegate> obj in self.delegates) {
            if([obj respondsToSelector:@selector(elitechManager:didConnect:result:isReconnecting:)]) {
                [obj elitechManager:self didConnect:peripheral result:NO isReconnecting:NO];
            }
        }
    }
    else
    {
        [self startReconnectForPeripheral:peripheral];
        for (id<ElitechManagerDelegate> obj in self.delegates) {
            if([obj respondsToSelector:@selector(elitechManager:didConnect:result:isReconnecting:)]) {
                [obj elitechManager:self didConnect:peripheral result:NO isReconnecting:YES];
            }
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
                    if([obj respondsToSelector:@selector(elitechManager:didConnect:result:isReconnecting:)]) {
                        [obj elitechManager:self didConnect:peripheral result:YES isReconnecting:NO];
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
