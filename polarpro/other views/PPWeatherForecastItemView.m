//
//  PPWeatherForecastItemView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 21.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPWeatherForecastItemView.h"

#import "Macros.h"
#import "UITableView+PPCustomHeaderFooterView.h"
#import "UICollectionView+PPCustomCollectionView.h"
#import "UIView+PPCustomView.h"
#import "PPUtils.h"

#import "PPHourlyWeatherForecastCollectionViewCell.h"
#import "PPWeatherForecastTableViewCell.h"

#import "PPSettingsModel.h"


@interface PPWeatherForecastItemView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *temperatureContentView;

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

@property (weak, nonatomic) IBOutlet UILabel *windSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *windSpeedUnitsLabel;

/*
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityUnitsLabel;
 */

@property (weak, nonatomic) IBOutlet UILabel *visibilityLabel;
@property (weak, nonatomic) IBOutlet UILabel *visibilityUnitsLabel;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UIView *leftGradientView;
@property (weak, nonatomic) IBOutlet UIView *rightGradientView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray <PPWeather *> *hourlyForecast;
@property (strong, nonatomic) NSArray <PPWeather *> *weeklyForecast;

/*
@property (weak, nonatomic) IBOutlet UIImageView *dropImageView;
 */

@property (weak, nonatomic) IBOutlet UIImageView *visibilityImageView;
@property (weak, nonatomic) IBOutlet UIImageView *windImageView;

@property (strong, nonatomic) NSArray <NSArray <UIView *> *> *views;

@end


@implementation PPWeatherForecastItemView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadViewFromNib];
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadViewFromNib];
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadViewFromNib];
        [self setup];
    }
    return self;
}

- (void)loadViewFromNib {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *nib = [UINib nibWithNibName:@"PPWeatherForecastItemView"
                                bundle:bundle];
    UIView *view = (UIView *)[nib instantiateWithOwner:self
                                               options:nil].firstObject;
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:view];
    NSArray *attributes = @[@(NSLayoutAttributeLeft),
                            @(NSLayoutAttributeTop),
                            @(NSLayoutAttributeRight),
                            @(NSLayoutAttributeBottom)];
    for (NSNumber *attribute in attributes) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:[attribute unsignedIntegerValue]
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:[attribute unsignedIntegerValue]
                                                        multiplier:1.f
                                                          constant:0.f]];
    }
}

- (void)setup {
    UIColor *mainColor = MAIN_COLOR;
    UIColor *clearColor = [mainColor colorWithAlphaComponent:0.f];
    [self createGradientLayersForView:_leftGradientView
                           withColors:@[(id)mainColor.CGColor,
                                        (id)clearColor.CGColor]];
    [self createGradientLayersForView:_rightGradientView
                           withColors:@[(id)clearColor.CGColor,
                                        (id)mainColor.CGColor]];
    [_temperatureLabel setFont:[UIFont fontWithName:@"BN-Book"
                                               size:120.f]];
    for (UILabel *label in @[_windSpeedLabel,
                             
                             /*
                             _humidityLabel,
                              */
                             
                             _visibilityLabel]) {
        [label setFont:[UIFont fontWithName:@"BN-Light"
                                       size:24.f]];
    }
    for (UILabel *label in @[_windSpeedUnitsLabel,
                             
                             /*
                             _humidityUnitsLabel,
                              */
                             
                             _visibilityUnitsLabel]) {
        [label setFont:[UIFont fontWithName:@"BN-Light"
                                       size:12.f]];
    }
    [_iconImageView setTintColor:RGB(116.f, 174.f, 190.f)];
    [self setupCollectionView];
    [self setupTableView];
    _views = @[@[_temperatureLabel,
                 _iconImageView],
               @[_windImageView,
                 _windSpeedLabel,
                 _windSpeedUnitsLabel,
                 
                 /*
                 _dropImageView,
                 _humidityLabel,
                 _humidityUnitsLabel,
                  */
                 
                 _visibilityImageView,
                 _visibilityLabel,
                 _visibilityUnitsLabel,
                 _descriptionLabel],
               @[_cityLabel]];
    [_collectionView setHidden:YES];
    [self fadeInOutWeatherForecastHidden:YES
                                animated:NO];
    [PPUtils resizeLabelsInView:_temperatureContentView];
    [PPUtils resizeLabelsInView:self.subviews.lastObject];
    [PPUtils resizeMarginsInView:self.subviews.lastObject];
}

- (void)setupCollectionView {
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    if (SYSTEM_VERSION_GRATER_THAN_OR_EQUAL_TO_IOS_10) {
        [_collectionView setPrefetchDataSource:self];
    }
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PPHourlyWeatherForecastCollectionViewCell class])
                                                bundle:nil]
      forCellWithReuseIdentifier:kHourlyWeatherForecastCollectionViewCellRI];
}

- (void)setupTableView {
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PPWeatherForecastTableViewCell class])
                                           bundle:nil]
     forCellReuseIdentifier:kWeatherForecastTableViewCellRI];
}

- (void)applyImageWithName:(NSString *)name {
    UIImage *image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_iconImageView setImage:image];
}

#pragma mark - Custom accessors

