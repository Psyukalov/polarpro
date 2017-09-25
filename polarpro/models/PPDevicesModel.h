//
//  PPDevicesModel.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 11.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface PPParameter : NSObject

@property (assign, readonly, nonatomic) NSUInteger identifier;
@property (strong, readonly, nonatomic) NSString *caption;

- (instancetype)initWithIdentifier:(NSUInteger)identifier
                        andCaption:(NSString *)caption;

@end


@interface PPFilter : NSObject

@property (assign, nonatomic) NSUInteger identifier;

@property (strong, nonatomic) NSString *model;
@property (strong, nonatomic) NSString *URL;

@property (assign, nonatomic) BOOL isAvailable;
@property (assign, nonatomic) BOOL isCalculatorParameter;

- (instancetype)initWithIdentifier:(NSUInteger)identifier
                          andModel:(NSString *)model;

- (void)addFilter;
- (void)removeFilter;

@end


@interface PPDevice : NSObject

@property (assign, nonatomic) NSUInteger identifier;

@property (strong, nonatomic) NSString *mark;
@property (strong, nonatomic) NSString *model;

@property (strong, nonatomic) NSMutableArray <PPParameter *> *FPSList;
@property (strong, nonatomic) NSMutableArray <PPParameter *> *shutterSpeedList;

@property (strong, nonatomic) NSMutableArray <PPFilter *> *filters;

@property (strong, nonatomic) NSArray *selectedParameters;

@property (assign, nonatomic) BOOL isAvailable;

- (instancetype)initWithIdentifier:(NSUInteger)identifier
                          withMark:(NSString *)mark
                          andModel:(NSString *)model;

- (void)addDevice;
- (void)removeDevice;

- (NSArray <NSString *> *)FPSCaptions;
- (NSArray <NSString *> *)shutterSpeedCaptions;
- (NSArray <NSString *> *)installedFiltersCaptions;

@end


@interface PPDevicesModel : NSObject

@property (assign, nonatomic) BOOL isUpdate;

@property (strong, nonatomic) NSMutableArray <PPDevice *> *devices;
@property (strong, nonatomic) NSMutableArray <PPDevice *> *availableDevices;

+ (id)sharedDevicesModel;

- (void)m_addDeviceWithIndex:(NSUInteger)index;
- (void)m_removeDeviceWithIndex:(NSUInteger)index;

- (void)m_addFilterWithSection:(NSUInteger)section
                        andRow:(NSUInteger)row;
- (void)m_removeFilterWithSection:(NSUInteger)section
                           andRow:(NSUInteger)row;

- (void)m_allFiltersInDeviceWithIdentifier:(NSUInteger)identifier;
- (void)m_noneFiltersInDeviceWithIdentifier:(NSUInteger)identifier;

- (BOOL)m_checkAllFiltersInDeviceWithIdentifier:(NSUInteger)identifier;

- (PPFilter *)m_filterWithName:(NSString *)filterName
             forDeviceWithName:(NSString *)deviceName;

@end
