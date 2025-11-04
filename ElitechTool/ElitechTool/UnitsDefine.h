//
//  UnitsDefine.h
//  ManifoldGauge
//
//  Created by mac on 2021/10/20.
//  Copyright © 2021 Reo. All rights reserved.
//

#ifndef UnitsDefine_h
#define UnitsDefine_h

#define ICT_220 @"ICT-220"
#define ICT_220_S @"ICT-220S"
#define JianLouYi @"Inframate-ppm"
#define ILD_800 @"ILD-800"
#define LD_800 @"LD-800"
#define ILD_1000 @"ILD-1000"
#define Inframate_s_max @"Inframate S Max"
#define VGW_MINI @"VGW-mini"
#define LMG_10W @"LMG-10W"
#define MS_810 @"MS-810"
#define MS_870 @"MS-870"
#define EMG_20 @"EMG-20"
#define EMG_40 @"EMG-40"
#define MS_20 @"MS-2000"
#define MS_40 @"MS-4000"
#define MS_1000s @"MS-1000s"
#define MS_1000 @"MS-1000"
#define HJOTA @"HJ OTA"

#define AI_DMG @"DMG-4B"
#define MS_100 @"MS-100"
#define DMG_10X @"DMG-10X"
#define DMG_4B_41 @"DMG-4B-41"
#define DMG_5B @"DMG-5B"
#define MS_200 @"MS-200"
#define MS_200_plus @"MS-200 Plus"

#define EMG_20V @"EMG-20V"
#define EMG_40V @"EMG-40V"
#define MS_2000 @"MS - 2000"
#define MS_4000 @"MS - 4000"

#define IPT_100 @"IPT-100"
#define IPT_01S @"IPT-01S"
#define IPT_01 @"IPT-01"


#define VGW_760 @"VGW-760"
#define VGW_760_U270 @"VGW-760-U270"
#define VGW_760_PRO @"VGW-760Pro"

#define SVP_XX @"SVP-XX"
#define SVP_7 @"SVP-7"
#define SVP_9 @"SVP-9"
#define SVP_12 @"SVP-12"
#define V_700 @"V700"
#define V_900 @"V900"
#define V_1200 @"V1200"

#define PGW_XX @"PGW-XX"
#define PGW_500 @"PGW-500"
#define PGW_800 @"PGW-800"
#define PT_500 @"PT-500"
#define PT_800 @"PT-800"

#define PT_500_pro @"PT-500 PRO"
#define PT_800_pro @"PT-800 PRO"


#define IMG_LINK_01 @"IMG-LINK-01"

#define SVG_DC_01 @"SVG-DC-01"
#define SVG_DC_HS @"SVG-DC-HS"


// tianyi add for 冷媒称
// 老冷媒称
#define LMC210       @"LMC210"
#define LMC210A      @"LMC210A"
#define LMC_210L     @"LMC210L"
#define LMC310       @"LMC310"
#define LMC310A      @"LMC310A"
#define SRC410       @"SRC410"
#define SRC510      @"SRC510"

//新冷媒称
#define SRL_100_ST  @"SRL-100-SC"
#define LMC_30B  @"LMC-30B"
#define LMC_30B_HAND  @"LMC-30B-HAND"
#define LMC_10A_SC  @"LMC-10A-SC"
#define LMC_10A_HAND  @"LMC-10A-HAND"
#define LMC_310_HAND  @"HAND-310"
#define LMC_210_SC  [NSString stringWithFormat:@"LMC-210%c",0x200d]
#define LMC_210A_SC  [NSString stringWithFormat:@"LMC-210A%c",0x200d]
#define LMC_210L_SC  [NSString stringWithFormat:@"LMC-210L%c",0x200d]
#define LMC_310_SC  [NSString stringWithFormat:@"LMC-310%c",0x200d]
#define LMC_310A_SC  [NSString stringWithFormat:@"LMC-310A%c",0x200d]
#define SRC_410_SC  [NSString stringWithFormat:@"SRC-410%c",0x200d]
#define SRC_510_SC  [NSString stringWithFormat:@"SRC-510%c",0x200d]
#define SRC_410A_SC  [NSString stringWithFormat:@"SRC-410A%c",0x200d]
#define SRC_510A_SC  [NSString stringWithFormat:@"SRC-510A%c",0x200d]
#define ERS_810_SC  [NSString stringWithFormat:@"ERS-810%c",0x200d]
#define ERS_811_SC  [NSString stringWithFormat:@"ERS-811%c",0x200d]
#define ERS_821_SC  [NSString stringWithFormat:@"ERS-821%c",0x200d]
#define ERS_810A_SC  [NSString stringWithFormat:@"ERS-810A%c",0x200d]
#define ERS_821A_SC  [NSString stringWithFormat:@"ERS-821A%c",0x200d]


