//
//  PPUser.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface PPUser : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;

@property (strong, nonatomic) NSMutableArray <NSNumber *> *devicesAvailable;
@property (strong, nonatomic) NSMutableArray <NSNumber *> *filtersAvailable;

@property (strong, nonatomic) NSArray *hubOrder;

@property (assign, nonatomic) BOOL notFirstTimeUseLocation;
@property (assign, nonatomic) BOOL notFirstTimeUseNotifications;

+ (id)sharedUser;

- (BOOL)u_checkDeviceWithIdentifier:(NSUInteger)identifier;
- (BOOL)u_checkFilterWithIdentifier:(NSUInteger)identifier;

- (NSArray *)u_selectedParametersWithIdentifier:(NSUInteger)identifier;
- (BOOL)u_saveSelectedParameters:(NSArray *)selectedParameters
                  withIdentifier:(NSUInteger)identifier;

- (BOOL)u_addDeviceWithIdentifier:(NSUInteger)identifier;
- (BOOL)u_addFilterWithIdentifier:(NSUInteger)identifier;

- (BOOL)u_remoweDeviceWithIdentifier:(NSUInteger)identifier;
- (BOOL)u_remoweFilterWithIdentifier:(NSUInteger)identifier;

- (NSUInteger)u_optionWithKey:(NSString *)key;
- (BOOL)u_saveOptionWithInteger:(NSUInteger)integer
                         andKey:(NSString *)key;

@end
