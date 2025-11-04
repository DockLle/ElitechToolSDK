//
//  UnitTool.m
//  ManifoldGauge
//
//  Created by mac on 2021/10/20.
//  Copyright © 2021 Reo. All rights reserved.
//

#import "UnitTool.h"
#import "UnitsDefine.h"

@implementation UnitTool

+ (UnitTool *)sharedInstance
{
    static UnitTool *ins;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[UnitTool alloc] init];
    });
    return ins;
}

#pragma mark - unitChange

+ (NSUInteger)vgw760_decimalNumOfUnit:(NSString *)unit
{
    NSDictionary *unitDic = @{
        Umicrons:@"0",
        UmTorr:@"0",
        UinHg:@"4",
        UPa:@"2",
        UTorr:@"4",
        UkPa:@"4",
        Umbar:@"4",
        Upsia:@"4",
    };
    
    return [unitDic[unit] intValue];
}

+ (NSUInteger)svp_decimalNumOfUnit:(NSString *)unit
{
    NSDictionary *unitDic = @{
        UinHg:@"1",
        UTorr:@"1",
        Umbar:@"1",
        UmTorr:@"0",
        UkPa:@"1",
        Umicrons:@"0",
        UPa:@"1",
    };
    
    return [unitDic[unit] intValue];
}

+ (NSUInteger)getDecimalNumForVGWMiniByUnit:(NSString *)unit
{
    if ([unit isEqualToString:Umicrons] || [unit isEqualToString:UmTorr]) {
        return 0;
    }
    else if ([unit isEqualToString:Upsia] || [unit isEqualToString:UinHg])
    {
        return 5;
    }
    else if ([unit isEqualToString:UPa])
    {
        return 1;
    }
    else if ([unit isEqualToString:Umbar] || [unit isEqualToString:UTorr])
    {
        return 3;
    }
    else if ([unit isEqualToString:UkPa])
    {
        return 4;
    }
    return 0;
}

+ (NSUInteger)pressureDecimalNumOfUnit:(NSString *)unit
{
    NSDictionary *unitDic = @{
        UPpsi:@"1",
        UPinHg:@"0",
        UPkgcm:@"2",
        UPcmHg:@"0",
        UPbar:@"2",
        UPkPa:@"0",
        UPMPa:@"3"
    };
    
    return [unitDic[unit] intValue];
}

#pragma mark -

+ (float)calculateVacuumWithInputValue:(float)inputValue inputUnit:(NSString *)inputUnit AimUnit:(NSString *)aimUnit {
    float pressure = 0;
    if (!aimUnit) {
        aimUnit = Umicrons;
    }
    if ([inputUnit isEqualToString:aimUnit]) {
        pressure = [self getVacPressure:inputValue newVacUnit:aimUnit needConvert:NO];
    }
    else
    {
        if ([inputUnit isEqualToString:UinHg])
        {
            pressure = inputValue / 29.921;
        }
        else if ([inputUnit isEqualToString:UTorr])
        {
            pressure = inputValue / 760.0;
        }
        else if ([inputUnit isEqualToString:Upsia])
        {
            pressure = inputValue / 14.696;
        }
        else if ([inputUnit isEqualToString:Umbar])
        {
            pressure = inputValue / 1013.25;
        }
        else if ([inputUnit isEqualToString:UmTorr])
        {
            pressure = inputValue / 760000.0;
        }
        else if ([inputUnit isEqualToString:UPa])
        {
            pressure = inputValue / 101325.0;
        }
        else if ([inputUnit isEqualToString:Umicrons])
        {
            pressure = inputValue / 760000.0;
        }
        else if ([inputUnit isEqualToString:UkPa])
        {
            pressure = inputValue / 101.325;
        }
        
        pressure = [self getVacPressure:pressure newVacUnit:aimUnit needConvert:YES];
    }
    return pressure;
}


