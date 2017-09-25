//
//  PPWindConditionItemView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 02.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPWindConditionItemView.h"

#import "Macros.h"
#import "UIView+PPCustomView.h"
#import "UICollectionView+PPCustomCollectionView.h"
#import "UITableView+PPCustomHeaderFooterView.h"
#import "PPWindProctatorView.h"
#import "PPUtils.h"

#import "PPHourlyWindConditionCollectionViewCell.h"

#import "PPWindConditionTableViewCell.h"

#import "PPSettingsModel.h"


#define kAlpha (4)

#define kRotateAnimationKey (@"rotate_animation")


@interface PPWindConditionItemView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet PPWindProctatorView *windProctatorView;

@property (weak, nonatomic) IBOutlet UILabel *northLabel;
@property (weak, nonatomic) IBOutlet UILabel *southLabel;
@property (weak, nonatomic) IBOutlet UILabel *westLabel;
@property (weak, nonatomic) IBOutlet UILabel *eastLabel;
@property (weak, nonatomic) IBOutlet UILabel *northEastLabel;
@property (weak, nonatomic) IBOutlet UILabel *southEastLabel;
@property (weak, nonatomic) IBOutlet UILabel *southWestLabel;
@property (weak, nonatomic) IBOutlet UILabel *northWestLabel;

@property (weak, nonatomic) IBOutlet UILabel *windSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;

@property (weak, nonatomic) IBOutlet UILabel *visibilityLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (weak, nonatomic) IBOutlet UIImageView *innerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *outerImageView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *leftGradientView;
@property (weak, nonatomic) IBOutlet UIView *rightGradientView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray <PPWeather *> *hourlyForecast;
@property (strong, nonatomic) NSArray <PPWeather *> *weeklyForecast;

@property (strong, nonatomic) NSArray *angels;

@property (strong, nonatomic) NSArray <UILabel *> *directionLabels;

@property (strong, nonatomic) CABasicAnimation *animation;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *test;

@end


@implementation PPWindConditionItemView

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
    UINib *nib = [UINib nibWithNibName:@"PPWindConditionItemView"
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
    [self setupAnimation];
    UIColor *mainColor = MAIN_COLOR;
    UIColor *clearColor = [mainColor colorWithAlphaComponent:0.f];
    [self createGradientLayersForView:_leftGradientView
                           withColors:@[(id)mainColor.CGColor,
                                        (id)clearColor.CGColor]];
    [self createGradientLayersForView:_rightGradientView
                           withColors:@[(id)clearColor.CGColor,
                                        (id)mainColor.CGColor]];
    _angels = @[@0, @45, @90, @135, @180, @225, @270, @315];
    _directionLabels = @[_northLabel,
                         _northEastLabel,
                         _eastLabel,
                         _southEastLabel,
                         _southLabel,
                         _southWestLabel,
                         _westLabel,
                         _northWestLabel];
    [self setupCollectionView];
    [self setupTableView];
    [_northLabel setText:LOCALIZE(@"_n")];
    [_southLabel setText:LOCALIZE(@"_s")];
    [_westLabel setText:LOCALIZE(@"_w")];
    [_eastLabel setText:LOCALIZE(@"_e")];
    [_northEastLabel setText:LOCALIZE(@"_ne")];
    [_southEastLabel setText:LOCALIZE(@"_se")];
    [_southWestLabel setText:LOCALIZE(@"_sw")];
    [_northWestLabel setText:LOCALIZE(@"_nw")];
    [_windSpeedLabel setFont:[UIFont fontWithName:@"BN-Book"
                                             size:64.f]];
    [_unitsLabel setFont:[UIFont fontWithName:@"BN-Book"
                                         size:14.f]];
    [_windProctatorView setDirection:0.f
                            animated:YES
                          completion:nil];
    [self highlitghtDirectionLabelWithAngel:0.f];
    [self fadeInOutProctatorHidden:YES
                          animated:NO
                        completion:nil];
    [self fadeInOutVisibilityLabelHidden:YES
                                animated:NO];
    [_collectionView setHidden:YES];
    [PPUtils resizeLabelsInView:self.subviews.lastObject];
    [PPUtils resizeMarginsInView:self.subviews.lastObject];
}

- (void)setupCollectionView {
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    if (SYSTEM_VERSION_GRATER_THAN_OR_EQUAL_TO_IOS_10) {
        [_collectionView setPrefetchDataSource:self];
    }
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PPHourlyWindConditionCollectionViewCell class])
                                                bundle:nil]
      forCellWithReuseIdentifier:kHourlyWindConditionCollectionViewCellRI];
}

- (void)setupTableView {
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PPWindConditionTableViewCell class])
                                           bundle:nil]
     forCellReuseIdentifier:kWindConditionTableViewCellRI];
}

