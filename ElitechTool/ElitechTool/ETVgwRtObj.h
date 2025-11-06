//
//  ETVgwRtObj.h
//  ElitechToolDemo
//
//  Created by wuwu on 2025/9/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ETVgwRtObj : NSObject


/// 真空值：设备实时检测的真空值，设备当前单位的数值
@property (nonatomic,copy) NSString *vaccum;

/// 环境温度：当前环境温度，设备当前单位的数值
@property (nonatomic,copy) NSString *tamb;

/// 水饱和温度：与当前真空度对应的水饱和温度值，设备当前单位的数值
@property (nonatomic,copy) NSString *th2o;

/// 温差,设备当前单位的数值
@property (nonatomic,copy) NSString *dtT;

/// 当前真空单位
/// micron：0
/// mTorr：1
/// inHg：2
/// Pa：3
/// Torr：4
/// kPa：5
/// mbar：6
/// psia：7
@property (nonatomic,copy) NSString *vacUnit;

/// 当前温度单位，℃：0，℉：1
@property (nonatomic,copy) NSString *temUnit;

/// 设备记录状态：当前设备数据记录功能的开启/关闭状态
/// 记录关：0
/// 记录中：1
/// 记录已满：2
@property (nonatomic) NSUInteger recordStatus;

/// 记录间隔，单位：秒
@property (nonatomic) NSUInteger recordInterval;

/// 设备显示模式，TH2O+Tamb ： 0，△T+Tamb： 1
@property (nonatomic) NSUInteger displayMode;

/// 电量：设备当前的剩余电量百分比
@property (nonatomic) NSUInteger power;

@end

NS_ASSUME_NONNULL_END
