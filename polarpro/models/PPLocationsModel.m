
//  PPLocationsModel.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 16.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPLocationsModel.h"

#import "Macros.h"
#import <AFNetworking.h>
#import <CoreLocation/CoreLocation.h>
#import "VPTimer.h"

#import "PPUser.h"

#import "PPAlertView.h"


#define kLocations (@"user_defaults_locations_key")

#define kZmw (@"location_zmw")
#define kName (@"location_name")

#define kUseCurrenLocation (@"use_current_location")

#define kAutocompleteURL (@"http://autocomplete.wunderground.com/aq?")
#define kConditionsURL (@"http://api.wunderground.com/api/%@/conditions/lang:%@/q/zmw:%@.json")
#define kHourlyForecastURL (@"http://api.wunderground.com/api/%@/hourly/lang:%@/q/zmw:%@.json")
#define kWeeklyForecastURL (@"http://api.wunderground.com/api/%@/forecast10day/lang:%@/q/zmw:%@.json")
#define kGeolookupURL (@"http://api.wunderground.com/api/%@/geolookup/lang:%@/q/%1.6f,%1.6f.json")
#define kAstronomyURL (@"http://spaceweather.herokuapp.com/spaceweather_api/get_times?date=%@&latitude=%@&longitude=%@")


#pragma mark - PPLocation


@interface PPLocation () <VPTimerDelegate>

@property (strong, nonatomic) VPTimer *timer; // For update current time;
@property (strong, nonatomic) VPTimer *conditionTimer;
@property (strong, nonatomic) VPTimer *hourlyTimer;
@property (strong, nonatomic) VPTimer *weeklyTimer;
@property (strong, nonatomic) VPTimer *astronomyTimer;

@end


@implementation PPLocation

- (instancetype)initWithZmw:(NSString *)zmw
                    andName:(NSString *)name {
    self = [super init];
    if (self) {
        _zmw = zmw;
        _name = name;
        [self setup];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _zmw = dictionary[@"zmw"];
        _name = dictionary[@"name"];
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _zmw = (NSString *)[aDecoder decodeObjectForKey:kZmw];
        _name = (NSString *)[aDecoder decodeObjectForKey:kName];
        [self setup];
    }
    return self;
}

- (void)setup {
    _timer = [[VPTimer alloc] initTimerWithTime:kUpdateInterval];
    _conditionTimer = [[VPTimer alloc] initTimerWithTime:kUpdateInterval];
    _hourlyTimer = [[VPTimer alloc] initTimerWithTime:kUpdateInterval];
    _weeklyTimer = [[VPTimer alloc] initTimerWithTime:kUpdateInterval];
    _astronomyTimer = [[VPTimer alloc] initTimerWithTime:24 * 3600];
    
    [_timer setDelegate:self];
    [_conditionTimer setDelegate:self];
    [_hourlyTimer setDelegate:self];
    [_weeklyTimer setDelegate:self];
    [_astronomyTimer setDelegate:self];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_zmw
                  forKey:kZmw];
    [aCoder encodeObject:_name
                  forKey:kName];
}

- (void)updateConditionWeatherDataWithCompletion:(void (^)(PPWeather *condition))completion {
    if (_condition) {
        NSLog(@"Catched conditions;");
        if (completion) {
            completion(_condition);
        }
        return;
    }
    NSLog(@"Load conditions;");
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    [manager GET:[NSString stringWithFormat:kConditionsURL, kAPIKey, LOCALIZE(@"api_localize_key"), _zmw]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if (!responseObject || responseObject[@"response"][@"error"]) {
                 [PPAlertView showErrorAlertViewWithMessage:responseObject[@"response"][@"error"][@"description"]];
                 return;
             }
             _condition = [self parseCondition:responseObject];
             if (completion && _condition) {
                 [_conditionTimer start];
                 completion(_condition);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error.localizedDescription);
             [PPAlertView showErrorAlertViewWithMessage:error.localizedDescription];
             if (completion) {
                 completion(nil);
             }
         }];
}

