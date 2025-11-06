//
//  ElitechToolDevice.m
//  ElitechToolDemo
//
//  Created by wuwu on 2025/9/11.
//

#import "ElitechToolDevice.h"
#import "ETNewProtocolWorker.h"
#import "NSData+Util.h"
#import "ETTimerTool.h"
#import "UnitTool.h"
#import "ETVgwRtObj.h"
#import "DeviceTypeDefine.h"
#import "NSObject+Utils.h"

@import CoreBluetooth;

static NSString *const hostPort = @"http://test.icoldcloud.com:10023";

@interface ElitechToolDevice()<NSURLSessionDownloadDelegate>

@property (nonatomic,strong) ETNewProtocolWorker *worker;
@property (nonatomic,strong) CBPeripheral *peripheral;

@property (nonatomic,strong) NSMutableData *allRecord;
@property (nonatomic) NSUInteger refreshInterval;
@property (nonatomic) ETTimerTool *timerTool;
@property (nonatomic,strong) ETVgwRtObj *realTimeObj;

@property (nonatomic,strong) void(^clockCallBack)(BOOL);
//@property (nonatomic,strong) void(^rtIntervalCallBack)(BOOL);
@property (nonatomic,strong) void(^clearCallBack)(BOOL);
@property (nonatomic,strong) void(^recordEnableCallBack)(BOOL);
@property (nonatomic,strong) void(^recordIntervalCallBack)(BOOL);
@property (nonatomic,strong) void(^recordResultCallBack)(float progress,NSError *err,NSArray *records);
@property (nonatomic,strong) void(^rtDataCallBack)(ETVgwRtObj *);


@property (nonatomic,strong) void(^vUnitCallBack)(BOOL);
@property (nonatomic,strong) void(^tUnitCallBack)(BOOL);

@property (nonatomic,strong) void(^verCallBack)(NSString *swv,NSString *remoteCode);
@property (nonatomic,strong) void(^checkUpdateCallback)(BOOL canUpdate,NSString *version,NSString *description);
@property (nonatomic,strong) void(^updateCallBack)(BOOL isDownloaded,float updateProgress,NSError *err);


@property (nonatomic,copy) NSString *remoteCode;
@property (nonatomic,copy) NSString *swv;
@property (nonatomic,strong) NSData *appData;// 服务器下载的软件包

@end
@implementation ElitechToolDevice
{
    NSURLSession *_downloadSession;
}


- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
{
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
        __weak typeof (self) weakSelf = self;
        [self setClockWithResult:^(BOOL res) {
            if (res) {
                [weakSelf setRecordInterval:5 result:^(BOOL res) {
                    if (res) {
                        
                    }
                }];
            }
        }];
        
    }
    return self;
}


#pragma mark - open

+ (BOOL)checkVgwMini:(NSDictionary *)advertisementData
{
    NSData *manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey];
    if (manufacturerData == nil || manufacturerData.length <2) {
        return false;
    }
    
    NSData *deviceMode = [manufacturerData subdataWithRange:NSMakeRange(0, 2)];
    UInt16 type = [NSData dataToUnsignedShort:deviceMode];
    if (type == 0x0007) {
        return YES;
    }
    
    return NO;
}

- (void)setClockWithResult:(void(^)(BOOL res))result
{
    //4字节：时间戳  ，2字节的偏移（8时区：8*60)
    UInt32 timeInterval = [[NSDate date] timeIntervalSince1970];
    timeInterval = NSSwapHostIntToBig(timeInterval);
    NSInteger sec = NSTimeZone.systemTimeZone.secondsFromGMT;
    SInt16 min = sec / 60;
    min = NSSwapHostShortToBig(min);
    
    NSMutableData *content = [NSMutableData data];
    [content appendBytes:&timeInterval length:sizeof(timeInterval)];
    [content appendBytes:&min length:sizeof(min)];
    
    NSData *data = [self.worker setClockData:content];
    
    self.clockCallBack = result;
    BOOL res = [self write:self.peripheral value:data];
    if (!res)
    {
        result(NO);
    }
}

//- (void)setRTInterval:(NSUInteger)interval result:(void(^)(BOOL res))result
//{
//    //设置实时数据间隔，会收到响应后自动发来实时数据
//    NSData *data = [self.worker realTimeDataWithInterval:interval];
//    self.rtIntervalCallBack = result;
//    BOOL res = [self write:self.peripheral value:data];
//    if (!res)
//    {
//        result(NO);
//    }
//}

