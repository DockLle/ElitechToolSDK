//
//  ETNewProtocol.m
//  ManifoldGauge
//
//  Created by mac on 2022/10/21.
//  Copyright © 2022 Reo. All rights reserved.
//

#import "ETNewProtocol.h"
#import "NSData+Util.h"

@implementation ETPacketObj

@end

@interface ETNewProtocol()

@property (nonatomic) NSMutableData *tempData;//用来处理被蓝牙分包的的数据

@end
@implementation ETNewProtocol

- (NSData *)packageDataWithAddress:(NSData *)address Func:(ETFuncCodeType)funcType andData:(NSData *)data
{
    Byte header[] = {0xAA,0x55};
    Byte footer[] = {0x0d,0x0a};
    Byte func[] = {funcType};
    
    
    UInt16 len = address.length + sizeof(func) + data.length + 8;
    len = NSSwapHostShortToBig(len);
    
    NSMutableData *v = [NSMutableData data];
    [v appendBytes:header length:sizeof(header)];
    [v appendBytes:&len length:sizeof(len)];
    [v appendData:address];
    [v appendBytes:func length:sizeof(func)];
    [v appendData:data];
    
    NSData *crc = [NSData getCrcVerifyCode:[v copy]];
    [v appendData:crc];
    
    [v appendBytes:footer length:sizeof(footer)];
    
    return v;
}

- (NSData *)img_packageDataWithAddress:(NSData *)address Func:(ETFuncCodeType)funcType mac:(NSData *)mac andData:(NSData *)data
{
    Byte header[] = {0xAA,0x55};
    Byte footer[] = {0x0d,0x0a};
    Byte func[] = {funcType};
    
    
    UInt16 len = address.length + sizeof(func) + data.length +mac.length + 8;
    len = NSSwapHostShortToBig(len);
    
    NSMutableData *v = [NSMutableData data];
    [v appendBytes:header length:sizeof(header)];
    [v appendBytes:&len length:sizeof(len)];
    [v appendData:address];
    [v appendBytes:func length:sizeof(func)];
    [v appendData:mac];
    [v appendData:data];
    
    NSData *crc = [NSData getCrcVerifyCode:[v copy]];
    [v appendData:crc];
    
    [v appendBytes:footer length:sizeof(footer)];
    
    return v;
}


- (ETPacketObj *)parseData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    
    Byte header[] = {0xaa,0x55};
    Byte footer[] = {0x0d,0x0a};
    NSData *aimH = [[NSData alloc] initWithBytes:header length:sizeof(header)];
    NSData *aimF = [[NSData alloc] initWithBytes:footer length:sizeof(footer)];
    
    if (data.length < 4) //头尾不全
    {
        return nil;
    }
    
    NSData *crc = [NSData getCrcVerifyCode:[data subdataWithRange:NSMakeRange(0, data.length - 4)]];
    if (![crc isEqualToData:[data subdataWithRange:NSMakeRange(data.length - 4, 2)]])
    {
        return nil;
    }
    
    BOOL hasHeader = [[data subdataWithRange:NSMakeRange(0, 2)] isEqualToData:aimH];
    BOOL hasFooter = [[data subdataWithRange:NSMakeRange(data.length - 2, 2)] isEqualToData:aimF];
    
    if (!(hasHeader && hasFooter)) return nil;
    
    
    
    UInt16 len = [NSData dataToUnsignedShort:[data subdataWithRange:NSMakeRange(2, 2)]];
    if (len != data.length) {
        return nil;
    }
    
    
