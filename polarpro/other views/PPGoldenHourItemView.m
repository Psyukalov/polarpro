//
//  PPGoldenHourItemView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 23.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPGoldenHourItemView.h"

#import "Macros.h"

#import "PPSunriseView.h"
#import "PPSunsetView.h"
#import "PPGoldenHourProgressView.h"
#import "PPUtils.h"


#define kConstantOffset (-44.f)


typedef NS_ENUM(NSUInteger, PPAstronomyViewType) {
    PPAstronomyViewTypeSunrise = 0,
    PPAstronomyViewTypeSunset,
    PPAstronomyViewTypeGoldenHour,
    PPAstronomyViewTypeNone
};


@interface PPGoldenHourItemView () <PPLocationDelegate>

@property (weak, nonatomic) IBOutlet PPSunriseView *sunriseView;
@property (weak, nonatomic) IBOutlet PPSunsetView *sunsetView;
@property (weak, nonatomic) IBOutlet PPGoldenHourProgressView *goldenHourProgressView;

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIView *alertView;

@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *secundsLabel;

@property (weak, nonatomic) IBOutlet UILabel *goldenHourDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextGoldenHourDurationLabel;

@property (weak, nonatomic) IBOutlet UILabel *goldentHourMinuteLabel;

@property (weak, nonatomic) IBOutlet UILabel *startGoldenHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextStartGoldenHourLabel;

@property (weak, nonatomic) IBOutlet UILabel *finishGoldenHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextFinishGoldenHourLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentStartGoldenHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentFinishGoldenHourLabel;

@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextStartLabel;

@property (weak, nonatomic) IBOutlet UILabel *finishLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextFinishLabel;

@property (weak, nonatomic) IBOutlet UILabel *nextDurationLabel;

@property (weak, nonatomic) IBOutlet UIImageView *descriptionImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@property (weak, nonatomic) IBOutlet UIView *containerGHDuration;
@property (weak, nonatomic) IBOutlet UIView *containerNextGHDuration;

@property (weak, nonatomic) IBOutlet UIView *containerGHStart;
@property (weak, nonatomic) IBOutlet UIView *containerGHFinish;

@property (weak, nonatomic) IBOutlet UIView *containerNextGHStart;
@property (weak, nonatomic) IBOutlet UIView *containerNextGHFinish;



@property (strong, nonatomic) PPAstronomy *astronomy;

@property (assign, nonatomic) PPAstronomyViewType currentAstronomyViewType;

@property (strong, nonatomic) NSArray <NSArray <UIView *> *> *views;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstant;

@end


@implementation PPGoldenHourItemView

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
    UINib *nib = [UINib nibWithNibName:@"PPGoldenHourItemView"
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
    _views = @[@[_sunriseView,
                 _sunsetView,
                 _goldenHourProgressView],
               @[_cityLabel],
               @[_timeView],
               @[_startLabel,
                 _startGoldenHourLabel,
                 _goldenHourDurationLabel,
                 _goldentHourMinuteLabel,
                 _finishLabel,
                 _finishGoldenHourLabel,
                 _currentStartGoldenHourLabel,
                 _currentTimeLabel,
                 _currentFinishGoldenHourLabel,
                 _alertLabel],
               @[_lineView],
               @[_descriptionImageView,
                 _descriptionLabel],
               @[_nextStartLabel,
                 _nextStartGoldenHourLabel,
                 _nextDurationLabel,
                 _nextGoldenHourDurationLabel,
                 _nextFinishLabel,
                 _nextFinishGoldenHourLabel]];
    [self fadeInOutWindConditionHidden:YES
                              animated:NO];
    _currentAstronomyViewType = PPAstronomyViewTypeNone;
    [_timeLabel setFont:[UIFont fontWithName:@"BN-Book"
                                        size:100.f]];
    [_secundsLabel setFont:[UIFont fontWithName:@"BN-Light"
                                           size:100.f]];
    [_sunriseView setHidden:YES];
    [_sunriseView setType:PPSunriseViewLargeType];
    [_sunriseView setDirection:180.f];
    [_sunriseView setAngle:-22.f];
    [_sunsetView setHidden:YES];
    [_sunsetView setType:PPSunsetViewLargeType];
    [_sunsetView setDirection:0.f];
    [_sunsetView setAngle:6.f];
    [_goldenHourProgressView setType:1];
    [_alertView setBackgroundColor:MAIN_COLOR];
    [_alertView setHidden:YES];
    [self localize];
    NSArray <UIView *> *labelsContainerViews = @[_timeView,
                                                 _containerGHDuration,
                                                 _containerNextGHDuration,
                                                 _containerGHStart,
                                                 _containerGHFinish,
                                                 _containerNextGHStart,
                                                 _containerNextGHFinish];
    for (UIView *view in labelsContainerViews) {
        [PPUtils resizeLabelsInView:view];
    }
    [PPUtils resizeLabelsInView:self.subviews.lastObject];
    [PPUtils resizeMarginsInView:self.subviews.lastObject];
}

