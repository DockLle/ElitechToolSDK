//
//  ETVgwMiniWorker.m
//  ManifoldGauge
//
//  Created by mac on 2022/10/21.
//  Copyright © 2022 Reo. All rights reserved.
//

#import "ETNewProtocolWorker.h"
#import "NSData+Util.h"
#import "UnitsDefine.h"

@interface ETNewProtocolWorker()

//@property (nonatomic,strong) NSData *modeCode;

@end

@implementation ETNewProtocolWorker

- (instancetype)initWithModeCode:(NSData *)modeCode
{
    self = [super init];
    if (self) {
        self.modeCode = modeCode;
    }
    return self;
}

- (NSData *)packageDataWithFunc:(ETFuncCodeType)funcType andData:(NSData *)data
{
    Byte addr[] = {0x00,0x00};
    NSMutableData *address = [NSMutableData dataWithData:self.modeCode];
    [address appendBytes:addr length:sizeof(addr)];
    
    return [self packageDataWithAddress:address Func:funcType andData:data];
}

- (NSData *)img_packageDataWithFunc:(ETFuncCodeType)funcType andData:(NSData *)data mac:(NSData *)mac
{
    Byte addr[] = {0x00,0x00};
    NSMutableData *address = [NSMutableData dataWithData:self.modeCode];
    [address appendBytes:addr length:sizeof(addr)];
    
    return [self img_packageDataWithAddress:address Func:funcType mac:mac andData:data];
}


- (NSData *)setClockData:(NSData *)date
{
    Byte b[] = {0,REG_COMM_RTC_TIME,0,3};
    
    NSMutableData *content = [NSMutableData data];
    [content appendBytes:b length:sizeof(b)];
    [content appendData:date];
    
    return [self packageDataWithFunc:ETFuncCodeType03 andData:content];
}

- (NSData *)realTimeData
{
    Byte b[] = {0,REG_COMM_AUTO_REP};
    UInt16 interval = 5;//单位：100ms,即为500ms
    interval = NSSwapHostShortToBig(interval);
    
    NSMutableData *content = [NSMutableData data];
    [content appendBytes:b length:sizeof(b)];
    [content appendBytes:&interval length:sizeof(interval)];
    
    return [self packageDataWithFunc:ETFuncCodeType01 andData:content];
}

- (NSData *)realTimeDataWithInterval:(NSInteger)timeInterval
{
    Byte b[] = {0,REG_COMM_AUTO_REP};
    UInt16 interval = timeInterval;
    interval = NSSwapHostShortToBig(interval);
    
    NSMutableData *content = [NSMutableData data];
    [content appendBytes:b length:sizeof(b)];
    [content appendBytes:&interval length:sizeof(interval)];
    
    return [self packageDataWithFunc:ETFuncCodeType01 andData:content];
}

- (NSData *)readDataWithSubFunc:(UInt16)subFunc subFuncCount:(UInt16)subFuncCount
{
    UInt16 b = subFunc;
    b = NSSwapHostShortToBig(b);
    UInt16 c = subFuncCount;
    c = NSSwapHostShortToBig(c);
    
    NSMutableData *content = [NSMutableData data];
    [content appendBytes:&b length:sizeof(b)];
    [content appendBytes:&c length:sizeof(c)];
    
    return [self packageDataWithFunc:ETFuncCodeType02 andData:content];
}

- (NSData *)setDataWithSubFunc:(UInt16)subFunc andContent:(UInt16)con
{
    UInt16 b = subFunc;
    b = NSSwapHostShortToBig(b);
    UInt16 c = con;
    c = NSSwapHostShortToBig(c);
    
    NSMutableData *content = [NSMutableData data];
    [content appendBytes:&b length:sizeof(b)];
    [content appendBytes:&c length:sizeof(c)];
    
    return [self packageDataWithFunc:ETFuncCodeType01 andData:content];
}

- (NSData *)setDataWithSubFunc:(UInt16)subFunc andContent:(UInt16)con modeCode:(NSData *)modeCode
{
    UInt16 b = subFunc;
    b = NSSwapHostShortToBig(b);
    UInt16 c = con;
    c = NSSwapHostShortToBig(c);
    
    NSMutableData *content = [NSMutableData data];
    [content appendBytes:&b length:sizeof(b)];
    [content appendBytes:&c length:sizeof(c)];
    
    Byte addr[] = {0x00,0x00};
    NSMutableData *address = [NSMutableData dataWithData:modeCode];
    [address appendBytes:addr length:sizeof(addr)];
    
    return [self packageDataWithAddress:address Func:ETFuncCodeType01 andData:content];
}