//不新不老冷媒称
#define LMC_TYPE_CODE  @"LMC_TYPE_CODE"

#define LMC_SRL_100   @"SRL-100"
#define LMC_U1   @"U1"

#define LMC210_NEW    @"LMC-210"
#define LMC210L_NEW   @"LMC-210L"
#define LMC310_NEW    @"LMC-310"

#define LMC210A_NEW   @"LMC-210A"
#define LMC310A_NEW   @"LMC-310A"

#define LMC_ERS_821   @"ERS-821"
#define LMC_ERS_810   @"ERS-810"
#define LMC_ERS_811   @"ERS-811"

#define LMC_ERS_821A  @"ERS-821A"
#define LMC_ERS_810A  @"ERS-810A"

#define LMC_SRC_510   @"SRC-510"
#define LMC_SRC_410   @"SRC-410"

#define LMC_SRC_510A  @"SRC-510A"
#define LMC_SRC_410A  @"SRC-410A"



static NSString *const ETDeviceCodeVgwmini = @"0002";
static NSString *const ETDeviceCodeVgwminiNew = @"0003";
static NSString *const ETDeviceCodeAIDMG = @"0120";
static NSString *const ETDeviceCodeMS100 = @"0121";
static NSString *const ETDeviceCodeDMG10X = @"0122";
static NSString *const ETDeviceCodeDMG4b41 = @"0123";
static NSString *const ETDeviceCodeMS1000S = @"0113";
static NSString *const ETDeviceCodeEMG20V = @"0131";
static NSString *const ETDeviceCodeEMG40V = @"0132";
static NSString *const ETDeviceCodeMS2000V = @"0133";
static NSString *const ETDeviceCodeMS4000V = @"0134";
static NSString *const ETDeviceCodeICT220 = @"0400";
static NSString *const ETDeviceCodeICT220S = @"0401";
static NSString *const ETDeviceCodeBleOTA = @"ff01ff01a501";
static NSString *const ETDeviceCodeSRL100ST = @"020a";
static NSString *const ETDeviceCodeLMC30B = @"020b";
static NSString *const ETDeviceCodeLMC30BHand = @"020c";
static NSString *const ETDeviceCodeLMC10ASC = @"020d";
static NSString *const ETDeviceCodeLMC10AHand = @"020e";
static NSString *const ETDeviceCodeNewProtocol310Hand = @"0210";
static NSString *const ETDeviceCodeNP_LMC210 = @"0211";
static NSString *const ETDeviceCodeNP_LMC210A = @"0212";
static NSString *const ETDeviceCodeNP_LMC210L = @"0213";
static NSString *const ETDeviceCodeNP_LMC310 = @"0214";
static NSString *const ETDeviceCodeNP_LMC310A = @"0215";
static NSString *const ETDeviceCodeNP_SRC410 = @"0216";
static NSString *const ETDeviceCodeNP_SRC510 = @"0217";
static NSString *const ETDeviceCodeNP_SRC410A = @"0218";
static NSString *const ETDeviceCodeNP_SRC510A = @"0219";
static NSString *const ETDeviceCodeNP_ERS810 = @"021a";
static NSString *const ETDeviceCodeNP_ERS811 = @"021b";
static NSString *const ETDeviceCodeNP_ERS821 = @"021c";
static NSString *const ETDeviceCodeNP_ERS810A = @"021d";
static NSString *const ETDeviceCodeNP_ERS821A = @"021e";
static NSString *const ETDeviceCodeLmg10W = @"0140";
static NSString *const ETDeviceCodeMS810  = @"0170";
static NSString *const ETDeviceCodeMS870  = @"0171";
static NSString *const ETDeviceCodeMs1000 = @"0141";
static NSString *const ETDeviceCodeIPT100 = @"0464";
static NSString *const ETDeviceCodeVgw760Pro = @"0006";
static NSString *const ETDeviceCodeLMCCode = @"0201";
static NSString *const ETDeviceCodeDMG5b = @"0150";
static NSString *const ETDeviceCodeMS200 = @"0151";
static NSString *const ETDeviceCodeMS_200_plus = @"0152";
static NSString *const ETDeviceCodeIPT100_en = @"0465";

