//
//  VPTime.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 04.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, VPTimeFormat) {
    VPTimeFullFormat = 0,
    VPTimeHoursAndMinutesFormat,
    VPTimeMinutesAndSecondsFormat,
    VPTimeSecondFormat,
    VPTimeMinutesFormat,
    VPTimeHoursFormat
};

typedef NS_ENUM(NSUInteger, VPTimeType) {
    VPTimeType24Hours = 0,
    VPTimeType12Hours
};


@class VPTime;


@interface VPTime : NSObject

@property (assign, nonatomic) NSUInteger interval;
@property (assign, nonatomic, readonly) NSUInteger hours;
@property (assign, nonatomic, readonly) NSUInteger minutes;
@property (assign, nonatomic, readonly) NSUInteger seconds;

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *separator;

@property (assign, nonatomic) VPTimeFormat timeFormat;
@property (assign, nonatomic) VPTimeType timeType;


- (instancetype)initWithHours:(NSUInteger)hours
                  withMinutes:(NSUInteger)minutes
                   andSeconds:(NSUInteger)seconds;
- (instancetype)initWithDate:(NSDate *)date
                 andTimeZone:(NSTimeZone *)timeZone;
- (instancetype)initWithInterval:(NSUInteger)interval;

- (NSString *)textWithTimeFormat:(VPTimeFormat)timeFormat;

- (CGFloat)completePercentFromTime:(VPTime *)fromTime
                            toTime:(VPTime *)toTime;

- (BOOL)earlierTime:(VPTime *)time;
- (BOOL)laterTime:(VPTime *)time;
- (BOOL)betweenfirstTime:(VPTime *)firstTime
           andSecondTime:(VPTime *)secondTime;

- (NSUInteger)intervalFromTime:(VPTime *)time;

- (void)addInterval:(NSUInteger)interval;

- (void)addOneSecond;
- (void)addOneMinute;
- (void)addOneHour;

+ (NSDate *)dateWithString:(NSString *)string
                 andFormat:(NSString *)format;

+ (NSString *)stringWithDate:(NSDate *)date
                  withFormat:(NSString *)format
                 andTimeZone:(NSTimeZone *)timeZone;

@end
