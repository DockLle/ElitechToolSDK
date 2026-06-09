# ElitechToolSDK API 文档

## 概述

ElitechToolSDK 是 Elitech（精英）真空计/测量仪器的 iOS BLE 通信 SDK，支持 VGW-mini 等设备型号。提供设备发现、连接管理、数据读取、参数配置、固件升级等功能。

---

## 快速开始

### 典型使用流程

```
初始化 ElitechManager → 开始扫描 → 发现设备 → 连接设备 
→ 创建 ElitechToolDevice → 接收实时数据 → 执行操作
```

**示例代码（Swift）：**

```swift
// 1. 添加代理并开始扫描
ElitechManager.shared().addDelegate(self)
ElitechManager.shared().startScan()

// 2. 发现设备后连接
func elitechManager(_ manager: ElitechManager,
                    didDiscoverPeripheral device: ETBleScanData) {
    ElitechManager.shared().connect(device.peripheral)
}

// 3. 连接成功后创建设备实例
func elitechManager(_ manager: ElitechManager,
                    didConnect peripheral: CBPeripheral,
                    result: Bool, isReconnecting: Bool) {
    device = ElitechToolDevice(peripheral: peripheral, withRecordInterval: 5)
    // 开启实时数据
    device?.receiveRtData(withInterval: 1) { rtobj in
        print("真空度: \(rtobj.vaccum ?? "--")")
    }
}

// 4. 将 BLE 数据转发给设备解析
func elitechManager(_ manager: ElitechManager,
                    didReceiveData data: Data, from peripheral: CBPeripheral) {
    device?.swallowData(data, from: peripheral)
}
```

---

## 核心类

### 1. ElitechManager

BLE 中央管理器，负责扫描、连接和分发 BLE 事件。单例模式，支持多代理。

| 属性 | 类型 | 说明 |
|------|------|------|
| `isScanning` | `BOOL` (readonly) | 当前是否正在扫描 |
| `state` | `CBManagerState` (readonly) | 蓝牙状态 |
| `delegates` | `NSPointerArray *` (readonly) | 代理列表（NSArray 包装） |

#### 获取单例

```objc
+ (ElitechManager *)shared;
```

#### 代理管理

```objc
- (void)addDelegate:(id<ElitechManagerDelegate>)delegate;
- (void)removeDelegate:(id<ElitechManagerDelegate>)delegate;
```

#### 扫描控制

```objc
- (void)startScan;   // 开始扫描附近设备
- (void)stopScan;    // 停止扫描
```

#### 连接管理

```objc
- (void)connect:(CBPeripheral *)peripheral;     // 连接指定设备
- (void)disconnect:(CBPeripheral *)peripheral;  // 断开连接
```

**自动重连机制：** 设备意外断开后会启动自动重连（最多 5 次，间隔 3 秒）。主动调用 `disconnect:` 或重连成功后停止。

---

### 2. ElitechToolDevice

设备交互核心类。所有 BLE 命令通过内部串行队列执行，保证命令不冲突。

#### 初始化

```objc
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                withRecordInterval:(NSUInteger)recordInterval;
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `peripheral` | `CBPeripheral *` | BLE 外设对象 |
| `recordInterval` | `NSUInteger` | 记录间隔（秒） |

> 初始化时自动调用 `setClockWithResult:` 和 `setRecordInterval:result:`。

#### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `peripheral` | `CBPeripheral *` (readonly) | 绑定的 BLE 外设 |

#### 类方法

```objc
+ (BOOL)checkVgwMini:(NSDictionary *)advertisementData;
```

检查广播数据是否匹配 VGW-mini 设备，返回 `YES` 表示匹配。

#### 数据接收

```objc
- (void)swallowData:(NSData *)data from:(CBPeripheral *)peripheral;
```

收到 BLE 数据时调用此方法，SDK 自动解析协议并回调对应结果。

---

### 3. 命令接口

所有命令通过 `performCommand:` 内部队列串行执行（5 秒超时自动推进）。`readRecordWithResult:` 和 `updateSoftware:` 使用 `performExclusiveCommand:` 互斥保护，同时只能有一个读数据或固件升级操作进行中，冲突时回调错误。

---

#### 3.1 设备信息

##### 获取软件版本

```objc
- (void)getDeviceVersion:(void(^)(NSString *_Nullable swv,
                                  NSString *_Nullable remoteCode))result;
