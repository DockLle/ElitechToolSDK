//
//  ETNewProtocol.h
//  ManifoldGauge
//
//  Created by mac on 2022/10/21.
//  Copyright © 2022 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(UInt16, ETDeviceTypeCode) {
    ETDeviceTypeCodeVgwMini = 0x0003,
};

typedef NS_ENUM(UInt8, ETFuncCodeType) {
    ETFuncCodeType01 = 0x01,
    ETFuncCodeType02 = 0x02,
    ETFuncCodeType03 = 0x03,
    ETFuncCodeType04 = 0x04,
    ETFuncCodeType05 = 0x05,//温度夹校准数据，检漏仪获取实时状态
    ETFuncCodeType06 = 0x06,//读历史数据
    ETFuncCodeType07 = 0x07,//更新固件
    ETFuncCodeType10 = 0x10,//冷媒数据更新
    ETFuncCodeType11 = 0x11,//读泄露测试数据
    ETFuncCodeType13 = 0x13,//通过联网伴侣给子机发数据
    ETFuncCodeType14 = 0x14,//联网伴侣使用
};

//通用寄存器，产品基础信息
/********寄存器名称*******寄存器地址****读写和占用寄存器长度********注释************/
#define REG_COMM_TYPEID        1            //RW 1            产品类型，比如EMG-20V：0x0201
#define REG_COMM_SNCODE        2            //RW 1            产品地址，协议中使用 0x0001 - 0xFFFF, 未配置则为0x0000
#define REG_COMM_SNUNIQ        3            //RW 16            产品序列号，字符串类型，最长31个ASCII码
#define REG_COMM_RUN_SEC    19            //R- 2            产品运行时长，用秒做单位
#define REG_COMM_RTC_TIME    21            //RW 3            产品内时钟时间 三个寄存器分别是：年月日时分秒，符合C语言sturct tm要求
#define REG_COMM_T_PCB        24            //R- 1            产品PCB板载温度值
#define REG_COMM_LANG        25            //Rw 1            产品语言设置  0：中文，1：英文

#define REG_COMM_OTAID      30            //RW 1            产品升级ID，现有平台申请改ID

#define REG_COMM_BLE_RSSI    50            //R- 2            蓝牙信号强度 0-100
#define REG_COMM_WIFI_RSSI    51            //R- 2            WIFI信号强度 0-100
#define REG_COMM_LTE_RSSI    52            //R- 2            蜂窝信号强度 0-100
#define REG_COMM_ZBEE_RSSI    53            //R- 2            zigbee信号强度 0-100
#define REG_COMM_LORA_RSSI    54            //R- 2            lora信号强度 0-100
#define REG_COMM_BLE_MAC    55            //R- 3            蓝牙MAC地址，用6个字节保存
#define REG_COMM_BLE_NAME    58            //RW 16            蓝牙广播名称

//通用寄存器，产品运行信息
/********寄存器名称*******寄存器地址****读写和占用寄存器长度********注释************/
#define REG_COMM_PWR_OFF    100            //-W 1            关机指令，写入非0值立即关机
#define REG_COMM_AUTO_OFF    101            //RW 1            自动关机时间，单位S 1-65536秒， 0:不关闭
#define REG_COMM_BKL_OFF    102            //RW 1            背光关闭时间，单位S 1-65535秒， 0:常闭 65536：常开
#define REG_COMM_BK_LEVEL    103            //RW 1            背光亮度等级，0-100
#define REG_COMM_BAT_LEVEL    104            //R- 1            电池电量等级，0-100
#define REG_COMM_TEMP_IN    105            //R- 1            设备内置温度，板载温度
#define REG_COMM_TOLPMODE    106            //-W 1            进入低功耗状态指令，未定义

#define REG_COMM_PING_TICK    120            //RW 1            心跳包周期配置 (1-65536)*100ms  0：关闭   上电默认关闭
#define REG_COMM_AUTO_REP    121            //RW 1            实时数据自报周期配置 (1-65536)*100ms  0：关闭    上电默认关闭
#define REG_COMM_REC_TIME    122            //RW 1            数据记录间隔设置，1-65536 单位秒，0则不记录
#define REG_COMM_REC_EN        123            //RW 1            数据记录使能设置，0关，1,打开 读出为2表示存储已满
#define REG_COMM_REC_CLEAR    124            //RW 1            数据记录清楚，1 清楚全部，2，清楚本次开机记录
#define REG_COMM_DEV_ZERO    125            //-W 1            设备清零操作，由设备自身决定
#define REG_COMM_TO_CALIB    126            //-W 1            设备进入标定状态