- (void)localize {
    [_startLabel setText:LOCALIZE(@"start")];
    [_nextStartLabel setText:LOCALIZE(@"start")];
    [_finishLabel setText:LOCALIZE(@"finish")];
    [_nextFinishLabel setText:LOCALIZE(@"finish")];
    [_nextDurationLabel setText:LOCALIZE(@"duration")];
    [_alertLabel setText:LOCALIZE(@"polar_day_or_night_more")];
}

- (void)setLocation:(PPLocation *)location {
    [_location setDelegate:nil];
    [self fadeInOutWindConditionHidden:YES
                              animated:NO];
    if (_location != location || !location.astronomy) {
        _location = location;
        [_cityLabel setText:_location.name];
        [_location updateAstronomyWithCompletion:^(PPAstronomy *astronomy) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_location setDelegate:self];
                [self locationDidUpdateCurrentTime:_location];
                [self fadeInOutWindConditionHidden:NO
                                          animated:YES];
            });
        }];
    } else {
        [_location setDelegate:self];
        [self locationDidUpdateCurrentTime:_location];
    }
}

- (void)locationDidUpdateCurrentTime:(PPLocation *)location {
    if (location != _location) {
        return;
    }
    _astronomy = location.astronomy;
    if (!_astronomy) {
        return;
    }
    if (_astronomy.isPolarDayOrNight) {
        [_alertView setHidden:NO];
        [_goldenHourProgressView setAngle:0.f];
        [self updateUIWithAstronomyViewType:PPAstronomyViewTypeGoldenHour
                               withInterval:0
                       withDurationInterval:0
                   withNextDurationInterval:0
                              withStartTime:[[VPTime alloc] initWithInterval:0]
                             withFinishTime:[[VPTime alloc] initWithInterval:0]
                             witCurrentTime:[[VPTime alloc] initWithInterval:0]
                           withNextStatTime:[[VPTime alloc] initWithInterval:0]
                         withNextFinishTime:[[VPTime alloc] initWithInterval:0]
                         andCompletePercent:1.f];
        return;
    } else {
        [_alertView setHidden:YES];
    }
    
    if ([_astronomy.currentTime betweenfirstTime:_astronomy.sunrise
                                   andSecondTime:_astronomy.goldenHour]) {
        _astronomy.intervalToGoldenHour = [_astronomy.currentTime intervalFromTime:_astronomy.goldenHour];
        
        _astronomy.nearestGoldenHour = _astronomy.goldenHour;
        _astronomy.nearestGoldenHourEnd = _astronomy.sunset;
    } else {
        NSUInteger day = 0;
        if ([_astronomy.currentTime laterTime:_astronomy.sunrise]) {
            day = 24 * 3600;
        }
        NSInteger interval = day - [_astronomy.currentTime intervalFromTime:_astronomy.sunrise];
        _astronomy.intervalToGoldenHour = ABS(interval);
        
        _astronomy.nearestGoldenHour = _astronomy.sunrise;
        _astronomy.nearestGoldenHourEnd = _astronomy.goldenHourEnd;
    }
    
    if ([_astronomy.currentTime betweenfirstTime:_astronomy.sunrise
                                   andSecondTime:_astronomy.goldenHourEnd]) {
        NSUInteger interval = [_astronomy.currentTime intervalFromTime:_astronomy.goldenHourEnd];
        CGFloat percent = [_astronomy.currentTime completePercentFromTime:_astronomy.sunrise
                                                                   toTime:_astronomy.sunriseEnd];//goldenHourEnd];
        [self updateUIWithAstronomyViewType:PPAstronomyViewTypeGoldenHour
                               withInterval:interval
                       withDurationInterval:[_astronomy.sunrise intervalFromTime:_astronomy.goldenHourEnd]
                   withNextDurationInterval:[_astronomy.goldenHour intervalFromTime:_astronomy.sunset]
                              withStartTime:_astronomy.sunrise
                             withFinishTime:_astronomy.goldenHourEnd
                             witCurrentTime:_astronomy.currentTime
                           withNextStatTime:_astronomy.goldenHour
                         withNextFinishTime:_astronomy.sunset
                         andCompletePercent:percent];
    }
    if ([_astronomy.currentTime betweenfirstTime:_astronomy.goldenHourEnd
                                   andSecondTime:_astronomy.goldenHour]) {
        NSUInteger interval = [_astronomy.currentTime intervalFromTime:_astronomy.goldenHour];
        CGFloat percent = [_astronomy.currentTime completePercentFromTime:_astronomy.sunrise
                                                                   toTime:_astronomy.sunset];
        [self updateUIWithAstronomyViewType:PPAstronomyViewTypeSunset
                               withInterval:interval
                       withDurationInterval:[_astronomy.goldenHour intervalFromTime:_astronomy.sunset]
                   withNextDurationInterval:[_astronomy.sunrise intervalFromTime:_astronomy.goldenHourEnd]
                              withStartTime:_astronomy.goldenHour
                             withFinishTime:_astronomy.sunset
                             witCurrentTime:_astronomy.currentTime
                           withNextStatTime:_astronomy.sunrise
                         withNextFinishTime:_astronomy.goldenHourEnd
                         andCompletePercent:percent];
    }
    if ([_astronomy.currentTime betweenfirstTime:_astronomy.goldenHour
                                   andSecondTime:_astronomy.sunset]) {
        NSUInteger interval = [_astronomy.currentTime intervalFromTime:_astronomy.sunset];
        CGFloat percent = 1.f - [_astronomy.currentTime completePercentFromTime:_astronomy.sunsetStart//goldenHour];
                                                                         toTime:_astronomy.sunset];
        [self updateUIWithAstronomyViewType:PPAstronomyViewTypeGoldenHour
                               withInterval:interval
                       withDurationInterval:[_astronomy.goldenHour intervalFromTime:_astronomy.sunset]
                   withNextDurationInterval:[_astronomy.sunrise intervalFromTime:_astronomy.goldenHourEnd]
                              withStartTime:_astronomy.goldenHour
                             withFinishTime:_astronomy.sunset
                             witCurrentTime:_astronomy.currentTime
                           withNextStatTime:_astronomy.sunrise
                         withNextFinishTime:_astronomy.goldenHourEnd
                         andCompletePercent:percent];
    }
    if (![_astronomy.currentTime betweenfirstTime:_astronomy.sunrise
                                    andSecondTime:_astronomy.sunset]) {
        NSUInteger day = 0;
        if ([_astronomy.currentTime laterTime:_astronomy.sunrise]) {
            day = 24 * 3600;
        }
        if ([_astronomy.currentTime earlierTime:_astronomy.sunrise]) {
            day = 0;
        }
        NSInteger interval = day - [_astronomy.currentTime intervalFromTime:_astronomy.sunrise];
        NSInteger allInterval = day - [_astronomy.sunset intervalFromTime:_astronomy.sunrise];
        CGFloat percent = 1.f - (CGFloat)ABS(interval) / (CGFloat)ABS(allInterval);
        [self updateUIWithAstronomyViewType:PPAstronomyViewTypeSunrise
                               withInterval:ABS(interval)
                       withDurationInterval:[_astronomy.sunrise intervalFromTime:_astronomy.goldenHourEnd]
                   withNextDurationInterval:[_astronomy.goldenHour intervalFromTime:_astronomy.sunset]
                              withStartTime:_astronomy.sunrise
                             withFinishTime:_astronomy.goldenHourEnd
                             witCurrentTime:_astronomy.currentTime
                           withNextStatTime:_astronomy.goldenHour
                         withNextFinishTime:_astronomy.sunset
                         andCompletePercent:percent];
    }
    
    [_sunriseView setAngle:ABS(_astronomy.sunPosition.degrees)];
    [_sunsetView setAngle:ABS(_astronomy.sunPosition.degrees)];
    [_goldenHourProgressView setAngle:ABS(_astronomy.sunPosition.degrees)];
}