```

| 回调参数 | 类型 | 说明 |
|----------|------|------|
| `swv` | `NSString *` | 设备软件版本号 |
| `remoteCode` | `NSString *` | OTA 远程代码（用于固件升级） |

##### 获取序列号

```objc
- (void)getSNWithresult:(void(^)(NSString *_Nullable sn))result;
```

| 回调参数 | 类型 | 说明 |
|----------|------|------|
| `sn` | `NSString *` | 设备序列号 |

---

#### 3.2 参数配置

##### 设置时钟

```objc
- (void)setClockWithResult:(void(^)(BOOL res))result;
```

将设备时钟同步为当前系统时间。

##### 设置记录间隔

```objc
- (void)setRecordInterval:(NSInteger)interval result:(void(^)(BOOL res))result;
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `interval` | `NSInteger` | 数据记录间隔（秒） |

##### 设置记录开关

```objc
- (void)setRecordEnable:(BOOL)enable result:(void(^)(BOOL res))result;
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `enable` | `BOOL` | `YES` 开启记录，`NO` 关闭记录 |

##### 清除记录

```objc
- (void)clearRecordWithResult:(void(^)(BOOL res))result;
```

删除设备上所有存储的历史数据。

##### 设置真空单位

```objc
- (void)setVacuumUnit:(NSInteger)unit result:(void(^)(BOOL res))result;
```

| 值 | 单位 |
|----|------|
| 0 | micron |
| 1 | mTorr |
| 2 | inHg |
| 3 | Pa |
| 4 | Torr |
| 5 | kPa |
| 6 | mbar |
| 7 | psia |

##### 设置温度单位

```objc
- (void)setTemperatureUnit:(NSInteger)unit result:(void(^)(BOOL res))result;
```

| 值 | 单位 |
|----|------|
| 0 | ℃（摄氏） |
| 1 | ℉（华氏） |

---

#### 3.3 真空操作

##### 开始抽真空

```objc
- (void)startVacuumingWithResult:(void(^)(BOOL res))result;
```

清除已有记录并重新开启数据记录。

##### 结束抽真空

```objc
- (void)endVacuumingWithResult:(void(^)(BOOL res))result;
```

关闭数据记录。

---

#### 3.4 数据读取

##### 读取历史记录

```objc
- (void)readRecordWithResult:
    (void(^)(float progress,
             NSError *_Nullable err,
             NSArray<NSDictionary<NSString*, NSString*>*> *records))result;
```

| 回调参数 | 类型 | 说明 |
|----------|------|------|
| `progress` | `float` | 下载进度 0~100，100 时表示完成 |
| `err` | `NSError *` | 错误信息，成功时为 nil |
| `records` | `NSArray<NSDictionary *> *` | 记录数组，每条包含 `timestamp`、`vacuum`、`TH2O`、`Tamb` |

> 此方法会多次回调：传输过程中持续回调进度，结束时 progress >= 100 同时返回完整 records 数组。  
> 此方法使用互斥保护，同时只能有一个读数据操作。

##### 获取实时数据

```objc
- (void)receiveRtDataWithInterval:(NSUInteger)interval
                          rtData:(void(^)(ETVgwRtObj *))rtData;
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `interval` | `NSUInteger` | 数据刷新间隔（秒） |

启动定时器，按指定间隔回调 `ETVgwRtObj` 实时数据对象。重复调用会重启定时器。

##### 停止实时数据

```objc
- (void)stopRtData;
```

停止实时数据定时器。

---

#### 3.5 固件升级

##### 检查更新

```objc
- (void)checkForUpdate:(void(^)(BOOL canUpdate,
                                NSString *version,
                                NSString *description))result;
```

| 回调参数 | 类型 | 说明 |
|----------|------|------|
| `canUpdate` | `BOOL` | 是否有可用更新 |
| `version` | `NSString *` | 最新版本号 |
| `description` | `NSString *` | 更新说明 |

> 必须先调用此方法，再调用 `updateSoftware:`。

##### 执行升级

```objc
- (void)updateSoftware:
    (void(^)(BOOL isDownloaded,
             float updateProgress,
             NSError *_Nullable err))result;
```

| 回调参数 | 类型 | 说明 |
|----------|------|------|
| `isDownloaded` | `BOOL` | 下载是否完成 |
| `updateProgress` | `float` | 升级进度 0~100 |
| `err` | `NSError *` | 错误信息，成功时为 nil |

> 此方法使用互斥保护，同时只能有一个固件升级操作。

---

#### 3.6 关机

```objc
- (void)shutdown;
```

关闭设备电源。此方法为 fire-and-forget 模式，无回调。

---

### 4. 数据模型

#### 4.1 ETBleScanData

扫描结果数据模型。