- (void)clearRecordWithResult:(void(^)(BOOL res))result
{
    NSData *data = [self.worker setDataWithSubFunc:REG_COMM_REC_CLEAR andContent:0];
    self.clearCallBack = result;
    BOOL res = [self write:self.peripheral value:data];
    if (!res)
    {
        result(NO);
    }
}

- (void)setRecordEnable:(BOOL)enable result:(void(^)(BOOL res))result
{
    NSData *data = [self.worker setDataWithSubFunc:REG_COMM_REC_EN andContent:enable];
    self.recordEnableCallBack = result;
    BOOL res = [self write:self.peripheral value:data];
    if (!res)
    {
        result(NO);
    }
}

- (void)setRecordInterval:(NSInteger)interval result:(void(^)(BOOL res))result
{
    NSData *data = [self.worker setDataWithSubFunc:REG_COMM_REC_TIME andContent:interval];
    self.recordIntervalCallBack = result;
    BOOL res = [self write:self.peripheral value:data];
    if (!res)
    {
        result(NO);
    }
}

- (void)setVacuumUnit:(NSInteger)unit result:(void(^)(BOOL res))result
{
    NSData *data = [self.worker setDataWithSubFunc:REG_COMM_U_VACCUM andContent:unit];
    self.vUnitCallBack = result;
    BOOL res = [self write:self.peripheral value:data];
    if (!res)
    {
        result(NO);
    }
}
- (void)setTemperatureUnit:(NSInteger)unit result:(void(^)(BOOL res))result
{
    NSData *data = [self.worker setDataWithSubFunc:REG_COMM_U_TEMP andContent:unit];
    self.tUnitCallBack = result;
    BOOL res = [self write:self.peripheral value:data];
    if (!res)
    {
        result(NO);
    }
}


- (void)startVacuumingWithResult:(void(^)(BOOL res))result
{
    __weak typeof (self) weakSelf = self;
    [self clearRecordWithResult:^(BOOL res) {
        if (res)
        {
            [weakSelf setRecordEnable:YES result:result];
        }
        else
        {
            result(res);
        }
    }];
}

- (void)endVacuumingWithResult:(void(^)(BOOL res))result
{
    [self setRecordEnable:NO result:result];
}

- (void)readRecordWithResult:(void(^)(float progress,NSError *_Nullable err,NSArray<NSDictionary<NSString*,NSString*> *> *records))result
{
    
    UInt16 con = 0;
    con = NSSwapHostShortToBig(con);
    NSData *data = [self.worker setReadHistoryDataWithFunc:1 andContent:[NSData dataWithBytes:&con length:sizeof(con)]];
    
    self.recordResultCallBack = result;
    BOOL res = [self write:self.peripheral value:data];
    if (!res)
    {
        NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"外设未连接"}];
        self.recordResultCallBack(0, err, @[]);
        self.recordResultCallBack = nil;
        return;
    }
}