- (NSData *)setFunc03WithSubFunc:(UInt16)SubFunc subFuncCount:(UInt16)subFuncCount andContent:(NSData *)content modeCode:(NSData *)modeCode
{
    UInt16 subFuncR = NSSwapHostShortToBig(SubFunc);
    UInt16 subFuncCountR = NSSwapHostShortToBig(subFuncCount);
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&subFuncR length:sizeof(subFuncR)];
    [data appendBytes:&subFuncCountR length:sizeof(subFuncCountR)];
    [data appendData:content];
    
    Byte addr[] = {0x00,0x00};
    NSMutableData *address = [NSMutableData dataWithData:modeCode];
    [address appendBytes:addr length:sizeof(addr)];
    
    return [self packageDataWithAddress:address Func:ETFuncCodeType03 andData:data];
}

- (NSData *)setFunc03WithSubFunc:(UInt16)SubFunc subFuncCount:(UInt16)subFuncCount andContent:(NSData *)content
{
    UInt16 subFuncR = NSSwapHostShortToBig(SubFunc);
    UInt16 subFuncCountR = NSSwapHostShortToBig(subFuncCount);
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&subFuncR length:sizeof(subFuncR)];
    [data appendBytes:&subFuncCountR length:sizeof(subFuncCountR)];
    [data appendData:content];
    
    return [self packageDataWithFunc:ETFuncCodeType03 andData:data];
}

- (NSData *)setUpdateDataWithFunc:(UInt8)func andContent:(NSData *_Nullable)con
{
    UInt8 fc = func;
    NSMutableData *content = [NSMutableData data];
    [content appendBytes:&fc length:sizeof(fc)];
    if (con) {
        [content appendData:con];
    }
    
    return [self packageDataWithFunc:ETFuncCodeType07 andData:content];
}

- (NSData *)setReadHistoryDataWithFunc:(UInt8)func andContent:(NSData *_Nullable)con
{
    UInt8 fc = func;
    NSMutableData *content = [NSMutableData data];
    [content appendBytes:&fc length:sizeof(fc)];
    if (con) {
        [content appendData:con];
    }
    
    return [self packageDataWithFunc:ETFuncCodeType06 andData:content];
}
- (NSData *)responseForHistoryDataWithFunc:(NSData *)cont
{
    UInt8 ser = 0x03;
    NSMutableData *replyData = [NSMutableData data];
    [replyData appendBytes:&ser length:sizeof(ser)];
    [replyData appendData:cont];
    
    return [self packageDataWithFunc:ETFuncCodeType06 andData:replyData];
}

- (NSData *)setUpdateRefriDataWithFunc:(UInt8)func andContent:(NSData *_Nullable)con
{
    UInt8 fc = func;
    NSMutableData *content = [NSMutableData data];
    [content appendBytes:&fc length:sizeof(fc)];
    if (con) {
        [content appendData:con];
    }
    
    return [self packageDataWithFunc:ETFuncCodeType10 andData:content];
}

- (NSData *)readTestData
{
    UInt8 fc = 0x01;
    UInt8 con1 = 0x01;
    NSMutableData *content = [NSMutableData data];
    [content appendBytes:&fc length:sizeof(fc)];
    [content appendBytes:&con1 length:sizeof(con1)];
    
    return [self packageDataWithFunc:ETFuncCodeType11 andData:content];
}

- (NSData *)responseForTestDataWithFunc:(NSData *)cont
{
    UInt8 ser = 0x03;
    NSMutableData *replyData = [NSMutableData data];
    [replyData appendBytes:&ser length:sizeof(ser)];
    [replyData appendData:cont];
    
    return [self packageDataWithFunc:ETFuncCodeType11 andData:replyData];
}

- (NSData *)imgLink_readDataWithFunc:(UInt8)func andContent:(NSData *_Nullable)con
{
    UInt8 fc = func;
    NSMutableData *content = [NSMutableData data];
    [content appendBytes:&fc length:sizeof(fc)];
    if (con) {
        [content appendData:con];
    }
    
    return [self packageDataWithFunc:ETFuncCodeType14 andData:content];
}


@end

@implementation ETNewProtocolWorker (Util)