+ (float)getVacPressure:(float)oldPressure newVacUnit:(NSString *)newVacUnit needConvert:(BOOL)needConvert {

    float pressure = oldPressure;
    if (needConvert)
    {
        NSUInteger decimalNum = [self getDecimalNumForVGWMiniByUnit:newVacUnit];
        float mutiple = powf(10, decimalNum);
        
        if ([newVacUnit isEqualToString:UinHg])
        {
            pressure = oldPressure * 29.921;
        }
        else if ([newVacUnit isEqualToString:UTorr])
        {
            pressure = oldPressure * 760;
        }
        else if ([newVacUnit isEqualToString:Upsia])
        {
            pressure = oldPressure * 14.696;
        }
        else if ([newVacUnit isEqualToString:Umbar])
        {
            pressure = oldPressure * 1013.25;
        }
        else if ([newVacUnit isEqualToString:UmTorr])
        {
            pressure = oldPressure * 760000;
        }
        else if ([newVacUnit isEqualToString:UPa])
        {
            pressure = oldPressure * 101325;
        }
        else if ([newVacUnit isEqualToString:Umicrons])
        {
            pressure = oldPressure * 760000;
        }
        else if ([newVacUnit isEqualToString:UkPa])
        {
            pressure = (float) (oldPressure * 101.325);
        }
        
        pressure = roundf(pressure * mutiple) / mutiple;
    }
    
    return pressure;
}

+ (float)calVaccum:(float)oldPressure newVacUnit:(NSString *)newVacUnit {

    float pressure = oldPressure;
    
    NSUInteger decimalNum = [self getDecimalNumForVGWMiniByUnit:newVacUnit];
    float mutiple = powf(10, decimalNum);
    
    if ([newVacUnit isEqualToString:UinHg])
    {
        pressure = oldPressure * 3.937e-5;
    }
    else if ([newVacUnit isEqualToString:UTorr])
    {
        pressure = oldPressure / 1000.f;
    }
    else if ([newVacUnit isEqualToString:Upsia])
    {
        pressure = oldPressure * 1.93368e-5;
    }
    else if ([newVacUnit isEqualToString:Umbar])
    {
        pressure = oldPressure * 1.33322e-3;
    }
    else if ([newVacUnit isEqualToString:UmTorr])
    {
        pressure = oldPressure;
    }
    else if ([newVacUnit isEqualToString:UPa])
    {
        pressure = oldPressure * 1.33322e-1;
    }
    else if ([newVacUnit isEqualToString:Umicrons])
    {
        pressure = oldPressure;
    }
    else if ([newVacUnit isEqualToString:UkPa])
    {
        pressure = oldPressure * 1.33322e-4;
    }
    
    pressure = roundf(pressure * mutiple) / mutiple;
    
    return pressure;
}


+ (float)temperatureChangeWithOldValue:(float)oldValue oldUnit:(NSString * _Nullable)oldUnit aimUnit:(NSString * _Nullable)aimUnit
{
    if (!oldUnit) {
        oldUnit = U_C;
    }
    if (!aimUnit) {
        aimUnit = U_C;
    }
    if ([oldUnit isEqualToString:aimUnit]) {
        return oldValue;
    }
    if ([aimUnit isEqualToString:U_C]) {
        if ([oldUnit isEqualToString:U_F])
        {
            return (oldValue - 32) / 1.8;
        }
        else if ([oldUnit isEqualToString:U_K])
        {
            return oldValue - 273.2;
        }
    }
    else if ([aimUnit isEqualToString:U_F])
    {
        if ([oldUnit isEqualToString:U_C])
        {
            return oldValue * 1.8 + 32;
        }
        else if ([oldUnit isEqualToString:U_K])
        {
            return oldValue * 1.8 - 459.7;
        }
    }
    else if ([aimUnit isEqualToString:U_K])
    {
        if ([oldUnit isEqualToString:U_C])
        {
            return oldValue + 273.2;
        }
        else if ([oldUnit isEqualToString:U_F])
        {
            return (oldValue  + 459.7) * 5 / 9.0;
        }
    }
    return oldValue;
}

+ (float)calculateCTemperatureByPSI:(float)psiValue dew0OrBubble0:(float)temp0 dew1OrBubble1:(float)temp1 psi0:(float)psi0 psi1:(float)psi1
{
    temp0 = roundf(temp0 * 100) * 0.01;
    temp1 = roundf(temp1 * 100) * 0.01;
    
    float a = (temp0 - temp1) / (psi0 - psi1);
    float result = (psiValue - psi1) * a + temp1;
    
    result = roundf(result * 10) * 0.1;
    
    return result;
}