//通用寄存器，可能存在的单位设置
/********寄存器名称*******寄存器地址****读写和占用寄存器长度********注释************/
#define REG_COMM_U_PRESS    200            //RW 1            压力单位    RegUnitPre
#define REG_COMM_U_VACCUM    201            //RW 1            真空单位    RegUnitVac
#define REG_COMM_U_TEMP        202            //RW 1            温度单位    RegUnitTemp
#define REG_COMM_U_HUMI        203            //RW 1            湿度单位
#define REG_COMM_U_CURRE    204            //RW 1            电流单位
#define REG_COMM_U_VOLTA    205            //RW 1            电压单位
#define REG_COMM_U_WEIGHT    206            //RW 1            重量单位
#define REG_COMM_U_DIVUL    207            //RW 1            泄露单位


#define REG_COMM_BT_RST      999            //-W 1            蓝牙重新初始化, 参数任意值均可

//压力表组使用的相关寄存器，初始通用参数
/********寄存器名称*******寄存器地址****读写和占用寄存器长度********注释************/
#define REG_PRESS_REFNAME       1000        //RW 4            冷媒名称，冷媒统一使用名称，便于动态处理
#define REG_PRESS_LOW           1004        //R- 1            低压压力，单位psi
#define REG_PRESS_T_L           1005        //R- 1            低压侧温度，默认单位C
#define REG_PRESS_T_EV           1006        //R- 1            低压侧温度，默认单位C
#define REG_PRESS_HIGH           1007        //R- 1            高压压力，单位psi
#define REG_PRESS_T_H           1008        //R- 1            高压侧温度，默认单位C
#define REG_PRESS_T_CO           1009        //R- 1            高压侧温度，默认单位C
#define REG_PRESS_T_MOT           1010        //R- 1            压缩机温度，默认单位C
#define REG_PRESS_L_UP           1011        //RW 1            低压压力警告上限
#define REG_PRESS_L_DOWN           1012        //RW 1            低压压力警告下限
#define REG_PRESS_H_UP           1013        //RW 1            高压压力警告上限
#define REG_PRESS_H_DOWN           1014        //RW 1            高压压力警告下限
#define REG_PRESS_LH_EN           1015        //RW 1            高低压力警告使能，0 关闭，非0 打开
#define REG_PRESS_CW_MODE           1016        //RW 1            制冷制热模式设置
#define REG_PRESS_CW_NOW           1017       //R- 1            当前的制冷制热模式 0：制冷，1：制热，2：自动

//压力表组使用的相关寄存器，保压相关参数
/********寄存器名称*******寄存器地址****读写和占用寄存器长度********注释************/
#define REG_PRESS_B_TCOMP       1050        //RW 1            保压补偿开关
#define REG_PRESS_B_LEAK        1051        //RW 1            保压衰变比例 0-50 表示 0.0%-5.0%
#define REG_PRESS_B_PERIOD      1052        //R- 2            保压设定进行的时间秒数
#define REG_PRESS_B_TARGET      1054        //R- 1            保压设定的目标值
#define REG_PRESS_B_START       1055        //R- 1            保压开始压力值
#define REG_PRESS_B_S_UTC       1056        //R- 2            保压开始时间值
#define REG_PRESS_B_K_SEC       1058        //R- 2            保压开始后经过的秒数



#define REG_PRESS_V_TARGET      1102        //RW 2            真空抽气目标值
#define REG_PRESS_V_LEAK        1104        //RW 2            真空抽气泄露值
#define REG_PRESS_V_L_MIN       1106        //RW 1            真空泄漏测试时间（单位分钟）
#define REG_PRESS_V_H2O_MODE    1110        //RW 1            水饱和温度显示模式


//冷媒秤
#define REG_LMC_WEIGHT          3000        //R-  2          重量值
#define REG_LMC_TAREWEIGHT      3002        //R-  2          皮重值
#define REG_LMC_AD_STATE        3004        //R-  1          秤体AD状态
#define REG_LMC_WORK_STATE      3005        //R-  1          秤体工作状态
//控制类参数
#define REG_LMC_ECON            3006        //RW  1          控制电磁阀开启、关闭
//加注指令
#define REG_LMC_ADD_WARN_VALUE  3007        //RW  1          加注预警值(0-100%,5 -- 已加注值到达加注设置值的5%的时候进行预警提示，默认95%)
#define REG_LMC_ADD_SET_VALUE   3008        //RW  2          加注设置值
#define REG_LMC_ADDD_CMD        3010        //RW  1          加注开始/暂停/继续/结束
#define REG_LMC_ADD_RUN_VALUE   3011        //R-  2          已加注值
//回收指令
#define REG_LMC_DEC_WARN_VALUE  3013        //RW  1          回收预警值(0-100%,5 -- 已回收值到达回收设置值的5%的时候进行预警提示，默认95%)
#define REG_LMC_DEC_SET_VALUE   3014        //RW  2          回收设置值
#define REG_LMC_DEC_CMD         3016        //RW  1          回收开始/暂停/继续/结束
#define REG_LMC_DEC_RUN_VALUE   3017        //R-  2          已回收值



