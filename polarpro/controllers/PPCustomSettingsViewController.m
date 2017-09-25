//
//  PPCustomSettingsViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 13.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPCustomSettingsViewController.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"


@interface PPCustomSettingsViewController () <PPSettingsViewControllerDelegate>

@property (strong, nonatomic) PPSettingsViewController *settingVC;

@property (assign, nonatomic) PPSettingsType type;

@property (assign, nonatomic) CGFloat settingsHeight;

@end


@implementation PPCustomSettingsViewController

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
    [self changeTitle];
    [self addSettings];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)changeTitle {
    NSString *title;
    switch (_type) {
        case PPSettingsTypeNone:
            title = @"settings";
            break;
        case PPSettingsTypeGoldenHour:
            title = @"sunrise_sunset_settings";
            break;
        case PPSettingsTypeWeatherForecast:
            title = @"weather_settings";
            break;
        case PPSettingsTypeWindCondition:
            title = @"wind_condition_settings";
            break;
    }
    [self.navigationItem setTitle:LOCALIZE(title)];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
}

- (void)addSettings {
    _settingVC = [[PPSettingsViewController alloc] initWithType:_type];
    [_settingVC setDelegate:self];
    
    UITextField *textField = self.searchTextField;
    
    UIView *settingsView = _settingVC.view;
    
    CGSize size = _settingVC.tableView.contentSize;
    _settingsHeight = size.height;
    
    [settingsView setFrame:CGRectMake(0.f, 0.f, WIDTH, size.height)];
    
    UIView *headerView = self.tableView.tableHeaderView;
    [headerView removeConstraints:headerView.constraints];
    [headerView setFrame:CGRectMake(0.f, 0.f, WIDTH, settingsView.bounds.size.height + kHeightSearchTextField)];
    
    [settingsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [headerView addSubview:settingsView];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:settingsView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.f
                                                            constant:0.f]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:settingsView
                                                           attribute:NSLayoutAttributeLeft
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView
                                                           attribute:NSLayoutAttributeLeft
                                                          multiplier:1.f
                                                            constant:0.f]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:settingsView
                                                           attribute:NSLayoutAttributeRight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView
                                                           attribute:NSLayoutAttributeRight
                                                          multiplier:1.f
                                                            constant:0.f]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:settingsView
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.f
                                                            constant:-kHeightSearchTextField]];
    
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.f
                                                            constant:10.f + size.height]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                           attribute:NSLayoutAttributeLeft
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView
                                                           attribute:NSLayoutAttributeLeft
                                                          multiplier:1.f
                                                            constant:20.f]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                           attribute:NSLayoutAttributeRight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView
                                                           attribute:NSLayoutAttributeRight
                                                          multiplier:1.f
                                                            constant:-20.f]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.f
                                                            constant:-10.f]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [self didUpdateSettings];
}

- (void)tableView:(VPDraggableTableView *)tableView dragCellFromSourceIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView dragCellFromSourceIndexPath:sourceIndexPath toIndexPath:indexPath];
    [self didUpdateSettings];
}

- (BOOL)didSwitchCurrentLocationWithIndexPath:(NSIndexPath *)indexPath {
    [self didUpdateSettings];
    return [super didSwitchCurrentLocationWithIndexPath:indexPath];
}

- (void)didDeleteLocationWithIndexPath:(NSIndexPath *)indexPath {
    [super didDeleteLocationWithIndexPath:indexPath];
    [self didUpdateSettings];
}

- (void)didFindNearestCityByLastCoordinate {
    [super didFindNearestCityByLastCoordinate];
    [self didUpdateSettings];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [super textFieldDidBeginEditing:textField];
    [self.tableView setContentOffset:CGPointMake(0.f, _settingsHeight)
                            animated:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidEndEditing:textField];
    [self.tableView setContentOffset:CGPointZero
                            animated:NO];
}

#pragma mark - PPSettingsViewControllerDelegate

- (void)didUpdateSettings {
    if (_delegate) {
        if ([_delegate conformsToProtocol:@protocol(PPCustomSettingsViewControllerDelegate)] &&
            [_delegate respondsToSelector:@selector(didUpdateSettings)]) {
            [_delegate didUpdateSettings];
        }
    }
}

@end
