//
//  ETVgwMiniWorker.h
//  ManifoldGauge
//
//  Created by mac on 2022/10/21.
//  Copyright © 2022 Reo. All rights reserved.
//

#import "ETNewProtocol.h"

NS_ASSUME_NONNULL_BEGIN


#define TEMP_ARG_NONE   32767-10           //数值无效
#define TEMP_ARG_ADCE   TEMP_ARG_NONE+1    //adc异常   0x7FF6
#define TEMP_ARG_CABE   TEMP_ARG_NONE+2   //未标定             0x7FF7
#define TEMP_ARG_UPOL   TEMP_ARG_NONE+3    //超上限         0x7FF8
#define TEMP_ARG_DNOL   TEMP_ARG_NONE+4    //超下限     0x7FF9
#define TEMP_ARG_NCON   TEMP_ARG_NONE+5    //传感器未连接 0x7FFA
#define TEMP_ARG_NTC    TEMP_ARG_NONE+6    //NTC温度超限  0x7FFB


#define TEMP_ARG_ADCE_870   TEMP_ARG_NONE+1    //adc异常   0x7FF6
#define TEMP_ARG_CABE_870   TEMP_ARG_NONE+2    //
#define TEMP_ARG_NCON_870   TEMP_ARG_NONE+3    //传感器未连接         0x7FF8
#define TEMP_ARG_UPOL_870   TEMP_ARG_NONE+4    //超上限或短路     0x7FF9



#define IPT_ARG_NONE   0x7FF5           //数值无效
#define IPT_ARG_OLHH   TEMP_ARG_NONE+1    //超上限   0x7FF6
#define IPT_ARG_OLLL   TEMP_ARG_NONE+2   //超下限          0x7FF7


#define VAC_ARG_NONE  0x7FFFFFFF-10         //数值无效
#define VAC_ARG_ADCE  VAC_ARG_NONE+1        //ADC异常
#define VAC_ARG_CABE  VAC_ARG_NONE+2        //未标定
#define VAC_ARG_UPOL  VAC_ARG_NONE+3        //超上限
#define VAC_ARG_DNOL  VAC_ARG_NONE+4        //超上限

#define PRESS_ARG_NONE  32767-10           //数值无效
#define PRESS_ARG_ADCE  PRESS_ARG_NONE+1   //ADC异常
#define PRESS_ARG_CABE  PRESS_ARG_NONE+2   //未标定
#define PRESS_ARG_UPOL  PRESS_ARG_NONE+3   //超上限
#define PRESS_ARG_DNOL  PRESS_ARG_NONE+4   //超下限

#define WEIGHT_ARG_NONE  0x7FFFFFFF-10      //数值无效
#define WEIGHT_ARG_ADCE  WEIGHT_ARG_NONE+1   //ADC异常
#define WEIGHT_ARG_CABE  WEIGHT_ARG_NONE+2   //未标定
#define WEIGHT_ARG_UPOL  WEIGHT_ARG_NONE+3   //超上限
#define WEIGHT_ARG_DNOL  WEIGHT_ARG_NONE+4   //超下限
#define WEIGHT_ARG_NCON  WEIGHT_ARG_NONE+5   //传感器异常

typedef NS_ENUM(NSInteger, SvpVaccumUnitType) {
    SvpVaccumUnitType_micron = 1,
    SvpVaccumUnitType_Pa     = 2,
    SvpVaccumUnitType_mTorr  = 3,
    SvpVaccumUnitType_inHg   = 4,
    SvpVaccumUnitType_Torr   = 5,
    SvpVaccumUnitType_kPa    = 6,
    SvpVaccumUnitType_mbar   = 7
};

typedef NS_ENUM(NSInteger, VGWMiniTUnitType) {
    VGWMiniTUnitType_micron = 0,
    VGWMiniTUnitType_mTorr = 1,
    VGWMiniTUnitType_inHg = 2,
    VGWMiniTUnitType_Pa = 3,
    VGWMiniTUnitType_Torr = 4,
    VGWMiniTUnitType_kPa = 5,
    VGWMiniTUnitType_mbar = 6,
    VGWMiniTUnitType_psia = 7
};

typedef NS_ENUM(NSInteger, PressUnitType) {
    PressUnitType_kPa = 0,
    PressUnitType_MPa = 1,
    PressUnitType_bar = 2,
    PressUnitType_psi = 3,
    PressUnitType_kgcm2 = 4,
    PressUnitType_inHg = 5,
    PressUnitType_cmHg = 6,
    PressUnitType_Pa = 7
};

@interface ETNewProtocolWorker : ETNewProtocol

@property (nonatomic,strong) NSData *modeCode;

- (instancetype)initWithModeCode:(NSData *)modeCode;

- (NSData *)packageDataWithFunc:(ETFuncCodeType)funcType andData:(NSData *)data;
- (NSData *)img_packageDataWithFunc:(ETFuncCodeType)funcType andData:(NSData *)data mac:(NSData *)mac;

