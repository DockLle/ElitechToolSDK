//
//  UnitTool.h
//  ManifoldGauge
//
//  Created by mac on 2021/10/20.
//  Copyright © 2021 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnitTool : NSObject

+ (UnitTool *)sharedInstance;

/// 获取各单位约定的小数位
+ (NSUInteger)vgw760_decimalNumOfUnit:(NSString *)unit;
+ (NSUInteger)svp_decimalNumOfUnit:(NSString *)unit;
+ (NSUInteger)getDecimalNumForVGWMiniByUnit:(NSString *)unit;
+ (NSUInteger)pressureDecimalNumOfUnit:(NSString *)unit;

/// 转换至目标单位真空值
+ (float)calculateVacuumWithInputValue:(float)inputValue inputUnit:(NSString *)inputUnit AimUnit:(NSString *)aimUnit;

+ (float)calVaccum:(float)oldPressure newVacUnit:(NSString *)newVacUnit;

+ (float)temperatureChangeWithOldValue:(float)oldValue oldUnit:(NSString * _Nullable)oldUnit aimUnit:(NSString * _Nullable)aimUnit;

+ (float)calculateCTemperatureByPSI:(float)psiValue dew0OrBubble0:(float)temp0 dew1OrBubble1:(float)temp1 psi0:(float)psi0 psi1:(float)psi1;
+ (float)calculatePsiPressureByTempC:(float)tempC dew0OrBubble0:(float)temp0 dew1OrBubble1:(float)temp1 psi0:(float)psi0 psi1:(float)psi1;


/// 压力转psi
+ (float)getPSIPressureWithOldValue:(float)oldvalue oldUnit:(NSString *)oldUnit;
/// psi转其他单位
+ (float)getPressureWithPSIValue:(float)oldPressure newPressureUnit:(NSString *)newPressureUnit;

///g转其他
+ (float)convertWeightWithG:(NSInteger)gVal toNewUnit:(NSString *)newUnit;
///其他转g
+ (float)convertWeightToGWithOldValue:(float)oldvalue oldUnit:(NSString *)oldUnit;

@end

NS_ASSUME_NONNULL_END
