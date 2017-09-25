//
//  PPHubViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 29.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "AppDelegate.h"

#import "PPHubViewController.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "UIView+PPCustomView.h"
#import "VPDraggableCollectionView.h"
#import "VPRefreshControl.h"
#import "PPUtils.h"

#import "PPFilterGuideViewController.h"
#import "PPWebViewController.h"

#import "PPAstronomyCollectionViewCell.h"
#import "PPWeatherCollectionViewCell.h"
#import "PPKPinfoCollectionViewCell.h"
#import "PPWindCollectionViewCell.h"
#import "PPMessageCollectionViewCell.h"

#import "PPGoldenHourViewController.h"
#import "PPWeatherForecastViewController.h"
#import "PPKPIndexViewController.h"
#import "PPWindConditionViewController.h"
#import "PPLocationsViewController.h"

#import "PPLocationsModel.h"
#import "PPGeomagneticStormModel.h"

#import "PPUser.h"

#import "VPActivityIndicatorView.h"
#import "PPStartView.h"


#define kSpacing (8.f)


@interface PPHubViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout, VPDraggableCollectionViewDelegate, PPLocationModelDelegate, AppListener, PPMessageCollectionViewCellDelegate, PPStartViewDelegate, UIScrollViewDelegate, VPRefreshControlDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *filterGuideView;
@property (weak, nonatomic) IBOutlet UIView *siteView;

@property (weak, nonatomic) IBOutlet UILabel *filterGuideLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *siteLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (weak, nonatomic) IBOutlet VPDraggableCollectionView *collectionView;

@property (weak, nonatomic) IBOutlet VPRefreshControl *refreshControl;

@property (strong, nonatomic) PPAstronomyCollectionViewCell *astronomyCVC;
@property (strong, nonatomic) PPKPinfoCollectionViewCell *KPInfoCVC;
@property (strong, nonatomic) PPWindCollectionViewCell *windCVC;
@property (strong, nonatomic) PPWeatherCollectionViewCell *weatherCVC;

@property (strong, nonatomic) PPLocationsModel *locationModel;

@end


@implementation PPHubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_scrollView setAlwaysBounceVertical:YES];
    [_refreshControl setDelegate:self];
    [self startViewSetup];
    [self setup];
    [self setupHubElements];
    [self localize];
    [PPUtils resizeLabelsInView:_filterGuideView];
    [PPUtils resizeLabelsInView:_siteView];
    [PPUtils resizeLabelsInView:_contentView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_locationModel setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupDidAppear];
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

- (void)startViewSetup {
    PPStartView *startView = [[PPStartView alloc] initWithFrame:CGRectMake(0.f, 0.f, WIDTH, HEIGHT)];
    [startView setDelegate:self];
    [startView play];
}

- (void)setup {
    _locationModel = [PPLocationsModel sharedModel];
    [_locationModel setDelegate:self];
    [self.view setBackgroundColor:MAIN_COLOR];
    [self.navigationItem setTitle:nil];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createMenuBBI];
    [self createLogoBBI];
    [_filterGuideView applyCornerRadius:6.f];
    [_siteView applyCornerRadius:6.f];
    [_filterGuideView setBackgroundColor:RGB(28.f, 30.f, 34.f)];
    [_siteView setBackgroundColor:RGB(28.f, 30.f, 34.f)];
    [_filterGuideLabel setFont:[UIFont fontWithName:@"BN-Regular"
                                               size:34.f]];
    UITapGestureRecognizer *tapGestureRecognizerOnFilterGuideView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                            action:@selector(tapGestureRecognizedOnFilterGuideViewAction:)];
    UITapGestureRecognizer *tapGestureRecognizerOnSiteView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                     action:@selector(tapGestureRecognizedOnSiteViewAction:)];
    [_filterGuideView setGestureRecognizers:@[tapGestureRecognizerOnFilterGuideView]];
    [_siteView setGestureRecognizers:@[tapGestureRecognizerOnSiteView]];
}

