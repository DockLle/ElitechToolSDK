//
//  DeviceTypeDefine.h
//  ElitechTool
//
//  Created by wuwu on 2025/10/28.
//

#ifndef DeviceTypeDefine_h
#define DeviceTypeDefine_h

//以下信息主要供自行使用系统蓝牙框架而不使用ElitechManager类的时候去发现设备


//真空计类型码及类型名
FOUNDATION_EXTERN NSString * const ETDeviceCodeVgwmini;
FOUNDATION_EXTERN NSString * const ETDeviceTypeNameVgwmini;

//真空计 服务id 特征id
FOUNDATION_EXTERN NSString * const vgwMini_serviceUUID;
FOUNDATION_EXTERN NSString * const vgwMini_recvCharacteristicsUUID;
FOUNDATION_EXTERN NSString * const vgwMini_sendCharacteristicsUUID;

#endif /* DeviceTypeDefine_h */