- (void)updateHourlyForecstWeatherWithCompletion:(void (^)(NSArray <PPWeather *> *))completion {
    if (_hourlyForecast) {
        NSLog(@"Catched hourly;");
        if (completion) {
            completion(_hourlyForecast);
        }
        return;
    }
    NSLog(@"Load hourly;");
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    [manager GET:[NSString stringWithFormat:kHourlyForecastURL, kAPIKey, LOCALIZE(@"api_localize_key"), _zmw]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if (!responseObject || responseObject[@"response"][@"error"]) {
                 [PPAlertView showErrorAlertViewWithMessage:responseObject[@"response"][@"error"][@"description"]];
                 return;
             }
             _hourlyForecast = [self parseHourlyForecast:responseObject];
             if (completion && _hourlyForecast.count > 0) {
                 [_hourlyTimer start];
                 completion(_hourlyForecast);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error.localizedDescription);
             [PPAlertView showErrorAlertViewWithMessage:error.localizedDescription];
             if (completion) {
                 completion(nil);
             }
         }];
}

- (void)updateWeeklyForecstWeatherWithCompletion:(void (^)(NSArray <PPWeather *> *))completion {
    if (_weeklyForecast) {
        NSLog(@"Catched weekly;");
        if (completion) {
            completion(_weeklyForecast);
        }
        return;
    }
    NSLog(@"Load weekly;");
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    [manager GET:[NSString stringWithFormat:kWeeklyForecastURL, kAPIKey, LOCALIZE(@"api_localize_key"), _zmw]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if (!responseObject || responseObject[@"response"][@"error"]) {
                 [PPAlertView showErrorAlertViewWithMessage:responseObject[@"response"][@"error"][@"description"]];
                 return;
             }
             _weeklyForecast = [self parseWeeklyForecast:responseObject];
             if (completion && _weeklyForecast.count > 0) {
                 [_weeklyTimer start];
                 completion(_weeklyForecast);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error.localizedDescription);
             [PPAlertView showErrorAlertViewWithMessage:error.localizedDescription];
             if (completion) {
                 completion(nil);
             }
         }];
}

- (void)updateAstronomyWithCompletion:(void (^)(PPAstronomy *))completion {
    if (_astronomy) {
        NSLog(@"Catched astronomy;");
        if (completion) {
            completion(_astronomy);
        }
        return;
    }
    NSLog(@"Load astronomy;");
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    [manager GET:[NSString stringWithFormat:kConditionsURL, kAPIKey, LOCALIZE(@"api_localize_key"), _zmw]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if (!responseObject || responseObject[@"response"][@"error"]) {
                 [PPAlertView showErrorAlertViewWithMessage:responseObject[@"response"][@"error"][@"description"]];
                 return;
             }
             [_astronomyTimer start];
             NSDictionary *dictionary = (NSDictionary *)responseObject[@"current_observation"];
             NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:dictionary[@"local_tz_long"]];
             NSDate *date = [VPTime dateWithString:dictionary[@"local_time_rfc822"]
                                         andFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
             NSString *latitude = dictionary[@"display_location"][@"latitude"];
             NSString *longitude = dictionary[@"display_location"][@"longitude"];
             [self astronomyWithDate:date
                        withTimeZone:timeZone
                        withLatitude:latitude
                       withLongitude:longitude
                       andCompletion:^(PPAstronomy *astronomy) {
                           _astronomy = astronomy;
                           if (completion) {
                               completion (_astronomy);
                           }
                       }];
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error.localizedDescription);
             [PPAlertView showErrorAlertViewWithMessage:error.localizedDescription];
             if (completion) {
                 completion(nil);
             }
         }];
}

