//
//  PPFilterGuideViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 19.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPFilterGuideViewController.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "iCarousel.h"
#import "PPUtils.h"

#import "PPSupportViewController.h"

#import "PPDevicesModel.h"

#import "PPFilterGuideItemView.h"

#import "PPDevicesViewController.h"

#import "PPAlertView.h"


@interface PPFilterGuideViewController () <iCarouselDataSource, iCarouselDelegate, PPFilterGuideItemViewDelegate, PPAlertViewDelegate>

@property (weak, nonatomic) IBOutlet iCarousel *carouselView;

@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) PPDevicesModel *devicesModel;

@end


@implementation PPFilterGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_devicesModel.isUpdate) {
        [_pageControl setNumberOfPages:_devicesModel.availableDevices.count];
        [self changeDeviceWithIndex:_carouselView.currentItemIndex];
        [_carouselView reloadData];
        _devicesModel.isUpdate = NO;
    }
    if (_devicesModel.availableDevices.count == 0) {
        PPAlertView *alertView = [[PPAlertView alloc] initWithTarget:self];
        [alertView setTitle:LOCALIZE(@"no_devices_title")];
        [alertView setMessage:LOCALIZE(@"no_devices_message")];
        [alertView setDelegate:self];
        [alertView setActionButtons:@[[PPActionButton actionButtonTypeCancelWithKey:@"cancel"],
                                      [PPActionButton actionButtonTypeOkWithKey:@"ok"]]];
        [alertView show];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setup {
    _devicesModel = [PPDevicesModel sharedDevicesModel];
    [_carouselView setDataSource:self];
    [_carouselView setDelegate:self];
    [_carouselView setDecelerationRate:.64f];
    [_carouselView setBounces:NO];
    [_pageControl setNumberOfPages:_devicesModel.availableDevices.count];
    [self changeDeviceWithIndex:0];
    [self.navigationItem setTitle:LOCALIZE(@"filter_guide")];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self.view setBackgroundColor:MAIN_COLOR];
    [self createBackBBI];
    [self createSettingsBBI];
    [PPUtils resizeLabelsInView:self.view];
}

#pragma mark - iCarouselDataSource, iCarouselDelegate

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    NSUInteger count = _devicesModel.availableDevices.count;
    return (count == 0) ? 1 : count;
}

- (UIView *)carousel:(iCarousel *)carousel
  viewForItemAtIndex:(NSInteger)index
         reusingView:(UIView *)view {
    if (!view) {
        view = [[PPFilterGuideItemView alloc] initWithFrame:carousel.bounds];
    }
    PPFilterGuideItemView *filterGuideItemView = (PPFilterGuideItemView *)view;
    [filterGuideItemView setIdentifier:index];
    [filterGuideItemView setDelegate:self];
    if (_devicesModel.availableDevices.count > 0 && index <= _devicesModel.availableDevices.count - 1) {
        [filterGuideItemView setDevice:[NSString stringWithFormat:@"%@ %@", _devicesModel.availableDevices[index].mark, _devicesModel.availableDevices[index].model]];
        [filterGuideItemView setFPS:_devicesModel.availableDevices[index].FPSCaptions];
        [filterGuideItemView setShutterSpeed:_devicesModel.availableDevices[index].shutterSpeedCaptions];
        [filterGuideItemView setFiltersInstalled:_devicesModel.availableDevices[index].installedFiltersCaptions];
        [filterGuideItemView setSelectedParameters:_devicesModel.availableDevices[index].selectedParameters];
    }
    [filterGuideItemView reloadView];
    return filterGuideItemView;
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    NSUInteger index = carousel.currentItemIndex;
    if (_pageControl.currentPage != index) {
        [self changeDeviceWithIndex:index];
    }
}

- (void)changeDeviceWithIndex:(NSUInteger)index {
    [_pageControl setCurrentPage:index];
    if (_devicesModel.availableDevices.count > 0 && index <= _devicesModel.availableDevices.count - 1) {
        PPDevice *device = _devicesModel.availableDevices[index];
        NSString *string = [NSString stringWithFormat:@"%@ %@", device.mark, device.model];
        string = [string uppercaseString];
        [_deviceLabel setText:string];
    } else {
        [_deviceLabel setText:[LOCALIZE(@"no_devices") uppercaseString]];
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionVisibleItems:
            return _devicesModel.availableDevices.count;
            break;
        case iCarouselOptionSpacing:
            return 1.68f * value;
            break;
        default:
            return value;
            break;
    }
}

#pragma mark - PPFilterGuideItemViewDelegate

- (void)didChangeCalculatorParameters:(NSArray<NSNumber *> *)parameters withIdentifier:(NSUInteger)identifier {
    [_devicesModel.availableDevices[identifier] setSelectedParameters:parameters];
}

#pragma mark - PPAlertViewDelegate

- (void)alertView:(PPAlertView *)alertView didActionWithActionButton:(PPActionButton *)actionButton {
    if ([actionButton.key isEqualToString:@"ok"]) {
        PPDevicesViewController *devicesVC = [[PPDevicesViewController alloc] init];
        [self.navigationController pushViewController:devicesVC
                                             animated:YES];
    } else if ([actionButton.key isEqualToString:@"cancel"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
