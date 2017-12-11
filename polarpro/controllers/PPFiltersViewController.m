//
//  PPFiltersViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 11.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPFiltersViewController.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "UITableView+PPCustomHeaderFooterView.h"
#import "FZAccordionTableView.h"
#import "polarpro-Swift.h"

#import "PPDeviceHeaderView.h"
#import "PPDeviceTableViewCell.h"

#import "PPDevicesViewController.h"

#import "PPDevicesModel.h"

#import "PPAlertView.h"


@interface PPFiltersViewController () <UITableViewDataSource, UITableViewDelegate, PPAlertViewDelegate>

@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;

@property (strong, nonatomic) PPDevicesModel *devicesModel;

@end


@implementation PPFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setup];
}

- (void)setup {
    _devicesModel = [PPDevicesModel sharedDevicesModel];
    [self.view setBackgroundColor:MAIN_COLOR];
    [self.navigationItem setTitle:LOCALIZE(@"filters")];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createBackBBI];
    [self createDoneBBI];
    [self hideDoneBBIAnimated:NO];
    [_tableView registerNib:[UINib nibWithNibName:@"PPDeviceHeaderView"
                                           bundle:nil] forHeaderFooterViewReuseIdentifier:kDeviceHeaderViewRI];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PPDeviceTableViewCell class])
                                           bundle:nil]
     forCellReuseIdentifier:kDeviceItemRI];
    [_tableView applyHeaderViewWithString:LOCALIZE(@"filters_tip")
                               andPadding:CGPaddingMake(20.f, 20.f, 20.f, 20.f)];
    [_tableView setAllowMultipleSectionsOpen:NO];
    [_tableView applySettings];
    [self enableScrolling];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableView reloadData];
    if (_devicesModel.availableDevices.count == 0) {
        
        PPAlertView *alertView = [[PPAlertView alloc] initWithTarget:self];
        [alertView setDelegate:self];
        [alertView setTitle:LOCALIZE(@"no_devices_title")];
        [alertView setMessage:LOCALIZE(@"no_devices_message")];
        PPActionButton *cancelActionButton = [PPActionButton actionButtonTypeCancelWithKey:@"cancel"];
        PPActionButton *okActionButton = [PPActionButton actionButtonTypeOkWithKey:@"ok"];
        [alertView setActionButtons:@[cancelActionButton, okActionButton]];
        [alertView show];
        
        /*
        [EZAlertController alert:LOCALIZE(@"no_devices_title")
                         message:LOCALIZE(@"no_devices_description")
                         buttons:@[LOCALIZE(@"cancel"),
                                   LOCALIZE(@"add")]
                        tapBlock:^(UIAlertAction * _Nonnull alertAction, NSInteger tag) {
                            switch (tag) {
                                case 0:
                                    [self.navigationController popViewControllerAnimated:YES];
                                    break;
                                case 1: {
                                    PPDevicesViewController *devicedVC = [[PPDevicesViewController alloc] init];
                                    [self.navigationController pushViewController:devicedVC
                                                                         animated:YES];
                                }
                                    break;
                                default:
                                    break;
                            }
                        }];
         */
    }
}

- (void)enableScrolling {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat height = HEIGHT - (self.navigationController.navigationBar.frame.size.height + kStatusBarHeight);
        [_tableView setScrollEnabled:_tableView.contentSize.height >= height];
    });
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _devicesModel.availableDevices.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _devicesModel.availableDevices [section].filters.count + 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PPDeviceHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kDeviceHeaderViewRI];
    if (_devicesModel.availableDevices.count > 0) {
        [view setMark:_devicesModel.availableDevices [section].mark];
        [view setModel:_devicesModel.availableDevices [section].model];
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PPDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDeviceItemRI
                                                                  forIndexPath:indexPath];
    if (_devicesModel.availableDevices.count > 0) {
        if (_devicesModel.availableDevices[indexPath.section].filters.count > 0) {
            [cell setMark:@"    "];
            if (indexPath.row == 0) {
                [cell setModel:LOCALIZE(@"i_own_all")];
                if ([_devicesModel m_checkAllFiltersInDeviceWithIdentifier:indexPath.section]) {
                    [tableView selectRowAtIndexPath:indexPath
                                           animated:YES
                                     scrollPosition:UITableViewScrollPositionNone];
                }
            } else {
                PPFilter *filter = _devicesModel.availableDevices[indexPath.section].filters[indexPath.row - 1];
                [cell setModel:filter.model];
                if (filter.isAvailable) {
                    [tableView selectRowAtIndexPath:indexPath
                                           animated:YES
                                     scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView heightForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showDoneBBIAnimated:YES];
    if (indexPath.row == 0) {
        [_devicesModel m_allFiltersInDeviceWithIdentifier:indexPath.section];
        [self selectRows:YES
             withSection:indexPath.section];
    } else {
        [_devicesModel m_addFilterWithSection:indexPath.section
                                       andRow:indexPath.row - 1];
        if ([_devicesModel m_checkAllFiltersInDeviceWithIdentifier:indexPath.section]) {
            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                               inSection:indexPath.section]
                                   animated:YES
                             scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showDoneBBIAnimated:YES];
    if (indexPath.row == 0) {
        [_devicesModel m_noneFiltersInDeviceWithIdentifier:indexPath.section];
        [self selectRows:NO
             withSection:indexPath.section];
    } else {
        [_devicesModel m_removeFilterWithSection:indexPath.section
                                          andRow:indexPath.row - 1];
        if (![_devicesModel m_checkAllFiltersInDeviceWithIdentifier:indexPath.section]) {
            [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                 inSection:indexPath.section]
                                     animated:YES];
        }
    }
}

- (void)selectRows:(BOOL)select
       withSection:(NSUInteger)section {
    for (NSUInteger i = 0; i <= _devicesModel.availableDevices[section].filters.count - 1; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i + 1
                                                    inSection:section];
        if (select) {
            [_tableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        } else {
            [_tableView deselectRowAtIndexPath:indexPath
                                      animated:YES];
        }
    }
}

#pragma mark - FZAccordionTableViewDelegate

- (void)tableView:(FZAccordionTableView *)tableView
  willOpenSection:(NSInteger)section
       withHeader:(UITableViewHeaderFooterView *)header {
    [(PPDeviceHeaderView *)header setIsSelected:YES];
}

- (void)tableView:(FZAccordionTableView *)tableView
   didOpenSection:(NSInteger)section
       withHeader:(UITableViewHeaderFooterView *)header {
    [self enableScrolling];
}

- (void)tableView:(FZAccordionTableView *)tableView
 willCloseSection:(NSInteger)section
       withHeader:(UITableViewHeaderFooterView *)header {
    [(PPDeviceHeaderView *)header setIsSelected:NO];
}

- (void)tableView:(FZAccordionTableView *)tableView
  didCloseSection:(NSInteger)section
       withHeader:(UITableViewHeaderFooterView *)header {
    [self enableScrolling];
}

#pragma mark - PPAlertViewDelegate

- (void)alertView:(PPAlertView *)alertView didActionWithActionButton:(PPActionButton *)actionButton {
    if ([actionButton.key isEqualToString:@"cancel"]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([actionButton.key isEqualToString:@"ok"]) {
        PPDevicesViewController *devicedVC = [[PPDevicesViewController alloc] init];
        [self.navigationController pushViewController:devicedVC
                                             animated:YES];
    }
}

@end