- (void)astronomyWithDate:(NSDate *)date
             withTimeZone:(NSTimeZone *)timeZone
             withLatitude:(NSString *)latitude
            withLongitude:(NSString *)longitude
            andCompletion:(void (^)(PPAstronomy *astronomy))completion {
    NSString *string = [VPTime stringWithDate:date
                                   withFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                  andTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    [manager GET:[NSString stringWithFormat:kAstronomyURL, string, latitude, longitude]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             PPAstronomy *astronomy = [self parseAstronomy:responseObject
                                              withTimeZone:timeZone];
             astronomy.currentTime = [[VPTime alloc] initWithDate:date
                                                      andTimeZone:timeZone];
             [_timer stop];
             [_timer start];
             if (completion) {
                 completion(astronomy);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error.localizedDescription);
             [PPAlertView showErrorAlertViewWithMessage:error.localizedDescription];
             if (completion) {
                 completion(nil);
             }
         }];
}

- (PPWeather *)parseCondition:(id)responce {
    PPWeather *weather = [[PPWeather alloc] init];
    NSDictionary *dictionary = (NSDictionary *)responce[@"current_observation"];
    weather.wind_dir = dictionary[@"wind_dir"];
    weather.wind_degrees = [dictionary[@"wind_degrees"] integerValue];
    weather.wind_kph = [dictionary[@"wind_kph"] floatValue];
    weather.visibility_km = [dictionary[@"visibility_km"] floatValue];
    return weather;
}

- (NSArray <PPWeather *> *)parseHourlyForecast:(id)responce {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray <NSDictionary *> *array = responce[@"hourly_forecast"];
    for (NSDictionary *dictionary in array) {
        PPWeather *weather = [[PPWeather alloc] init];
        NSDictionary *FCTTIME = (NSDictionary *)dictionary[@"FCTTIME"];
        weather.temp = [dictionary[@"temp"][@"metric"] floatValue];
        weather.humidity = [dictionary[@"humidity"] floatValue];
        weather.icon = dictionary[@"icon"];
        weather.wind_dir = dictionary[@"wdir"][@"dir"];
        weather.wind_degrees = [dictionary[@"wdir"][@"degrees"] integerValue];
        weather.wind_kph = [dictionary[@"wspd"][@"metric"] floatValue];
        weather.time = [NSString stringWithFormat:@"%@:%@", FCTTIME[@"hour_padded"], FCTTIME[@"min"]];
        weather.conditions = dictionary[@"condition"];
        [result addObject:weather];
    }
    return result;
}

- (NSArray <PPWeather *> *)parseWeeklyForecast:(id)responce {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray <NSDictionary *> *array = responce[@"forecast"][@"simpleforecast"][@"forecastday"];
    for (NSDictionary *dictionary in array) {
        PPWeather *weather = [[PPWeather alloc] init];
        NSDictionary *date = (NSDictionary *)dictionary[@"date"];
        NSDictionary *wind = (NSDictionary *)dictionary[@"avewind"];
        weather.wind_dir = wind[@"dir"];
        weather.wind_degrees = [wind[@"degrees"] integerValue];
        weather.wind_kph = [wind[@"kph"] floatValue];
        weather.weekday = date[@"weekday"];
        weather.low = [dictionary[@"low"][@"celsius"] floatValue];
        weather.high = [dictionary[@"high"][@"celsius"] floatValue];
        weather.icon = dictionary[@"icon"];
        [result addObject:weather];
    }
    return result;
}

