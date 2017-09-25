//
//  VPTimer.m
//
//  Created by Vladimir Psyukalov on 23.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "VPTimer.h"


@interface VPTimer ()

@property (assign, nonatomic) NSUInteger count;

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) VPTimerStack *timerStack;

@end


@implementation VPTimer

- (instancetype)initTimerWithTime:(NSUInteger)time {
    self = [super init];
    if (self) {
        _time = time;
        _rate = 1.f;
    }
    return self;
}

- (void)start {
    UIBackgroundTaskIdentifier backgroundTask = 0;
    UIApplication  *application = [UIApplication sharedApplication];
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
    }];
    NSTimer *currentTimer = [NSTimer scheduledTimerWithTimeInterval:_rate
                                                             target:self
                                                           selector:@selector(tick)
                                                           userInfo:nil
                                                            repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:currentTimer
                              forMode:NSRunLoopCommonModes];
    _count = _time;
    _timer = currentTimer;
}

- (void)setTime:(NSUInteger)time {
    _time = time;
    _count = _time;
    [self calculateTime];
}

- (void)pause {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)stop {
    [self pause];
    _count = 0.f;
}

- (void)tick {
    if (_count > 0) {
        _count -= _rate;
        [self calculateTime];
    } else {
        _count = _time;
        if ([self checkDelegate] && [_delegate respondsToSelector:@selector(timerDidTimeEnd:)]) {
            [_delegate timerDidTimeEnd:self];
        }
        [self stop];
    }
}

- (void)calculateTime {
    NSUInteger hours = _count / 3600;
    NSUInteger minutes = (_count / 60) % 60;
    NSUInteger seconds = _count % 60;
    if ([self checkDelegate] && [_delegate respondsToSelector:@selector(timerDidTick:)]) {
        [_delegate timerDidTick:self];
    }
    if ([self checkDelegate] && [_delegate respondsToSelector:@selector(timer:didTickWithHours:withMinutes:andSeconds:)]) {
        [_delegate timer:self didTickWithHours:hours withMinutes:minutes andSeconds:seconds];
    }
}

- (BOOL)checkDelegate {
    return _delegate && [_delegate conformsToProtocol:@protocol(VPTimerDelegate)];
}

@end


@implementation VPTimerStack

+ (id)sharedTimerStack {
    static VPTimerStack *timerStack = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerStack = [[self alloc] init];
    });
    return timerStack;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _timers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addTimer:(VPTimer *)timer {
    [_timers addObject:timer];
    NSLog(@"Timer stack; Add; Count: %ld;", (unsigned long)_timers.count);
}

- (void)removeTimer:(VPTimer *)timer {
    [timer stop];
    [_timers removeObject:timer];
    NSLog(@"Timer stack; Remove; Count: %ld;", (unsigned long)_timers.count);
}

- (void)removeAllTimers {
    [_timers removeAllObjects];
    NSLog(@"Timer stack; Remove all;");
}

- (void)stopAll {
    for (VPTimer *timer in _timers) {
        if (timer) {
            [timer stop];
            NSLog(@"Timer stack; Stop timer: %@;", timer);
        }
    }
    [self removeAllTimers];
}

@end