- (void)setupHubElements {
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PPMessageCollectionViewCell class])
                                                bundle:nil]
      forCellWithReuseIdentifier:kMessageCollectionViewCellRI];
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PPAstronomyCollectionViewCell class])
                                                bundle:nil]
      forCellWithReuseIdentifier:kAstronomyCollectionViewCellRI];
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PPWeatherCollectionViewCell class])
                                                bundle:nil]
      forCellWithReuseIdentifier:kWeatherCollectionViewCellRI];
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PPKPinfoCollectionViewCell class])
                                                bundle:nil]
      forCellWithReuseIdentifier:kKPInfoCollectionViewCellRI];
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PPWindCollectionViewCell class])
                                                bundle:nil]
      forCellWithReuseIdentifier:kWindCollectionViewCellRI];
    if (SYSTEM_VERSION_GRATER_THAN_OR_EQUAL_TO_IOS_10) {
        [_collectionView setPrefetchDataSource:self];
    }
    [_collectionView setDraggableDelegate:self];
}

- (void)setupDidAppear {
    static BOOL firstRun = YES;
    if (!firstRun) {
        [_collectionView reloadData];
        return;
    }
    firstRun = NO;
}

#pragma mark - PPLocationModelDelegate

- (void)didFindNearestCityByLastCoordinate {
    NSLog(@"Did find nearest city");
    [_collectionView reloadData];
}

#pragma mark - Actions

- (void)localize {
    [_filterGuideLabel setText:LOCALIZE(@"hub_filter_guide")];
    [_tipLabel setText:LOCALIZE(@"hub_filter_guide_tip")];
    [_siteLabel setText:LOCALIZE(@"hub_site")];
    [_subtitleLabel setText:LOCALIZE(@"shop_now")];
}

- (void)tapGestureRecognizedOnFilterGuideViewAction:(UITapGestureRecognizer *)sender {
    PPFilterGuideViewController *filterGuideVC = [[PPFilterGuideViewController alloc] init];
    [self.navigationController pushViewController:filterGuideVC
                                         animated:YES];
}

- (void)tapGestureRecognizedOnSiteViewAction:(UITapGestureRecognizer *)sender {
    PPWebViewController *webVC = [[PPWebViewController alloc] initWithURL:@"https://www.polarprofilters.com/"];
    [self.navigationController pushViewController:webVC
                                         animated:YES];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _locationModel.locations.count == 0 ? 1 : 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    if (_locationModel.locations.count > 0) {
        NSUInteger index = [[[PPUser sharedUser] hubOrder][indexPath.row] integerValue];
        switch (index) {
            case 0: {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAstronomyCollectionViewCellRI
                                                                 forIndexPath:indexPath];
                _astronomyCVC = (PPAstronomyCollectionViewCell *)cell;
                [_astronomyCVC setLocation:_locationModel.locations[0]];
            }
                break;
            case 1: {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWeatherCollectionViewCellRI
                                                                 forIndexPath:indexPath];
                _weatherCVC = (PPWeatherCollectionViewCell *)cell;
                [_weatherCVC setLocation:_locationModel.locations[0]];
            }
                break;
            case 2: {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:kKPInfoCollectionViewCellRI
                                                                 forIndexPath:indexPath];
                _KPInfoCVC = (PPKPinfoCollectionViewCell *)cell;
                [_KPInfoCVC updateCell];
            }
                break;
            case 3: {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWindCollectionViewCellRI
                                                                 forIndexPath:indexPath];
                _windCVC = (PPWindCollectionViewCell *)cell;
                [_windCVC setLocation:_locationModel.locations[0]];
            }
                break;
            default:
                //
                break;
        }
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMessageCollectionViewCellRI
                                                         forIndexPath:indexPath];
        [((PPMessageCollectionViewCell *)cell) setDelegate:self];
    }
    return cell;
}

#ifdef SYSTEM_VERSION_GRATER_THAN_OR_EQUAL_TO_IOS_10

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    //
}