+ (NSString *)vUnitFrom:(NSInteger)val
{
    switch (val) {
        case VGWMiniTUnitType_micron:
            return Umicrons;
            break;
        case VGWMiniTUnitType_mTorr:
            return UmTorr;
            break;
        case VGWMiniTUnitType_inHg:
            return UinHg;
            break;
        case VGWMiniTUnitType_Pa:
            return UPa;
            break;
        case VGWMiniTUnitType_Torr:
            return UTorr;
            break;
        case VGWMiniTUnitType_kPa:
            return UkPa;
            break;
        case VGWMiniTUnitType_mbar:
            return Umbar;
            break;
        case VGWMiniTUnitType_psia:
            return Upsia;
            break;
        default:
            return @"";
            break;
    }
}

+ (NSString *)tUnitFrom:(NSInteger)val
{
    switch (val) {
        case 0:
            return U_C;
            break;
        case 1:
            return U_F;
            break;
        case 2:
            return U_K;
            break;
        default:
            return @"";
            break;
    }
}

+ (NSInteger)tValueFrom:(NSString *)temUnit
{
    if ([temUnit isEqualToString:U_C]) {
        return 0;
    }
    else if ([temUnit isEqualToString:U_F])
    {
        return 1;
    }
    else if ([temUnit isEqualToString:U_K])
    {
        return 2;
    }
    
    return 0;
}


+ (BOOL)temperatureValid:(NSInteger)val
{
    if (val < TEMP_ARG_NONE) {
        return YES;
    }
    return NO;
}

+ (BOOL)iptValValid:(NSInteger)val
{
    if (val < IPT_ARG_NONE) {
        return YES;
    }
    return NO;
}

@end

@implementation ETNewProtocolWorker (press)

+ (NSUInteger)pressureDecimalNumOfUnit:(NSString *)unit
{
    NSDictionary *unitDic = @{
        UPpsi:@"0",
        UPkgcm:@"2",
        UPbar:@"2",
        UPkPa:@"0",
        UPMPa:@"3",
        UPinHg:@"0",
    };
    
    return [unitDic[unit] intValue];
}

+ (NSUInteger)dmg5b_pressureDecimalNumOfUnit:(NSString *)unit
{
    NSDictionary *unitDic = @{
        UPpsi:@"1",
        UPkgcm:@"2",
        UPbar:@"2",
        UPkPa:@"0",
        UPMPa:@"3",
        UPinHg:@"0",
    };
    
    return [unitDic[unit] intValue];
}

+ (NSString *)pUnitFrom:(NSInteger)val
{
    switch (val) {
        case PressUnitType_psi:
            return UPpsi;
            break;
        case PressUnitType_kPa:
            return UPkPa;
            break;
        case PressUnitType_MPa:
            return UPMPa;
            break;
        case PressUnitType_kgcm2:
            return UPkgcm;
            break;
        case PressUnitType_inHg:
            return UPinHg;
            break;
        case PressUnitType_bar:
            return UPbar;
            break;
        case PressUnitType_cmHg:
            return UPcmHg;
            break;
        case PressUnitType_Pa:
            return UPPa;
            break;
        default:
            return @"";
            break;
    }
}

+ (NSUInteger)emg_pressureDecimalNumOfUnit:(NSString *)unit
{
    NSDictionary *unitDic = @{
        UPpsi:@"1",
        UPkgcm:@"2",
        UPbar:@"2",
        UPkPa:@"0",
        UPMPa:@"3",
        UPinHg:@"0",
        UPcmHg:@"0",
    };
    
    return [unitDic[unit] intValue];
}

+ (BOOL)pressureValid:(NSInteger)val
{
    if (val < PRESS_ARG_NONE) {
        return YES;
    }
    return NO;
}

+ (BOOL)byte4ValValid:(NSInteger)val
{
    if (val < VAC_ARG_NONE) {
        return YES;
    }
    return NO;
}

+ (float)emg_getMaxHighPressure:(NSString *)pressUnit {
    float press = 0;
    if ([pressUnit isEqualToString:UPpsi])
    {
        press = 800;
    }
    else if ([pressUnit isEqualToString:UPkgcm])
    {
        press = 56;
    }
    else if ([pressUnit isEqualToString:UPcmHg])
    {
        press = 4100;
    }
    else if ([pressUnit isEqualToString:UPinHg])
    {
        press = 1600;
    }
    else if ([pressUnit isEqualToString:UPbar])
    {
        press = 55;
    }
    else if ([pressUnit isEqualToString:UPkPa])
    {
        press = 5520;
    }
    else if ([pressUnit isEqualToString:UPMPa])
    {
        press = 5.5f;
    }
    return press;
    
}

