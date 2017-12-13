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
#import "iCarousel.h"

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
#import "PPCameraCalculatorViewController.h"

#import "PPLocationsModel.h"
#import "PPGeomagneticStormModel.h"

#import "PPUser.h"

#import "VPActivityIndicatorView.h"
#import "PPStartView.h"
#import "PPHubCalculatorView.h"
#import "PPAdView.h"


#define kSpacing (8.f)


@interface PPHubViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout, VPDraggableCollectionViewDelegate, PPLocationModelDelegate, AppListener, PPMessageCollectionViewCellDelegate, PPStartViewDelegate, UIScrollViewDelegate, VPRefreshControlDelegate, iCarouselDataSource, iCarouselDelegate, PPAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet iCarousel *carouselView;

@property (weak, nonatomic) IBOutlet PPAdView *adView;

@property (weak, nonatomic) IBOutlet VPDraggableCollectionView *collectionView;

@property (weak, nonatomic) IBOutlet VPRefreshControl *refreshControl;

@property (strong, nonatomic) PPAstronomyCollectionViewCell *astronomyCVC;
@property (strong, nonatomic) PPKPinfoCollectionViewCell *KPInfoCVC;
@property (strong, nonatomic) PPWindCollectionViewCell *windCVC;
@property (strong, nonatomic) PPWeatherCollectionViewCell *weatherCVC;

@property (strong, nonatomic) PPLocationsModel *locationModel;

@property (strong, nonatomic) NSArray <PPAd *> *ads;

@end


@implementation PPHubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_scrollView setAlwaysBounceVertical:YES];
    [_refreshControl setDelegate:self];
    [self startViewSetup];
    [self setup];
    [self setupHubElements];
    [PPUtils resizeLabelsInView:_contentView];
    [self setupCarousel];
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
    [_adView stop];
    [((AppDelegate *)[APPLICATION delegate]) setListener:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setupCarousel {
    [_carouselView layoutIfNeeded];
    [_carouselView setDecelerationRate:.64f];
    [_carouselView setBounces:NO];
    _carouselView.type = iCarouselTypeLinear;
    [_carouselView setDataSource:self];
    [_carouselView setDelegate:self];
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
    _adView.delegate = self;
    _adView.autoplay = YES;
    
    // TODO: Test;
    PPAd *ad0 = [PPAd new];
    ad0.type = PPAdTypeImage;
    ad0.URL = @"https://www.bhphotovideo.com/images/images1000x1000/polar_pro_850454006048_strapmount_gopro_backpack_scuba_mount_1144813.jpg";
    ad0.actionURL = @"https://vk.com";
    ad0.showTime = 2.f;
    
    PPAd *ad1 = [PPAd new];
    ad1.type = PPAdTypeImage;
    ad1.URL = @"http://image.helipal.com/polarpro-filter-p4p-cinema-shutter-big.jpg";
    ad1.actionURL = @"https://www.facebook.com";
    ad1.showTime = 2.f;
    
    PPAd *ad5 = [PPAd new];
    ad5.type = PPAdTypeGIF;
    ad5.URL = @"https://media1.giphy.com/media/3o7qE52FdzR7awdCo0/giphy.gif";
    ad1.actionURL = @"https://ok.ru";
    
    _ads = @[ad0, ad1, ad5];
    //
    
    _adView.ads = _ads;
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
        [_adView play];
        [_collectionView reloadData];
        return;
    }
    firstRun = NO;
}

#pragma mark - PPLocationModelDelegate

- (void)didFindNearestCityByLastCoordinate {
    [_collectionView reloadData];
}

#pragma mark - iCarouselDataSource, iCarouselDelegate

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel
  viewForItemAtIndex:(NSInteger)index
         reusingView:(UIView *)view {
    if (!view) {
        view = [[PPHubCalculatorView alloc] initWithFrame:carousel.bounds];
    }
    ((PPHubCalculatorView *)view).type = index;
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionVisibleItems:
            return 4.f;
            break;
        case iCarouselOptionSpacing:
            return 1.f * value;
            break;
        case iCarouselOptionWrap:
            return 1.f;
            break;
        default:
            return value;
            break;
    }
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (index == 0) {
        PPFilterGuideViewController *filterGuideVC = [[PPFilterGuideViewController alloc] init];
        [self.navigationController pushViewController:filterGuideVC
                                             animated:YES];
    } else {
        PPCameraCalculatorViewController *cameraCalculatorVC = [PPCameraCalculatorViewController new];
        [self.navigationController pushViewController:cameraCalculatorVC
                                             animated:YES];
    }
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout

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

#pragma mark - PPAdViewDelegate

- (void)didSelectDefaultAdInAdView:(PPAdView *)adView {
    PPWebViewController *webVC = [[PPWebViewController alloc] initWithURL:@"https://www.polarprofilters.com/"];
    [self.navigationController pushViewController:webVC
                                         animated:YES];
}

- (void)adView:(PPAdView *)adView didSelectAdAtIndex:(NSUInteger)index {
    PPWebViewController *webVC = [[PPWebViewController alloc] initWithURL:_ads[index].actionURL];
    [self.navigationController pushViewController:webVC
                                         animated:YES];
}

#pragma mark - VPRefreshControl

- (void)didStartRefreshControl:(VPRefreshControl *)refreshControl {
    [_locationModel clearAll];
    [((PPGeomagneticStormModel *)[PPGeomagneticStormModel sharedModel]) stopTimersAndClear];
    [_collectionView reloadData];
}

@end