#endif

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize result;
    if (_locationModel.locations.count > 0) {
        result = CGSizeMake((_collectionView.frame.size.width - kSpacing) / 2,
                            (_collectionView.frame.size.height - kSpacing) / 2);
    } else {
        result = CGSizeMake(_collectionView.frame.size.width,
                            _collectionView.frame.size.height);
    }
    return result;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_locationModel.locations.count == 0) {
        return;
    }
    NSUInteger index = [[[PPUser sharedUser] hubOrder][indexPath.row] integerValue];
    switch (index) {
        case 0: {
            PPGoldenHourViewController *goldenHourVC = [[PPGoldenHourViewController alloc] init];
            [self.navigationController pushViewController:goldenHourVC
                                                 animated:YES];
        }
            break;
        case 1: {
            PPWeatherForecastViewController *weatherForecastVC = [[PPWeatherForecastViewController alloc] init];
            [self.navigationController pushViewController:weatherForecastVC
                                                 animated:YES];
        }
            break;
        case 2: {
            PPKPIndexViewController *KPIndexVC = [[PPKPIndexViewController alloc] init];
            [self.navigationController pushViewController:KPIndexVC
                                                 animated:YES];
        }
            break;
        case 3: {
            PPWindConditionViewController *windConditionVC = [[PPWindConditionViewController alloc] init];
            [self.navigationController pushViewController:windConditionVC
                                                 animated:YES];
        }
            break;
        default:
            //
            break;
    }
}

#pragma mark - VPDraggableCollectionViewDelegate

- (void)collectionView:(VPDraggableCollectionView *)collectionView didLongPressCellAtIndexPath:(NSIndexPath *)indexPath {
    [_KPInfoCVC stopAnimation];
    [_windCVC stopAnimation];
}

- (void)collectionView:(VPDraggableCollectionView *)collectionView didCancelLongPressCellAtIndexPath:(NSIndexPath *)indexPath {
    [_KPInfoCVC playAnimation];
    [_windCVC playAnimation];
}

- (void)collectionView:(VPDraggableCollectionView *)collectionView dragCellFromSourceIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *hubOrder = [NSMutableArray arrayWithArray:[[PPUser sharedUser] hubOrder]];
    NSUInteger index = [hubOrder[sourceIndexPath.row] integerValue];
    [hubOrder removeObjectAtIndex:sourceIndexPath.row];
    [hubOrder insertObject:@(index)
                   atIndex:indexPath.row];
    [[PPUser sharedUser] setHubOrder:hubOrder.mutableCopy];
}

- (BOOL)collectionView:(VPDraggableCollectionView *)collectionView canDragCellAtIndexPath:(NSIndexPath *)indexPath {
    return _locationModel.locations.count > 0;
}

#pragma mark - PPMessageCollectionViewCellDelegate

- (void)didActionWithButton:(UIButton *)button {
    PPLocationsViewController *locationVC = [[PPLocationsViewController alloc] init];
    [self.navigationController pushViewController:locationVC
                                         animated:YES];
}

#pragma mark - AppListener

- (void)didEnterForeground {
    [self setupDidAppear];
}

#pragma mark - PPStartViewDelegate

- (void)didCompleteStartAnimation {
    
    if (!SYSTEM_VERSION_GRATER_THAN_OR_EQUAL_TO_IOS_10) {
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeSound)
                                                                                 categories:nil];
        [APPLICATION registerUserNotificationSettings:settings];
        [APPLICATION registerForRemoteNotifications];
        
    }
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshControl fadeInOutWithScrollView:scrollView];
    if (scrollView.contentOffset.y > 0.f) {
        [scrollView setContentOffset:CGPointZero];
    }
}

#pragma mark - VPRefreshControl

- (void)didStartRefreshControl:(VPRefreshControl *)refreshControl {
    [_locationModel clearAll];
    [((PPGeomagneticStormModel *)[PPGeomagneticStormModel sharedModel]) stopTimersAndClear];
    [_collectionView reloadData];
}

@end