//+ (float)emg_getMaxLowPressure:(NSString *)pressUnit {
//    float press = 0;
//    if ([pressUnit isEqualToString:UPpsi])
//    {
//        press = 500;
//    }
//    else if ([pressUnit isEqualToString:UPkgcm])
//    {
//        press = 56;
//    }
//    else if ([pressUnit isEqualToString:UPcmHg])
//    {
//        press = 4100;
//    }
//    else if ([pressUnit isEqualToString:UPinHg])
//    {
//        press = 1600;
//    }
//    else if ([pressUnit isEqualToString:UPbar])
//    {
//        press = 55;
//    }
//    else if ([pressUnit isEqualToString:UPkPa])
//    {
//        press = 5520;
//    }
//    else if ([pressUnit isEqualToString:UPMPa])
//    {
//        press = 5.5f;
//    }
//    return press;
//    
//}

+ (float)emg_getMinChartPressure:(NSString *)pressUnit {
    float press = 0;
    if ([pressUnit isEqualToString:UPpsi])
    {
        press = -14.5f;
    }
    else if ([pressUnit isEqualToString:UPkgcm])
    {
        press = -1.02f;
    }
    else if ([pressUnit isEqualToString:UPcmHg])
    {
        press = -75;
    }
    else if ([pressUnit isEqualToString:UPinHg])
    {
        press = -30;
    }
    else if ([pressUnit isEqualToString:UPbar])
    {
        press = -1.00f;
    }
    else if ([pressUnit isEqualToString:UPkPa])
    {
        press = -100;
    }
    else if ([pressUnit isEqualToString:UPMPa])
    {
        press = -0.100f;
    }
    return press;
    
}

+ (float)emg_getMinChartPressure_show:(NSString *)pressUnit {
    float press = 0;
    if ([pressUnit isEqualToString:UPpsi])
    {
        press = -14.7f;
    }
    else if ([pressUnit isEqualToString:UPkgcm])
    {
        press = -1.03f;
    }
    else if ([pressUnit isEqualToString:UPcmHg])
    {
        press = -75;
    }
    else if ([pressUnit isEqualToString:UPinHg])
    {
        press = -30;
    }
    else if ([pressUnit isEqualToString:UPbar])
    {
        press = -1.01f;
    }
    else if ([pressUnit isEqualToString:UPkPa])
    {
        press = -101;
    }
    else if ([pressUnit isEqualToString:UPMPa])
    {
        press = -0.101f;
    }
    return press;
    
}

+ (float)emg_getShowPressure:(NSString *)pressUnit andInputVal:(float)val
{
//    float max = [self emg_getMaxHighPressure:pressUnit];
    float min = [self emg_getMinChartPressure:pressUnit];
//    if (val > max) return max;
    if (val < min) return [self emg_getMinChartPressure_show:pressUnit];
    
    return val;
}



+ (BOOL)needIntTemp:(NSInteger)tem withUnit:(NSString *)unit
{
    if ([unit isEqualToString:U_C])
    {
        if (tem >= 1000)
        {
            return YES;
        }
    }
    else if ([unit isEqualToString:U_F])
    {
        float temF = tem * 1.8 + 320;
        if (temF >= 1000)
        {
            return YES;
        }
        
    }
    return NO;
}



+ (BOOL)weightValValid:(NSInteger)val
{
    if (val < WEIGHT_ARG_NONE) {
        return YES;
    }
    return NO;
}

+ (NSString *)lmcUnitFrom:(NSInteger)val
{
    switch (val) {
        case 0:
            return U_kg;
            break;
        case 1:
            return U_lb;
            break;
        case 2:
            return U_oz;
            break;
        case 3:
            return [NSString stringWithFormat:@"%@-%@",U_kg,U_g];
            break;
        case 4:
            return [NSString stringWithFormat:@"%@-%@",U_lb,U_oz];
            break;
        
        default:
            return @"";
            break;
    }
}





+ (float)dealOzVal:(float)zoVal
{
    int a = zoVal * 10;//保留一位
    int b = a % 10;//取小数位
    int c = a - b;//取整数位
    
    SInt32 res = [self cutDiv:b ucDiv:2];
    
    return (c + res) * 0.1;//缩小10倍还原
}

