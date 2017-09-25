//
//  VPTime.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 04.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "VPTime.h"


@interface VPTime ()



@end


@implementation VPTime

@synthesize interval = _interval;

- (instancetype)initWithHours:(NSUInteger)hours
                  withMinutes:(NSUInteger)minutes
                   andSeconds:(NSUInteger)seconds {
    self = [super init];
    if (self) {
        _hours = hours;
        _minutes = minutes;
        _seconds = seconds;
        _interval = 3600 * _hours + 60 * _minutes + _seconds;
        [self setup];
    }
    return self;
}

- (instancetype)initWithDate:(NSDate *)date
                 andTimeZone:(NSTimeZone *)timeZone {
    self = [super init];
    if (self) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:timeZone];
        [dateFormatter setDateFormat:@"HH"];
        _hours = [[dateFormatter stringFromDate:date] integerValue];
        [dateFormatter setDateFormat:@"mm"];
        _minutes = [[dateFormatter stringFromDate:date] integerValue];
        [dateFormatter setDateFormat:@"ss"];
        _seconds = [[dateFormatter stringFromDate:date] integerValue];
        [self setInterval:3600 * _hours + 60 * _minutes + _seconds];
        [self setup];
    }
    return self;
}

- (instancetype)initWithInterval:(NSUInteger)interval {
    self = [super init];
    if (self) {
        [self setInterval:interval];
        [self setup];
    }
    return self;
}

- (void)setup {
    _separator = @":";
    _timeFormat = VPTimeHoursAndMinutesFormat;
    _timeType = VPTimeType12Hours;
}

- (void)setInterval:(NSUInteger)interval {
    if (interval > 24 * 3600) {
        interval = interval % 3600;
    }
    _interval = interval;
    _hours = _interval / 3600;
    _minutes = (_interval / 60) % 60;
    _seconds = _interval % 60;
}

- (NSString *)text {
    return [self textWithTimeFormat:_timeFormat];
}

- (NSString *)textWithTimeFormat:(VPTimeFormat)timeFormat {
    NSString *result;
    NSUInteger hours = _hours;
    NSString *meridiem = @"";
    if (_timeType == VPTimeType12Hours) {
        if (_hours < 12) {
            meridiem = @" AM";
        } else {
            meridiem = @" PM";
            hours = _hours - 12;
        }
    }
    switch (timeFormat) {
        case VPTimeFullFormat:
            result = [NSString stringWithFormat:@"%02ld%@%02ld%@%02ld%@", (unsigned long)hours, _separator, (unsigned long)_minutes, _separator, (unsigned long)_seconds, meridiem];
            break;
        case VPTimeHoursAndMinutesFormat:
            result = [NSString stringWithFormat:@"%02ld%@%02ld%@", (unsigned long)hours, _separator, (unsigned long)_minutes, meridiem];
            break;
        case VPTimeMinutesAndSecondsFormat:
            result = [NSString stringWithFormat:@"%02ld%@%02ld", (unsigned long)_minutes, _separator, (unsigned long)_seconds];
            break;
        case VPTimeSecondFormat:
            result = [NSString stringWithFormat:@"%02ld", (unsigned long)_seconds];
            break;
        case VPTimeMinutesFormat:
            result = [NSString stringWithFormat:@"%02ld", (unsigned long)_minutes];
            break;
        case VPTimeHoursFormat:
            result = [NSString stringWithFormat:@"%02ld%@", (unsigned long)hours, meridiem];
            break;
    }
    return result;
}

- (CGFloat)completePercentFromTime:(VPTime *)fromTime
                            toTime:(VPTime *)toTime {
    if ([self earlierTime:fromTime]) {
        return 0.f;
    }
    if ([self laterTime:toTime]) {
        return 1.f;
    }
    NSUInteger interval = [fromTime intervalFromTime:toTime];
    NSUInteger completeInterval = [fromTime intervalFromTime:self];
    return (CGFloat)completeInterval / (CGFloat)interval;
}

- (BOOL)earlierTime:(VPTime *)time {
    return [self interval] < time.interval;
}

- (BOOL)laterTime:(VPTime *)time {
    return [self interval] > time.interval;
}

- (BOOL)betweenfirstTime:(VPTime *)firstTime andSecondTime:(VPTime *)secondTime {
    return [self laterTime:firstTime] && [self earlierTime:secondTime];
}

- (NSUInteger)intervalFromTime:(VPTime *)time {
    NSInteger result = _interval - time.interval;
    return (NSUInteger)ABS(result);
}

- (void)addInterval:(NSUInteger)interval {
    NSUInteger newInterval = _interval + interval;
    [self setInterval:newInterval];
}

- (void)addOneSecond {
    [self addInterval:1];
}

- (void)addOneMinute {
    [self addInterval:60];
}

- (void)addOneHour {
    [self addInterval:3600];
}

+ (NSDate *)dateWithString:(NSString *)string
                 andFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:string];
}

+ (NSString *)stringWithDate:(NSDate *)date
                  withFormat:(NSString *)format
                 andTimeZone:(NSTimeZone *)timeZone {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

@end
