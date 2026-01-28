//
//  ElitechToolDevice.h
//  ElitechToolDemo
//
//  Created by wuwu on 2025/9/11.
//

#import <Foundation/Foundation.h>

@class ETVgwRtObj;
@class CBPeripheral;

NS_ASSUME_NONNULL_BEGIN

/// 可配合系统蓝牙框架使用，也可配合ElitechManager使用，二选一
@interface ElitechToolDevice : NSObject

/// 系统外设对象
@property(nonatomic,strong,readonly) CBPeripheral *peripheral;


/// 初始化外设实例，确保在外设对象是已连接状态再初始化
/// - Parameter peripheral: 外设对象
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral withRecordInterval:(NSUInteger)recordInterval;

/// 检查是否为真空计设备（备注：若不使用用ElitechManager去管理蓝牙框架，自行使用系统蓝牙框架，可使用此方法鉴别目标设备）
/// - Parameter advertisementData: 设备广播数据
+ (BOOL)checkVgwMini:(NSDictionary *)advertisementData;

/// 接收处理数据，当蓝牙框架接收到来自真空计设备的原始数据时，需调用此方法进行数据处理。
/// - Parameters:
///   - data: 从设备端传输过来的未经过解析的原始二进制数据
///   - peripheral: 外设对象，用于定位数据来源设备
- (void)swallowData:(NSData *)data from:(CBPeripheral *)peripheral;

/// 将当前时间同步到真空计设备
- (void)setClockWithResult:(void(^)(BOOL res))result;


/// 删除设备中存储的所有历史数据
- (void)clearRecordWithResult:(void(^)(BOOL res))result;

/// 设备开启/关闭数据记录功能
/// - Parameters:
///   - enable: 开关
- (void)setRecordEnable:(BOOL)enable result:(void(^)(BOOL res))result;

/// 配置设备进行数据记录时的时间间隔
/// - Parameters:
///   - interval: 时间间隔
- (void)setRecordInterval:(NSInteger)interval result:(void(^)(BOOL res))result;

/// 设置真空单位
/// micron：0  mTorr：1  inHg：2  Pa：3  Torr：4  kPa：5  mbar：6  psia：7
- (void)setVacuumUnit:(NSInteger)unit result:(void(^)(BOOL res))result;
/// 设置温度单位
/// ℃：0  ℉：1
- (void)setTemperatureUnit:(NSInteger)unit result:(void(^)(BOOL res))result;



/// 开始抽真空
/// - Description 调用此方法会清空目前设备中记录的数据并重新开启记录
- (void)startVacuumingWithResult:(void(^)(BOOL res))result;

/// 结束抽真空
- (void)endVacuumingWithResult:(void(^)(BOOL res))result;

/// 读取数据记录
/// - Description 读取设备中所有数据
- (void)readRecordWithResult:(void(^)(float progress,NSError *_Nullable err,NSArray<NSDictionary<NSString*,NSString*> *> *records))result;


/// 接收实时数据
/// - Parameters:
///   - interval: 实时数据更新间隔时间,单位秒
///   - rtData: 实时数据回调
- (void)receiveRtDataWithInterval:(NSUInteger)interval rtData:(void(^)(ETVgwRtObj *))rtData;


/// 获取设备版本
/// - swv:设备软件版本  remoteCode：用于ota升级
- (void)getDeviceVersion:(void(^)(NSString *_Nullable swv,NSString *_Nullable remoteCode))result;



/// 检查版本更新（调用updateSoftware更新之前必须先使用此api）
- (void)checkForUpdate:(void(^)(BOOL canUpdate,NSString *version,NSString *description))result;

/// 升级更新
/// isDownloaded：固件包是否下载完成 ，updateProgress：在完成下载固件包后，正式进行更新的的进度；
- (void)updateSoftware:(void(^)(BOOL isDownloaded,float updateProgress,NSError *_Nullable err))result;
@end

NS_ASSUME_NONNULL_END
