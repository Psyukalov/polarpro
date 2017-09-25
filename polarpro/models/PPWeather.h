//
//  PPWeather.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 30.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, PPWeatherTemperatureUnits) {
    PPWeatherTemperatureUnitsFahrenheit = 0,
    PPWeatherTemperatureUnitsCelsius
};


typedef NS_ENUM(NSUInteger, PPWeatherSpeedUnits) {
    PPWeatherSpeedUnitsMilePerHour = 0,
    PPWeatherSpeedUnitsKilometersPerHour,
    PPWeatherSpeedUnitsMetersPerSecond,
    PPWeatherSpeedUnitsKnots
};


@interface PPWeather : NSObject

@property (assign, nonatomic) PPWeatherTemperatureUnits temperatureUnits;

@property (assign, nonatomic) PPWeatherSpeedUnits speedUnits;

@property (strong, nonatomic) NSString *localizedTemperatureUnits;
@property (strong, nonatomic) NSString *localizedSpeedUnits;
@property (strong, nonatomic) NSString *localizedDistanceUnits;

// All properties named as in API.

// Wind

@property (strong, nonatomic) NSString *wind_dir;

@property (assign, nonatomic) NSUInteger wind_degrees;

@property (assign, nonatomic) CGFloat wind_kph;

// Weather

@property (assign, nonatomic) CGFloat temp;
@property (assign, nonatomic) CGFloat low;
@property (assign, nonatomic) CGFloat high;

@property (assign, nonatomic) CGFloat humidity;

@property (strong, nonatomic) NSString *icon;

// Time

@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *epoch;
@property (strong, nonatomic) NSString *weekday;

// Others

@property (strong, nonatomic) NSString *conditions;

@property (assign, nonatomic) CGFloat visibility_km;

@end
