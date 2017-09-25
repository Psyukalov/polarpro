//
//  PPAstronomy.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 22.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPAstronomy.h"

#import "Macros.h"

#import "PPSettingsModel.h"


@implementation PPSunPosition

@synthesize radians = _radians;

- (void)setDegrees:(CGFloat)degrees {
    _radians = DEGREES_TO_RADIANS(degrees);
}

- (CGFloat)degrees {
    return RADIANS_TO_DEGREES(_radians);
}

- (NSString *)text {
    return [NSString stringWithFormat:@"%1.2f%@", [self degrees], kDegreeCharacter];
}

@end


@interface PPAstronomy ()

@property (strong, nonatomic) PPSettingsModel *settingsModel;

@end


@implementation PPAstronomy

- (instancetype)init {
    self = [super init];
    if (self) {
        _settingsModel = [PPSettingsModel sharedModel];
    }
    return self;
}

- (VPTimeType)timeType {
    return (VPTimeType)_settingsModel.groups[1].options[0].currentParameter;
}

- (BOOL)isPolarDayOrNight {
    BOOL value = (_sunrise == nil) || (_sunset == nil) || (_sunriseEnd == nil) || (_sunsetStart == nil) || (_goldenHour == nil) || (_goldenHourEnd == nil);
    return value;
}

- (VPTime *)currentTime {
    [_currentTime setTimeType:_settingsModel.groups[1].options[0].currentParameter];
    return _currentTime;
}

- (VPTime *)sunrise {
    [_sunrise setTimeType:_settingsModel.groups[1].options[0].currentParameter];
    return _sunrise;
}

- (VPTime *)sunriseEnd {
    [_sunriseEnd setTimeType:_settingsModel.groups[1].options[0].currentParameter];
    return _sunriseEnd;
}

- (VPTime *)sunset {
    [_sunset setTimeType:_settingsModel.groups[1].options[0].currentParameter];
    return _sunset;
}

- (VPTime *)sunsetStart {
    [_sunsetStart setTimeType:_settingsModel.groups[1].options[0].currentParameter];
    return _sunsetStart;
}

- (VPTime *)goldenHour {
    [_goldenHour setTimeType:_settingsModel.groups[1].options[0].currentParameter];
    return _goldenHour;
}

- (VPTime *)goldenHourEnd {
    [_goldenHourEnd setTimeType:_settingsModel.groups[1].options[0].currentParameter];
    return _goldenHourEnd;
}

- (void)timeInfo {
    NSLog(@"\n Current time %@ \n Sunrise %@ \n Golden hour end %@ \n Golden hour %@ \n Sunset start %@ \n Sunset %@ \n",
          _currentTime.text,
          _sunrise.text,
          _goldenHourEnd.text,
          _goldenHour.text,
          _sunsetStart.text,
          _sunset.text);
}

- (void)intervalInfo {
    NSLog(@"\n Current time %ld \n Sunrise %ld \n Golden hour end %ld \n Golden hour %ld \n Sunset start %ld \n Sunset %ld \n",
          (unsigned long)_currentTime.interval,
          (unsigned long)_sunrise.interval,
          (unsigned long)_goldenHourEnd.interval,
          (unsigned long)_goldenHour.interval,
          (unsigned long)_sunsetStart.interval,
          (unsigned long)_sunset.interval);
}

@end
