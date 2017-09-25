//
//  PPGeomagneticStormModel.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 30.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>


#define kMaxKPIndex (9.f)


@interface PPGeomagneticStormModel : NSObject

@property (assign, nonatomic) BOOL isCurrentKP;
@property (assign, nonatomic) BOOL isThreeDaysKP;
@property (assign, nonatomic) BOOL isMonthKP;

+ (id)sharedModel;

- (void)updateCurrentIndexWithCompletion:(void (^)(BOOL success, CGFloat index))completion;
- (void)updateThreeDaysForecastWithCompletion:(void (^)(BOOL success, NSArray *dates, NSArray *values))completion;
- (void)updateMonthForecastWithCompletion:(void (^)(BOOL success, NSArray <NSDictionary *> *responce))completion;

- (void)stopTimersAndClear;

@end