/// 分度化及四舍五入
/// - Parameters:
///   - fValue: 要分度化的数据
///   - ucDiv: 分度值
+ (SInt32)cutDiv:(SInt32)fValue ucDiv:(UInt8)ucDiv
{
    SInt32 lTemp;
    lTemp = 0;
    if(fValue > 0)
    {
        lTemp = fValue;
        lTemp = (SInt32) ((lTemp + (UInt8)(0.5 * ucDiv)) / ucDiv);
        lTemp = lTemp *  ucDiv;
    }
    else  if(fValue < 0)
    {
        lTemp = 0 - fValue;
        lTemp = (SInt32) ((lTemp + (UInt8)(0.5 * ucDiv)) / ucDiv);
        lTemp = 0 - lTemp *  ucDiv;
    }
    return lTemp;
}


//MARK: IPT-100

+ (NSString *)showIPTHum:(NSInteger)hum
{
    if ([ETNewProtocolWorker iptValValid:hum])
    {
        float rTem = hum * 0.1;
        return [NSString stringWithFormat:@"%.1f%%",rTem];
    }
    else if (hum == IPT_ARG_OLHH)
    {
        return @"HH";
    }
    else if (hum == IPT_ARG_OLLL)
    {
        return @"LL";
    }
    
    return @"--";
}

+ (NSString *)showIPTHumWithoutUnit:(NSInteger)hum
{
    if ([ETNewProtocolWorker iptValValid:hum])
    {
        float rTem = hum * 0.1;
        return [NSString stringWithFormat:@"%.1f",rTem];
    }
    else if (hum == IPT_ARG_OLHH)
    {
        return @"HH";
    }
    else if (hum == IPT_ARG_OLLL)
    {
        return @"LL";
    }
    
    return @"--";
}

+ (NSString *)iptSceneFrom:(NSInteger)val
{
    switch (val) {
        case 0:
            return @"生活办公";
            break;
        case 1:
            return @"实验室";
            break;
        case 2:
            return @"工业仓库";
            break;
        case 3:
            return @"药店冷柜";
            break;
        case 4:
            return @"家庭养殖";
            break;
        case 5:
            return @"医院病房";
            break;
        case 6:
            return @"其他";
            break;
        default:
            return @"";
            break;
    }
}

+ (NSString *)iptTimeModeFrom:(NSInteger)val
{
    switch (val) {
        case 0:
            return @"12h";
            break;
        case 1:
            return @"24h";
            break;
        
        default:
            return @"";
            break;
    }
}

//MARK: vgw760pro

+ (BOOL)vgw760pro_vacuumValid:(NSInteger)val
{
    if (val < VAC_ARG_NONE) {
        return YES;
    }
    return NO;
}

+ (NSUInteger)vgw760pro_decimalNumForUnit:(NSString *)unit
{
    NSDictionary *unitDic = @{
        Umicrons:@"0",
        UmTorr:@"0",
        Upsia:@"4",
        UinHg:@"3",
        UPa:@"1",
        Umbar:@"3",
        UTorr:@"3",
        UkPa:@"4",
    };
    
    return [unitDic[unit] intValue];
}

+ (NSString *)vgw760pro_showVacuum:(NSInteger)vacuum andUnit:(NSString *)unit
{
    if ([self vgw760pro_vacuumValid:vacuum])
    {
        float vv = [self vgw760pro_calVaccum:vacuum newVacUnit:unit];
        
        NSUInteger decimals = [self vgw760pro_decimalNumForUnit:unit];
        NSString *format = [NSString stringWithFormat:@"%%.%luf",(unsigned long)decimals];
        
//        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//        f.maximumFractionDigits = decimals;
        
        return [NSString stringWithFormat:format,vv];
    }
    return @"--";
}

+ (NSString *)vgw760pro_showVacuum:(NSInteger)vacuum andShowUnit:(NSString *)unit
{
    if ([self vgw760pro_vacuumValid:vacuum])
    {
        float vv = [self vgw760pro_calVaccum:vacuum newVacUnit:unit];
        
        NSUInteger decimals = [self vgw760pro_decimalNumForUnit:unit];
//        NSString *format = [NSString stringWithFormat:@"%%.%luf",(unsigned long)decimals];
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.maximumFractionDigits = decimals;
        
        return [NSString stringWithFormat:@"%@%@",[f stringFromNumber:@(vv)],unit];
    }
    return @"--";
}

+ (NSString *)vgw760pro_unitFrom:(NSInteger)val
{
    switch (val) {
        case 0:
            return Umicrons;
            break;
        case 1:
            return UmTorr;
            break;
        case 2:
            return UinHg;
            break;
        case 3:
            return UPa;
            break;
        case 4:
            return UTorr;
            break;
        case 5:
            return UkPa;
            break;
        case 6:
            return Umbar;
            break;
        case 7:
            return Upsia;
            break;
        
        default:
            return @"";
            break;
    }
    
}