- (void)swallowData:(NSData *)data from:(CBPeripheral *)peripheral
{
    if (![peripheral.identifier.UUIDString isEqualToString:self.peripheral.identifier.UUIDString])
    {
        return;
    }
    
    NSArray<ETPacketObj *> *modelList = [self.worker parseMoreData:data];
    for (ETPacketObj *model in modelList) {
        if (model.funcCode == ETFuncCodeType03) {
            if (model.subFuncCode == REG_COMM_RTC_TIME) {//收到设置时钟响应
                if (self.clockCallBack) {
                    self.clockCallBack(YES);
                    self.clockCallBack = nil;
                }
            }
        }
        else if (model.funcCode == ETFuncCodeType07)
        {
            
            NSData *stData = model.data;
            UInt8 code = [NSData dataToUnsignedChar:[stData subdataWithRange:NSMakeRange(0, 1)]];
            
            switch (code) {
                case 0x02://收到版本信息
                {
                    
                    UInt16 code = [NSData dataToUnsignedShort:[stData subdataWithRange:NSMakeRange(1, 2)]];
                    NSData *info = [stData subdataWithRange:NSMakeRange(3, stData.length - 3)];
                    NSString *a = [[NSString alloc] initWithData:info encoding:NSUTF8StringEncoding];
                    NSArray *arr = [a componentsSeparatedByString:@"#"];
                    
                    if (arr.count >= 3) {
                        NSString *softwareVer = arr[2];
                        softwareVer = [softwareVer substringFromIndex:3];
                        if (self.verCallBack)
                        {
                            self.verCallBack(softwareVer,[NSString stringWithFormat:@"%d",code]);
                        }
                    }
                }
                    break;
                case 0x04://收到请求更新包数据
                {
                    UInt32 serial = [NSData dataToUnsignedInt:[stData subdataWithRange:NSMakeRange(1, 4)]];
                    UInt16 size = [NSData dataToUnsignedShort:[stData subdataWithRange:NSMakeRange(5, 2)]];
                    
                    
                    NSData *sData = [self.appData subdataWithRange:NSMakeRange(serial,size)];
                    [self sendUpdateDataWithSerial:[stData subdataWithRange:NSMakeRange(1, 6)] pakCon:sData];
                    
                    float progress = serial / (float)self.appData.length;
                    if (self.updateCallBack) {
                        self.updateCallBack(YES, progress * 100, nil);
                    }
                }
                    break;
                case 0x06://升级结束
                {
                    UInt8 result = [NSData dataToUnsignedChar:[stData subdataWithRange:NSMakeRange(1, 1)]];
                    
                    if (result == 1) {
                        if (self.updateCallBack) {
                            self.updateCallBack(YES, 100, nil);
                        }
                    }
                    else
                    {
                        NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:2002 userInfo:@{NSLocalizedDescriptionKey:@"软件升级失败"}];
                        if (self.updateCallBack) {
                            self.updateCallBack(YES, 100, err);
                        }
                    }
                    
                }
                    break;
                    
                default:
                    break;
            }
            
        }
        else if (model.funcCode == ETFuncCodeType01)
        {
            if (model.subFuncCode == REG_COMM_AUTO_REP) {
//                if (self.rtIntervalCallBack)
//                {
//                    self.rtIntervalCallBack(YES);
//                }
            }
            else if (model.subFuncCode == REG_COMM_REC_EN)
            {
                if (self.recordEnableCallBack)
                {
                    self.recordEnableCallBack(YES);
                }
            }
            else if (model.subFuncCode == REG_COMM_REC_TIME)
            {
                if (self.recordIntervalCallBack)
                {
                    self.recordIntervalCallBack(YES);
                }
            }
            else if (model.subFuncCode == REG_COMM_REC_CLEAR)
            {
                if (self.clearCallBack)
                {
                    self.clearCallBack(YES);
                }
            }
            else if (model.subFuncCode == REG_COMM_U_VACCUM)
            {
                if (self.vUnitCallBack)
                {
                    self.vUnitCallBack(YES);
                }
            }
            else if (model.subFuncCode == REG_COMM_U_TEMP)
            {
                if (self.tUnitCallBack)
                {
                    self.tUnitCallBack(YES);
                }
            }
        }
        else if (model.funcCode == ETFuncCodeType06) //收到历史数据
        {
            NSData *stData = model.data;
            [self handleHistory:[stData subdataWithRange:NSMakeRange(1, stData.length - 1)]];
        }
        else if (model.funcCode == ETFuncCodeType04) //收到实时数据
        {
            NSData *rtData = model.data;
            UInt32 vaccum = [NSData dataToUnsignedInt:[rtData subdataWithRange:NSMakeRange(0, 4)]];
            SInt16 t_pcb = [NSData dataToShort:[rtData subdataWithRange:NSMakeRange(4, 2)]];
            SInt16 t_h20 = [NSData dataToShort:[rtData subdataWithRange:NSMakeRange(6, 2)]];
            UInt16 vUnit = [NSData dataToUnsignedShort:[rtData subdataWithRange:NSMakeRange(8, 2)]];
            UInt16 tUnit = [NSData dataToUnsignedShort:[rtData subdataWithRange:NSMakeRange(10, 2)]];
            UInt16 recordStatus = [NSData dataToUnsignedShort:[rtData subdataWithRange:NSMakeRange(12, 2)]];
            UInt16 recordInterval = [NSData dataToUnsignedShort:[rtData subdataWithRange:NSMakeRange(14, 2)]];
            UInt16 displayMode = [NSData dataToUnsignedShort:[rtData subdataWithRange:NSMakeRange(16, 2)]];
            UInt16 powerLevel = [NSData dataToUnsignedShort:[rtData subdataWithRange:NSMakeRange(18, 2)]];
            
            NSString *vunitStr = [ETNewProtocolWorker vUnitFrom:vUnit];
            NSString *tunitStr = [ETNewProtocolWorker tUnitFrom:tUnit];
            
            if (!_realTimeObj) {
                _realTimeObj = [[ETVgwRtObj alloc] init];
            }
            if (vaccum >= VAC_ARG_NONE) {
                _realTimeObj.vaccum = @"-1000";
            }
            else
            {
                float vv = vaccum;
                vv = [UnitTool calVaccum:vaccum newVacUnit:vunitStr];
                
                NSUInteger decimals = [UnitTool getDecimalNumForVGWMiniByUnit:vunitStr];
                
                NSString *format = [NSString stringWithFormat:@"%%.%luf",(unsigned long)decimals];
                
                _realTimeObj.vaccum = [NSString stringWithFormat:format,vv];
            }
            
            if (t_pcb < TEMP_ARG_NONE && t_h20 < TEMP_ARG_NONE) {
                float s_pcb = t_pcb * 0.1;
                float s_h2o = t_h20 * 0.1;
                s_pcb = [UnitTool temperatureChangeWithOldValue:s_pcb oldUnit:nil aimUnit:tunitStr];
                s_h2o = [UnitTool temperatureChangeWithOldValue:s_h2o oldUnit:nil aimUnit:tunitStr];
                _realTimeObj.tamb = [NSString stringWithFormat:@"%.1f",s_pcb];
                _realTimeObj.th2o = [NSString stringWithFormat:@"%.1f",s_h2o];
                _realTimeObj.dtT = [NSString stringWithFormat:@"%.1f",s_pcb - s_h2o];
            }
            else if (t_pcb < TEMP_ARG_NONE)
            {
                float s_pcb = t_pcb * 0.1;
                s_pcb = [UnitTool temperatureChangeWithOldValue:s_pcb oldUnit:nil aimUnit:tunitStr];
                _realTimeObj.tamb = [NSString stringWithFormat:@"%.1f",s_pcb];
                _realTimeObj.th2o = @"-1000";
                _realTimeObj.dtT = @"-1000";
            }
            else if (t_h20 < TEMP_ARG_NONE)
            {
                float s_h2o = t_h20 * 0.1;
                s_h2o = [UnitTool temperatureChangeWithOldValue:s_h2o oldUnit:nil aimUnit:tunitStr];
                _realTimeObj.tamb = @"-1000";
                _realTimeObj.th2o = [NSString stringWithFormat:@"%.1f",s_h2o];
                _realTimeObj.dtT = @"-1000";
            }
            else
            {
                _realTimeObj.tamb = @"-1000";
                _realTimeObj.th2o = @"-1000";
                _realTimeObj.dtT = @"-1000";
            }
            
            
            _realTimeObj.vacUnit = vunitStr;
            _realTimeObj.temUnit = tunitStr;
            _realTimeObj.recordStatus = recordStatus;
            _realTimeObj.recordInterval = recordInterval;
            _realTimeObj.displayMode = displayMode;
            _realTimeObj.power = powerLevel;
            
            
        }
    }
}

