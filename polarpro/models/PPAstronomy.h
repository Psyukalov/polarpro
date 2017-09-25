//
//  PPAstronomy.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 22.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "VPTime.h"


@interface PPSunPosition : NSObject

@property (assign, nonatomic) CGFloat radians;
@property (assign, nonatomic) CGFloat degrees;

@property (strong, nonatomic) NSString *text;

@end


@interface PPAstronomy : NSObject

@property (assign, nonatomic) BOOL isPolarDayOrNight;

@property (assign, nonatomic) VPTimeType timeType;

@property (strong, nonatomic) VPTime *currentTime;
@property (strong, nonatomic) VPTime *sunrise;
@property (strong, nonatomic) VPTime *sunriseEnd;
@property (strong, nonatomic) VPTime *sunset;
@property (strong, nonatomic) VPTime *sunsetStart;
@property (strong, nonatomic) VPTime *goldenHour;
@property (strong, nonatomic) VPTime *goldenHourEnd;

@property (strong, nonatomic) VPTime *nearestGoldenHour;
@property (strong, nonatomic) VPTime *nearestGoldenHourEnd;

@property (assign, nonatomic) NSUInteger intervalToGoldenHour;

@property (strong, nonatomic) PPSunPosition *sunPosition;

- (void)timeInfo;
- (void)intervalInfo;

@end