| 属性 | 类型 | 说明 |
|------|------|------|
| `peripheral` | `CBPeripheral *` | BLE 外设 |
| `advertisementData` | `NSDictionary *` | 广播数据 |
| `RSSI` | `NSNumber *` | 信号强度 |
| `localName` | `NSString *` | 设备名称 |
| `modeCode` | `NSString *` | 型号代码（如 "0003"） |
| `modeName` | `NSString *` | 型号名称（如 "VGW-mini"） |
| `custom` | `id` (nullable) | 扩展字段，可存储自定义数据 |

#### 4.2 ETVgwRtObj

实时数据对象。

| 属性 | 类型 | 说明 |
|------|------|------|
| `vaccum` | `NSString *` | 真空值（统一为 Pa） |
| `tamb` | `NSString *` | 环境温度（设备当前单位） |
| `th2o` | `NSString *` | 水饱和温度（设备当前单位） |
| `dtT` | `NSString *` | 温差（Tamb - TH2O） |
| `vacUnit` | `NSString *` | 真空单位（固定 @"Pa"） |
| `temUnit` | `NSString *` | 温度单位（@"℃" 或 @"℉"） |
| `recordStatus` | `NSUInteger` | 记录状态：0=关闭，1=录制中，2=已满 |
| `recordInterval` | `NSUInteger` | 记录间隔（秒） |
| `displayMode` | `NSUInteger` | 显示模式：0=TH2O+Tamb，1=DeltaT+Tamb |
| `power` | `NSUInteger` | 电量百分比（0~100） |

> 无效传感器值表示为 "FF" 或 "E01"。

---

## 协议

### ElitechManagerDelegate

所有方法为 `@required`。

```objc
@protocol ElitechManagerDelegate <NSObject>

// 蓝牙状态更新
- (void)elitechManagerDidUpdateState:(ElitechManager *)manager;

// 发现设备
- (void)elitechManager:(ElitechManager *)manager
 didDiscoverPeripheral:(ETBleScanData *)device;

// 连接结果
- (void)elitechManager:(ElitechManager *)manager
            didConnect:(CBPeripheral *)peripheral
                result:(BOOL)isSuccess
        isReconnecting:(BOOL)isReconnecting;

// 断开连接
- (void)elitechManager:(ElitechManager *)manager
         didDisconnect:(CBPeripheral *)peripheral
        isReconnecting:(BOOL)isReconnecting
                 error:(nullable NSError *)error;

// 收到数据
- (void)elitechManager:(ElitechManager *)manager
        didReceiveData:(NSData *)data
                  from:(CBPeripheral *)peripheral;

@end
```

| 回调 | 触发时机 |
|------|----------|
| `elitechManagerDidUpdateState:` | 蓝牙状态变更时 |
| `elitechManager:didDiscoverPeripheral:` | 扫描到设备时 |
| `elitechManager:didConnect:result:isReconnecting:` | 连接完成（成功或失败）时 |
| `elitechManager:didDisconnect:isReconnecting:error:` | 断开连接时 |
| `elitechManager:didReceiveData:from:` | 收到设备数据时，需转发给 `ElitechToolDevice` 的 `swallowData:from:` |

---

## 枚举

### ETDeviceTypeCode

```objc
typedef NS_ENUM(UInt16, ETDeviceTypeCode) {
    ETDeviceTypeCodeVgwMini = 0x0003,
};
```

### ETFuncCodeType

协议功能码。

```objc
typedef NS_ENUM(UInt8, ETFuncCodeType) {
    ETFuncCodeType01 = 0x01,  // 写单个参数
    ETFuncCodeType02 = 0x02,  // 读参数
    ETFuncCodeType03 = 0x03,  // 写单个/多个参数
    ETFuncCodeType04 = 0x04,  // 实时数据
    ETFuncCodeType05 = 0x05,  // 温度钳校准/检漏仪状态
    ETFuncCodeType06 = 0x06,  // 读取历史数据
    ETFuncCodeType07 = 0x07,  // 固件升级
    ETFuncCodeType10 = 0x10,  // 冷媒数据更新
    ETFuncCodeType11 = 0x11,  // 读取检漏测试数据
    ETFuncCodeType13 = 0x13,  // 通过网络伴侣发送数据
    ETFuncCodeType14 = 0x14,  // 网络伴侣
};
```

### SvpVaccumUnitType

SVP 真空单位类型。

```objc
typedef NS_ENUM(NSInteger, SvpVaccumUnitType) {
    SvpVaccumUnitType_micron = 1,
    SvpVaccumUnitType_Pa     = 2,
    SvpVaccumUnitType_mTorr  = 3,
    SvpVaccumUnitType_inHg   = 4,
    SvpVaccumUnitType_Torr   = 5,
    SvpVaccumUnitType_kPa    = 6,
    SvpVaccumUnitType_mbar   = 7
};
```