- (void)receiveRtDataWithInterval:(NSUInteger)interval rtData:(void(^)(ETVgwRtObj *))rtData
{
    self.refreshInterval = interval;
    self.rtDataCallBack = rtData;
    
    if (!_timerTool) {
        _timerTool = [[ETTimerTool alloc] initWithRefreshInterval:interval];
        __weak typeof (self) weakSelf = self;
        [_timerTool startCountDown:^{
            if (weakSelf.rtDataCallBack) {
                weakSelf.rtDataCallBack(weakSelf.realTimeObj);
            }
        }];
    }
}

- (void)getDeviceVersion:(void(^)(NSString *swv,NSString *remoteCode))result
{
    NSData *data = [self.worker setUpdateDataWithFunc:1 andContent:nil];
    self.verCallBack = result;
    BOOL res = [self write:self.peripheral value:data];
    if (!res)
    {
        result(nil,nil);
    }
}

- (void)checkForUpdate:(void(^)(BOOL canUpdate,NSString *version,NSString *description))result
{
    self.checkUpdateCallback = result;
    
    [self getDeviceVersion:^(NSString * _Nullable swv, NSString * _Nullable remoteCode) {
        if (swv)
        {
            self.swv = swv;
            self.remoteCode = remoteCode;
            [self reqSoftversion:self.remoteCode andSoftversion:self.swv];
        }
        else
        {
            result(NO,nil,nil);
        }
    }];
    
}

