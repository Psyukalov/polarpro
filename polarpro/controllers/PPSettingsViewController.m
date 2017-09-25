//
//  PPSettingsViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 12.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPSettingsViewController.h"

#import "Macros.h"
#import <CoreLocation/CoreLocation.h>
#import "UIViewController+PPCostomViewController.h"
#import "UITableView+PPCustomHeaderFooterView.h"
#import "VPSegmentedControl.h"
#import "PPUtils.h"

#import "PPSettingsHeaderView.h"
#import "PPSettingsTableViewCell.h"

#import "PPSettingsModel.h"
#import "PPLocationsModel.h"


@interface PPSettingsViewController () <UITableViewDataSource, UITableViewDelegate, PPSettingsTableViewCellDelegate>

@property (assign, nonatomic) PPSettingsType type;

@property (strong, nonatomic) PPSettingsModel *settingsModel;

@property (strong, nonatomic) NSMutableArray <PPSettingsGroup *> *groups;

@property (assign, nonatomic) CGFloat delta;

@end


@implementation PPSettingsViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = PPSettingsTypeNone;
    }
    return self;
}

- (instancetype)initWithType:(PPSettingsType)type {
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _settingsModel = [PPSettingsModel sharedModel];
    _groups = [[NSMutableArray alloc] init];
    _delta = 20.f;
    switch (_type) {
        case PPSettingsTypeNone:
            _groups = _settingsModel.groups;
            _delta = 0.f;
            break;
        case PPSettingsTypeGoldenHour: {
            [_groups addObject:_settingsModel.groups[1]];
        }
            break;
        case PPSettingsTypeWeatherForecast: {
            [_groups addObject:_settingsModel.groups[0]];
            [_groups addObject:_settingsModel.groups[1]];
        }
            break;
        case PPSettingsTypeWindCondition: {
            PPSettingsOption *speedOption = _settingsModel.groups[0].options[1];
            PPSettingsGroup *group = [[PPSettingsGroup alloc] initWithTitle:LOCALIZE(@"units")];
            [group setOptions:[NSMutableArray arrayWithArray:@[speedOption]]];
            [_groups addObject:group];
            [_groups addObject:_settingsModel.groups[1]];
        }
            break;
    }
    
    [self.view setBackgroundColor:MAIN_COLOR];
    [self.navigationItem setTitle:LOCALIZE(@"settings")];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createBackBBI];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PPSettingsHeaderView class])
                                           bundle:nil] forHeaderFooterViewReuseIdentifier:kSettingsHeaderViewRI];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PPSettingsTableViewCell class])
                                           bundle:nil]
     forCellReuseIdentifier:kSettingsItemRI];
    [_tableView applySettings];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groups[section].options.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (kCellHeight - _delta) * [PPUtils screenRate];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight * [PPUtils screenRate];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PPSettingsHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kSettingsHeaderViewRI];
    if (_groups.count > 0) {
        [view setTitle:_groups[section].title];
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PPSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSettingsItemRI
                                                                    forIndexPath:indexPath];
    [cell setDelegate:self];
    [cell setIndexPath:indexPath];
    if (_groups[indexPath.section].options.count > 0) {
        PPSettingsOption *option = _groups[indexPath.section].options[indexPath.row];
        [cell setTitle:option.title];
        [cell setParameters:option.parameters];
        [cell setSelectedSegment:option.currentParameter];
    }
    return cell;
}

- (void)didChangeSegmentedControlWithIndex:(NSUInteger)index
                              andIndexPath:(NSIndexPath *)indexPath {
    [_groups[indexPath.section].options[indexPath.row] setCurrentParameter:index];
    if (_delegate) {
        if ([_delegate conformsToProtocol:@protocol(PPSettingsViewControllerDelegate)] &&
            [_delegate respondsToSelector:@selector(didUpdateSettings)]) {
            [_delegate didUpdateSettings];
        }
    }
}

@end
