//
//  ETBleScanData.h
//  ElitechTool
//
//  Created by wuwu on 2025/10/28.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;

NS_ASSUME_NONNULL_BEGIN

@interface ETBleScanData : NSObject

/// 外设对象
@property(nonatomic,strong) CBPeripheral *peripheral;

/// 广播信息
@property(nonatomic,strong) NSDictionary *advertisementData;

/// 信号值
@property(nonatomic,strong) NSNumber    *RSSI;

@property(nonatomic,copy) NSString    *localName;//设备名
@property(nonatomic,copy) NSString    *modeCode;//设备型号的code
@property(nonatomic,copy) NSString    *modeName;//设备型号名字

@property(nonatomic,strong,nullable) id custom;//扩展字段，预留备用，可自定义信息

@end

NS_ASSUME_NONNULL_END