+ (float)vgw760pro_calVaccum:(float)oldPressure newVacUnit:(NSString *)newVacUnit
{

    double pressure = oldPressure;
    
    NSUInteger decimalNum = [self vgw760pro_decimalNumForUnit:newVacUnit];
    float mutiple = powf(10, decimalNum);
    
    if ([newVacUnit isEqualToString:UinHg])
    {
        pressure = oldPressure * 3.937 * 0.00001 - 29.9212;
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
    
    if ([newVacUnit isEqualToString:Upsia] && pressure < 0.0001) {
        return 0.0001;
    }
    
    return pressure;
}

+ (float)vgw760pro_calculateVacuumWithInputValue:(float)inputValue inputUnit:(NSString *)inputUnit
{
    float pressure = 0;
    
    if ([inputUnit isEqualToString:UinHg])
    {
        pressure = (inputValue + 29.9212f) / 3.937e-5;
    }
    else if ([inputUnit isEqualToString:UTorr])
    {
        pressure = inputValue * 1000.0;
    }
    else if ([inputUnit isEqualToString:Upsia])
    {
        pressure = inputValue / 1.93368e-5;
    }
    else if ([inputUnit isEqualToString:Umbar])
    {
        pressure = inputValue / 1.33322e-3;
    }
    else if ([inputUnit isEqualToString:UmTorr])
    {
        pressure = inputValue;
    }
    else if ([inputUnit isEqualToString:UPa])
    {
        pressure = inputValue / 1.33322e-1;
    }
    else if ([inputUnit isEqualToString:Umicrons])
    {
        pressure = inputValue;
    }
    else if ([inputUnit isEqualToString:UkPa])
    {
        pressure = inputValue / 1.33322e-4;
    }
    
    return pressure;
}

//MARK: ipt01
+ (BOOL)ipt01_valValid:(NSInteger)val
{
    if (val < TEMP_ARG_NONE) {
        return YES;
    }
    return NO;
}


+ (NSString *)ipt01_showHum:(NSInteger)hum
{
    if ([ETNewProtocolWorker ipt01_valValid:hum])
    {
        float rHum = hum * 0.1;
        return [NSString stringWithFormat:@"%.1f%%",rHum];
    }
    
    return @"--";
}

+ (NSString *)ipt01_showHumWithoutUnit:(NSInteger)hum
{
    if ([ETNewProtocolWorker ipt01_valValid:hum])
    {
        float rHum = hum * 0.1;
        return [NSString stringWithFormat:@"%.1f",rHum];
    }
    
    return @"--";
}

//MARK: pt500pro
+ (BOOL)pt_valValid:(NSInteger)val
{
    if (val < PRESS_ARG_NONE) {
        return YES;
    }
    return NO;
}
+ (NSUInteger)pt_decimalNumForUnit:(NSString *)unit
{
    NSDictionary *unitDic = @{
        UPpsi:@"1",
        UPkgcm:@"2",
        UPbar:@"2",
        UPkPa:@"0",
        UPMPa:@"3",
        UPinHg:@"0",
        UPcmHg:@"0",
    };
    
    return [unitDic[unit] intValue];
}


+ (NSString *)pt_unitFrom:(NSInteger)val
{
    switch (val) {
        case PressUnitType_psi:
            return UPpsi;
            break;
        case PressUnitType_kPa:
            return UPkPa;
            break;
        case PressUnitType_MPa:
            return UPMPa;
            break;
        case PressUnitType_kgcm2:
            return UPkgcm;
            break;
        case PressUnitType_inHg:
            return UPinHg;
            break;
        case PressUnitType_bar:
            return UPbar;
            break;
        case PressUnitType_cmHg:
            return UPcmHg;
            break;
        case PressUnitType_Pa:
            return UPPa;
            break;
        default:
            return @"";
            break;
    }
}

+ (NSInteger)pt_valFromUnit:(NSString *)unit
{
    NSDictionary *unitDic = @{
        UPpsi:@(PressUnitType_psi),
        UPkgcm:@(PressUnitType_kgcm2),
        UPbar:@(PressUnitType_bar),
        UPkPa:@(PressUnitType_kPa),
        UPMPa:@(PressUnitType_MPa),
        UPinHg:@(PressUnitType_inHg),
        UPcmHg:@(PressUnitType_cmHg),
        UPPa:@(PressUnitType_Pa),
    };
    
    return [unitDic[unit] integerValue];
}

@end
