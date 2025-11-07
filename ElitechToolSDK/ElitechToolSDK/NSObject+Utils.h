//
//  NSObject+Utils.h
//  ManifoldGauge
//
//  Created by mac on 2021/12/20.
//  Copyright © 2021 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Utils)
- (BOOL)notNull;
- (BOOL)notEmpty;
- (instancetype)notNullObject;
- (NSString *)notNullString__;
- (NSString *)notNullStringWithFormat:(NSString *)string;
- (BOOL)notEmptyPointer;
+ (NSString *)notNullFormatString:(NSObject *)obj;
+ (NSString *)notNullFormatString:(NSObject *)obj WithDefaultString:(NSString *)ds;

- (BOOL)notEmptyAll;
+ (NSString *)fmtNotNullString:(id)fmtString;
+ (NSString *)fmtNotNullString:(id)fmtString defaultString:(NSString *)text;
@end

@interface NSObject (Number)

- (NSString *)maxFractionDigits:(NSUInteger)num;

@end

NS_ASSUME_NONNULL_END
