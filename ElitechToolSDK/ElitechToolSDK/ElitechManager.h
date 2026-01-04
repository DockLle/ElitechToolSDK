//
//  ElitechManager.h
//  ElitechTool
//
//  Created by wuwu on 2025/10/27.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN
@class ETBleScanData;

@protocol ElitechManagerDelegate;

@interface ElitechManager : NSObject

/// 当前是否正在扫描
@property(nonatomic, assign, readonly) BOOL isScanning;

/// 蓝牙状态
@property(nonatomic, assign, readonly) CBManagerState state;

/// 多个代理数组，支持一对多
@property (nonatomic,readonly,strong) NSPointerArray *delegates;

/// 添加代理
- (void)addDelegate:(id<ElitechManagerDelegate>)delegate;

/// 主动移除代理
- (void)removeDelegate:(id<ElitechManagerDelegate>)delegate;


+ (ElitechManager *)shared;

/// 开始扫描
- (void)startScan;

/// 停止扫描
- (void)stopScan;

/// 连接设备
- (void)connect:(CBPeripheral *)peripheral;

/// 断开连接
- (void)disconnect:(CBPeripheral *)peripheral;

@end

@protocol ElitechManagerDelegate <NSObject>

/// 蓝牙状态更新
- (void)elitechManagerDidUpdateState:(ElitechManager *)manager;

/// 扫描到目标设备
- (void)elitechManager:(ElitechManager *)manager didDiscoverPeripheral:(ETBleScanData *)device;

/// 连接成功或失败回调
/// - Parameters:
///   - isSuccess: 成功或失败
///   - isReconnecting: 连接失败的时候，当前设备是否在重连
- (void)elitechManager:(ElitechManager *)manager didConnect:(CBPeripheral *)peripheral result:(BOOL)isSuccess isReconnecting:(BOOL)isReconnecting;


/// 连接断开回调
/// - Parameters:
///   - isReconnecting: 当前设备是否在重连
- (void)elitechManager:(ElitechManager *)manager didDisconnect:(CBPeripheral *)peripheral isReconnecting:(BOOL)isReconnecting error:(nullable NSError *)error;

/// 蓝牙接收数据
- (void)elitechManager:(ElitechManager *)manager didReceiveData:(NSData *)data from:(CBPeripheral *)peripheral;

@end

NS_ASSUME_NONNULL_END