//    NSData *dataHeader = [data subdataWithRange:NSMakeRange(0, 2)];
//    NSData *dataFooter = [data subdataWithRange:NSMakeRange(len - 2, 2)];
//
//    if (!([header isEqualToData:[NSData dataWithBytes:h length:sizeof(h)]] && [footer isEqualToData:[NSData dataWithBytes:f length:sizeof(f)]])) {
//        return nil;
//    }
    
    
    ETPacketObj *obj = [ETPacketObj new];
    obj.address1 = [data subdataWithRange:NSMakeRange(4, 2)];
    obj.address2 = [data subdataWithRange:NSMakeRange(6, 2)];
    obj.funcCode = [NSData dataToUnsignedChar:[data subdataWithRange:NSMakeRange(8, 1)]];
    obj.data = [data subdataWithRange:NSMakeRange(9, len - 5 - 8)];
    if (obj.data.length < 2)
    {
        return nil;
    }
    UInt16 subFuncCode = [NSData dataToUnsignedShort:[obj.data subdataWithRange:NSMakeRange(0, 2)]];
    obj.subFuncCode = subFuncCode;
    
    return obj;
}

- (NSArray <ETPacketObj *> *)parseMoreData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    
    Byte header[] = {0xaa,0x55};
    Byte footer[] = {0x0d,0x0a};
    NSData *aimH = [[NSData alloc] initWithBytes:header length:sizeof(header)];
    NSData *aimF = [[NSData alloc] initWithBytes:footer length:sizeof(footer)];
    
    if (data.length < 4) //头尾不全
    {
        return nil;
    }
    
    NSData *crc = [NSData getCrcVerifyCode:[data subdataWithRange:NSMakeRange(0, data.length - 4)]];
    if (![crc isEqualToData:[data subdataWithRange:NSMakeRange(data.length - 4, 2)]])
    {
        Byte bottom[] = {0x0d,0x0a,0xaa,0x55};
        NSData *aimB = [[NSData alloc] initWithBytes:bottom length:sizeof(bottom)];
        NSData *remainData = data;
        NSRange range = [remainData rangeOfData:aimB options:NSDataSearchBackwards range:NSMakeRange(0, remainData.length)];
        NSMutableArray *mList = [NSMutableArray array];
        while (range.location != NSNotFound) {
            NSData *suf = [data subdataWithRange:NSMakeRange(range.location + 2, remainData.length - range.location - 2)];
            ETPacketObj *obj = [self parseData:suf];
            remainData = [data subdataWithRange:NSMakeRange(0, range.location + 2)];
            range = [remainData rangeOfData:aimB options:NSDataSearchBackwards range:NSMakeRange(0, remainData.length)];
            if (obj) {
                [mList addObject:obj];
            }
            
        }
        
        if (remainData.length > 0) {
            ETPacketObj *obj = [self parseData:remainData];
            if (obj) {
                [mList addObject:obj];
            }
        }
        
        return mList;
    }
    
    BOOL hasHeader = [[data subdataWithRange:NSMakeRange(0, 2)] isEqualToData:aimH];
    BOOL hasFooter = [[data subdataWithRange:NSMakeRange(data.length - 2, 2)] isEqualToData:aimF];
    
    if (!(hasHeader && hasFooter)) return nil;
    
    
    
    UInt16 len = [NSData dataToUnsignedShort:[data subdataWithRange:NSMakeRange(2, 2)]];
    if (len != data.length) {
        return nil;
    }
    
    
//    NSData *dataHeader = [data subdataWithRange:NSMakeRange(0, 2)];
//    NSData *dataFooter = [data subdataWithRange:NSMakeRange(len - 2, 2)];
//
//    if (!([header isEqualToData:[NSData dataWithBytes:h length:sizeof(h)]] && [footer isEqualToData:[NSData dataWithBytes:f length:sizeof(f)]])) {
//        return nil;
//    }
    
    
    ETPacketObj *obj = [ETPacketObj new];
    obj.address1 = [data subdataWithRange:NSMakeRange(4, 2)];
    obj.address2 = [data subdataWithRange:NSMakeRange(6, 2)];
    obj.funcCode = [NSData dataToUnsignedChar:[data subdataWithRange:NSMakeRange(8, 1)]];
    obj.data = [data subdataWithRange:NSMakeRange(9, len - 5 - 8)];
    if (obj.data.length < 2)
    {
        return nil;
    }
    UInt16 subFuncCode = [NSData dataToUnsignedShort:[obj.data subdataWithRange:NSMakeRange(0, 2)]];
    obj.subFuncCode = subFuncCode;
    
    return @[obj];
}