//温度计 2023.8.29 需更改  温度上下限值的类型更改给32位，占2个寄存器
#define REG_TEMP_CH1_UP                       4000        //RW 2            通道1警告上限
#define REG_TEMP_CH1_DOWN                     4002        //RW 2            通道1警告下限
#define REG_TEMP_CH2_UP                       4004        //RW 2            通道2警告上限
#define REG_TEMP_CH2_DOWN                     4006        //RW 2            通道2警告下限
#define REG_TEMP_CH12_ALARM_EN           4008        //RW 1            通道1，2警告使能，0 关闭，非0 打开

#define REG_TEMP_TCOMP                           4009        //RW 2          温度补偿开关,0关闭，非0开启，（关闭需手动增加环境温度值）
#define REG_ICT_FUN_KEY                            4011        //-W    1      该寄存器写入基于序列号的计算的KEY值后(序列号字符串部分计算测CRC值)，才可以进行功能设置
#define REG_ICT_FUN_ENB                            4012        //RW    1        功能设置值
#define REG_ICT_MaxINIT_CH1                    4013      //RW    1      通道1复位最值
#define REG_ICT_MaxINIT_CH2                   4014        //RW    1      通道2复位最值
#define REG_ICT_probeType                   4015        //RW    1      热电偶类型


//ipt温度计
#define REG_TEMP_T_I_UP                   5009        //RW    1      内置温上限
#define REG_TEMP_T_I_DOWN                   5010        //RW    1     内置温下限
#define REG_TEMP_H_I_UP                   5011        //RW    1      内置湿上限
#define REG_TEMP_H_I_DOWN                   5012        //RW    1      内置湿度下限
#define REG_TEMP_T_E_UP                   5013        //RW    1      外置温度上限
#define REG_TEMP_T_E_DOWN                   5014        //RW    1      外置温度下限
#define REG_TEMP_SCENES                   5015        //RW    1      场景
#define REG_TEMP_ALARM_SOUNDS             5016        //RW     1     设备告警声音开关
#define REG_TEMP_DIS_TIME                   5017        //RW    1      时间显示12小时24小时切换   0x0001: 12小时 0x0002: 24小时
#define REG_HUM_RANGE_DOWN           5019        //RW     1     湿度范围
#define REG_HUM_RANGE_UP             5020        //RW     1     湿度范围


//联网伴侣 IMG_LINK
static int KEY_REG_COMM_NET_SERVER = 6000;            //RW 32  联网设备服务器地址
static int KEY_REG_COMM_NET_PORT = 6032;              //RW 1    联网设备服务器端口
static int KEY_REG_COMM_NET_SECRET = 6033;            //RW 16  联网设备连接一机一密秘钥
static int KEY_REG_COMM_NET_DATAUP = 6098;            //RW 2   数据采集与上报间隔
static int KEY_REG_COMM_NET_4GAPN = 6100;             //RW 32  蜂窝网络设备APN值


//ipt01
#define REG_TEMP_LI_OPEN                   20001        //RW    1      开关
#define REG_TEMP_LI_UP                   20002        //RW    1      内置温上限
#define REG_TEMP_LI_DOWN                   20003        //RW    1     内置温下限
#define REG_COMM_ICE_WATER                   20004        //-W    1     进入冰水混合物标定

//pt-500/800 new
#define REG_PRESS_TYPE    20000        //-W 1            压力类型

#define REG_DMG_FUN_KEY    20000        //-W 1            序列号crc
#define REG_DMG_FUN_ENB    20001        //RW 1            购买的功能

//svp泵
#define REG_SVP_KEEP_VACC    2018       //RW 1            保持真空值

#define REG_PROBE_ADDRL     20010        //RW 1   低压温度夹编号，1-65536，0未配置
#define REG_PROBE_ADDRH      20011        //RW 1   高压温度夹编号，1-65536，0未配置


@interface ETPacketObj : NSObject

@property (nonatomic,assign) BOOL packetComplete;//包是否完整,判断是否是有效包

@property (nonatomic) NSData *address1;
@property (nonatomic) NSData *address2;
@property (nonatomic,assign) ETFuncCodeType funcCode;
@property (nonatomic,assign) NSInteger subFuncCode;//可能没有,有些功能有有些没有
@property (nonatomic) NSData *data;

@end

@interface ETNewProtocol : NSObject

- (NSData *)packageDataWithAddress:(NSData *)address Func:(ETFuncCodeType)funcType andData:(NSData *)data;
- (NSData *)img_packageDataWithAddress:(NSData *)address Func:(ETFuncCodeType)funcType mac:(NSData *)mac andData:(NSData *)data;
- (ETPacketObj *)parseData:(NSData *)data;
- (NSArray <ETPacketObj *> *)parseMoreData:(NSData *)data;
@end



////////////////////////////////////
//MARK:svp
@interface ETNewProtocol (SVP)
- (NSData *)svp_packageDataWithAddress:(NSData *)address Func:(ETFuncCodeType)funcType andData:(NSData *)data;
- (ETPacketObj *)svp_parseData:(NSData *)data;
@end






NS_ASSUME_NONNULL_END