- (void)updateSoftware:(void(^)(BOOL isDownloaded,float updateProgress,NSError *_Nullable err))result
{
    if (self.remoteCode.length > 0 && self.swv.length > 0) {
        self.updateCallBack = result;
        
        [self ota_downloadHardware:self.remoteCode andSoftversion:self.swv];
        
    }
    else
    {
        NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:2001 userInfo:@{NSLocalizedDescriptionKey:@"请先调用检查更新"}];
        self.updateCallBack(NO, 0, err);
    }
    
}

- (void)sendStartUpdateCmd:(unsigned int)filesize
{
    unsigned int fs = NSSwapHostIntToBig(filesize);
    NSData *d = [NSData dataWithBytes:&fs length:sizeof(fs)];
    
    NSData *data = [self.worker setUpdateDataWithFunc:3 andContent:d];
    
    BOOL res = [self write:self.peripheral value:data];
    if (!res)
    {
        NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"外设未连接"}];
        if (self.updateCallBack) {
            self.updateCallBack(NO, 0, err);
        }
    }
}

- (void)sendUpdateDataWithSerial:(NSData *)serialData pakCon:(NSData *)content
{
    NSMutableData *d = [NSMutableData dataWithCapacity:0];
    [d appendData:serialData];
    [d appendData:content];
    
    NSData *data = [self.worker setUpdateDataWithFunc:5 andContent:d];
    BOOL res = [self write:self.peripheral value:data];
    if (!res)
    {
        NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"外设未连接"}];
        if (self.updateCallBack) {
            self.updateCallBack(NO, 0, err);
        }
    }
}

#pragma mark - private

- (void)reqSoftversion:(NSString *)deviceTypeCode andSoftversion:(NSString *)softversion
{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/api/device/DeviceSoftwareVersion/deviceType?deviceTypeCode=%@",hostPort,deviceTypeCode];
    // 创建 NSURL 对象
    NSURL *url = [NSURL URLWithString:urlStr];

    // 创建 NSURLSession
    NSURLSession *session = [NSURLSession sharedSession];

    // 创建数据任务
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            self.checkUpdateCallback(NO, nil, nil);
            return;
        }
        
        // 解析返回的数据
        if (data) {
            NSError *jsonError;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError) {
//                NSLog(@"响应数据: %@", jsonDict);
                
                NSDictionary *item = jsonDict[@"data"];
                if ([item notEmpty])
                {
                    NSString *lastVer = [NSObject fmtNotNullString:item[@"latestVersionValue"] defaultString:@""];
                    NSString *ver;
                    if ([softversion containsString:@"."]) {
                        NSArray *arr = [softversion componentsSeparatedByString:@"."];
                        ver = [NSString stringWithFormat:@"%@%@",arr.firstObject,arr.lastObject];
                    }
                    else
                    {
                        ver = softversion;
                    }
                    
                    if ([lastVer integerValue] > [ver integerValue])
                    {
                        if (self.checkUpdateCallback)
                        {
                            self.checkUpdateCallback(YES, [NSObject fmtNotNullString:item[@"latestVersionLabel"] defaultString:@""], [NSObject fmtNotNullString:item[@"versionDescrip"] defaultString:@""]);
                        }
                    }
                    else
                    {
                        self.checkUpdateCallback(NO, nil, nil);
                    }
                }
                else
                {
                    self.checkUpdateCallback(NO, nil, nil);
                }
            } else {
                self.checkUpdateCallback(NO, nil, nil);
            }
        }
    }];

    // 启动任务
    [dataTask resume];
}

