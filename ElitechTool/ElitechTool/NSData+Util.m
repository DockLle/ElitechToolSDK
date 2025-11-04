//
//  NSData+Util.m
//  Csafe
//
//  Created by mac on 2022/7/19.
//

#import "NSData+Util.h"

@implementation NSData (Util)

+ (SInt16)dataToShort:(NSData *)data {
//    SInt16 num;
//    Byte *bytes = (Byte *)[data bytes];
//    SInt16 u16 = (short)(bytes[0] << 8) + (bytes[1] & 0xff);
//    if ((u16 & 0x8000) != 0) {
//        u16 &= 0x7FFF;
//        num = -u16;
//    }
//    else
//    {
//        num = u16;
//    }
    
    SInt16 val = 0;
    [data getBytes:&val length:sizeof(val)];
    val = NSSwapHostShortToBig(val);
    return val;
}

+ (UInt8)dataToUnsignedChar:(NSData *)data
{
    UInt8 val = 0;
    [data getBytes:&val length:sizeof(val)];
    return val;
}

+ (UInt16)dataToUnsignedShort:(NSData *)data
{
    UInt16 val = 0;
    [data getBytes:&val length:sizeof(val)];
    val = NSSwapHostShortToBig(val);
    return val;
}

+ (UInt32)dataToUnsignedInt:(NSData *)data
{
    UInt32 val = 0;
    [data getBytes:&val length:sizeof(val)];
    val = NSSwapHostIntToBig(val);
    return val;
}

+ (SInt32)dataToInt32:(NSData *)data
{
    SInt32 val = 0;
    [data getBytes:&val length:sizeof(val)];
    val = NSSwapHostIntToBig(val);
    return val;
}

+ (NSData *)shortToData:(int)shortValue
{
    int u16Temp;
    if (shortValue < 0) {
        u16Temp = 0 - shortValue;
        u16Temp |= 0x8000;
    } else {
        u16Temp = shortValue;
    }
    
    UInt8 result[2];
    result[0] = (Byte)(u16Temp >> 8);
    result[1] = (Byte)(u16Temp & 0xFF);
    
    NSData *data = [NSData dataWithBytes:result length:sizeof(result)];
    return data;
}

+ (UInt8)setBitNumWithOriginalUint8:(UInt8)oriValue bitSerial:(NSUInteger)serial setValue:(UInt8)setValue
{
    UInt8 value = oriValue;
    
    UInt8 a = 1 << serial;
    UInt8 b = 0xff ^ a;
    
    value = (value & b) | (((UInt8)setValue << serial) & a);
    return value;
}

+ (UInt8)setBitNumWithOriginalUint8:(UInt8)oriValue bitSerial:(NSUInteger)serial bitLen:(NSUInteger)bitLen setValue:(UInt8)setValue
{
    UInt8 value = oriValue;
    
    int num = powf(2, bitLen) - 1;
    UInt8 a = num << serial;
    UInt8 b = 0xff ^ a;
    
    value = (value & b) | (((UInt8)setValue << serial) & a);
    return value;
}

@end

@implementation NSData (CRC16)
+ (NSData *)getCrcVerifyCode:(NSData *)data {
    
    Byte *bytes = (Byte *)[data bytes];
    int CRC = 0x0000ffff;
    int POLYNOMIAL = 0x0000a001;
    int i, j;
    for (i = 0; i < data.length; i++) {
        CRC ^= ((int) bytes[i] & 0x000000ff);
        for (j = 0; j < 8; j++) {
            if ((CRC & 0x00000001) != 0) {
                CRC >>= 1;
                CRC ^= POLYNOMIAL;
            } else {
                CRC >>= 1;
            }
        }
    }
    
//    UInt8 crc33 = nsswaphost
    UInt16 crc = NSSwapHostShortToBig(CRC);
    
    return [NSData dataWithBytes:&crc length:sizeof(crc)];;
}

+ (NSData *)crcForVGW760:(NSData *)data {
    
    Byte *bytes = (Byte *)[data bytes];
    UInt32 total = 0;
    for (int i = 0; i < data.length; i++) {
        total += bytes[i];
    }
    
    UInt8 crc = total & 0xff;
    
    return [NSData dataWithBytes:&crc length:sizeof(crc)];;
}

+ (NSData *)crcForSVP:(NSData *)data {
    
    Byte *bytes = (Byte *)[data bytes];
    UInt32 total = 0;
    for (int i = 0; i < data.length; i++) {
        total += bytes[i];
    }
    
    UInt16 crc = total & 0xffff;
    crc = NSSwapHostShortToBig(crc);
    NSData *ret = [NSData dataWithBytes:&crc length:sizeof(crc)];
//    ret = [NSData reverseByte:ret];
    return ret;
}

@end

@implementation NSData (Hex)

//NSdata 转16进制字符串
+ (NSString *)hexadecimalStringWithData:(NSData *)data
{
    /* Returns hexadecimal string of NSData. Empty string if data is empty.  */
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
    {
        return [NSString string];
    }
    NSUInteger dataLength = [data length];
    
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
    {
        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }
    return [NSString stringWithString:hexString];
}

//16进制字符转(不带0x),转NSData
+ (NSData *)hexToBytes:(NSString *)str
{
    
    NSMutableData * data = [NSMutableData data];
    
    for (int i = 0; i+2 <= str.length; i+=2) {
        
        NSString * subString = [str substringWithRange:NSMakeRange(i, 2)];
        
        NSScanner * scanner = [NSScanner scannerWithString:subString];
        
        uint number;
        
        [scanner scanHexInt:&number];
        
        [data appendBytes:&number length:1];
        
    }
    return data.copy;
}

@end

