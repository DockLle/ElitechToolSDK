//
//  NSData+Util.h
//  Csafe
//
//  Created by mac on 2022/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Util)

+ (SInt16)dataToShort:(NSData *)data;
+ (UInt8)dataToUnsignedChar:(NSData *)data;
+ (UInt16)dataToUnsignedShort:(NSData *)data;
+ (UInt32)dataToUnsignedInt:(NSData *)data;
+ (SInt32)dataToInt32:(NSData *)data;

+ (NSData *)shortToData:(int)shortValue;
+ (UInt8)setBitNumWithOriginalUint8:(UInt8)oriValue bitSerial:(NSUInteger)serial setValue:(UInt8)setValue;

/// 设置一个字节中连续n位的值(例：原始值0b00011111，需要将7设置到高3位，即将高3位变111，最终目标结果位0b11111111)
/// @param oriValue 原始值 (0b00011111)
/// @param serial 要设置的最低位的序号,范围0-7 (5)
/// @param bitLen 要设置的连续位数 (3)
/// @param setValue 要设置的值 (7)
+ (UInt8)setBitNumWithOriginalUint8:(UInt8)oriValue bitSerial:(NSUInteger)serial bitLen:(NSUInteger)bitLen setValue:(UInt8)setValue;
@end


@interface NSData (CRC16)
+ (NSData *)getCrcVerifyCode:(NSData *)data;
+ (NSData *)crcForVGW760:(NSData *)data;
+ (NSData *)crcForSVP:(NSData *)data;
@end


@interface NSData (Hex)

//NSdata 转16进制字符串
+ (NSString *)hexadecimalStringWithData:(NSData *)data;
//16进制字符转(不带0x),转NSData
+ (NSData *)hexToBytes:(NSString *)str;
@end

NS_ASSUME_NONNULL_END
