//
//  PPGeomagneticStormModel.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 30.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPGeomagneticStormModel.h"

#import "Macros.h"
#import <AFNetworking/AFNetworking.h>
#import "VPTimer.h"
#import "PPAlertView.h"


@interface PPGeomagneticStormModel () <VPTimerDelegate>

@property (strong, nonatomic) NSNumber *index;

@property (strong, nonatomic) NSArray *dates;
@property (strong, nonatomic) NSArray *values;

@property (strong, nonatomic) NSArray <NSDictionary *> *month;

@property (strong, nonatomic) VPTimer *currentTimer;
@property (strong, nonatomic) VPTimer *threeDaysTimer;
@property (strong, nonatomic) VPTimer *monthTimer;

@end


@implementation PPGeomagneticStormModel

+ (id)sharedModel {
    static PPGeomagneticStormModel *stormModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stormModel = [[self alloc] init];
    });
    return stormModel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentTimer = [[VPTimer alloc] initTimerWithTime:kUpdateInterval];
        _threeDaysTimer = [[VPTimer alloc] initTimerWithTime:kUpdateInterval];
        _monthTimer = [[VPTimer alloc] initTimerWithTime:kUpdateInterval];
        
        [_currentTimer setDelegate:self];
        [_threeDaysTimer setDelegate:self];
        [_monthTimer setDelegate:self];
    }
    return self;
}

- (void)updateCurrentIndexWithCompletion:(void (^)(BOOL, CGFloat))completion {
    if (_isCurrentKP) {
        NSLog(@"Catched current KP info;");
        if (completion) {
            completion(YES, [_index floatValue]);
        }
        return;
    }
    NSLog(@"Load current KP info;");
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    [manager GET:@"http://services.swpc.noaa.gov/products/noaa-planetary-k-index.json"
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             BOOL success = NO;
             CGFloat index = 0.f;
             if (responseObject) {
                 success = YES;
                 NSArray *lastObject = (NSArray *)((NSArray *)responseObject).lastObject;
                 index = [lastObject[1] floatValue]; // Value at index 1 contain planetary KP-index.
             }
             _index = @(index);
             _isCurrentKP = success;
             [_currentTimer start];
             if (completion) {
                 completion(success, index);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error.localizedDescription);
             [PPAlertView showErrorAlertViewWithMessage:error.localizedDescription];
             if (completion) {
                 completion(NO, 0.f);
             }
         }];
}

- (void)updateThreeDaysForecastWithCompletion:(void (^)(BOOL, NSArray *, NSArray *))completion {
    if (_isThreeDaysKP) {
        NSLog(@"Catched three days KP info;");
        if (completion) {
            completion (YES, _dates, _values);
        }
        return;
    }
    NSLog(@"Load three days KP info;");
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    [manager GET:@"http://saltwars.herokuapp.com/saltwars_api/indexes/three_days/"
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if (!responseObject) {
                 return;
             }
             _isThreeDaysKP = YES;
             [_threeDaysTimer start];
             NSMutableArray *dates = [[NSMutableArray alloc] init];
             NSMutableArray *values = [[NSMutableArray alloc] init];
             NSArray <NSDictionary *> *days = (NSArray <NSDictionary *> *)responseObject;
             if (!days || days.count == 0) {
                 return;
             }
             for (NSDictionary *dictionary in days) {
                 [dates addObject:dictionary[@"date"]];
                 NSArray <NSDictionary *> *indexes = (NSArray <NSDictionary *> *)dictionary[@"values"];
                 if (!indexes || indexes.count == 0) {
                     return;
                 }
                 for (NSDictionary *dictionary in indexes) {
                     [values addObject:dictionary[@"index"]];
                 }
             }
             _dates = dates.copy;
             _values = values.copy;
             if (completion) {
                 completion(YES, dates, values);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error.localizedDescription);
             [PPAlertView showErrorAlertViewWithMessage:error.localizedDescription];
             if (completion) {
                 completion(NO, nil, nil);
             }
         }];
}

- (void)updateMonthForecastWithCompletion:(void (^)(BOOL, NSArray <NSDictionary *> *))completion {
    if (_isMonthKP) {
        NSLog(@"Catched month KP info;");
        if (completion) {
            completion(YES, _month);
        }
        return;
    }
    NSLog(@"Load month KP info;");
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    [manager GET:@"http://saltwars.herokuapp.com/saltwars_api/indexes/month/"
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             BOOL success = NO;
             if (responseObject) {
                 success = YES;
                 _month = (NSArray <NSDictionary *> *)responseObject;
                 if (!_month || _month.count == 0) {
                     return;
                 }
             }
             _isMonthKP = success;
             [_monthTimer start];
             if (completion) {
                 completion(success, _month);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error.localizedDescription);
             [PPAlertView showErrorAlertViewWithMessage:error.localizedDescription];
             if (completion) {
                 completion(NO, nil);
             }
         }];
}

- (void)stopTimersAndClear {
    _isCurrentKP = NO;
    _isThreeDaysKP = NO;
    _isMonthKP = NO;
    [_currentTimer stop];
    [_threeDaysTimer stop];
    [_monthTimer stop];
}

#pragma mark - VPTimerDelegate

- (void)timerDidTimeEnd:(VPTimer *)timer {
    if (timer == _currentTimer) {
        _isCurrentKP = NO;
    }
    if (timer == _threeDaysTimer) {
        _isThreeDaysKP = NO;
    }
    if (timer == _monthTimer) {
        _isMonthKP = NO;
    }
}

@end
