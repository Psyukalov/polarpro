//
//  PPLocationsViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 16.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPLocationsViewController.h"


#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "UIView+PPCustomView.h"
#import "UITextField+PPCustomAttributedPlaceholder.h"
#import "UITableView+PPCustomHeaderFooterView.h"
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>

#import "PPLocationTableViewCell.h"
#import "PPCurrentLocationTableViewCell.h"
#import "PPSearchTableViewCell.h"

#import "PPUser.h"
#import "PPLocationsModel.h"

#import "PPAlertView.h"


#define kHeightSearchTextField (60.f)
#define kCornerRadiusSearchTextField (20.f)


@interface PPLocationsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, VPDraggableTableViewDelegate, PPCurrentLocationTableViewCellDelegate, PPLocationTableViewCellDelegate, PPLocationModelDelegate, PPAlertViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraint;

@property (strong, nonatomic) UIActivityIndicatorView *searchIndicatorView;

@property (strong, nonatomic) PPLocationsModel *locationsModel;

@end


@implementation PPLocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setupSearchTextField];
    [self setupSearchTableView];
    [self registerObservers];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableView applySettings];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObservers];
}

- (void)setup {
    _locationsModel = [PPLocationsModel sharedModel];
    [_locationsModel setDelegate:self];
    [self.view setBackgroundColor:MAIN_COLOR];
    [self.navigationItem setTitle:LOCALIZE(@"locations")];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createBackBBI];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PPLocationTableViewCell class])
                                           bundle:nil]
     forCellReuseIdentifier:kLocationItemRI];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PPCurrentLocationTableViewCell class])
                                           bundle:nil]
     forCellReuseIdentifier:kCurrentLocationItemRI];
    _tableView.draggableDelegate = self;
}

- (void)setupSearchTextField {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, WIDTH, kHeightSearchTextField)];
    [view setBackgroundColor:MAIN_COLOR];
    UITextField *textField = [[UITextField alloc] init];
    [textField setBorderStyle:UITextBorderStyleNone];
    [textField setBackgroundColor:RGB(24.f, 28.f, 32.f)];
    [textField setFont:[UIFont fontWithName:@"Montserrat-Light"
                                       size:14.f]];
    [textField setTextColor:[UIColor whiteColor]];
    [textField applyAttributedPlaceholderWithString:LOCALIZE(@"add_new_location")
                                           withFont:[UIFont fontWithName:@"Montserrat-ExtraLightItalic"
                                                                    size:14.f]
                                           andColor:RGB(78.f, 84.f, 94.f)];
    [textField sizeToFit];
    [textField setDelegate:self];
    [textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:textField];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.f
                                                      constant:20.f]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.f
                                                      constant:10.f]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.f
                                                      constant:-20.f]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.f
                                                      constant:-10.f]];
    [textField applyCornerRadius:kCornerRadiusSearchTextField];
    [textField setLeftViewMode:UITextFieldViewModeAlways];
    [textField setRightViewMode:UITextFieldViewModeAlways];
    CGFloat width = 2 * kCornerRadiusSearchTextField;
    UIImageView *addImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, width, kHeightSearchTextField)];
    [addImageView setContentMode:UIViewContentModeCenter];
    [addImageView setImage:[UIImage imageNamed:@"add_i.png"]];
    [textField setLeftView:addImageView];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicatorView setHidesWhenStopped:YES];
    [indicatorView setFrame:CGRectMake(0.f, 0.f, width, kHeightSearchTextField)];
    [textField setRightView:indicatorView];
    _searchTextField = textField;
    _searchIndicatorView = indicatorView;
    [_tableView setTableHeaderView:view];
}

- (void)setupSearchTableView {
    [_layoutConstraint setConstant:kHeightSearchTextField];
    [_searchTableView setHidden:YES];
    [_searchTableView setBackgroundColor:self.view.backgroundColor];
    [_searchTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_searchTableView registerNib:[UINib nibWithNibName:NSStringFromClass([PPSearchTableViewCell class])
                                                 bundle:nil]
           forCellReuseIdentifier:kSearchItemRI];
}

- (void)registerObservers {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardWillShow:)
                               name:UIKeyboardWillShowNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardWillHide:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
}