- (void)setLocation:(PPLocation *)location {
    _location = location;
    [_collectionView setContentOffset:CGPointZero
                             animated:NO];
    [_cityLabel setText:_location.name];
    [_location updateConditionWeatherDataWithCompletion:^(PPWeather *condition) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_visibilityLabel setText:[NSString stringWithFormat:@"%@ %1.0f %@", LOCALIZE(@"visibility"), condition.visibility_km, condition.localizedDistanceUnits]];
            [self fadeInOutVisibilityLabelHidden:NO
                                        animated:YES];
        });
    }];
    [_location updateHourlyForecstWeatherWithCompletion:^(NSArray <PPWeather *> *hourlyForecast) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_windSpeedLabel setText:[NSString stringWithFormat:@"%1.0f", hourlyForecast.firstObject.wind_kph]];
            [_unitsLabel setText:hourlyForecast.firstObject.localizedSpeedUnits];
            [self highlitghtDirectionLabelWithAngel:hourlyForecast.firstObject.wind_degrees];
            [_directionLabel setText:LOCALIZE(hourlyForecast.firstObject.wind_dir)];
            [_windProctatorView setDirection:hourlyForecast.firstObject.wind_degrees
                                    animated:YES
                                  completion:nil];
            CGFloat windSpeed = hourlyForecast.firstObject.wind_kph;
            CGFloat duration;
            if (windSpeed > kMaxWindSpeed) {
                duration = kMinRotateWindDuration;
            } else if (windSpeed <= 0.f) {
                duration = FLT_MAX;
            } else {
                CGFloat k = (kMaxRotateWindDuration - kMinRotateWindDuration) / (kMaxWindSpeed - kMinWindSpeed);
                duration = -k * windSpeed + kMaxRotateWindDuration;
            }
            if (_animation) {
                _animation.duration = duration;
            }
            [self playAnimation];
            [self fadeInOutProctatorHidden:NO
                                  animated:YES
                                completion:nil];
            // Data for collection view.
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
    PPHourlyWindConditionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHourlyWindConditionCollectionViewCellRI
                                                                                              forIndexPath:indexPath];
    if (_hourlyForecast.count > 0 &&
        indexPath.row <= _hourlyForecast.count - 1) {
        NSDate *date = [VPTime dateWithString:_hourlyForecast[indexPath.row].time
                                    andFormat:@"HH:mm"];
        VPTime *time = [[VPTime alloc] initWithDate:date
                                        andTimeZone:nil];
        VPTimeType currentTimeType = VPTimeType24Hours;
        VPTimeFormat currentTimeFormat = VPTimeHoursAndMinutesFormat;
        if (((PPSettingsModel *)[PPSettingsModel sharedModel]).groups[1].options[0].currentParameter == 1) {
            currentTimeType = VPTimeType12Hours;
            currentTimeFormat = VPTimeHoursFormat;
        }
        [time setTimeType:currentTimeType];
        [time setTimeFormat:currentTimeFormat];
        [cell setTime:time.text];
        [cell setSpeed:[NSString stringWithFormat:@"%1.0f", _hourlyForecast[indexPath.row].wind_kph]];
        [cell setDirection:_hourlyForecast[indexPath.row].wind_dir];
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
    PPWindConditionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWindConditionTableViewCellRI
                                                                         forIndexPath:indexPath];
    if (_weeklyForecast.count > 0 &&
        indexPath.row <= _weeklyForecast.count - 1) {
        PPWeather *weather = _weeklyForecast[indexPath.row];
        [cell setWeekday:weather.weekday];
        [cell setSpeed:weather.wind_kph];
        [cell setUnits:weather.localizedSpeedUnits];
        [cell setDirection:weather.wind_dir];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f * [PPUtils screenRate];
}

#pragma mark - Other methods

- (void)highlitghtDirectionLabelWithAngel:(NSInteger)angel {
    static NSUInteger index;
    if (angel >= 360) {
        angel = angel % 360;
    }
    [UIView animateWithDuration:.6f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (index != 0) {
                             _directionLabels[index].textColor = index % 2 == 0 ? RGB(166.f, 174.f, 166.f) : [UIColor whiteColor];
                         } else {
                             [_directionLabels[index] setTextColor:[UIColor whiteColor]];
                         }
                     }
                     completion:nil];
    for (NSUInteger i = 0; i <= _angels.count - 1; i++) {
        NSInteger currentAngel = [_angels[i] integerValue];
        if (currentAngel - kAlpha <= angel && currentAngel + kAlpha >= angel) {
            [UIView animateWithDuration:.6f
                                  delay:0.f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [_directionLabels[i] setTextColor:RGB(238.f, 184.f, 24.f)];
                             }
                             completion:nil];
            index = i;
        }
    }
}