### VGWMiniTUnitType

VGW-mini 温度单位类型（也用于真空单位参数）。

```objc
typedef NS_ENUM(NSInteger, VGWMiniTUnitType) {
    VGWMiniTUnitType_micron = 0,
    VGWMiniTUnitType_mTorr  = 1,
    VGWMiniTUnitType_inHg   = 2,
    VGWMiniTUnitType_Pa     = 3,
    VGWMiniTUnitType_Torr   = 4,
    VGWMiniTUnitType_kPa    = 5,
    VGWMiniTUnitType_mbar   = 6,
    VGWMiniTUnitType_psia   = 7
};
```

### PressUnitType

压力单位类型。

```objc
typedef NS_ENUM(NSInteger, PressUnitType) {
    PressUnitType_kPa   = 0,
    PressUnitType_MPa   = 1,
    PressUnitType_bar   = 2,
    PressUnitType_psi   = 3,
    PressUnitType_kgcm2 = 4,
    PressUnitType_inHg  = 5,
    PressUnitType_cmHg  = 6,
    PressUnitType_Pa    = 7
};
```

---

## 错误码

| 错误域 | Code | 说明 |
|--------|------|------|
| NSCocoaErrorDomain | 1000 | 外设未连接 |
| NSCocoaErrorDomain | 1002 | 设备正忙，请稍后再试 |
| NSCocoaErrorDomain | 2000 | 下载升级包出错 |
| NSCocoaErrorDomain | 2001 | 请先调用检查更新 |
| NSCocoaErrorDomain | 2002 | 软件升级失败 |

---

## 命令队列机制

SDK 内部使用串行命令队列管理所有 BLE 命令，保证命令按序执行、互不冲突：

| 机制 | 说明 |
|------|------|
| `performCommand:` | 通用串行队列，命令依次在主线程执行，单条命令 5 秒超时自动推进 |
| `performExclusiveCommand:exclusiveKey:conflictBlock:` | 互斥队列，用于 `readRecord`（key: `readData`）和 `firmware`（key: `firmware`）操作 |

**冲突处理：** 当互斥命令正在执行时再次调用相同 key 的方法，`conflictBlock` 立即回调 Code 1002 错误，队列不阻塞。

---

## 工具类参考

### UnitTool

单元转换工具类（单例）。

```objc
+ (UnitTool *)sharedInstance;

// 压力真空转换
+ (float)calculateVacuumWithInputValue:(float)inputValue
                             inputUnit:(NSString *)inputUnit
                               AimUnit:(NSString *)aimUnit;

// 温度转换（设备单位 ↔ 目标单位）
+ (float)temperatureChangeWithOldValue:(float)oldValue
                               oldUnit:(NSString *)oldUnit
                               aimUnit:(NSString *)aimUnit;

// 重量转换
+ (float)convertWeightWithG:(NSInteger)gVal toNewUnit:(NSString *)newUnit;
```

### ETNewProtocolWorker

协议编解码工具，封装常用命令的数据包构造。

```objc
- (instancetype)initWithModeCode:(NSData *)modeCode;

// 常用协议方法
- (NSData *)setClockData:(NSData *)date;
- (NSData *)realTimeData;
- (NSData *)realTimeDataWithInterval:(NSInteger)timeInterval;
- (NSData *)readDataWithSubFunc:(UInt16)subFunc subFuncCount:(UInt16)subFuncCount;
- (NSData *)setDataWithSubFunc:(UInt16)subFunc andContent:(UInt16)con;
```

---

## 常量

### 单位字符串

```objc
// 真空单位
extern NSString *const Umicrons;  // @"micron"
extern NSString *const UmTorr;    // @"mTorr"
extern NSString *const UinHg;     // @"inHg"
extern NSString *const UPa;       // @"Pa"
extern NSString *const UTorr;     // @"Torr"
extern NSString *const UkPa;      // @"kPa"
extern NSString *const Umbar;     // @"mbar"
extern NSString *const Upsia;     // @"psia"

// 温度单位
extern NSString *const U_C;       // @"℃"
extern NSString *const U_F;       // @"℉"

// 重量单位
extern NSString *const U_kg;      // @"kg"
extern NSString *const U_g;       // @"g"
extern NSString *const U_lb;      // @"lb"
extern NSString *const U_oz;      // @"oz"
```

### 设备型号常量

```objc
extern NSString *const ETDeviceCodeVgwmini;     // @"0003"
extern NSString *const ETDeviceTypeNameVgwmini; // @"VGW-mini"
```

### BLE UUID

```objc
// 服务 UUID: FCFD
// 接收特征 UUID (notify): FCFD
// 发送特征 UUID (write): FCFE
```
