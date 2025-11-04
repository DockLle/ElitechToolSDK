//
//  ETBleScanData.m
//  ElitechTool
//
//  Created by wuwu on 2025/10/28.
//

#import "ETBleScanData.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation ETBleScanData

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    else {
        return [self.peripheral.identifier isEqual:((ETBleScanData *)other).peripheral.identifier];
    }
}

- (NSUInteger)hash
{
    return [self.peripheral.identifier hash];
}

@end
