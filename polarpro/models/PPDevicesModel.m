//
//  PPDevicesModel.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 11.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPDevicesModel.h"

#import "PPUser.h"


#pragma mark - PPParameter


@implementation PPParameter

- (instancetype)initWithIdentifier:(NSUInteger)identifier
                        andCaption:(NSString *)caption {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _caption = caption;
    }
    return self;
}

@end


#pragma mark - PPFilter


@implementation PPFilter

@synthesize identifier = _identifier;

@synthesize model = _model;

@synthesize isAvailable = _isAvailable;

- (instancetype)initWithIdentifier:(NSUInteger)identifier
                          andModel:(NSString *)model {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _model = model;
        _isAvailable = [[PPUser sharedUser] u_checkFilterWithIdentifier:_identifier];
    }
    return self;
}

- (void)addFilter {
    _isAvailable = [[PPUser sharedUser] u_addFilterWithIdentifier:_identifier];
}

- (void)removeFilter {
    _isAvailable = ![[PPUser sharedUser] u_remoweFilterWithIdentifier:_identifier];
}

@end


#pragma mark - PPDevice


@implementation PPDevice

@synthesize identifier = _identifier;

@synthesize mark = _mark;
@synthesize model = _model;

@synthesize isAvailable = _isAvailable;

@synthesize filters = _filters;

- (instancetype)initWithIdentifier:(NSUInteger)identifier
                          withMark:(NSString *)mark
                          andModel:(NSString *)model {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _mark = mark;
        _model = model;
        _isAvailable = [[PPUser sharedUser] u_checkDeviceWithIdentifier:_identifier];
        _filters = [[NSMutableArray alloc] init];
        NSArray *selectedParameters = [[PPUser sharedUser] u_selectedParametersWithIdentifier:_identifier];
        if (!selectedParameters) {
            selectedParameters = @[@0, @0, @0];
        }
        _selectedParameters = selectedParameters;
        
    }
    return self;
}

- (void)setSelectedParameters:(NSArray *)selectedParameters {
    BOOL synhronize = [[PPUser sharedUser] u_saveSelectedParameters:selectedParameters
                                                     withIdentifier:_identifier];
    if (synhronize) {
        _selectedParameters = selectedParameters;
    }
}

- (void)addDevice {
    _isAvailable = [[PPUser sharedUser] u_addDeviceWithIdentifier:_identifier];
}

- (void)removeDevice {
    _isAvailable = ![[PPUser sharedUser] u_remoweDeviceWithIdentifier:_identifier];
}

- (NSArray <NSString *> *)FPSCaptions {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (PPParameter *parameter in _FPSList) {
        [result addObject:parameter.caption];
    }
    return result.copy;
}

- (NSArray <NSString *> *)shutterSpeedCaptions {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (PPParameter *parameter in _shutterSpeedList) {
        [result addObject:parameter.caption];
    }
    return result.copy;
}

- (NSArray <NSString *> *)installedFiltersCaptions {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (PPFilter *filter in _filters) {
        if (filter.isAvailable && filter.isCalculatorParameter) {
            [result addObject:filter.model];
        }
    }
    return result.copy;
}

@end


#pragma mark - PPDevicesModel


@interface PPDevicesModel ()

@property (assign, nonatomic) BOOL isModified;

@end


@implementation PPDevicesModel

@synthesize devices = _devices;
@synthesize availableDevices = _availableDevices;


+ (id)sharedDevicesModel {
    static PPDevicesModel *devicesModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        devicesModel = [[self alloc] init];
    });
    return devicesModel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _devices = [[NSMutableArray alloc] init];
        _availableDevices = [[NSMutableArray alloc] init];
        _isModified = YES;
        [self setupDevices];
    }
    return self;
}

- (void)m_addDeviceWithIndex:(NSUInteger)index {
    [_devices[index] addDevice];
    _isModified = YES;
    _isUpdate = YES;
}

- (void)m_removeDeviceWithIndex:(NSUInteger)index {
    [_devices[index] removeDevice];
    _isModified = YES;
    _isUpdate = YES;
}

- (void)m_addFilterWithSection:(NSUInteger)section
                        andRow:(NSUInteger)row {
    [_availableDevices[section].filters[row] addFilter];
    _isUpdate = YES;
}

- (void)m_removeFilterWithSection:(NSUInteger)section
                           andRow:(NSUInteger)row {
    [_availableDevices[section].filters[row] removeFilter];
    _isUpdate = YES;
}

- (void)m_allFiltersInDeviceWithIdentifier:(NSUInteger)identifier {
    [self switchAvailable:YES
            andIdentifier:identifier];
    _isUpdate = YES;
}

- (void)m_noneFiltersInDeviceWithIdentifier:(NSUInteger)identifier {
    [self switchAvailable:NO
            andIdentifier:identifier];
    _isUpdate = YES;
}

- (BOOL)m_checkAllFiltersInDeviceWithIdentifier:(NSUInteger)identifier {
    for (PPFilter *filter in _availableDevices[identifier].filters) {
        if (!filter.isAvailable) {
            return NO;
        }
    }
    return YES;
}

- (PPFilter *)m_filterWithName:(NSString *)filterName
             forDeviceWithName:(NSString *)deviceName {
    PPDevice *currentDevice;
    for (PPDevice *device in _availableDevices) {
        if ([deviceName isEqualToString:[NSString stringWithFormat:@"%@ %@", device.mark, device.model]]) {
            currentDevice = device;
        }
    }
    PPFilter *currentFilter;
    for (PPFilter *filter in currentDevice.filters) {
        if ([filterName isEqualToString:filter.model]) {
            currentFilter = filter;
        }
    }
    return currentFilter;
}

- (void)switchAvailable:(BOOL)isAvailable
          andIdentifier:(NSUInteger)identifier {
    for (PPFilter *filter in _availableDevices[identifier].filters) {
        if (isAvailable) {
            [filter addFilter];
        } else {
            [filter removeFilter];
        }
    }
}

- (NSMutableArray <PPDevice *> *)availableDevices {
    if (_isModified) {
        NSMutableArray <PPDevice *> *result = [[NSMutableArray alloc] init];
        for (PPDevice *device in _devices) {
            if (device.isAvailable) {
                [result addObject:device];
            }
        }
        _availableDevices = result;
        _isModified = NO;
    }
    return _availableDevices;
}