- (void)setLocation:(PPLocation *)location {
    _location = location;
    [_collectionView setContentOffset:CGPointZero
                             animated:NO];
    [_cityLabel setText:_location.name];
    [_location updateConditionWeatherDataWithCompletion:^(PPWeather *condition) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_visibilityLabel setText:[NSString stringWithFormat:@"%1.0f", condition.visibility_km]];
            [_visibilityUnitsLabel setText:condition.localizedDistanceUnits];
        });
    }];
    [_location updateHourlyForecstWeatherWithCompletion:^(NSArray <PPWeather *> *hourlyForecast) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_temperatureLabel setText:[NSString stringWithFormat:@"%1.0f%@", hourlyForecast.firstObject.temp, kDegreeCharacter]];
            [_windSpeedLabel setText:[NSString stringWithFormat:@"%1.0f", hourlyForecast.firstObject.wind_kph]];
            
            /*
            [_humidityLabel setText:[NSString stringWithFormat:@"%1.0f", hourlyForecast.firstObject.humidity]];
             */
             
            [_windSpeedUnitsLabel setText:hourlyForecast.firstObject.localizedSpeedUnits];
            
            [_location updateAstronomyWithCompletion:^(PPAstronomy *astronomy) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *imageName;
                    NSDate *date = [VPTime dateWithString:hourlyForecast.firstObject.time
                                                andFormat:@"HH:mm"];
                    VPTime *time = [[VPTime alloc] initWithDate:date
                                                    andTimeZone:nil];
                    if ([time betweenfirstTime:astronomy.sunrise
                                 andSecondTime:astronomy.sunset]) {
                        imageName = [NSString stringWithFormat:@"%@_i.png", hourlyForecast.firstObject.icon];
                    } else {
                        imageName = [NSString stringWithFormat:@"%@_i_n.png", hourlyForecast.firstObject.icon];
                    }
                    [self applyImageWithName:imageName];
                    [_descriptionLabel setText:hourlyForecast.firstObject.conditions];
                    [self fadeInOutWeatherForecastHidden:NO
                                                animated:YES];
                    _hourlyForecast = hourlyForecast;
                    [_collectionView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_collectionView fadeInOutVisibleCellsHidden:YES
                                                            animated:NO];
                        [_collectionView fadeInOutVisibleCellsHidden:NO
                                                            animated:YES];
                    });
                    
                });
            }];
            
        });
    }];
    [_location updateWeeklyForecstWeatherWithCompletion:^(NSArray <PPWeather *> *weeklyForecast) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _weeklyForecast = weeklyForecast;
            [_tableView reloadData];
            [_tableView fadeInOutVisibleCellsHidden:YES
                                           animated:NO];
            [_tableView fadeInOutVisibleCellsHidden:NO
                                           animated:YES];
        });
    }];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (_hourlyForecast.count > kDay) ? kDay : _hourlyForecast.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PPHourlyWeatherForecastCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHourlyWeatherForecastCollectionViewCellRI
                                                                                                forIndexPath:indexPath];
    if (_hourlyForecast.count > 0 &&
        indexPath.row <= _hourlyForecast.count - 1) {
        PPWeather *weather = _hourlyForecast[indexPath.row];
        NSString *imageName;
        NSDate *date = [VPTime dateWithString:weather.time
                                    andFormat:@"HH:mm"];
        VPTime *time = [[VPTime alloc] initWithDate:date
                                        andTimeZone:nil];
        if ([time betweenfirstTime:_location.astronomy.sunrise
                     andSecondTime:_location.astronomy.sunset]) {
            imageName = [NSString stringWithFormat:@"%@_i.png", weather.icon];
        } else {
            imageName = [NSString stringWithFormat:@"%@_i_n.png", weather.icon];
        }
        VPTimeType currentTimeType = VPTimeType24Hours;
        VPTimeFormat currentTimeFormat = VPTimeHoursAndMinutesFormat;
        if (((PPSettingsModel *)[PPSettingsModel sharedModel]).groups[1].options[0].currentParameter == 1) {
            currentTimeType = VPTimeType12Hours;
            currentTimeFormat = VPTimeHoursFormat;
        }
        [time setTimeType:currentTimeType];
        [time setTimeFormat:currentTimeFormat];
        [cell setTime:time.text];
        [cell setIcon:imageName];
        [cell setTemperature:weather.temp];
    }
    return cell;
}

#ifdef SYSTEM_VERSION_GRATER_THAN_OR_EQUAL_TO_IOS_10

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    //
}

#endif

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width / kHourlyForecastCount, collectionView.frame.size.height) ;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (_weeklyForecast.count > kWeek) ? kWeek : _weeklyForecast.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PPWeatherForecastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWeatherForecastTableViewCellRI
                                                                           forIndexPath:indexPath];
    if (_weeklyForecast.count > 0 &&
        indexPath.row <= _weeklyForecast.count - 1) {
        PPWeather *weather = _weeklyForecast[indexPath.row];
        [cell setWeekday:weather.weekday];
        [cell setIcon:[NSString stringWithFormat:@"%@_i.png", weather.icon]];
        [cell setMaxTemperature:weather.high];
        [cell setMinTemperature:weather.low];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f * [PPUtils screenRate];
}

- (void)fadeInOutWeatherForecastHidden:(BOOL)hidden
                              animated:(BOOL)animated {
    CGFloat alpha = hidden ? 0.f : 1.f;
    CGAffineTransform scaleTransform = hidden ? CGAffineTransformMakeScale(.8f, .8f) : CGAffineTransformIdentity;
    if (animated) {
        for (NSUInteger i = 0; i <= _views.count - 1; i++) {
            for (NSUInteger j = 0; j <= _views[i].count - 1; j++) {
                [UIView animateWithDuration:.6f
                                      delay:i * .2f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [_views[i][j] setAlpha:alpha];
                                     [_views[i][j] setTransform:scaleTransform];
                                 }
                                 completion:nil];
            }
        }
    } else {
        for (NSUInteger i = 0; i <= _views.count - 1; i++) {
            for (NSUInteger j = 0; j <= _views[i].count - 1; j++) {
                [_views[i][j] setAlpha:alpha];
                [_views[i][j] setTransform:scaleTransform];
            }
        }
    }
}

@end