- (NSMutableData *)tempData
{
    if (!_tempData)
    {
        _tempData = [[NSMutableData alloc] init];
    }
    return _tempData;
}

@end



////////////////////////////////////
//MARK:svp
@implementation ETNewProtocol (SVP)
- (NSData *)svp_packageDataWithAddress:(NSData *)address Func:(ETFuncCodeType)funcType andData:(NSData *)data
{
    Byte header[] = {0xAA,0x55};
    Byte footer[] = {0x0d,0x0a};
    Byte func[] = {funcType};
    
    
    UInt16 len = address.length + sizeof(func) + data.length + 8;
    len = NSSwapHostShortToBig(len);
    
    NSMutableData *v = [NSMutableData data];
    [v appendBytes:header length:sizeof(header)];
    [v appendBytes:&len length:sizeof(len)];
    [v appendData:address];
    [v appendBytes:func length:sizeof(func)];
    [v appendData:data];
    
    NSData *crc = [NSData crcForSVP:[v copy]];
    [v appendData:crc];
    
    [v appendBytes:footer length:sizeof(footer)];
    
    return v;
}

- (ETPacketObj *)svp_parseData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    
    Byte header[] = {0xaa,0x55};
    Byte footer[] = {0x0d,0x0a};
    NSData *aimH = [[NSData alloc] initWithBytes:header length:sizeof(header)];
    NSData *aimF = [[NSData alloc] initWithBytes:footer length:sizeof(footer)];
    
    if (data.length < 4) //头尾不全
    {
        return nil;
    }
    
    NSData *crc = [NSData crcForSVP:[data subdataWithRange:NSMakeRange(0, data.length - 4)]];
    if (![crc isEqualToData:[data subdataWithRange:NSMakeRange(data.length - 4, 2)]])
    {
        return nil;
    }
    
    BOOL hasHeader = [[data subdataWithRange:NSMakeRange(0, 2)] isEqualToData:aimH];
    BOOL hasFooter = [[data subdataWithRange:NSMakeRange(data.length - 2, 2)] isEqualToData:aimF];
    
    if (!(hasHeader && hasFooter)) return nil;
    
    
    
    UInt16 len = [NSData dataToUnsignedShort:[data subdataWithRange:NSMakeRange(2, 2)]];
    if (len != data.length) {
        return nil;
    }
    
    
//    NSData *dataHeader = [data subdataWithRange:NSMakeRange(0, 2)];
//    NSData *dataFooter = [data subdataWithRange:NSMakeRange(len - 2, 2)];
//
//    if (!([header isEqualToData:[NSData dataWithBytes:h length:sizeof(h)]] && [footer isEqualToData:[NSData dataWithBytes:f length:sizeof(f)]])) {
//        return nil;
//    }
    
    
    ETPacketObj *obj = [ETPacketObj new];
    obj.address1 = [data subdataWithRange:NSMakeRange(4, 2)];
    obj.address2 = [data subdataWithRange:NSMakeRange(6, 2)];
    obj.funcCode = [NSData dataToUnsignedChar:[data subdataWithRange:NSMakeRange(8, 1)]];
    obj.data = [data subdataWithRange:NSMakeRange(9, len - 5 - 8)];
    if (obj.data.length < 2)
    {
        return nil;
    }
    UInt16 subFuncCode = [NSData dataToUnsignedShort:[obj.data subdataWithRange:NSMakeRange(0, 2)]];
    obj.subFuncCode = subFuncCode;
    
    return obj;
}
@end