- (void)setupDevices {
    // FPS list
    PPParameter *FPS_24 = [[PPParameter alloc] initWithIdentifier:0 andCaption:@"24"];
    PPParameter *FPS_25 = [[PPParameter alloc] initWithIdentifier:1 andCaption:@"25"];
    PPParameter *FPS_30 = [[PPParameter alloc] initWithIdentifier:2 andCaption:@"30"];
    PPParameter *FPS_48 = [[PPParameter alloc] initWithIdentifier:3 andCaption:@"48"];
    PPParameter *FPS_50 = [[PPParameter alloc] initWithIdentifier:4 andCaption:@"50"];
    PPParameter *FPS_60 = [[PPParameter alloc] initWithIdentifier:5 andCaption:@"60"];
    PPParameter *FPS_120 = [[PPParameter alloc] initWithIdentifier:6 andCaption:@"120"];
    
    // Shutter speed list
    
    /*
     PPParameter *ss_1 = [[PPParameter alloc] initWithIdentifier:0 andCaption:@"1"];
     PPParameter *ss_3 = [[PPParameter alloc] initWithIdentifier:1 andCaption:@"1/3"];
     PPParameter *ss_7 = [[PPParameter alloc] initWithIdentifier:2 andCaption:@"1/7"];
     PPParameter *ss_15 = [[PPParameter alloc] initWithIdentifier:3 andCaption:@"1/15"];
     */
    
    PPParameter *ss_25 = [[PPParameter alloc] initWithIdentifier:4 andCaption:@"1/25"];
    PPParameter *ss_30 = [[PPParameter alloc] initWithIdentifier:5 andCaption:@"1/30"];
    PPParameter *ss_50 = [[PPParameter alloc] initWithIdentifier:6 andCaption:@"1/50"];
    PPParameter *ss_60 = [[PPParameter alloc] initWithIdentifier:7 andCaption:@"1/60"];
    PPParameter *ss_100 = [[PPParameter alloc] initWithIdentifier:8 andCaption:@"1/100"];
    PPParameter *ss_120 = [[PPParameter alloc] initWithIdentifier:9 andCaption:@"1/120"];
    PPParameter *ss_200 = [[PPParameter alloc] initWithIdentifier:10 andCaption:@"1/200"];
    PPParameter *ss_240 = [[PPParameter alloc] initWithIdentifier:11 andCaption:@"1/240"];
    PPParameter *ss_400 = [[PPParameter alloc] initWithIdentifier:12 andCaption:@"1/400"];
    PPParameter *ss_500 = [[PPParameter alloc] initWithIdentifier:13 andCaption:@"1/500"];
    PPParameter *ss_800 = [[PPParameter alloc] initWithIdentifier:14 andCaption:@"1/800"];
    PPParameter *ss_1000 = [[PPParameter alloc] initWithIdentifier:15 andCaption:@"1/1000"];
    PPParameter *ss_1600 = [[PPParameter alloc] initWithIdentifier:16 andCaption:@"1/1600"];
    PPParameter *ss_2000 = [[PPParameter alloc] initWithIdentifier:17 andCaption:@"1/2000"];
    PPParameter *ss_3200 = [[PPParameter alloc] initWithIdentifier:18 andCaption:@"1/3200"];
    
    PPParameter *ss_40 = [[PPParameter alloc] initWithIdentifier:19 andCaption:@"1/40"];
    PPParameter *ss_80 = [[PPParameter alloc] initWithIdentifier:20 andCaption:@"1/80"];
    PPParameter *ss_160 = [[PPParameter alloc] initWithIdentifier:21 andCaption:@"1/160"];
    PPParameter *ss_320 = [[PPParameter alloc] initWithIdentifier:22 andCaption:@"1/320"];
    PPParameter *ss_640 = [[PPParameter alloc] initWithIdentifier:24 andCaption:@"1/640"];
    PPParameter *ss_1250 = [[PPParameter alloc] initWithIdentifier:25 andCaption:@"1/1250"];
    PPParameter *ss_2500 = [[PPParameter alloc] initWithIdentifier:26 andCaption:@"1/2500"];
    
    // Filters
    PPFilter *mavic_pro_uv = [[PPFilter alloc] initWithIdentifier:0
                                                         andModel:@"UV"];
    PPFilter *mavic_pro_cp = [[PPFilter alloc] initWithIdentifier:1
                                                         andModel:@"CP"];
    PPFilter *mavic_pro_nd4_pl = [[PPFilter alloc] initWithIdentifier:2
                                                             andModel:@"ND4/PL"];
    PPFilter *mavic_pro_nd8 = [[PPFilter alloc] initWithIdentifier:3
                                                          andModel:@"ND8"];
    PPFilter *mavic_pro_nd8_pl = [[PPFilter alloc] initWithIdentifier:4
                                                             andModel:@"ND8/PL"];
    PPFilter *mavic_pro_nd16 = [[PPFilter alloc] initWithIdentifier:5
                                                           andModel:@"ND16"];
    PPFilter *mavic_pro_nd16_pl = [[PPFilter alloc] initWithIdentifier:6
                                                              andModel:@"ND16/PL"];
    PPFilter *mavic_pro_nd32 = [[PPFilter alloc] initWithIdentifier:7
                                                           andModel:@"ND32"];
    PPFilter *mavic_pro_nd32_pl = [[PPFilter alloc] initWithIdentifier:8
                                                              andModel:@"ND32/PL"];
    PPFilter *mavic_pro_nd64 = [[PPFilter alloc] initWithIdentifier:9
                                                           andModel:@"ND64"];
    PPFilter *mavic_pro_nd64_pl = [[PPFilter alloc] initWithIdentifier:10
                                                              andModel:@"ND64/PL"];
    
    [mavic_pro_uv setURL:@"https://www.polarprofilters.com/collections/dji-mavic-filters-and-accessories/products/dji-mavic-uv-filter"];
    [mavic_pro_cp setURL:@"https://www.polarprofilters.com/collections/dji-mavic-filters-and-accessories"];
    [mavic_pro_nd4_pl setURL:@"https://www.polarprofilters.com/collections/dji-mavic-filters-and-accessories"];
    [mavic_pro_nd8 setURL:@"https://www.polarprofilters.com/collections/dji-mavic-filters-and-accessories"];
    [mavic_pro_nd8_pl setURL:@"https://www.polarprofilters.com/collections/dji-mavic-filters-and-accessories"];
    [mavic_pro_nd16 setURL:@"https://www.polarprofilters.com/collections/dji-mavic-filters-and-accessories"];
    [mavic_pro_nd16_pl setURL:@"https://www.polarprofilters.com/collections/dji-mavic-filters-and-accessories"];
    [mavic_pro_nd32 setURL:@"https://www.polarprofilters.com/collections/dji-mavic-filters-and-accessories"];
    [mavic_pro_nd32_pl setURL:@"https://www.polarprofilters.com/collections/dji-mavic-filters-and-accessories"];
    [mavic_pro_nd64 setURL:@"https://www.polarprofilters.com/collections/dji-mavic-filters-and-accessories"];
    [mavic_pro_nd64_pl setURL:@"https://www.polarprofilters.com/collections/dji-mavic-filters-and-accessories"];
    
    [mavic_pro_nd8 setIsCalculatorParameter:YES];
    [mavic_pro_nd16 setIsCalculatorParameter:YES];
    [mavic_pro_nd32 setIsCalculatorParameter:YES];
    [mavic_pro_nd64 setIsCalculatorParameter:YES];
    
    PPFilter *phantom_4_pro_uv = [[PPFilter alloc] initWithIdentifier:11
                                                             andModel:@"UV"];
    PPFilter *phantom_4_pro_nd4 = [[PPFilter alloc] initWithIdentifier:12
                                                              andModel:@"ND4"];
    PPFilter *phantom_4_pro_nd4_pl = [[PPFilter alloc] initWithIdentifier:13
                                                                 andModel:@"ND4/PL"];
    PPFilter *phantom_4_pro_nd8 = [[PPFilter alloc] initWithIdentifier:14
                                                              andModel:@"ND8"];
    PPFilter *phantom_4_pro_nd8_pl = [[PPFilter alloc] initWithIdentifier:15
                                                                 andModel:@"ND8/PL"];
    PPFilter *phantom_4_pro_nd16 = [[PPFilter alloc] initWithIdentifier:16
                                                               andModel:@"ND16"];
    PPFilter *phantom_4_pro_nd16_pl = [[PPFilter alloc] initWithIdentifier:17
                                                                  andModel:@"ND16/PL"];
    PPFilter *phantom_4_pro_nd32 = [[PPFilter alloc] initWithIdentifier:18
                                                               andModel:@"ND32"];
    PPFilter *phantom_4_pro_nd32_pl = [[PPFilter alloc] initWithIdentifier:19
                                                                  andModel:@"ND32/PL"];
    PPFilter *phantom_4_pro_nd64 = [[PPFilter alloc] initWithIdentifier:20
                                                               andModel:@"ND64"];
    
    [phantom_4_pro_uv setURL:@"https://www.polarprofilters.com/collections/dji-phantom-4-pro/products/phantom-4-pro-uv-filter"];
    [phantom_4_pro_nd4 setURL:@"https://www.polarprofilters.com/collections/dji-phantom-4-pro"];
    [phantom_4_pro_nd4_pl setURL:@"https://www.polarprofilters.com/collections/dji-phantom-4-pro"];
    [phantom_4_pro_nd8 setURL:@"https://www.polarprofilters.com/collections/dji-phantom-4-pro"];
    [phantom_4_pro_nd8_pl setURL:@"https://www.polarprofilters.com/collections/dji-phantom-4-pro"];
    [phantom_4_pro_nd16 setURL:@"https://www.polarprofilters.com/collections/dji-phantom-4-pro"];
    [phantom_4_pro_nd16_pl setURL:@"https://www.polarprofilters.com/collections/dji-phantom-4-pro"];
    [phantom_4_pro_nd32 setURL:@"https://www.polarprofilters.com/collections/dji-phantom-4-pro"];
    [phantom_4_pro_nd32_pl setURL:@"https://www.polarprofilters.com/collections/dji-phantom-4-pro"];
    [phantom_4_pro_nd64 setURL:@"https://www.polarprofilters.com/collections/dji-phantom-4-pro"];
    
    [phantom_4_pro_nd4 setIsCalculatorParameter:YES];
    [phantom_4_pro_nd8 setIsCalculatorParameter:YES];
    [phantom_4_pro_nd16 setIsCalculatorParameter:YES];
    [phantom_4_pro_nd32 setIsCalculatorParameter:YES];
    [phantom_4_pro_nd64 setIsCalculatorParameter:YES];
    
    PPFilter *phantom_4_cp = [[PPFilter alloc] initWithIdentifier:21
                                                         andModel:@"CP"];
    PPFilter *phantom_4_nd4 = [[PPFilter alloc] initWithIdentifier:22
                                                          andModel:@"ND4"];
    PPFilter *phantom_4_nd8 = [[PPFilter alloc] initWithIdentifier:23
                                                          andModel:@"ND8"];
    PPFilter *phantom_4_nd8_pl = [[PPFilter alloc] initWithIdentifier:24
                                                             andModel:@"ND8/PL"];
    PPFilter *phantom_4_nd16 = [[PPFilter alloc] initWithIdentifier:25
                                                           andModel:@"ND16"];
    PPFilter *phantom_4_nd16_pl = [[PPFilter alloc] initWithIdentifier:26
                                                              andModel:@"ND16/PL"];
    PPFilter *phantom_4_nd32 = [[PPFilter alloc] initWithIdentifier:27
                                                           andModel:@"ND32"];
    PPFilter *phantom_4_nd32_pl = [[PPFilter alloc] initWithIdentifier:28
                                                              andModel:@"ND32/PL"];
    PPFilter *phantom_4_nd64 = [[PPFilter alloc] initWithIdentifier:29
                                                           andModel:@"ND64"];
    
    [phantom_4_cp setURL:@"https://www.polarprofilters.com/collections/phantom-4-accessories"];
    [phantom_4_nd4 setURL:@"https://www.polarprofilters.com/collections/phantom-4-accessories"];
    [phantom_4_nd8 setURL:@"https://www.polarprofilters.com/collections/phantom-4-accessories"];
    [phantom_4_nd8_pl setURL:@"https://www.polarprofilters.com/collections/phantom-4-accessories"];
    [phantom_4_nd16 setURL:@"https://www.polarprofilters.com/collections/phantom-4-accessories"];
    [phantom_4_nd16_pl setURL:@"https://www.polarprofilters.com/collections/phantom-4-accessories"];
    [phantom_4_nd32 setURL:@"https://www.polarprofilters.com/collections/phantom-4-accessories"];
    [phantom_4_nd32_pl setURL:@"https://www.polarprofilters.com/collections/phantom-4-accessories/products/djiphantom3filternd32"];
    [phantom_4_nd64 setURL:@"https://www.polarprofilters.com/collections/phantom-4-accessories/products/djiphantom3nd64"];
    
    [phantom_4_nd4 setIsCalculatorParameter:YES];
    [phantom_4_nd8 setIsCalculatorParameter:YES];
    [phantom_4_nd16 setIsCalculatorParameter:YES];
    [phantom_4_nd32 setIsCalculatorParameter:YES];
    [phantom_4_nd64 setIsCalculatorParameter:YES];
    
    PPFilter *x_5_s_uv = [[PPFilter alloc] initWithIdentifier:30
                                                     andModel:@"UV"];
    PPFilter *x_5_s_cp = [[PPFilter alloc] initWithIdentifier:31
                                                     andModel:@"CP"];
    PPFilter *x_5_s_nd8 = [[PPFilter alloc] initWithIdentifier:32
                                                      andModel:@"ND8"];
    PPFilter *x_5_s_nd8_pl = [[PPFilter alloc] initWithIdentifier:33
                                                         andModel:@"ND8/PL"];
    PPFilter *x_5_s_nd16 = [[PPFilter alloc] initWithIdentifier:34
                                                       andModel:@"ND16"];
    PPFilter *x_5_s_nd16_pl = [[PPFilter alloc] initWithIdentifier:35
                                                          andModel:@"ND16/PL"];
    PPFilter *x_5_s_nd32 = [[PPFilter alloc] initWithIdentifier:36
                                                       andModel:@"ND32"];
    
    [x_5_s_uv setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_s_cp setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_s_nd8 setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_s_nd8_pl setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_s_nd16 setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_s_nd16_pl setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_s_nd32 setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    
    [x_5_s_nd8 setIsCalculatorParameter:YES];
    [x_5_s_nd16 setIsCalculatorParameter:YES];
    [x_5_s_nd32 setIsCalculatorParameter:YES];
    
    PPFilter *x_5_r_uv = [[PPFilter alloc] initWithIdentifier:37
                                                     andModel:@"UV"];
    PPFilter *x_5_r_cp = [[PPFilter alloc] initWithIdentifier:38
                                                     andModel:@"CP"];
    PPFilter *x_5_r_nd8 = [[PPFilter alloc] initWithIdentifier:39
                                                      andModel:@"ND8"];
    PPFilter *x_5_r_nd8_pl = [[PPFilter alloc] initWithIdentifier:40
                                                         andModel:@"ND8/PL"];
    PPFilter *x_5_r_nd16 = [[PPFilter alloc] initWithIdentifier:41
                                                       andModel:@"ND16"];
    PPFilter *x_5_r_nd16_pl = [[PPFilter alloc] initWithIdentifier:42
                                                          andModel:@"ND16/PL"];
    PPFilter *x_5_r_nd32 = [[PPFilter alloc] initWithIdentifier:43
                                                       andModel:@"ND32"];
    
    [x_5_r_uv setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_r_cp setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_r_nd8 setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_r_nd8_pl setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_r_nd16 setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_r_nd16_pl setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_r_nd32 setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    
    [x_5_r_nd8 setIsCalculatorParameter:YES];
    [x_5_r_nd16 setIsCalculatorParameter:YES];
    [x_5_r_nd32 setIsCalculatorParameter:YES];
    
    PPFilter *x_5_uv = [[PPFilter alloc] initWithIdentifier:44
                                                   andModel:@"UV"];
    PPFilter *x_5_cp = [[PPFilter alloc] initWithIdentifier:45
                                                   andModel:@"CP"];
    PPFilter *x_5_nd8 = [[PPFilter alloc] initWithIdentifier:46
                                                    andModel:@"ND8"];
    PPFilter *x_5_nd8_pl = [[PPFilter alloc] initWithIdentifier:47
                                                       andModel:@"ND8/PL"];
    PPFilter *x_5_nd16 = [[PPFilter alloc] initWithIdentifier:48
                                                     andModel:@"ND16"];
    PPFilter *x_5_nd16_pl = [[PPFilter alloc] initWithIdentifier:49
                                                        andModel:@"ND16/PL"];
    PPFilter *x_5_nd32 = [[PPFilter alloc] initWithIdentifier:50
                                                     andModel:@"ND32"];
    
    [x_5_uv setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_cp setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_nd8 setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_nd8_pl setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_nd16 setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_nd16_pl setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_5_nd32 setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    
    [x_5_nd8 setIsCalculatorParameter:YES];
    [x_5_nd16 setIsCalculatorParameter:YES];
    [x_5_nd32 setIsCalculatorParameter:YES];
    
    PPFilter *x_4_s_nd4_pl = [[PPFilter alloc] initWithIdentifier:51
                                                         andModel:@"ND4/PL"];
    PPFilter *x_4_s_nd8 = [[PPFilter alloc] initWithIdentifier:52
                                                      andModel:@"ND8"];
    PPFilter *x_4_s_nd8_pl = [[PPFilter alloc] initWithIdentifier:53
                                                         andModel:@"ND8/PL"];
    PPFilter *x_4_s_nd16 = [[PPFilter alloc] initWithIdentifier:54
                                                       andModel:@"ND16"];
    PPFilter *x_4_s_nd16_pl = [[PPFilter alloc] initWithIdentifier:55
                                                          andModel:@"ND16/PL"];
    PPFilter *x_4_s_nd32 = [[PPFilter alloc] initWithIdentifier:56
                                                       andModel:@"ND32"];
    
    [x_4_s_nd4_pl setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_4_s_nd8 setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_4_s_nd8_pl setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_4_s_nd16 setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_4_s_nd16_pl setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    [x_4_s_nd32 setURL:@"https://www.polarprofilters.com/collections/zenmusex5filters"];
    
    [x_4_s_nd8 setIsCalculatorParameter:YES];
    [x_4_s_nd16 setIsCalculatorParameter:YES];
    [x_4_s_nd32 setIsCalculatorParameter:YES];
    
    PPFilter *x_3_cp = [[PPFilter alloc] initWithIdentifier:57
                                                   andModel:@"CP"];
    PPFilter *x_3_nd8 = [[PPFilter alloc] initWithIdentifier:58
                                                    andModel:@"ND8"];
    PPFilter *x_3_nd8_pl = [[PPFilter alloc] initWithIdentifier:59
                                                       andModel:@"ND8/PL"];
    PPFilter *x_3_nd16 = [[PPFilter alloc] initWithIdentifier:60
                                                     andModel:@"ND16"];
    PPFilter *x_3_nd16_pl = [[PPFilter alloc] initWithIdentifier:61
                                                        andModel:@"ND16/PL"];
    PPFilter *x_3_nd32 = [[PPFilter alloc] initWithIdentifier:62
                                                     andModel:@"ND32"];
    PPFilter *x_3_nd32_pl = [[PPFilter alloc] initWithIdentifier:63
                                                        andModel:@"ND32/PL"];
    PPFilter *x_3_nd_64 = [[PPFilter alloc] initWithIdentifier:64
                                                      andModel:@"ND64"];
    
    [x_3_cp setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [x_3_nd8 setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [x_3_nd8_pl setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [x_3_nd16 setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [x_3_nd16_pl setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [x_3_nd32 setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [x_3_nd32_pl setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter/products/inspire2filter"];
    [x_3_nd_64 setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter/products/inspire1x5filter"];
    
    [x_3_nd8 setIsCalculatorParameter:YES];
    [x_3_nd16 setIsCalculatorParameter:YES];
    [x_3_nd32 setIsCalculatorParameter:YES];
    [x_3_nd_64 setIsCalculatorParameter:YES];
    
    PPFilter *z_3_cp = [[PPFilter alloc] initWithIdentifier:65
                                                   andModel:@"CP"];
    PPFilter *z_3_nd8 = [[PPFilter alloc] initWithIdentifier:66
                                                    andModel:@"ND8"];
    PPFilter *z_3_nd8_pl = [[PPFilter alloc] initWithIdentifier:67
                                                       andModel:@"ND8/PL"];
    PPFilter *z_3_nd16 = [[PPFilter alloc] initWithIdentifier:68
                                                     andModel:@"ND16"];
    PPFilter *z_3_nd16_pl = [[PPFilter alloc] initWithIdentifier:69
                                                        andModel:@"ND16/PL"];
    PPFilter *z_3_nd32 = [[PPFilter alloc] initWithIdentifier:70
                                                     andModel:@"ND32"];
    PPFilter *z_3_nd32_pl = [[PPFilter alloc] initWithIdentifier:71
                                                        andModel:@"ND32/PL"];
    PPFilter *z_3_nd64 = [[PPFilter alloc] initWithIdentifier:72
                                                     andModel:@"ND64"];
    
    [z_3_cp setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [z_3_nd8 setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [z_3_nd8_pl setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [z_3_nd16 setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [z_3_nd16_pl setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [z_3_nd32 setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [z_3_nd32_pl setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter/products/inspire2filter"];
    [z_3_nd64 setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter/products/inspire1x5filter"];
    
    [z_3_nd8 setIsCalculatorParameter:YES];
    [z_3_nd16 setIsCalculatorParameter:YES];
    [z_3_nd32 setIsCalculatorParameter:YES];
    [z_3_nd64 setIsCalculatorParameter:YES];
    
    PPFilter *phantom_3_pro_cp = [[PPFilter alloc] initWithIdentifier:73
                                                             andModel:@"CP"];
    PPFilter *phantom_3_pro_nd4 = [[PPFilter alloc] initWithIdentifier:74
                                                              andModel:@"ND4"];
    PPFilter *phantom_3_pro_nd4_pl = [[PPFilter alloc] initWithIdentifier:75
                                                                 andModel:@"ND4/PL"];
    PPFilter *phantom_3_pro_nd8 = [[PPFilter alloc] initWithIdentifier:76
                                                              andModel:@"ND8"];
    PPFilter *phantom_3_pro_nd8_pl = [[PPFilter alloc] initWithIdentifier:77
                                                                 andModel:@"ND8/PL"];
    PPFilter *phantom_3_pro_nd16 = [[PPFilter alloc] initWithIdentifier:78
                                                               andModel:@"ND16"];
    PPFilter *phantom_3_pro_nd16_pl = [[PPFilter alloc] initWithIdentifier:79
                                                                  andModel:@"ND16/PL"];
    PPFilter *phantom_3_pro_nd32 = [[PPFilter alloc] initWithIdentifier:80
                                                               andModel:@"ND32"];
    PPFilter *phantom_3_pro_nd32_pl = [[PPFilter alloc] initWithIdentifier:81
                                                                  andModel:@"ND32/PL"];
    PPFilter *phantom_3_pro_nd64 = [[PPFilter alloc] initWithIdentifier:82
                                                               andModel:@"ND64"];
    
    [phantom_3_pro_cp setURL:@"https://www.polarprofilters.com/collections/phantom3filters"];
    [phantom_3_pro_nd4 setURL:@"https://www.polarprofilters.com/collections/phantom3filters"];
    [phantom_3_pro_nd4_pl setURL:@"https://www.polarprofilters.com/collections/phantom3filters"];
    [phantom_3_pro_nd8 setURL:@"https://www.polarprofilters.com/collections/phantom3filters"];
    [phantom_3_pro_nd8_pl setURL:@"https://www.polarprofilters.com/collections/phantom3filters"];
    [phantom_3_pro_nd16 setURL:@"https://www.polarprofilters.com/collections/phantom3filters"];
    [phantom_3_pro_nd16_pl setURL:@"https://www.polarprofilters.com/collections/phantom3filters"];
    [phantom_3_pro_nd32 setURL:@"https://www.polarprofilters.com/collections/phantom3filters"];
    [phantom_3_pro_nd32_pl setURL:@"https://www.polarprofilters.com/collections/phantom3filters/products/djiphantom3filternd32"];
    [phantom_3_pro_nd64 setURL:@"https://www.polarprofilters.com/collections/phantom3filters/products/djiphantom3nd64"];
    
    [phantom_3_pro_nd4 setIsCalculatorParameter:YES];
    [phantom_3_pro_nd8 setIsCalculatorParameter:YES];
    [phantom_3_pro_nd16 setIsCalculatorParameter:YES];
    [phantom_3_pro_nd32 setIsCalculatorParameter:YES];
    [phantom_3_pro_nd64 setIsCalculatorParameter:YES];
    
    PPFilter *phantom_3_standart_cp = [[PPFilter alloc] initWithIdentifier:83
                                                                  andModel:@"CP"];
    PPFilter *phantom_3_standart_nd4 = [[PPFilter alloc] initWithIdentifier:84
                                                                   andModel:@"ND4"];
    PPFilter *phantom_3_standart_nd8 = [[PPFilter alloc] initWithIdentifier:85
                                                                   andModel:@"ND8"];
    
    [phantom_3_standart_cp setURL:@"https://www.polarprofilters.com/collections/phantom3filters/products/dji-phantom-3-standard-filter-3-pack"];
    [phantom_3_standart_nd4 setURL:@"https://www.polarprofilters.com/collections/phantom3filters/products/dji-phantom-3-standard-filter-3-pack"];
    [phantom_3_standart_nd8 setURL:@"https://www.polarprofilters.com/collections/phantom3filters/products/dji-phantom-3-standard-filter-3-pack"];
    
    [phantom_3_standart_nd4 setIsCalculatorParameter:YES];
    [phantom_3_standart_nd8 setIsCalculatorParameter:YES];
    
    PPFilter *osmo_cp = [[PPFilter alloc] initWithIdentifier:86
                                                    andModel:@"CP"];
    PPFilter *osmo_nd8 = [[PPFilter alloc] initWithIdentifier:87
                                                     andModel:@"ND8"];
    PPFilter *osmo_nd8_pl = [[PPFilter alloc] initWithIdentifier:88
                                                        andModel:@"ND8/PL"];
    PPFilter *osmo_nd16 = [[PPFilter alloc] initWithIdentifier:89
                                                      andModel:@"ND16"];
    PPFilter *osmo_nd16_pl = [[PPFilter alloc] initWithIdentifier:90
                                                         andModel:@"ND16/PL"];
    PPFilter *osmo_nd32 = [[PPFilter alloc] initWithIdentifier:91
                                                      andModel:@"ND32"];
    PPFilter *osmo_nd32_pl = [[PPFilter alloc] initWithIdentifier:92
                                                         andModel:@"ND32/PL"];
    PPFilter *osmo_nd64 = [[PPFilter alloc] initWithIdentifier:93
                                                      andModel:@"ND64"];
    
    [osmo_cp setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [osmo_nd8 setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [osmo_nd8_pl setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [osmo_nd16 setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [osmo_nd16_pl setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [osmo_nd32 setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter"];
    [osmo_nd32_pl setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter/products/inspire2filter"];
    [osmo_nd64 setURL:@"https://www.polarprofilters.com/collections/djiinspire1filter/products/inspire1x5filter"];
    
    [osmo_nd8 setIsCalculatorParameter:YES];
    [osmo_nd16 setIsCalculatorParameter:YES];
    [osmo_nd32 setIsCalculatorParameter:YES];
    [osmo_nd64 setIsCalculatorParameter:YES];
    
    PPFilter *spark_uv = [[PPFilter alloc] initWithIdentifier:94
                                                     andModel:@"UV"];
    PPFilter *spark_pl = [[PPFilter alloc] initWithIdentifier:95
                                                     andModel:@"PL"];
    PPFilter *spark_nd4_pl = [[PPFilter alloc] initWithIdentifier:96
                                                         andModel:@"ND4/PL"];
    PPFilter *spark_nd8 = [[PPFilter alloc] initWithIdentifier:97
                                                      andModel:@"ND8"];
    PPFilter *spark_nd8_pl = [[PPFilter alloc] initWithIdentifier:98
                                                         andModel:@"ND8/PL"];
    PPFilter *spark_nd16 = [[PPFilter alloc] initWithIdentifier:99
                                                       andModel:@"ND16"];
    PPFilter *spark_nd16_pl = [[PPFilter alloc] initWithIdentifier:100
                                                          andModel:@"ND16/PL"];
    PPFilter *spark_nd32 = [[PPFilter alloc] initWithIdentifier:101
                                                       andModel:@"ND32"];
    
    [spark_uv setURL:@"https://www.polarprofilters.com/collections/dji-spark-filters-accessories/products/dji-spark-uv-filter"];
    [spark_pl setURL:@"https://www.polarprofilters.com/collections/dji-spark-filters-accessories"];
    [spark_nd4_pl setURL:@"https://www.polarprofilters.com/collections/dji-spark-filters-accessories"];
    [spark_nd8 setURL:@"https://www.polarprofilters.com/collections/dji-spark-filters-accessories"];
    [spark_nd8_pl setURL:@"https://www.polarprofilters.com/collections/dji-spark-filters-accessories"];
    [spark_nd16 setURL:@"https://www.polarprofilters.com/collections/dji-spark-filters-accessories"];
    [spark_nd16_pl setURL:@"https://www.polarprofilters.com/collections/dji-spark-filters-accessories"];
    [spark_nd32 setURL:@"https://www.polarprofilters.com/collections/dji-spark-filters-accessories"];
    
    [spark_nd8 setIsCalculatorParameter:YES];
    [spark_nd16 setIsCalculatorParameter:YES];
    [spark_nd32 setIsCalculatorParameter:YES];
    
    // Mavic Pro
    PPDevice *mavic_pro = [[PPDevice alloc] initWithIdentifier:0
                                                      withMark:@"DJI"
                                                      andModel:@"Mavic Pro"];
    [mavic_pro setFPSList:[NSMutableArray arrayWithArray:@[FPS_24,
                                                           FPS_25,
                                                           FPS_30,
                                                           FPS_48,
                                                           FPS_60,
                                                           FPS_120]]];
    [mavic_pro setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_25,
                                                                    ss_30,
                                                                    ss_50,
                                                                    ss_60,
                                                                    ss_100,
                                                                    ss_120,
                                                                    ss_200,
                                                                    ss_240,
                                                                    ss_400,
                                                                    ss_500,
                                                                    ss_800,
                                                                    ss_1000,
                                                                    ss_1600,
                                                                    ss_2000,
                                                                    ss_3200]]];
    [mavic_pro setFilters:[NSMutableArray arrayWithArray:@[mavic_pro_uv,
                                                           mavic_pro_cp,
                                                           mavic_pro_nd4_pl,
                                                           mavic_pro_nd8,
                                                           mavic_pro_nd8_pl,
                                                           mavic_pro_nd16,
                                                           mavic_pro_nd16_pl,
                                                           mavic_pro_nd32,
                                                           mavic_pro_nd32_pl,
                                                           mavic_pro_nd64,
                                                           mavic_pro_nd64_pl]]];
    
    // Phantom 4 Pro
    PPDevice *phantom_4_pro = [[PPDevice alloc] initWithIdentifier:1
                                                          withMark:@"DJI"
                                                          andModel:@"Phantom 4 Pro"];
    [phantom_4_pro setFPSList:[NSMutableArray arrayWithArray:@[FPS_24,
                                                               FPS_25,
                                                               FPS_30,
                                                               FPS_48,
                                                               FPS_50,
                                                               FPS_60,
                                                               FPS_120]]];
    [phantom_4_pro setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_30,
                                                                        ss_50,
                                                                        ss_60,
                                                                        ss_100,
                                                                        ss_120,
                                                                        ss_200,
                                                                        ss_240,
                                                                        ss_400,
                                                                        ss_500,
                                                                        ss_800,
                                                                        ss_1000,
                                                                        ss_1600,
                                                                        ss_2000,
                                                                        ss_3200]]];
    [phantom_4_pro setFilters:[NSMutableArray arrayWithArray:@[phantom_4_pro_uv,
                                                               phantom_4_pro_nd4,
                                                               phantom_4_pro_nd4_pl,
                                                               phantom_4_pro_nd8,
                                                               phantom_4_pro_nd8_pl,
                                                               phantom_4_pro_nd16,
                                                               phantom_4_pro_nd16_pl,
                                                               phantom_4_pro_nd32,
                                                               phantom_4_pro_nd32_pl,
                                                               phantom_4_pro_nd64]]];
    
    // Phantom 4
    PPDevice *phantom_4 = [[PPDevice alloc] initWithIdentifier:2
                                                      withMark:@"DJI"
                                                      andModel:@"Phantom 4"];
    [phantom_4 setFPSList:[NSMutableArray arrayWithArray:@[FPS_24,
                                                           FPS_25,
                                                           FPS_30,
                                                           FPS_48,
                                                           FPS_60,
                                                           FPS_120]]];
    [phantom_4 setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_30,
                                                                    ss_50,
                                                                    ss_60,
                                                                    ss_100,
                                                                    ss_120,
                                                                    ss_200,
                                                                    ss_240,
                                                                    ss_400,
                                                                    ss_500,
                                                                    ss_800,
                                                                    ss_1000,
                                                                    ss_1600,
                                                                    ss_2000,
                                                                    ss_3200]]];
    [phantom_4 setFilters:[NSMutableArray arrayWithArray:@[phantom_4_cp,
                                                           phantom_4_nd4,
                                                           phantom_4_nd8,
                                                           phantom_4_nd8_pl,
                                                           phantom_4_nd16,
                                                           phantom_4_nd16_pl,
                                                           phantom_4_nd32,
                                                           phantom_4_nd32_pl,
                                                           phantom_4_pro_nd64]]];
    
    // X5S
    PPDevice *x_5_s = [[PPDevice alloc] initWithIdentifier:3
                                                  withMark:@"DJI"
                                                  andModel:@"X5S"];
    [x_5_s setFPSList:[NSMutableArray arrayWithArray:@[FPS_24,
                                                       FPS_25,
                                                       FPS_30,
                                                       FPS_50,
                                                       FPS_60,
                                                       FPS_120]]];
    [x_5_s setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_30,
                                                                ss_50,
                                                                ss_60,
                                                                ss_100,
                                                                ss_120,
                                                                ss_200,
                                                                ss_240,
                                                                ss_400,
                                                                ss_500,
                                                                ss_800,
                                                                ss_1000,
                                                                ss_1600,
                                                                ss_2000,
                                                                ss_3200]]];
    [x_5_s setFilters:[NSMutableArray arrayWithArray:@[x_5_s_uv,
                                                       x_5_s_cp,
                                                       x_5_s_nd8,
                                                       x_5_s_nd8_pl,
                                                       x_5_s_nd16,
                                                       x_5_s_nd16_pl,
                                                       x_5_s_nd32]]];
    
    // X5R
    PPDevice *x_5_r = [[PPDevice alloc] initWithIdentifier:4
                                                  withMark:@"DJI"
                                                  andModel:@"X5R"];
    [x_5_r setFPSList:[NSMutableArray arrayWithArray:@[FPS_24,
                                                       FPS_30,
                                                       FPS_48,
                                                       FPS_60]]];
    [x_5_r setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_30,
                                                                ss_50,
                                                                ss_60,
                                                                ss_100,
                                                                ss_120,
                                                                ss_200,
                                                                ss_240,
                                                                ss_400,
                                                                ss_500,
                                                                ss_800,
                                                                ss_1000,
                                                                ss_1600,
                                                                ss_2000,
                                                                ss_3200]]];
    [x_5_r setFilters:[NSMutableArray arrayWithArray:@[x_5_r_uv,
                                                       x_5_r_cp,
                                                       x_5_r_nd8,
                                                       x_5_r_nd8_pl,
                                                       x_5_r_nd16,
                                                       x_5_r_nd16_pl,
                                                       x_5_r_nd32]]];
    
    // X5
    PPDevice *x_5 = [[PPDevice alloc] initWithIdentifier:5
                                                withMark:@"DJI"
                                                andModel:@"X5"];
    [x_5 setFPSList:[NSMutableArray arrayWithArray:@[FPS_24,
                                                     FPS_25,
                                                     FPS_30,
                                                     FPS_48,
                                                     FPS_50,
                                                     FPS_60]]];
    [x_5 setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_30,
                                                              ss_50,
                                                              ss_60,
                                                              ss_100,
                                                              ss_120,
                                                              ss_200,
                                                              ss_240,
                                                              ss_400,
                                                              ss_500,
                                                              ss_800,
                                                              ss_1000,
                                                              ss_1600,
                                                              ss_2000,
                                                              ss_3200]]];
    [x_5 setFilters:[NSMutableArray arrayWithArray:@[x_5_uv,
                                                     x_5_cp,
                                                     x_5_nd8,
                                                     x_5_nd8_pl,
                                                     x_5_nd16,
                                                     x_5_nd16_pl,
                                                     x_5_nd32]]];
    
    // X4S
    PPDevice *x_4_s = [[PPDevice alloc] initWithIdentifier:6
                                                  withMark:@"DJI"
                                                  andModel:@"X4S"];
    [x_4_s setFPSList:[NSMutableArray arrayWithArray:@[FPS_24,
                                                       FPS_25,
                                                       FPS_30,
                                                       FPS_48,
                                                       FPS_50,
                                                       FPS_60,
                                                       FPS_120]]];
    [x_4_s setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_30,
                                                                ss_50,
                                                                ss_60,
                                                                ss_100,
                                                                ss_120,
                                                                ss_200,
                                                                ss_240,
                                                                ss_400,
                                                                ss_500,
                                                                ss_800,
                                                                ss_1000,
                                                                ss_1600,
                                                                ss_2000,
                                                                ss_3200]]];
    [x_4_s setFilters:[NSMutableArray arrayWithArray:@[x_4_s_nd4_pl,
                                                       x_4_s_nd8,
                                                       x_4_s_nd8_pl,
                                                       x_4_s_nd16,
                                                       x_4_s_nd16_pl,
                                                       x_4_s_nd32]]];
    
    // X3
    PPDevice *x_3 = [[PPDevice alloc] initWithIdentifier:7
                                                withMark:@"DJI"
                                                andModel:@"X3"];
    [x_3 setFPSList:[NSMutableArray arrayWithArray:@[FPS_24,
                                                     FPS_25,
                                                     FPS_30,
                                                     FPS_48,
                                                     FPS_50,
                                                     FPS_60]]];
    [x_3 setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_30,
                                                              ss_50,
                                                              ss_60,
                                                              ss_100,
                                                              ss_120,
                                                              ss_200,
                                                              ss_240,
                                                              ss_400,
                                                              ss_500,
                                                              ss_800,
                                                              ss_1000,
                                                              ss_1600,
                                                              ss_2000,
                                                              ss_3200]]];
    [x_3 setFilters:[NSMutableArray arrayWithArray:@[x_3_cp,
                                                     x_3_nd8,
                                                     x_3_nd8_pl,
                                                     x_3_nd16,
                                                     x_3_nd16_pl,
                                                     x_3_nd32,
                                                     x_3_nd32_pl,
                                                     x_3_nd_64]]];
    
    // Z3
    PPDevice *z_3 = [[PPDevice alloc] initWithIdentifier:8
                                                withMark:@"DJI"
                                                andModel:@"Z3"];
    [z_3 setFPSList:[NSMutableArray arrayWithArray:@[FPS_24,
                                                     FPS_25,
                                                     FPS_30,
                                                     FPS_48,
                                                     FPS_50,
                                                     FPS_60]]];
    [z_3 setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_30,
                                                              ss_50,
                                                              ss_60,
                                                              ss_100,
                                                              ss_120,
                                                              ss_200,
                                                              ss_240,
                                                              ss_400,
                                                              ss_500,
                                                              ss_800,
                                                              ss_1000,
                                                              ss_1600,
                                                              ss_2000,
                                                              ss_3200]]];
    [z_3 setFilters:[NSMutableArray arrayWithArray:@[z_3_cp,
                                                     z_3_nd8,
                                                     z_3_nd8_pl,
                                                     z_3_nd16,
                                                     z_3_nd16_pl,
                                                     z_3_nd32,
                                                     z_3_nd32_pl,
                                                     z_3_nd64]]];
    
    // Phantom 3 Pro
    PPDevice *phantom_3_pro = [[PPDevice alloc] initWithIdentifier:9
                                                          withMark:@"DJI"
                                                          andModel:@"Phantom 3 Pro / Advanced"];
    [phantom_3_pro setFPSList:[NSMutableArray arrayWithArray:@[FPS_24,
                                                               FPS_25,
                                                               FPS_30,
                                                               FPS_48,
                                                               FPS_50,
                                                               FPS_60]]];
    [phantom_3_pro setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_30,
                                                                        ss_50,
                                                                        ss_60,
                                                                        ss_100,
                                                                        ss_120,
                                                                        ss_200,
                                                                        ss_240,
                                                                        ss_400,
                                                                        ss_500,
                                                                        ss_800,
                                                                        ss_1000,
                                                                        ss_1600,
                                                                        ss_2000,
                                                                        ss_3200]]];
    [phantom_3_pro setFilters:[NSMutableArray arrayWithArray:@[phantom_3_pro_cp,
                                                               phantom_3_pro_nd4,
                                                               phantom_3_pro_nd4_pl,
                                                               phantom_3_pro_nd8,
                                                               phantom_3_pro_nd8_pl,
                                                               phantom_3_pro_nd16,
                                                               phantom_3_pro_nd16_pl,
                                                               phantom_3_pro_nd32,
                                                               phantom_3_pro_nd32_pl,
                                                               phantom_3_pro_nd64]]];
    
    // Phantom 3 Standart
    PPDevice *phantom_3_standart = [[PPDevice alloc] initWithIdentifier:10
                                                               withMark:@"DJI"
                                                               andModel:@"Phantom 3"];
    [phantom_3_standart setFPSList:[NSMutableArray arrayWithArray:@[FPS_24,
                                                                    FPS_25,
                                                                    FPS_30,
                                                                    FPS_48,
                                                                    FPS_50,
                                                                    FPS_60]]];
    [phantom_3_standart setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_30,
                                                                             ss_50,
                                                                             ss_60,
                                                                             ss_100,
                                                                             ss_120,
                                                                             ss_200,
                                                                             ss_240,
                                                                             ss_400,
                                                                             ss_500,
                                                                             ss_800,
                                                                             ss_1000,
                                                                             ss_1600,
                                                                             ss_2000,
                                                                             ss_3200]]];
    [phantom_3_standart setFilters:[NSMutableArray arrayWithArray:@[phantom_3_standart_cp,
                                                                    phantom_3_standart_nd4,
                                                                    phantom_3_standart_nd8]]];
    
    // Osmo
    PPDevice *osmo = [[PPDevice alloc] initWithIdentifier:11
                                                 withMark:@"DJI"
                                                 andModel:@"Osmo"];
    [osmo setFPSList:[NSMutableArray arrayWithArray:@[FPS_24,
                                                      FPS_25,
                                                      FPS_30,
                                                      FPS_48,
                                                      FPS_50,
                                                      FPS_60]]];
    [osmo setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_30,
                                                               ss_50,
                                                               ss_60,
                                                               ss_100,
                                                               ss_120,
                                                               ss_200,
                                                               ss_240,
                                                               ss_400,
                                                               ss_500,
                                                               ss_800,
                                                               ss_1000,
                                                               ss_1600,
                                                               ss_2000,
                                                               ss_3200]]];
    [osmo setFilters:[NSMutableArray arrayWithArray:@[osmo_cp,
                                                      osmo_nd8,
                                                      osmo_nd8_pl,
                                                      osmo_nd16,
                                                      osmo_nd16_pl,
                                                      osmo_nd32,
                                                      osmo_nd32_pl,
                                                      osmo_nd64]]];
    
    // Spark
    PPDevice *spark = [[PPDevice alloc] initWithIdentifier:12
                                                  withMark:@"DJI"
                                                  andModel:@"Spark"];
    [spark setFPSList:[NSMutableArray arrayWithArray:@[FPS_30]]];
    [spark setShutterSpeedList:[NSMutableArray arrayWithArray:@[ss_30,
                                                                ss_40,
                                                                ss_50,
                                                                ss_60,
                                                                ss_80,
                                                                ss_100,
                                                                ss_120,
                                                                ss_160,
                                                                ss_200,
                                                                ss_240,
                                                                ss_320,
                                                                ss_400,
                                                                ss_500,
                                                                ss_640,
                                                                ss_800,
                                                                ss_1000,
                                                                ss_1250,
                                                                ss_1600,
                                                                ss_2000,
                                                                ss_2500,
                                                                ss_3200]]];
    [spark setFilters:[NSMutableArray arrayWithArray:@[spark_uv,
                                                       spark_pl,
                                                       spark_nd4_pl,
                                                       spark_nd8,
                                                       spark_nd8_pl,
                                                       spark_nd16,
                                                       spark_nd16_pl,
                                                       spark_nd32]]];
    
    // Model
    [_devices setArray:@[mavic_pro,
                         spark,
                         phantom_4_pro,
                         phantom_4,
                         x_5_s,
                         x_5_r,
                         x_5,
                         x_4_s,
                         x_3,
                         z_3,
                         phantom_3_pro,
                         phantom_3_standart,
                         osmo]];
}

@end