- (void)ota_downloadHardware:(NSString *)deviceTypeCode andSoftversion:(NSString *)softversion
{
    
    if (self.updateCallBack) {
        self.updateCallBack(YES, 0, nil);
    }
    NSString *ver;
    if ([softversion containsString:@"."]) {
        NSArray *arr = [softversion componentsSeparatedByString:@"."];
        ver = [NSString stringWithFormat:@"%@%@",arr.firstObject,arr.lastObject];
    }
    else
    {
        ver = softversion;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/api/device/DeviceSoftwareVersion/getSoftwareFileByTypeCode?deviceTypeCode=%@&version=%@",hostPort,deviceTypeCode,ver];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _downloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSURLSessionDownloadTask *task = [_downloadSession downloadTaskWithRequest:request];
    [task resume];
}

- (BOOL)write:(CBPeripheral *)peripheral value:(NSData *)data
{
    
    if (peripheral.state == CBPeripheralStateConnected) {
        
        CBService * service;
        CBCharacteristic  * charact;
        service = [self getService:vgwMini_serviceUUID fromPeripheral:peripheral];
        charact = [self getCharacteristic:vgwMini_sendCharacteristicsUUID fromService:service];

        [peripheral writeValue:data forCharacteristic:charact type:CBCharacteristicWriteWithResponse];
        return YES;
    }
    else
    {
        return NO;
    }
    
}

- (void)handleHistory:(NSData *)data
{
//    if (self.hasCancleAction) {
//        self.hasCancleAction = NO;
//        
//        _allRecord = nil;
//        [self.readRecordList removeAllObjects];
//        return;
//    }
    
    UInt32 totalPoint = [NSData dataToUnsignedInt:[data subdataWithRange:NSMakeRange(0, 4)]];
    if (totalPoint == 0)
    {
        //提示数据为空
//        [QMUITips showError:@"暂无数据".localizedString];
        
        if (self.recordResultCallBack)
        {
            self.recordResultCallBack(1, nil, @[]);
            self.recordResultCallBack = nil;
        }
        
        return;
    }
    
    UInt32 offset = [NSData dataToUnsignedInt:[data subdataWithRange:NSMakeRange(4, 4)]];
    UInt16 numOfPoint = [NSData dataToUnsignedShort:[data subdataWithRange:NSMakeRange(8, 2)]];
    UInt16 pointLen = [NSData dataToUnsignedShort:[data subdataWithRange:NSMakeRange(10, 2)]];
    
    [self.allRecord appendData:[data subdataWithRange:NSMakeRange(12, data.length - 12)]];
    
    //回复
    UInt8 ser = 03;
    NSMutableData *replyData = [NSMutableData data];
    [replyData appendBytes:&ser length:sizeof(ser)];
    [replyData appendData:[data subdataWithRange:NSMakeRange(0, 12)]];
    NSData *d = [self.worker packageDataWithFunc:ETFuncCodeType06 andData:replyData];
    BOOL res = [self write:self.peripheral value:d];
    if (!res)
    {
        NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"外设未连接"}];
        self.recordResultCallBack(0, err, @[]);
        self.recordResultCallBack = nil;
        return;
    }
    
    
    if (self.allRecord.length >= totalPoint * pointLen) {
        
        
        NSMutableArray *records = [NSMutableArray array];
        
        NSUInteger count = self.allRecord.length / pointLen;//条数
        NSData *vd = self.allRecord;
        for (NSUInteger i = 0; i < count; i ++) {
            UInt32 timestamp;
            UInt32 vacuum;
            SInt16 TH2O,Tamb;
            NSUInteger location = i * pointLen;
            [vd getBytes:&timestamp range:NSMakeRange(location, 4)];
            [vd getBytes:&vacuum range:NSMakeRange(location + 4, 4)];
            [vd getBytes:&TH2O range:NSMakeRange(location + 8, 2)];
            [vd getBytes:&Tamb range:NSMakeRange(location + 10, 2)];
            
            timestamp = NSSwapBigIntToHost(timestamp);
            vacuum = NSSwapBigIntToHost(vacuum);
            TH2O = NSSwapBigShortToHost(TH2O);
            Tamb = NSSwapBigShortToHost(Tamb);
            
            NSString *vacStr = @"";
            if (vacuum >= VAC_ARG_NONE) {
                vacStr = @"-1000";
            }
            else
            {
                vacStr = [NSString stringWithFormat:@"%u",(UInt32)vacuum];
            }
            
            NSString *TH2OStr = @"";
            if (TH2O >= TEMP_ARG_NONE) {
                TH2OStr = @"-1000";
            }
            else
            {
                TH2OStr = [NSString stringWithFormat:@"%.1f",TH2O * 0.1];
            }
            
            NSString *TambStr = @"";
            if (Tamb >= TEMP_ARG_NONE) {
                TambStr = @"-1000";
            }
            else
            {
                TambStr = [NSString stringWithFormat:@"%.1f",Tamb * 0.1];
            }
            
            //读出的数据默认单位microns,℃,温度数值需要除以10为原值
            [records addObject:@{@"timestamp":[NSString stringWithFormat:@"%@",@(timestamp)],@"vacuum":vacStr,@"TH2O":TH2OStr,@"Tamb":TambStr}];
        }
        
        _allRecord = nil;
        if (self.recordResultCallBack)
        {
            self.recordResultCallBack(100, nil, records);
        }
        
    }
    else
    {
        float p = self.allRecord.length / (float)(totalPoint * pointLen);
        if (self.recordResultCallBack)
        {
            self.recordResultCallBack(p * 100, nil, nil);
        }
    }
    
}

