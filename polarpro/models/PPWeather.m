//
//  PPWeather.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 30.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPWeather.h"

#import "Macros.h"

#import "PPSettingsModel.h"


@interface PPWeather ()

@property (strong, nonatomic) PPSettingsModel *settingsModel;

@end


@implementation PPWeather

- (instancetype)init {
    self = [super init];
    if (self) {
        _settingsModel = [PPSettingsModel sharedModel];
    }
    return self;
}

- (CGFloat)wind_kph {
    return [self translateSpeed:_wind_kph];
}

- (CGFloat)visibility_km {
    return [self translateDistance:_visibility_km];
}

- (CGFloat)temp {
    return [self translateTemperature:_temp];
}

- (CGFloat)low {
    return [self translateTemperature:_low];
}

- (CGFloat)high {
    return [self translateTemperature:_high];
}

- (NSString *)localizedTemperatureUnits {
    NSString *result = @"p_c";
    _temperatureUnits = _settingsModel.groups[0].options[0].currentParameter;
    if (_temperatureUnits == PPWeatherTemperatureUnitsFahrenheit) {
        result = @"p_f";
    }
    return [NSString stringWithFormat:@"%@%@", LOCALIZE(result), kDegreeCharacter];
}

- (NSString *)localizedSpeedUnits {
    NSString *result;
    _speedUnits = _settingsModel.groups[0].options[1].currentParameter;
    switch (_speedUnits) {
        case PPWeatherSpeedUnitsMilePerHour:
            result = @"p_mph";
            break;
        case PPWeatherSpeedUnitsKilometersPerHour:
            result = @"p_km_h";
            break;
        case PPWeatherSpeedUnitsMetersPerSecond:
            result = @"p_m_s";
            break;
        case PPWeatherSpeedUnitsKnots:
            result = @"p_knots";
            break;
    }
    return LOCALIZE(result);
}

- (NSString *)localizedDistanceUnits {
    NSString *result = @"p_km";
    _speedUnits = _settingsModel.groups[0].options[1].currentParameter;
    if (_speedUnits == PPWeatherSpeedUnitsMilePerHour) {
        result = @"p_mi";
    }
    return LOCALIZE(result);
}

- (CGFloat)translateTemperature:(CGFloat)temperature {
    CGFloat result = temperature;
    _temperatureUnits = _settingsModel.groups[0].options[0].currentParameter;
    if (_temperatureUnits == PPWeatherTemperatureUnitsFahrenheit) {
        result = temperature * 9.f / 5.f+ 32.f;
    }
    return result;
}

- (CGFloat)translateSpeed:(CGFloat)speed {
    CGFloat result;
    _speedUnits = _settingsModel.groups[0].options[1].currentParameter;
    switch (_speedUnits) {
        case PPWeatherSpeedUnitsMilePerHour:
            result = speed * .621371f;
            break;
        case PPWeatherSpeedUnitsKilometersPerHour:
            result = speed;
            break;
        case PPWeatherSpeedUnitsMetersPerSecond:
            result = speed * .277778f;
            break;
        case PPWeatherSpeedUnitsKnots:
            result = speed * .539957f;
            break;
    }
    return result;
}

- (CGFloat)translateDistance:(CGFloat)distance {
    CGFloat result = distance;
    _speedUnits = _settingsModel.groups[0].options[1].currentParameter;
    if (_speedUnits == PPWeatherSpeedUnitsMilePerHour) {
        result = distance * .621371f;
    }
    return result;
}

@end
