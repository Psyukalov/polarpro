//
//  PPSettingsModel.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 15.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPSettingsModel.h"

#import "AppDelegate.h"

#import "Macros.h"
#import <CoreLocation/CoreLocation.h>

#import "PPUser.h"


#pragma mark - PPSettingsOption

@implementation PPSettingsOption

@synthesize title = _title;
@synthesize key = _key;

@synthesize parameters = _parameters;

- (instancetype)initWithTitle:(NSString *)title
                      withKey:(NSString *)key
                andParameters:(NSArray<NSString *> *)parameters {
    self = [super init];
    if (self) {
        _title = title;
        _key = key;
        _parameters = parameters;
        _currentParameter = [[PPUser sharedUser] u_optionWithKey:_key];
    }
    return self;
}

- (void)setCurrentParameter:(NSUInteger)currentParameter {
    if (currentParameter > _parameters.count - 1) {
        return;
    }
    if ([[PPUser sharedUser] u_saveOptionWithInteger:currentParameter
                                              andKey:_key]) {
        _currentParameter = currentParameter;
    }
}

@end

#pragma mark - PPSettingsGroup

@implementation PPSettingsGroup

@synthesize title = _title;

@synthesize options = _options;

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        _title = title;
        _options = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

#pragma mark - PPSettingsModel

@implementation PPSettingsModel

@synthesize groups = _groups;

+ (id)sharedModel {
    static PPSettingsModel *settingsModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settingsModel = [[self alloc] init];
    });
    return settingsModel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        PPSettingsGroup *group_0 = [[PPSettingsGroup alloc] initWithTitle:LOCALIZE(@"units")];
        PPSettingsGroup *group_1 = [[PPSettingsGroup alloc] initWithTitle:LOCALIZE(@"time")];
        
        /*
        PPSettingsGroup *group_2 = [[PPSettingsGroup alloc] initWithTitle:LOCALIZE(@"notifications")];
         */
        
        PPSettingsOption *option_0_0 = [[PPSettingsOption alloc] initWithTitle:LOCALIZE(@"temperature")
                                                                       withKey:@"option_temperature"
                                                                 andParameters:@[[NSString stringWithFormat:@"%@%@", @"\u00B0", LOCALIZE(@"p_f")],
                                                                                 [NSString stringWithFormat:@"%@%@", @"\u00B0", LOCALIZE(@"p_c")]]];
        PPSettingsOption *option_0_1 = [[PPSettingsOption alloc] initWithTitle:LOCALIZE(@"wind_speed")
                                                                       withKey:@"option_wind_speed"
                                                                 andParameters:@[LOCALIZE(@"p_mph"),
                                                                                 LOCALIZE(@"p_km_h"),
                                                                                 LOCALIZE(@"p_m_s"),
                                                                                 LOCALIZE(@"p_knots")]];
        
        PPSettingsOption *option_1_0 = [[PPSettingsOption alloc] initWithTitle:LOCALIZE(@"use_24")
                                                                       withKey:@"option_use_24"
                                                                 andParameters:@[LOCALIZE(@"p_yes"),
                                                                                 LOCALIZE(@"p_no")]];
        
        /*
        PPNotificationOption *option_2_0 = [[PPNotificationOption alloc] initWithTitle:LOCALIZE(@"send_notifications")
                                                                               withKey:@"option_send_notifications"
                                                                         andParameters:@[LOCALIZE(@"p_yes"),
                                                                                         LOCALIZE(@"p_no")]];
        
        PPSettingsOption *option_3_0 = [[PPSettingsOption alloc] initWithTitle:LOCALIZE(@"use_geo_locations")
                                                                       withKey:@"option_use_geo_locations"
                                                                 andParameters:@[LOCALIZE(@"p_yes"),
                                                                                 LOCALIZE(@"p_no")]];
         */
        
        [group_0 setOptions:[NSMutableArray arrayWithArray:@[option_0_0, option_0_1]]];
        [group_1 setOptions:[NSMutableArray arrayWithArray:@[option_1_0]]];
        
        /*
        [group_2 setOptions:[NSMutableArray arrayWithArray:@[option_2_0]]];
         */
        
        _groups = [NSMutableArray arrayWithArray:@[group_0,
                                                   group_1]];
    }
    return self;
}

- (void)m_saveOptionWithGroup:(NSUInteger)group
                   withOption:(NSUInteger)option
                 andParameter:(NSUInteger)parameter {
    if (_groups.count > 0) {
        if (_groups[group].options.count > 0) {
            [_groups[group].options[option] setCurrentParameter:parameter];
        }
    }
}

@end