- (PPAstronomy *)parseAstronomy:(id)responce
                   withTimeZone:(NSTimeZone *)timeZone {
    NSString *format = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    NSDictionary *times = (NSDictionary *)responce[@"data"][@"times"];
    
    NSDate *currentTimeDate = [[VPTime dateWithString:responce[@"request"][@"date"]
                                            andFormat:format] dateByAddingTimeInterval:[timeZone secondsFromGMT]];
    VPTime *currentTime = [[VPTime alloc] initWithDate:currentTimeDate
                                           andTimeZone:nil];
    
    VPTime *sunrise;
    if (times[@"sunrise"] == [NSNull null]) {
        sunrise = nil;
    } else {
        NSDate *sunriseDate = [[VPTime dateWithString:times[@"sunrise"]
                                            andFormat:format] dateByAddingTimeInterval:[timeZone secondsFromGMT]];
        sunrise = [[VPTime alloc] initWithDate:sunriseDate
                                   andTimeZone:nil];
    }
    
    VPTime *sunriseEnd;
    if (times[@"sunriseEnd"] == [NSNull null]) {
        sunriseEnd = nil;
    } else {
        NSDate *sunriseEndDate = [[VPTime dateWithString:times[@"sunriseEnd"]
                                               andFormat:format] dateByAddingTimeInterval:[timeZone secondsFromGMT]];
        sunriseEnd = [[VPTime alloc] initWithDate:sunriseEndDate
                                      andTimeZone:nil];
    }
    
    VPTime *sunset;
    if (times[@"sunset"] == [NSNull null]) {
        sunset = nil;
    } else {
        NSDate *sunsetDate = [[VPTime dateWithString:times[@"sunset"]
                                           andFormat:format] dateByAddingTimeInterval:[timeZone secondsFromGMT]];
        sunset = [[VPTime alloc] initWithDate:sunsetDate
                                  andTimeZone:nil];
    }
    
    VPTime *sunsetStart;
    if (times[@"sunsetStart"] == [NSNull null]) {
        sunsetStart = nil;
    } else {
        NSDate *sunsetStartDate = [[VPTime dateWithString:times[@"sunsetStart"]
                                                andFormat:format] dateByAddingTimeInterval:[timeZone secondsFromGMT]];
        sunsetStart = [[VPTime alloc] initWithDate:sunsetStartDate
                                       andTimeZone:nil];
    }
    
    VPTime *goldenHour;
    if (times[@"goldenHour"] == [NSNull null]) {
        goldenHour = nil;
    } else {
        NSDate *goldenHourDate = [[VPTime dateWithString:times[@"goldenHour"]
                                               andFormat:format] dateByAddingTimeInterval:[timeZone secondsFromGMT]];
        goldenHour = [[VPTime alloc] initWithDate:goldenHourDate
                                      andTimeZone:nil];
    }
    
    VPTime *goldenHourEnd;
    if (times[@"goldenHourEnd"] == [NSNull null]) {
        goldenHourEnd = nil;
    } else {
        NSDate *goldenHourEndDate = [[VPTime dateWithString:times[@"goldenHourEnd"]
                                                  andFormat:format] dateByAddingTimeInterval:[timeZone secondsFromGMT]];
        goldenHourEnd = [[VPTime alloc] initWithDate:goldenHourEndDate
                                         andTimeZone:nil];
    }
    
    PPAstronomy *astronomy = [[PPAstronomy alloc] init];
    
    astronomy.currentTime = currentTime;
    astronomy.sunrise = sunrise;
    astronomy.sunriseEnd = sunriseEnd;
    astronomy.sunset = sunset;
    astronomy.sunsetStart = sunsetStart;
    astronomy.goldenHour = goldenHour;
    astronomy.goldenHourEnd = goldenHourEnd;
    
    astronomy.sunPosition = [[PPSunPosition alloc] init];
    if (responce[@"data"][@"currentPos"][@"altitude"] != [NSNull null]) {
        [astronomy.sunPosition setRadians:[responce[@"data"][@"currentPos"][@"altitude"] floatValue]];
    }
    
    return astronomy;
}

- (void)stopTimersAndClear {
    [_conditionTimer stop];
    [_hourlyTimer stop];
    [_weeklyTimer stop];
    
    /*
    [_astronomyTimer stop];
     */
    
    _condition = nil;
    _hourlyForecast = nil;
    _weeklyForecast = nil;
    
    /*
    _astronomy = nil;
     */
}

#pragma mark - VPTimer

- (void)timerDidTick:(VPTimer *)timer {
    if (timer == _timer && _astronomy) {
        [_astronomy.currentTime addOneSecond];
        if (_delegate) {
            if ([_delegate conformsToProtocol:@protocol(PPLocationDelegate)] &&
                [_delegate respondsToSelector:@selector(locationDidUpdateCurrentTime:)]) {
                [_delegate locationDidUpdateCurrentTime:self];
            }
        }
    }
}

