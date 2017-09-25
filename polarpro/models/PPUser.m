//
//  PPUser.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPUser.h"


#define kUserName (@"user_name")
#define kUserEmail (@"user_email")

#define kUserDevices (@"user_devices")
#define kUserFilters (@"user_filters")

#define kUserSelectedParameters (@"user_selected_parameters")

#define kUserHubOrder (@"user_hub_order")

#define kNotFirstTimeUseLocation (@"user_not_first_time_use_location")
#define kNotFirstTimeUseNotifications (@"user_not_first_time_use_notifications")


@interface PPUser ()

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end


@implementation PPUser

@synthesize name = _name;
@synthesize email = _email;

@synthesize hubOrder = _hubOrder;

@synthesize notFirstTimeUseLocation = _notFirstTimeUseLocation;
@synthesize notFirstTimeUseNotifications = _notFirstTimeUseNotifications;

+ (id)sharedUser {
    static PPUser *user = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[self alloc] init];
    });
    return user;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _devicesAvailable = [[NSMutableArray alloc] initWithArray:(NSArray *)[_userDefaults objectForKey:kUserDevices]];
        _filtersAvailable = [[NSMutableArray alloc] initWithArray:(NSArray *)[_userDefaults objectForKey:kUserFilters]];
    }
    return self;
}

#pragma mark - Methods

- (BOOL)u_checkDeviceWithIdentifier:(NSUInteger)identifier {
    return [self checkExistWithArray:_devicesAvailable
                       andIdentifier:identifier];
}

- (BOOL)u_checkFilterWithIdentifier:(NSUInteger)identifier {
    return [self checkExistWithArray:_filtersAvailable
                       andIdentifier:identifier];
}

- (NSArray *)u_selectedParametersWithIdentifier:(NSUInteger)identifier {
    return [_userDefaults objectForKey:[NSString stringWithFormat:@"%@_%ld", kUserSelectedParameters, (unsigned long)identifier]];
}

- (BOOL)u_saveSelectedParameters:(NSArray *)selectedParameters
                  withIdentifier:(NSUInteger)identifier {
    [_userDefaults setObject:selectedParameters
                      forKey:[NSString stringWithFormat:@"%@_%ld", kUserSelectedParameters, (unsigned long)identifier]];
    return [_userDefaults synchronize];
}

- (BOOL)u_addDeviceWithIdentifier:(NSUInteger)identifier {
    if (![self checkExistWithArray:_devicesAvailable
                     andIdentifier:identifier]) {
        [_devicesAvailable addObject:[NSNumber numberWithInteger:identifier]];
        [_userDefaults setObject:_devicesAvailable
                          forKey:kUserDevices];
        if ([_userDefaults synchronize]) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)u_addFilterWithIdentifier:(NSUInteger)identifier {
    if (![self checkExistWithArray:_filtersAvailable
                     andIdentifier:identifier]) {
        [_filtersAvailable addObject:[NSNumber numberWithInteger:identifier]];
        [_userDefaults setObject:_filtersAvailable
                          forKey:kUserFilters];
        if ([_userDefaults synchronize]) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)u_remoweDeviceWithIdentifier:(NSUInteger)identifier {
    if ([self checkExistWithArray:_devicesAvailable
                    andIdentifier:identifier]) {
        [_devicesAvailable removeObject:[NSNumber numberWithInteger:identifier]];
        [_userDefaults setObject:_devicesAvailable
                          forKey:kUserDevices];
        if ([_userDefaults synchronize]) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)u_remoweFilterWithIdentifier:(NSUInteger)identifier {
    if ([self checkExistWithArray:_filtersAvailable
                    andIdentifier:identifier]) {
        [_filtersAvailable removeObject:[NSNumber numberWithInteger:identifier]];
        [_userDefaults setObject:_filtersAvailable
                          forKey:kUserFilters];
        if ([_userDefaults synchronize]) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)u_saveOptionWithInteger:(NSUInteger)integer andKey:(NSString *)key {
    [_userDefaults setInteger:integer
                       forKey:key];
    return [_userDefaults synchronize];
}

- (NSUInteger)u_optionWithKey:(NSString *)key {
    return [_userDefaults integerForKey:key];
}

#pragma mark - Custom accessors

- (void)setName:(NSString *)name {
    [_userDefaults setObject:name
                      forKey:kUserName];
    if ([_userDefaults synchronize]) {
        _name = name;
    }
}

- (NSString *)name {
    if (!_name) {
        _name = [_userDefaults stringForKey:kUserName];
    }
    return _name;
}

- (void)setEmail:(NSString *)email {
    [_userDefaults setObject:email
                      forKey:kUserEmail];
    if ([_userDefaults synchronize]) {
        _email = email;
    }
}

- (NSString *)email {
    if (!_email) {
        _email = [_userDefaults stringForKey:kUserEmail];
    }
    return _email;
}

- (void)setHubOrder:(NSArray *)hubOrder {
    if (hubOrder) {
        [_userDefaults setObject:hubOrder
                          forKey:kUserHubOrder];
        if ([_userDefaults synchronize]) {
            _hubOrder = hubOrder;
        }
    }
}

- (NSArray *)hubOrder {
    if (_hubOrder.count == 0) {
        NSArray *array = [_userDefaults objectForKey:kUserHubOrder];
        if (array.count == 0) {
            [self setHubOrder:@[@0, @1, @2, @3]];
        } else {
            _hubOrder = array;
        }
    }
    return _hubOrder;
}

- (void)setNotFirstTimeUseLocation:(BOOL)notFirstTimeUseLocation {
    [_userDefaults setBool:notFirstTimeUseLocation
                    forKey:kNotFirstTimeUseLocation];
    if ([_userDefaults synchronize]) {
        _notFirstTimeUseLocation = notFirstTimeUseLocation;
    }
}

- (BOOL)notFirstTimeUseLocation {
    return [_userDefaults boolForKey:kNotFirstTimeUseLocation];
}

- (void)setNotFirstTimeUseNotifications:(BOOL)notFirstTimeUseNotifications {
    [_userDefaults setBool:notFirstTimeUseNotifications
                    forKey:kNotFirstTimeUseNotifications];
    if ([_userDefaults synchronize]) {
        _notFirstTimeUseNotifications = notFirstTimeUseNotifications;
    }
}

- (BOOL)notFirstTimeUseNotifications {
    return [_userDefaults boolForKey:kNotFirstTimeUseNotifications];
}

#pragma mark - Other methods

- (BOOL)checkExistWithArray:(NSMutableArray <NSNumber *> *)array
              andIdentifier:(NSUInteger)identifier {
    for (NSNumber *number in array) {
        if ([number isEqualToNumber:[NSNumber numberWithInteger:identifier]]) {
            return YES;
        }
    }
    return NO;
}

@end
