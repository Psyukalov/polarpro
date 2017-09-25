//
//  PPDevicesViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 11.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPDevicesViewController.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "UITableView+PPCustomHeaderFooterView.h"

#import "PPDeviceTableViewCell.h"

#import "PPDevicesModel.h"


@interface PPDevicesViewController () <UITableViewDataSource, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) PPDevicesModel *devicesModel;

@end


@implementation PPDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    _devicesModel = [PPDevicesModel sharedDevicesModel];
    [self.view setBackgroundColor:MAIN_COLOR];
    [self.navigationItem setTitle:LOCALIZE(@"devices")];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createBackBBI];
    [self createDoneBBI];
    [self hideDoneBBIAnimated:NO];
    [_tableView applyHeaderViewWithString:LOCALIZE(@"devices_tip")
                               andPadding:CGPaddingMake(20.f, 20.f, 20.f, 20.f)];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PPDeviceTableViewCell class])
                                           bundle:nil]
     forCellReuseIdentifier:kDeviceItemRI];
    [_tableView applySettings];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _devicesModel.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PPDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDeviceItemRI
                                                                  forIndexPath:indexPath];
    if (_devicesModel.devices.count > 0) {
        [cell setMark:_devicesModel.devices [indexPath.row].mark];
        [cell setModel:_devicesModel.devices [indexPath.row].model];
        if (_devicesModel.devices [indexPath.row].isAvailable) {
            [tableView selectRowAtIndexPath:indexPath
                                   animated:YES
                             scrollPosition:UITableViewScrollPositionNone];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showDoneBBIAnimated:YES];
    [_devicesModel m_addDeviceWithIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showDoneBBIAnimated:YES];
    [_devicesModel m_removeDeviceWithIndex:indexPath.row];
}

@end