- (void)timerDidTimeEnd:(VPTimer *)timer {
    if (timer == _timer) {
        if (_delegate) {
            if ([_delegate conformsToProtocol:@protocol(PPLocationDelegate)] &&
                [_delegate respondsToSelector:@selector(locationDidStopTimer:)]) {
                [_delegate locationDidStopTimer:self];
            }
        }
    }
    if (timer == _conditionTimer) {
        _condition = nil;
    }
    if (timer == _hourlyTimer) {
        _hourlyForecast = nil;
    }
    if (timer == _weeklyTimer) {
        _weeklyForecast = nil;
    }
    if (timer == _astronomyTimer) {
        _astronomy = nil;
    }
}

@end


#pragma mark - PPLocationsModel


@interface PPLocationsModel () <CLLocationManagerDelegate>

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (assign, nonatomic) CLLocationCoordinate2D lastCoordinate;

@end


@implementation PPLocationsModel

@synthesize useCurrentLocation = _useCurrentLocation;

+ (id)sharedModel {
    static PPLocationsModel *locationsModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationsModel = [[self alloc] init];
    });
    return locationsModel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _locationsForSettings = [[NSMutableArray alloc] init];
    _autocompleteLocations = [[NSMutableArray alloc] init];
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager setDistanceFilter:100.f];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self useCurrentLocation];
    [self loadLocations];
    [self toggleUpdatingLocation];
}

- (void)requestLocation {
    [_locationManager requestAlwaysAuthorization];
    [_locationManager requestWhenInUseAuthorization];
}