+ (float)calculatePsiPressureByTempC:(float)tempC dew0OrBubble0:(float)temp0 dew1OrBubble1:(float)temp1 psi0:(float)psi0 psi1:(float)psi1
{
    float b = (temp0 * psi1 - temp1 * psi0) / (temp0 - temp1);
    float a = (psi0 - psi1) / (temp0 - temp1);

    float result = tempC * a + b;
    return result;
}

+ (float)getPSIPressureWithOldValue:(float)oldvalue oldUnit:(NSString *)oldUnit
{
    float val = 0;
    
    if ([oldUnit isEqualToString:UPpsi]) {
        val = oldvalue;
    }
    else if ([oldUnit isEqualToString:UPbar])
    {
        val = oldvalue / 0.0689476;
    }
    else if ([oldUnit isEqualToString:UPinHg])
    {
        val = oldvalue / 2.0360209;
    }
    else if ([oldUnit isEqualToString:UPcmHg])
    {
        val = oldvalue / 5.171493;
    }
    else if ([oldUnit isEqualToString:UPkgcm])
    {
        val = oldvalue / 0.070307;
    }
    else if ([oldUnit isEqualToString:UPkPa])
    {
        val  = oldvalue / 6.894757;
    }
    else if ([oldUnit isEqualToString:UPMPa])
    {
        val = oldvalue / 0.0068948;
    }
    return val;
}

+ (float)getPressureWithPSIValue:(float)oldPressure newPressureUnit:(NSString *)newPressureUnit
{
    if ([newPressureUnit isEqualToString:UPpsi]) {
        return oldPressure;
    }
    else if ([newPressureUnit isEqualToString:UPbar])
    {
        return oldPressure * 0.0689476;
    }
    else if ([newPressureUnit isEqualToString:UPinHg])
    {
        return oldPressure * 2.0360209;
    }
    else if ([newPressureUnit isEqualToString:UPcmHg])
    {
        return oldPressure * 5.171493;
    }
    else if ([newPressureUnit isEqualToString:UPkgcm])
    {
        return oldPressure * 0.070307;
    }
    else if ([newPressureUnit isEqualToString:UPkPa])
    {
        return oldPressure * 6.894757;
    }
    else if ([newPressureUnit isEqualToString:UPMPa])
    {
        return oldPressure * 0.0068948;
    }
    return oldPressure;
}

+ (float)getPressureWithMpaValue:(float)oldPressure newPressureUnit:(NSString *)newPressureUnit
{
    if ([newPressureUnit isEqualToString:UPpsi]) {
        return oldPressure;
    }
    else if ([newPressureUnit isEqualToString:UPbar])
    {
        return oldPressure * 0.0689476;
    }
    else if ([newPressureUnit isEqualToString:UPinHg])
    {
        return oldPressure * 2.0360209;
    }
    else if ([newPressureUnit isEqualToString:UPcmHg])
    {
        return oldPressure * 5.171493;
    }
    else if ([newPressureUnit isEqualToString:UPkgcm])
    {
        return oldPressure * 0.070307;
    }
    else if ([newPressureUnit isEqualToString:UPkPa])
    {
        return oldPressure * 6.894757;
    }
    else if ([newPressureUnit isEqualToString:UPMPa])
    {
        return oldPressure * 0.0068948;
    }
    return oldPressure;
}



+ (float)convertWeightWithG:(NSInteger)gVal toNewUnit:(NSString *)newUnit
{
    if ([newUnit isEqualToString:U_kg])
    {
        return gVal * 0.001;
    }
    else if ([newUnit isEqualToString:U_lb])
    {
        return gVal * 0.0022046;
    }
    else if ([newUnit isEqualToString:U_oz])
    {
        return gVal * 0.035274;
    }
    
    return gVal;
}

+ (float)convertWeightToGWithOldValue:(float)oldvalue oldUnit:(NSString *)oldUnit
{
    if ([oldUnit isEqualToString:U_kg])
    {
        return oldvalue * 1000;
    }
    else if ([oldUnit isEqualToString:U_lb])
    {
        return oldvalue * 453.59237;
    }
    else if ([oldUnit isEqualToString:U_oz])
    {
        return oldvalue * 28.3495231;
    }
    
    return oldvalue;
}

@end
