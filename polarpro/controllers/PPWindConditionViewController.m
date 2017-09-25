//
//  PPWindConditionViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 01.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPWindConditionViewController.h"

#import "AppDelegate.h"

#import "Macros.h"
#import "PPWindProctatorView.h"
#import "UIViewController+PPCostomViewController.h"
#import "VPPageControl.h"
#import "iCarousel.h"
#import "VPRefreshControl.h"

#import "PPWindConditionItemView.h"

#import "PPCustomSettingsViewController.h"

#import "PPAlertView.h"


@interface PPWindConditionViewController () <iCarouselDataSource, iCarouselDelegate, PPCustomSettingsViewControllerDelegate, PPAlertViewDelegate, AppListener, UIScrollViewDelegate, VPRefreshControlDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet iCarousel *carouselView;

@property (weak, nonatomic) IBOutlet VPPageControl *pageControl;

@property (weak, nonatomic) IBOutlet VPRefreshControl *refreshControl;

@property (strong, nonatomic) PPLocationsModel *locationModel;

@end


@implementation PPWindConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupDidAppear];
    [((AppDelegate *)[APPLICATION delegate]) setListener:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!_locationModel.useCurrentLocation && _locationModel.locations.count > 1) {
        if (_carouselView.currentItemIndex != 0) {
            NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:_carouselView.currentItemIndex
                                                              inSection:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                        inSection:0];
            [_locationModel m_replaceLocationFromSourceIndexPath:sourceIndexPath
                                                     toIndexPath:indexPath];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [((AppDelegate *)[APPLICATION delegate]) setListener:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setup {
    [_scrollView setAlwaysBounceVertical:YES];
    [_refreshControl setDelegate:self];
    [_refreshControl setFreezeThenStart:YES];
    _locationModel = [PPLocationsModel sharedModel];
    [self.navigationItem setTitle:LOCALIZE(@"wind_condition")];
    [self.view setBackgroundColor:MAIN_COLOR];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createBackBBI];
    [self createSettingsBBI];
    [_pageControl setAlpha:0.f];
    [self.navigationItem.rightBarButtonItem setAction:@selector(settingsBBI_TUI)];
    [_pageControl setIndexForImage:0];
    [_pageControl setDefaultImage:[UIImage imageNamed:@"geo_dot_default_i.png"]];
    [_pageControl setSelectedImage:[UIImage imageNamed:@"geo_dot_selected_i.png"]];
    [_pageControl setPageIndicatorTintColor:RGB(46.f, 62.f, 70.f)];
    [_pageControl setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
    [_carouselView setDataSource:self];
    [_carouselView setDelegate:self];
    [_carouselView setDecelerationRate:.64f];
    [_carouselView setBounces:NO];
}

- (void)setupDidAppear {
    [self applyLocationsCount];
    if (_locationModel.locations.count == 0) {
        PPAlertView *alertView = [[PPAlertView alloc] initWithTarget:self];
        [alertView setTitle:LOCALIZE(@"no_locations_title")];
        [alertView setMessage:LOCALIZE(@"no_locations_message")];
        [alertView setDelegate:self];
        [alertView setActionButtons:@[[PPActionButton actionButtonTypeCancelWithKey:@"cancel"],
                                      [PPActionButton actionButtonTypeOkWithKey:@"ok"]]];
        [alertView show];
    }
    if (_pageControl.alpha == 0.f) {
        [UIView animateWithDuration:.6f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_pageControl setAlpha:1.f];
                         }
                         completion:nil];
    }
}

#pragma mark - iCarouselDataSource, iCarouselDelegate

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return _locationModel.locations.count;
}

- (UIView *)carousel:(iCarousel *)carousel
  viewForItemAtIndex:(NSInteger)index
         reusingView:(UIView *)view {
    if (!view) {
        view = [[PPWindConditionItemView alloc] initWithFrame:carousel.bounds];
    }
    PPWindConditionItemView *windConditionItemView = (PPWindConditionItemView *)view;
    if (_locationModel.locations.count > 0 && index <= _locationModel.locations.count - 1) {
        [windConditionItemView setLocation:_locationModel.locations[index]];
    }
    return windConditionItemView;
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    [_pageControl setCurrentPage:carousel.currentItemIndex];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionVisibleItems:
            return 3;
            break;
        case iCarouselOptionSpacing:
            return 1.68f * value;
            break;
        default:
            return value;
            break;
    }
}

#pragma mark - Actions

- (void)settingsBBI_TUI {
    PPCustomSettingsViewController *settingVC = [[PPCustomSettingsViewController alloc] initWithType:PPSettingsTypeWindCondition];
    [settingVC setDelegate:self];
    [self.navigationController pushViewController:settingVC
                                         animated:YES];
}

#pragma mark - PPCustomSettingsViewControllerDelegate

- (void)didUpdateSettings {
    [_carouselView reloadData];
    [self applyLocationsCount];
    [_pageControl setAlpha:0.f];
}

#pragma mark - Other methods

- (void)applyLocationsCount {
    [_pageControl setUseIndexForImage:(_locationModel.useCurrentLocation && _locationModel.currentLocation)];
    if (_locationModel.locations.count != 0) {
        [_pageControl setNumberOfPages:_locationModel.locations.count];
        [_pageControl setCurrentPage:_carouselView.currentItemIndex];
    }
}

#pragma mark - PPAlertViewDelegate

- (void)alertView:(PPAlertView *)alertView didActionWithActionButton:(PPActionButton *)actionButton {
    if ([actionButton.key isEqualToString:@"ok"]) {
        [self settingsBBI_TUI];
    } else if ([actionButton.key isEqualToString:@"cancel"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - AppListener

- (void)didEnterForeground {
    [self setupDidAppear];
    [_carouselView reloadData];
}

#pragma mark - UIScrollViewDelegate & VPRefreshControlDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshControl fadeInOutWithScrollView:scrollView];
}

- (void)didStartRefreshControl:(VPRefreshControl *)refreshControl {
    [_locationModel clearAll];
    [_carouselView reloadData];
    [self performSelector:@selector(stopRefreshControl)
               withObject:nil
               afterDelay:1.f];
}

- (void)stopRefreshControl {
    [_refreshControl endAnimating];
}

@end