//获取服务
-(CBService *)getService:(NSString *)serviceID fromPeripheral:(CBPeripheral *)peripheral
{
    CBUUID *uuid = [CBUUID UUIDWithString:serviceID];
    for (NSUInteger i=0; i<peripheral.services.count; i++) {
        CBService *service = [peripheral.services objectAtIndex:i];
        if ([service.UUID isEqual:uuid]) {
            return service;
        }
    }
    return nil;
}
//获取特征值
-(CBCharacteristic *)getCharacteristic:(NSString *)characteristicID fromService:(CBService *)service
{
    CBUUID *uuid = [CBUUID UUIDWithString:characteristicID];
    for (NSUInteger i=0; i<service.characteristics.count; i++) {
        CBCharacteristic *characteristic = [service.characteristics objectAtIndex:i];
        if ([characteristic.UUID isEqual:uuid]) {
            return characteristic;
        }
    }
    return nil;
}

#pragma mark - NSURLSessionDownloadDelegate

//// 下载进度回调
//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
//    // 计算进度
//    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
//    NSLog(@"下载进度: %lld==%lld==%lld", bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
//    
//    if (self.updateCallBack) {
//        self.updateCallBack(progress * 100, 0, nil);
//    }
//}

// 下载完成回调
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    // 下载完成，文件被保存在临时位置 location
    
    self.appData = [NSData dataWithContentsOfURL:location];
    
}

// 任务完成回调（无论成功还是失败）
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        self.appData = nil;
        NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:2000 userInfo:@{NSLocalizedDescriptionKey:@"下载升级包出错"}];
        if (self.updateCallBack) {
            self.updateCallBack(NO, 0, err);
        }
    } else {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode =  httpResponse.statusCode;
        
        if (statusCode == 200) {
            if ([httpResponse.MIMEType containsString:@"json"]) {
                self.appData = nil;
                NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:2000 userInfo:@{NSLocalizedDescriptionKey:@"下载升级包出错"}];
                if (self.updateCallBack) {
                    self.updateCallBack(NO, 0, err);
                }
                return;
            }
            
            if (self.updateCallBack) {
                self.updateCallBack(YES, 0, nil);
            }
            
            [self sendStartUpdateCmd:(unsigned int)self.appData.length];
            
        }
        else
        {
            self.appData = nil;
            NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:2000 userInfo:@{NSLocalizedDescriptionKey:@"下载升级包出错"}];
            if (self.updateCallBack) {
                self.updateCallBack(NO, 0, err);
            }
        }
    }
}

#pragma mark - getter

- (ETNewProtocolWorker *)worker
{
    if (!_worker) {
        NSData *data = [NSData hexToBytes:ETDeviceCodeVgwmini];
        _worker = [[ETNewProtocolWorker alloc] initWithModeCode:data];
    }
    return _worker;
}

- (NSMutableData *)allRecord
{
    if (!_allRecord) {
        _allRecord = [[NSMutableData alloc] init];
    }
    return _allRecord;
}

@end