- (NSData *)setClockData:(NSData *)date;
- (NSData *)realTimeData;
- (NSData *)realTimeDataWithInterval:(NSInteger)timeInterval;

/// 功能码02的, 读参数
- (NSData *)readDataWithSubFunc:(UInt16)subFunc subFuncCount:(UInt16)subFuncCount;
/// 功能码01的，写单个参数
- (NSData *)setDataWithSubFunc:(UInt16)subFunc andContent:(UInt16)con;
/// 功能码03的，写单个或多个参数
- (NSData *)setFunc03WithSubFunc:(UInt16)SubFunc subFuncCount:(UInt16)subFuncCount andContent:(NSData *)content;
/// 功能码01的，写单个参数,自定义组包的设备型号
- (NSData *)setDataWithSubFunc:(UInt16)subFunc andContent:(UInt16)con modeCode:(NSData *)modeCode;
/// 功能码03的，写单个或多个参数,自定义组包的设备型号
- (NSData *)setFunc03WithSubFunc:(UInt16)SubFunc subFuncCount:(UInt16)subFuncCount andContent:(NSData *)content modeCode:(NSData *)modeCode;

//固件更新
- (NSData *)setUpdateDataWithFunc:(UInt8)func andContent:(NSData *_Nullable)con;
//读取历史记录
- (NSData *)setReadHistoryDataWithFunc:(UInt8)func andContent:(NSData *_Nullable)con;
- (NSData *)responseForHistoryDataWithFunc:(NSData *)cont;
//冷媒
- (NSData *)setUpdateRefriDataWithFunc:(UInt8)func andContent:(NSData *_Nullable)con;
//读取泄露保压测试数据
- (NSData *)readTestData;
- (NSData *)responseForTestDataWithFunc:(NSData *)cont;

/// 联网伴侣
- (NSData *)imgLink_readDataWithFunc:(UInt8)func andContent:(NSData *_Nullable)con;
@end


@interface ETNewProtocolWorker (Util)

+ (NSString *)vUnitFrom:(NSInteger)val;
+ (NSString *)tUnitFrom:(NSInteger)val;
+ (NSInteger)tValueFrom:(NSString *)temUnit;
+ (BOOL)temperatureValid:(NSInteger)val;
+ (BOOL)iptValValid:(NSInteger)val;

@end

@interface ETNewProtocolWorker (press)

+ (NSUInteger)pressureDecimalNumOfUnit:(NSString *)unit;
+ (NSUInteger)dmg5b_pressureDecimalNumOfUnit:(NSString *)unit;
+ (NSString *)pUnitFrom:(NSInteger)val;
+ (NSUInteger)emg_pressureDecimalNumOfUnit:(NSString *)unit;
+ (BOOL)pressureValid:(NSInteger)val;
+ (BOOL)byte4ValValid:(NSInteger)val;
+ (float)emg_getMaxHighPressure:(NSString *)pressUnit;
//+ (float)emg_getMaxLowPressure:(NSString *)pressUnit;
+ (float)emg_getMinChartPressure:(NSString *)pressUnit;
+ (float)emg_getShowPressure:(NSString *)pressUnit andInputVal:(float)val;


+ (BOOL)needIntTemp:(NSInteger)tem withUnit:(NSString *)unit;

+ (BOOL)weightValValid:(NSInteger)val;
+ (NSString *)lmcUnitFrom:(NSInteger)val;


+ (float)dealOzVal:(float)zoVal;

//MARK: IPT-100

+ (NSString *)showIPTHum:(NSInteger)hum;
+ (NSString *)showIPTHumWithoutUnit:(NSInteger)hum;
+ (NSString *)iptSceneFrom:(NSInteger)val;
+ (NSString *)iptTimeModeFrom:(NSInteger)val;


//MARK: vgw760pro
+ (BOOL)vgw760pro_vacuumValid:(NSInteger)val;
+ (NSUInteger)vgw760pro_decimalNumForUnit:(NSString *)unit;
+ (NSString *)vgw760pro_showVacuum:(NSInteger)vacuum andUnit:(NSString *)unit;
+ (NSString *)vgw760pro_showVacuum:(NSInteger)vacuum andShowUnit:(NSString *)unit;
+ (NSString *)vgw760pro_unitFrom:(NSInteger)val;

+ (float)vgw760pro_calVaccum:(float)oldPressure newVacUnit:(NSString *)newVacUnit;
+ (float)vgw760pro_calculateVacuumWithInputValue:(float)inputValue inputUnit:(NSString *)inputUnit;



//MARK: ipt01
+ (BOOL)ipt01_valValid:(NSInteger)val;
+ (NSString *)ipt01_showHum:(NSInteger)hum;
+ (NSString *)ipt01_showHumWithoutUnit:(NSInteger)hum;

//MARK: pt500pro
+ (BOOL)pt_valValid:(NSInteger)val;
+ (NSUInteger)pt_decimalNumForUnit:(NSString *)unit;
+ (NSString *)pt_unitFrom:(NSInteger)val;
+ (NSInteger)pt_valFromUnit:(NSString *)unit;
@end

NS_ASSUME_NONNULL_END
