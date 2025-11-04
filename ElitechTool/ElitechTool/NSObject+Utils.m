//
//  NSObject+Utils.m
//  ManifoldGauge
//
//  Created by mac on 2021/12/20.
//  Copyright © 2021 Reo. All rights reserved.
//

#import "NSObject+Utils.h"

@implementation NSObject (Utils)

- (BOOL)notNull {
    if ([self isEqual:[NSNull null]]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)notEmpty {
    if ([self isEqual:[NSNull null]]) {
        return NO;
    }
    else if ([self isKindOfClass:[NSString class]] && ((NSString *)self).length == 0)
    {
        return NO;
    }
    return YES;
}

// sht add
- (instancetype)notNullObject
{
    if ([self notNull]) {
        return self;
    } else {
        return nil;
    }
}

- (NSString *)notNullString__
{
    return [self notNullStringWithFormat:@"--"];
}

- (NSString *)notNullStringWithFormat:(NSString *)string
{
    if ([self notNull]) {
        return [NSString stringWithFormat:@"%@",self];
    } else {
        return string;
    }
}
- (BOOL)notEmptyPointer {
    if ([self isEqual:[NSNull null]]) {
        return NO;
    }
    return YES;
}
// end

+ (NSString *)notNullFormatString:(NSObject *)obj
{
    return [self notNullFormatString:obj WithDefaultString:@"--"];
}

+ (NSString *)notNullFormatString:(NSObject *)obj WithDefaultString:(NSString *)ds
{
    if ([obj notEmpty]) {
        return [NSString stringWithFormat:@"%@",obj];
    }
    else
    {
        return ds;
    }
}


// 空指针，空字串，数字为0，判断
- (BOOL)notEmptyAll{
    if (self == nil || [self isEqual:[NSNull null]]) {
        return NO;
    } else if ([self isKindOfClass:[NSString class]]) {
        return ![((NSString *)self) isEqualToString:@""];
    }
    
    return YES;
}

+ (NSString *)fmtNotNullString:(id)fmtString
{
    return [self fmtNotNullString:fmtString defaultString:@"--"];
}

+ (NSString *)fmtNotNullString:(id)fmtString defaultString:(NSString *)text
{
    if ([fmtString notEmptyAll]) {
        return [NSString stringWithFormat:@"%@",fmtString];
    }
    else
    {
        return text;
    }
}
@end

@implementation NSObject (Number)

- (NSString *)maxFractionDigits:(NSUInteger)num
{
    NSNumber *item = @([[NSObject fmtNotNullString:self defaultString:@""] doubleValue]);
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.maximumFractionDigits = num;
    return [f stringFromNumber:item];
}

@end