static NSString *const ETDeviceCodeIPT01S = @"0420";
static NSString *const ETDeviceCodeIPT01 = @"0421";
static NSString *const ETDeviceCodeIPT01Union = @"0420union";
static NSString *const ETDeviceCodePT500_new = @"0160";
static NSString *const ETDeviceCodePT800_new = @"0161";
static NSString *const ETDeviceCodeImg_link = @"0601";
static NSString *const ETDeviceCodeILD_800 = @"0516";
static NSString *const ETDeviceCodeILD_800_Sensor = @"05C0";
static NSString *const ETDeviceCodeLD_800 = @"0517";
static NSString *const ETDeviceCodeILD_1000 = @"0518";
static NSString *const ETDeviceCodeILD_1000_Sensor = @"05C1";
static NSString *const ETDeviceCodeInframate_s_max = @"0519";

//场景modeCode
static NSString *const ETDeviceCodeSceneEmg = @"0120_0400";

static NSString *const ETDeviceCodeSVP_DC_01 = @"0307";
static NSString *const ETDeviceCodeSVP_DC_HS = @"0308";


static NSString *const localRefrigerant = @"localRefrigerant_757";
static NSString *const localTempUnit = @"localTempUnit_757";

//真空单位
static NSString *const Umicrons = @"micron";
static NSString *const Umicrons2 = @"microns";
static NSString *const UmTorr = @"mTorr";
static NSString *const UinHg = @"inHg";
static NSString *const UPa = @"Pa";
static NSString *const UTorr = @"Torr";
static NSString *const UkPa = @"kPa";
static NSString *const Umbar = @"mbar";
static NSString *const Upsia = @"psia";

//压力单位
static NSString *const UPpsi = @"psi";
static NSString *const UPinHg = @"inHg";
static NSString *const UPkgcm = @"kg/cm²";
static NSString *const UPcmHg = @"cmHg";
static NSString *const UPbar = @"bar";
static NSString *const UPkPa = @"kPa";
static NSString *const UPMPa = @"Mpa";
static NSString *const UPPa = @"Pa";

//温度单位
static NSString *const U_C = @"℃";
static NSString *const U_F = @"℉";
static NSString *const U_K = @"K";

//质量单位
static NSString *const U_kg = @"kg";
static NSString *const U_g = @"g";
static NSString *const U_lb = @"lb";
static NSString *const U_oz = @"oz";

//ict220s热电偶类型
static NSString *const Pt_K = @"K";
static NSString *const Pt_T = @"T";
static NSString *const Pt_J = @"J";
static NSString *const Pt_E = @"E";

static NSString *const T1s = @"1S";
static NSString *const T10s = @"10S";
static NSString *const T60s = @"60S";
static NSString *const T5min = @"5Min";
static NSString *const T10min = @"10Min";
static NSString *const T15min = @"15Min";
static NSString *const T30min = @"30Min";
static NSString *const T60min = @"60Min";
static NSString *const T180min = @"180Min";
static NSString *const T30s = @"30S";
static NSString *const T5s = @"5S";
static NSString *const T1min = @"1Min";
static NSString *const T2min = @"2Min";
static NSString *const T45min = @"45Min";
static NSString *const T1H = @"1H";
static NSString *const T2H = @"2H";
static NSString *const T4H = @"4H";
static NSString *const T6H = @"6H";
static NSString *const T12H = @"12H";
static NSString *const T24H = @"24H";
static NSString *const T48H = @"48H";

static NSString *const During_all = @"所有记录数据";
static NSString *const During_one = @"本次开机后记录的数据";
static NSString *const During_two = @"过去一小时数据";
static NSString *const During_three = @"过去一天数据";
static NSString *const During_four = @"过去一周数据";


static NSString *const Status_close = @"停止脱机记录";
static NSString *const Status_recording = @"开启脱机记录";
static NSString *const Status_full = @"脱机记录已满";


static NSString *const N_instrument_work = @"N_instrument_work";
static NSString *const N_instrument_customer = @"N_instrument_customer";
static NSString *const N_need_login = @"N_need_login";

#endif /* UnitsDefine_h */