- (void)setupAnimation {
    _animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    _animation.fromValue = @0;
    _animation.toValue = @(2 * M_PI);
    _animation.duration = 0.f;
    _animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    _animation.repeatCount = INFINITY;
}

- (void)playAnimation {
    [self stopAnimation];
    [_outerImageView.layer addAnimation:_animation
                                 forKey:kRotateAnimationKey];
}

- (void)stopAnimation {
    [_outerImageView.layer removeAnimationForKey:kRotateAnimationKey];
}

- (void)fadeInOutVisibilityLabelHidden:(BOOL)hidden
                              animated:(BOOL)animated {
    CGFloat alpha = hidden ? 0.f : 1.f;
    CGAffineTransform transform = hidden ? CGAffineTransformMakeTranslation(-32.f, 0.f) : CGAffineTransformIdentity;
    if (animated) {
        [UIView animateWithDuration:.6f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [_visibilityLabel setAlpha:alpha];
                             [_visibilityLabel setTransform:transform];
                         }
                         completion:nil];
    } else {
        [_visibilityLabel setAlpha:alpha];
        [_visibilityLabel setTransform:transform];
    }
}

- (void)fadeInOutProctatorHidden:(BOOL)hidden
                        animated:(BOOL)animated
                      completion:(void (^)())completion {
    CGFloat alpha = hidden ? 0.f : 1.f;
    CGAffineTransform proctatorScaleTransform = hidden ? CGAffineTransformMakeScale(.08f, .08f) : CGAffineTransformIdentity;
    CGAffineTransform proctatorRotateTransform = hidden ? CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90.f)) : CGAffineTransformIdentity;
    CGAffineTransform labelsScaleTransform = hidden ? CGAffineTransformMakeScale(.6f, .6f) : CGAffineTransformIdentity;
    CGAffineTransform directionalLabelTransform = hidden ? CGAffineTransformMakeTranslation(32.f, 0.f) : CGAffineTransformIdentity;
    NSArray <NSArray <UIView *> *> *views = @[@[_unitsLabel],
                                              @[_windSpeedLabel],
                                              @[_innerImageView,
                                                _outerImageView]];
    if (animated) {
        [UIView animateWithDuration:.6f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [_cityLabel setAlpha:alpha];
                             [_directionLabel setAlpha:alpha];
                             [_directionLabel setTransform:directionalLabelTransform];
                         }
                         completion:nil];
        [UIView animateWithDuration:1.4f
                              delay:0.f
             usingSpringWithDamping:.62f
              initialSpringVelocity:4.8f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_windProctatorView setAlpha:alpha];
                             [_windProctatorView setTransform:CGAffineTransformConcat(proctatorScaleTransform, proctatorRotateTransform)];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:.6f
                                                   delay:0.f
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  for (NSUInteger i = 0; i <= views.count - 1; i++) {
                                                      for (NSUInteger j = 0; j <= views[i].count - 1; j++) {
                                                          [UIView animateWithDuration:.6f
                                                                                delay:i * .2f
                                                                              options:UIViewAnimationOptionCurveEaseOut
                                                                           animations:^{
                                                                               [views[i][j] setAlpha:alpha];
                                                                           }
                                                                           completion:nil];
                                                      }
                                                  }
                                              }
                                              completion:nil];
                             for (NSUInteger i = 0; i <= _directionLabels.count - 1; i++) {
                                 [UIView animateWithDuration:.2f
                                                       delay:i * .12f
                                                     options:UIViewAnimationOptionCurveEaseOut
                                                  animations:^{
                                                      [_directionLabels[i] setAlpha:alpha];
                                                      [_directionLabels[i] setTransform:labelsScaleTransform];
                                                  }
                                                  completion:^(BOOL finished) {
                                                      if (i == _directionLabels.count - 1) {
                                                          if (completion) {
                                                              completion();
                                                          }
                                                      }
                                                  }];
                             }
                         }];
    } else {
        [_windProctatorView setAlpha:alpha];
        [_windProctatorView setTransform:CGAffineTransformConcat(proctatorScaleTransform, proctatorRotateTransform)];
        for (NSUInteger i = 0; i <= views.count - 1; i++) {
            for (NSUInteger j = 0; j <= views[i].count - 1; j++) {
                [views[i][j] setAlpha:alpha];
            }
        }
        [_directionLabel setAlpha:alpha];
        [_directionLabel setTransform:directionalLabelTransform];
        for (NSUInteger i = 0; i <= _directionLabels.count - 1; i++) {
            [_cityLabel setAlpha:alpha];
            [_directionLabels[i] setAlpha:alpha];
            [_directionLabels[i] setTransform:labelsScaleTransform];
        }
        if (completion) {
            completion();
        }
    }
}

@end
