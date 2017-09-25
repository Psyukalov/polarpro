//
//  PPLocationsModel.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 16.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//

/*
 
 Using Weather Underground - AutoComplete API
 
 Link: https://www.wunderground.com/weather/api/d/docs?d=autocomplete-api&MR=1
 
 */


#import <Foundation/Foundation.h>

#import "PPWeather.h"
#import "PPAstronomy.h"


@class PPLocation;


@protocol PPLocationDelegate <NSObject>

@optional

- (void)locationDidUpdateCurrentTime:(PPLocation *)location;

- (void)locationDidStopTimer:(PPLocation *)location;

@end


@interface PPLocation : NSObject

@property (strong, nonatomic) id<PPLocationDelegate> delegate;

@property (strong, readonly, nonatomic) NSString *zmw;
@property (strong, readonly, nonatomic) NSString *name;

@property (strong, nonatomic) PPWeather *condition;

@property (strong, nonatomic) NSArray <PPWeather *> *hourlyForecast;
@property (strong, nonatomic) NSArray <PPWeather *> *weeklyForecast;

@property (strong, nonatomic) PPAstronomy *astronomy;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (void)encodeWithCoder:(NSCoder *)aCoder;

- (void)updateConditionWeatherDataWithCompletion:(void (^)(PPWeather *condition))completion;
- (void)updateHourlyForecstWeatherWithCompletion:(void (^)(NSArray <PPWeather *> *hourlyForecast))completion;
- (void)updateWeeklyForecstWeatherWithCompletion:(void (^)(NSArray <PPWeather *> *weeklyForecast))completion;
- (void)updateAstronomyWithCompletion:(void (^)(PPAstronomy *astronomy))completion;

- (void)stopTimersAndClear;

@end


@protocol PPLocationModelDelegate <NSObject>

@optional

- (void)didFindNearestCityByLastCoordinate;

@end


@interface PPLocationsModel : NSObject

@property (strong, nonatomic) id<PPLocationModelDelegate> delegate;

@property (strong, nonatomic) PPLocation *currentLocation;

@property (strong, nonatomic) NSMutableArray <PPLocation *> *locations;
@property (strong, nonatomic) NSMutableArray <PPLocation *> *locationsForSettings;
@property (strong, nonatomic) NSMutableArray <PPLocation *> *autocompleteLocations;

@property (assign, nonatomic) BOOL useCurrentLocation;

+ (id)sharedModel;

- (void)requestLocation;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

- (void)m_addLocationWithIndex:(NSUInteger)index;
- (void)m_removeLocationsWithIndex:(NSUInteger)index;
- (void)m_replaceLocationFromSourceIndexPath:(NSIndexPath *)sourceIndexPath
                                 toIndexPath:(NSIndexPath *)indexPath;

- (BOOL)m_synchronize;

- (void)m_autocompleteSearchWithString:(NSString *)string
                            completion:(void (^)(BOOL isSuccess))completion;

- (void)clearAll;

@end
