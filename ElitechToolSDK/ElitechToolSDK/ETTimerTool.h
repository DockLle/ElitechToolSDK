//
//  ETTimerTool.h
//  ManifoldGauge
//
//  Created by mac on 2023/1/29.
//  Copyright © 2023 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ETTimerTool : NSObject

@property (nonatomic) BOOL running;

- (instancetype)initWithRefreshInterval:(CGFloat)refreshInterval;

- (void)startCountDown:(dispatch_block_t)timerBlock;
- (void)stopCountDown;

@end

NS_ASSUME_NONNULL_END