- (void)startUpdatingLocation {
    [_locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    [_locationManager stopUpdatingLocation];
}

- (void)loadLocations {
    NSData *data = [_userDefaults objectForKey:kLocations];
    if (data) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (array) {
            _locationsForSettings = [NSMutableArray arrayWithArray:array];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    dispatch_async(dispatch_get_main_queue(), ^{
        CLLocationCoordinate2D coordinate = locations.lastObject.coordinate;
        if (_lastCoordinate.latitude != coordinate.latitude &&
            _lastCoordinate.longitude != coordinate.longitude) {
            _lastCoordinate = coordinate;
            [self findNearestCityByLastCoordinate];
        }
    });
}

#pragma mark - Custom accessors

- (void)setUseCurrentLocation:(BOOL)useCurrentLocation {
    [_userDefaults setBool:useCurrentLocation
                    forKey:kUseCurrenLocation];
    if ([_userDefaults synchronize]) {
        _useCurrentLocation = useCurrentLocation;
    }
    [self toggleUpdatingLocation];
}

- (BOOL)useCurrentLocation {
    _useCurrentLocation = [_userDefaults boolForKey:kUseCurrenLocation];
    return _useCurrentLocation;
}

- (NSMutableArray <PPLocation *> *)locations {
    NSMutableArray <PPLocation *> *array = [NSMutableArray arrayWithArray:_locationsForSettings.mutableCopy];
    if (_useCurrentLocation && _currentLocation) {
        [array insertObject:_currentLocation
                    atIndex:0];
    }
    return array;
}

#pragma mark - Model methods

- (void)m_addLocationWithIndex:(NSUInteger)index {
    if (_locationsForSettings.count >= kMaxCityCount) {
        [PPAlertView showErrorAlertViewWithMessage:[NSString stringWithFormat:LOCALIZE(@"city_limit"), (unsigned long)kMaxCityCount]];
        return;
    }
    for (PPLocation *location in _locationsForSettings) {
        if ([location.zmw isEqualToString:_autocompleteLocations[index].zmw]) {
            return;
        }
    }
    if (_autocompleteLocations.count > 0 && index <= _autocompleteLocations.count - 1) {
        [_locationsForSettings addObject:_autocompleteLocations[index]];
        [self m_synchronize];
    }
}

- (void)m_removeLocationsWithIndex:(NSUInteger)index {
    if (_locationsForSettings.count > 0 && index <= _locationsForSettings.count - 1) {
        [_locationsForSettings removeObjectAtIndex:index];
        [self m_synchronize];
    }
}

- (void)m_replaceLocationFromSourceIndexPath:(NSIndexPath *)sourceIndexPath
                                 toIndexPath:(NSIndexPath *)indexPath {
    PPLocation *location = _locationsForSettings[sourceIndexPath.row];
    [_locationsForSettings removeObjectAtIndex:sourceIndexPath.row];
    [_locationsForSettings insertObject:location
                                atIndex:indexPath.row];
    [self m_synchronize];
}

- (BOOL)m_synchronize {
    [_userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:_locationsForSettings]
                      forKey:kLocations];
    return [_userDefaults synchronize];
}

- (void)m_autocompleteSearchWithString:(NSString *)string
                            completion:(void (^)(BOOL isSuccess))completion {
    if (!string || [string isEqualToString:@""]) {
        [_autocompleteLocations removeAllObjects];
        if (completion) {
            completion(NO);
        }
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    [manager GET:kAutocompleteURL
      parameters:@{@"query" : string}
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             BOOL isSuccess = [self parse:responseObject];
             if (completion) {
                 completion(isSuccess);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error.localizedDescription);
             [PPAlertView showErrorAlertViewWithMessage:error.localizedDescription];
             if (completion) {
                 completion(NO);
             }
         }];
}

#pragma mark - Other methods

- (BOOL)parse:(id)responce {
    [_autocompleteLocations removeAllObjects];
    NSArray *array = (NSArray *)responce[kResultApiKey];
    if (array.count == 0) {
        return NO;
    }
    for (NSUInteger i = 0; i <= array.count - 1; i++) {
        NSDictionary *dictionary = (NSDictionary *)array[i];
        if ([dictionary[@"type"] isEqualToString:@"city"]) {
            PPLocation *location = [[PPLocation alloc] initWithDictionary:dictionary];
            [_autocompleteLocations addObject:location];
        }
    }
    return !(_autocompleteLocations.count == 0);
}

- (void)toggleUpdatingLocation {
    _currentLocation = nil;
    if (_useCurrentLocation) {
        [_locationManager startUpdatingLocation];
    } else {
        [_locationManager stopUpdatingLocation];
        if ([self checkDelegate] && [_delegate respondsToSelector:@selector(didFindNearestCityByLastCoordinate)]) {
            [_delegate didFindNearestCityByLastCoordinate];
        }
    }
}

- (void)findNearestCityByLastCoordinate {
    if (!_useCurrentLocation) { // Something wrong. After stop updating location method didUpdateLocation didn't stop.
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    [manager GET:[NSString stringWithFormat:kGeolookupURL, kAPIKey, LOCALIZE(@"api_localize_key"), _lastCoordinate.latitude, _lastCoordinate.longitude]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if (!responseObject || responseObject[@"response"][@"error"]) {
                 [PPAlertView showErrorAlertViewWithMessage:responseObject[@"response"][@"error"][@"description"]];
                 return;
             }
             NSDictionary *dictionary = (NSDictionary *)responseObject[@"location"];
             NSString *zmw = dictionary[@"l"];
             zmw = [zmw stringByReplacingOccurrencesOfString:@"/q/zmw:"
                                                  withString:@""];
             if (_currentLocation && [_currentLocation.zmw isEqualToString:zmw]) {
                 return;
             }
             PPLocation *location = [[PPLocation alloc] initWithZmw:zmw
                                                            andName:dictionary[@"city"]];
             _currentLocation = location;
             if ([self checkDelegate] && [_delegate respondsToSelector:@selector(didFindNearestCityByLastCoordinate)]) {
                 [_delegate didFindNearestCityByLastCoordinate];
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error.localizedDescription);
             [PPAlertView showErrorAlertViewWithMessage:error.localizedDescription];
         }];
}

- (BOOL)checkDelegate {
    if (!_delegate || ![_delegate conformsToProtocol:@protocol(PPLocationModelDelegate)]) {
        return NO;
    }
    return YES;
}

- (void)clearAll {
    for (PPLocation *location in [self locations]) {
        [location stopTimersAndClear];
    }
}

@end