- (void)locationDidStopTimer:(PPLocation *)location {
    if (_location) {
        [self setLocation:_location];
    }
}

- (void)switchViewsWithAstronomyViewType:(PPAstronomyViewType)astronomyViewType {
    if (_currentAstronomyViewType == astronomyViewType) {
        return;
    }
    _currentAstronomyViewType = astronomyViewType;
    NSArray *views = @[_sunriseView,
                       _sunsetView,
                       _goldenHourProgressView];
    for (NSUInteger i = 0; i <= views.count - 1; i++) {
        [views[i] setHidden:!(i == astronomyViewType)];
    }
    [self switchUIAsGoldenHour:(_currentAstronomyViewType == PPAstronomyViewTypeGoldenHour)];
}

- (void)updateUIWithAstronomyViewType:(PPAstronomyViewType)astronomyViewType
                         withInterval:(NSUInteger)interval
                 withDurationInterval:(NSUInteger)durationInterval
             withNextDurationInterval:(NSUInteger)nextDurationInterval
                        withStartTime:(VPTime *)startTime
                       withFinishTime:(VPTime *)finishTime
                       witCurrentTime:(VPTime *)currentTime
                     withNextStatTime:(VPTime *)nextStartTime
                   withNextFinishTime:(VPTime *)nextFinishTime
                   andCompletePercent:(CGFloat)completePercent {
    
    [self switchViewsWithAstronomyViewType:astronomyViewType];
    
    [_sunriseView setPercent:completePercent];
    [_sunsetView setPercent:completePercent];
    [_goldenHourProgressView setPercent:completePercent];
    
    VPTime *time = [[VPTime alloc] initWithInterval:interval];
    if (astronomyViewType == PPAstronomyViewTypeGoldenHour) {
        [_timeLabel setTextColor:RGB(255.f, 202.f, 42.f)];
        [_timeLabel setText:[NSString stringWithFormat:@"%02ld:%02ld", (unsigned long)time.minutes, (unsigned long)time.seconds]];
        [_secundsLabel setText:nil];
    } else {
        [_timeLabel setTextColor:[UIColor whiteColor]];
        [_timeLabel setText:[NSString stringWithFormat:@"%02ld:%02ld", (unsigned long)time.hours, (unsigned long)time.minutes]];
        [_secundsLabel setText:[NSString stringWithFormat:@":%02ld", (unsigned long)time.seconds]];
    }
    
    [_goldenHourDurationLabel setText:[NSString stringWithFormat:@"%ld", (unsigned long)durationInterval / 60]];
    [_nextGoldenHourDurationLabel setText:[NSString stringWithFormat:@"%ld %@", (unsigned long)nextDurationInterval / 60, LOCALIZE(@"min")]];
    
    [_startGoldenHourLabel setText:startTime.text];
    [_currentStartGoldenHourLabel setText:startTime.text];
    [_nextStartGoldenHourLabel setText:nextStartTime.text];
    
    [_finishGoldenHourLabel setText:finishTime.text];
    [_currentFinishGoldenHourLabel setText:finishTime.text];
    [_nextFinishGoldenHourLabel setText:nextFinishTime.text];
    
    [_currentTimeLabel setText:currentTime.text];
    
    NSString *imageName;
    NSString *description;
    if ([_astronomy.currentTime betweenfirstTime:_astronomy.sunrise
                                   andSecondTime:_astronomy.sunset]) {
        imageName = @"sunrise_i.png";
        description = LOCALIZE(@"next_sunrise");
    } else {
        imageName = @"sunset_i.png";
        description = LOCALIZE(@"next_sunset");
    }
    
    [_descriptionImageView setImage:[UIImage imageNamed:imageName]];
    [_descriptionLabel setText:description];
    
}

- (void)switchUIAsGoldenHour:(BOOL)asGoldenHour {
    _layoutConstant.constant = !asGoldenHour ? kConstantOffset : 0.f;
    [_startGoldenHourLabel setHidden:asGoldenHour];
    [_finishGoldenHourLabel setHidden:asGoldenHour];
    [_startLabel setHidden:asGoldenHour];
    [_finishLabel setHidden:asGoldenHour];
    [_currentStartGoldenHourLabel setHidden:!asGoldenHour];
    [_currentTimeLabel setHidden:!asGoldenHour];
    [_currentFinishGoldenHourLabel setHidden:!asGoldenHour];
}

- (void)fadeInOutWindConditionHidden:(BOOL)hidden
                            animated:(BOOL)animated {
    CGFloat alpha = hidden ? 0.f : 1.f;
    CGAffineTransform scaleTransform = hidden ? CGAffineTransformMakeScale(.8f, .8f) : CGAffineTransformIdentity;
    if (animated) {
        for (NSUInteger i = 0; i <= _views.count - 1; i++) {
            for (NSUInteger j = 0; j <= _views[i].count - 1; j++) {
                [UIView animateWithDuration:.6f
                                      delay:i * .16f
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
