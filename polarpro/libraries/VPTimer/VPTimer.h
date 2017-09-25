//
//  VPTimer.h
//
//  Created by Vladimir Psyukalov on 23.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>


@class VPTimer;


@protocol VPTimerDelegate <NSObject>

@optional

- (void)timer:(VPTimer *)timer didTickWithHours:(NSUInteger)hours withMinutes:(NSUInteger)minutes andSeconds:(NSUInteger)seconds;

- (void)timerDidTick:(VPTimer *)timer;

- (void)timerDidTimeEnd:(VPTimer *)timer;

@end


@interface VPTimer : NSObject

@property (strong, nonatomic) id<VPTimerDelegate> delegate;

@property (assign, nonatomic) NSUInteger time;

@property (assign, nonatomic) CGFloat rate;

- (instancetype)initTimerWithTime:(NSUInteger)time;

- (void)start;
- (void)pause;
- (void)stop;

@end

@interface VPTimerStack : NSObject

@property (strong, nonatomic) NSMutableArray <VPTimer *> *timers;

+ (id)sharedTimerStack;

- (void)addTimer:(VPTimer *)timer;
- (void)removeTimer:(VPTimer *)timer;

- (void)stopAll;

@end
