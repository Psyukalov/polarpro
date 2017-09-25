//
//  PPKPIndexViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 13.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPKPIndexViewController.h"

#import "AppDelegate.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "VPRefreshControl.h"

#import "PPGeomagneticStormModel.h"

#import "PPKPIndexItemView.h"


@interface PPKPIndexViewController () <AppListener, UIScrollViewDelegate, VPRefreshControlDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet PPKPIndexItemView *KPIndexItemView;

@property (weak, nonatomic) IBOutlet VPRefreshControl *refreshControl;

@end


@implementation PPKPIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [((AppDelegate *)[APPLICATION delegate]) setListener:self];
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
    [self.view setBackgroundColor:MAIN_COLOR];
    [self.navigationItem setTitle:LOCALIZE(@"kp_index")];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createBackBBI];
    [self createInfoBBI];
}

- (void)didEnterForeground {
    [_KPIndexItemView updateData];
}

#pragma mark - UIScrollViewDelegate & VPRefreshControlDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshControl fadeInOutWithScrollView:scrollView];
}

- (void)didStartRefreshControl:(VPRefreshControl *)refreshControl {
    [((PPGeomagneticStormModel *)[PPGeomagneticStormModel sharedModel]) stopTimersAndClear];
    [_KPIndexItemView updateData];
}

@end
