//
//  ETTimerTool.m
//  ManifoldGauge
//
//  Created by mac on 2023/1/29.
//  Copyright © 2023 Reo. All rights reserved.
//

#import "ETTimerTool.h"

@interface ETTimerTool()
{
    dispatch_source_t _timer;
}

@property (nonatomic, assign) CGFloat refreshInterval;

@end

@implementation ETTimerTool

- (instancetype)initWithRefreshInterval:(CGFloat)refreshInterval
{
    self = [super init];
    if (self) {
        self.refreshInterval = refreshInterval;
    }
    return self;
}

- (BOOL)running
{
    if (_timer == nil)
    {
        return NO;
    }
    intptr_t res = dispatch_source_testcancel(_timer);
    return res == 0;
}

#pragma mark - timer

/// 开始计时
- (void)startCountDown:(dispatch_block_t)timerBlock
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW + self.refreshInterval, self.refreshInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, timerBlock);
    dispatch_resume(timer);
    _timer = timer;
    
}

- (void)stopCountDown
{
    if (_timer)
    {
        dispatch_source_cancel(_timer);
    }
}

@end