- (void)removeObservers {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:UIKeyboardWillShowNotification
                                object:nil];
    [notificationCenter removeObserver:self
                                  name:UIKeyboardWillHideNotification
                                object:nil];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return tableView == _tableView ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tableView) {
        return section == 0 ? 1 : _locationsModel.locationsForSettings.count;
    } else if (tableView == _searchTableView) {
        return _locationsModel.autocompleteLocations.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (tableView == _tableView) {
        if (indexPath.section == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:kCurrentLocationItemRI
                                                   forIndexPath:indexPath];
            [(PPCurrentLocationTableViewCell *)cell setDelegate:self];
            [(PPCurrentLocationTableViewCell *)cell setIndexPath:indexPath];
            [(PPCurrentLocationTableViewCell *)cell setUseCurrentLocation:_locationsModel.useCurrentLocation];
            NSString *title = _locationsModel.currentLocation ? _locationsModel.currentLocation.name : LOCALIZE(@"current_location");
            [(PPCurrentLocationTableViewCell *)cell setTitle:title];
        } else if (indexPath.section == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:kLocationItemRI
                                                   forIndexPath:indexPath];
            [(PPLocationTableViewCell *)cell setDelegate:self];
            [(PPLocationTableViewCell *)cell setIndexPath:indexPath];
            if (_locationsModel.locationsForSettings.count > 0 && indexPath.row <= _locationsModel.locationsForSettings.count - 1) {
                [(PPLocationTableViewCell *)cell setTitle:_locationsModel.locationsForSettings[indexPath.row].name];
            }
        }
    } else if (tableView == _searchTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:kSearchItemRI
                                               forIndexPath:indexPath];
        if (_locationsModel.autocompleteLocations.count > 0 &&
            indexPath.row <= _locationsModel.autocompleteLocations.count - 1) {
            [(PPSearchTableViewCell *)cell setTitle:_locationsModel.autocompleteLocations[indexPath.row].name];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _searchTableView) {
        [_locationsModel m_addLocationWithIndex:indexPath.row];
        [_tableView reloadData];
        [_searchTextField resignFirstResponder];
        [_tableView applyScrollingEnable];
    }
}

#pragma mark - VPDraggableTableViewDelegate

- (BOOL)tableView:(VPDraggableTableView *)tableView canDragCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(VPDraggableTableView *)tableView dragCellFromSourceIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)indexPath {
    [_locationsModel m_replaceLocationFromSourceIndexPath:sourceIndexPath
                                              toIndexPath:indexPath];
}

#pragma mark - PPCurrentLocationTableViewCellDelegate, PPLocationTableViewCellDelegate

- (BOOL)didSwitchCurrentLocationWithIndexPath:(NSIndexPath *)indexPath {
    if ([[PPUser sharedUser] notFirstTimeUseLocation] == NO) {
        [_locationsModel requestLocation];
        [[PPUser sharedUser] setNotFirstTimeUseLocation:YES];
        return NO;
    }
    if ([CLLocationManager locationServicesEnabled]) {
        if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
            CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [_locationsModel setUseCurrentLocation:!_locationsModel.useCurrentLocation];
            [_searchTextField setEnabled:NO];
            return YES;
        } else {
            PPAlertView *alertView = [[PPAlertView alloc] initWithTarget:self];
            [alertView setDelegate:self];
            [alertView setTitle:LOCALIZE(@"this_app_not_allow_to_use_geo_location_title")];
            [alertView setMessage:LOCALIZE(@"this_app_not_allow_to_use_geo_location_message")];
            PPActionButton *okActionButton = [PPActionButton actionButtonTypeOkWithKey:@"i_understood"];
            [alertView setActionButtons:@[okActionButton]];
            [alertView show];
            return NO;
        }
    }
    return NO;
}

- (void)didDeleteLocationWithIndexPath:(NSIndexPath *)indexPath {
    
    PPLocation *location = _locationsModel.locations[indexPath.row];
    
    if (SYSTEM_VERSION_GRATER_THAN_OR_EQUAL_TO_IOS_10) {
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center removePendingNotificationRequestsWithIdentifiers:@[location.zmw]];
        [center removePendingNotificationRequestsWithIdentifiers:@[[NSString stringWithFormat:@"%@_20", location.zmw]]];
        
    } else {
        
        for (UILocalNotification *localNotification in APPLICATION.scheduledLocalNotifications) {
            if ([location.zmw isEqualToString:localNotification.userInfo[@"zmw"]]) {
                [APPLICATION cancelLocalNotification:localNotification];
            }
        }
        
    }
    
    [_locationsModel m_removeLocationsWithIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[indexPath]
                      withRowAnimation:UITableViewRowAnimationNone];
    [_tableView reloadData];
    [_tableView applyScrollingEnable];
}

#pragma mark - PPLocationModelDelegate

- (void)didFindNearestCityByLastCoordinate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
        [_searchTextField setEnabled:YES];
    });
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [_tableView setScrollEnabled:NO];
    [_searchTableView setHidden:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField setText:nil];
    [_tableView setScrollEnabled:YES];
    [_searchTableView setHidden:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_locationsModel.autocompleteLocations.count == 1) {
        [_locationsModel m_addLocationWithIndex:0];
        [_tableView reloadData];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)sender {
    [_searchIndicatorView startAnimating];
    [_locationsModel m_autocompleteSearchWithString:sender.text
                                         completion:^(BOOL isSuccess) {
                                             [_searchTableView reloadData];
                                             [_searchIndicatorView stopAnimating];
                                             if (isSuccess) {
                                                 [_searchTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                                             inSection:0]
                                                                         atScrollPosition:UITableViewScrollPositionNone
                                                                                 animated:YES];
                                             }
                                         }];
}

#pragma mark - Observer methods

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [_searchTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, WIDTH, keyboardHeight)]];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [_searchTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

@end
