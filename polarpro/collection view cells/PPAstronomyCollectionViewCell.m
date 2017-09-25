//
//  PPAstronomyCollectionViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 22.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPAstronomyCollectionViewCell.h"

#import "Macros.h"
#import "UIView+PPCustomView.h"
#import "PPSunriseView.h"
#import "PPSunsetView.h"
#import "PPGoldenHourProgressView.h"
#import "VPActivityIndicatorView.h"
#import "PPUtils.h"


#define kConstantX (-10.f)
#define kConstantY (40.f)


typedef NS_ENUM(NSUInteger, PPAstronomyViewType) {
    PPAstronomyViewTypeSunrise = 0,
    PPAstronomyViewTypeSunset,
    PPAstronomyViewTypeGoldenHour,
    PPAstronomyViewTypeNone
};


@interface PPAstronomyCollectionViewCell () <PPLocationDelegate>

@property (weak, nonatomic) IBOutlet PPSunriseView *sunriseView;
@property (weak, nonatomic) IBOutlet PPSunsetView *sunsetView;
@property (weak, nonatomic) IBOutlet PPGoldenHourProgressView *goldenHourProgressView;


@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *secundsLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet VPActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) PPLocationsModel *locationsModel;

@property (assign, nonatomic) NSUInteger interval;

@property (strong, nonatomic) PPAstronomy *astronomy;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintY;

@end


@implementation PPAstronomyCollectionViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    _locationsModel = [PPLocationsModel sharedModel];
    [_sunriseView setType:PPSunriseViewSmallType];
    [_sunsetView setType:PPSunsetViewSmallType];
    [_goldenHourProgressView setType:0];
    [_sunriseView setHidden:YES];
    [_sunsetView setHidden:YES];
    [_goldenHourProgressView setHidden:YES];
    [self setBackgroundColor:RGB(28.f, 30.f, 34.f)];
    [self applyCornerRadius:6.f];
    [_timeLabel setFont:[UIFont fontWithName:@"BN-Book"
                                        size:70.f]];
    [_secundsLabel setFont:[UIFont fontWithName:@"BN-Light"
                                           size:26.f]];
    [self elementsWithAlpha:0.f];
    [PPUtils resizeLabelsInView:self.contentView];
    [PPUtils resizeMarginsInView:self.contentView];
}

- (void)setLocation:(PPLocation *)location {
    [_location setDelegate:nil];
    if (_location != location || !location.astronomy) {
        _location = location;
        [UIView animateWithDuration:.4f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self elementsWithAlpha:0.f];
                         }
                         completion:^(BOOL finished) {
                             [_activityIndicator start];
                             _interval = 0;
                             [location updateAstronomyWithCompletion:^(PPAstronomy *astronomy) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [_activityIndicator stopWithComlpetion:^{
                                         [_location setDelegate:self];
                                         [self locationDidUpdateCurrentTime:location];
                                         [self showCellWithZoomInAnimation];
                                     }];
                                 });
                             }];
                         }];
    } else {
        [_location setDelegate:self];
        [self locationDidUpdateCurrentTime:_location];
    }
}

- (void)elementsWithAlpha:(CGFloat)alpha {
    [_sunriseView setAlpha:alpha];
    [_sunsetView setAlpha:alpha];
    [_goldenHourProgressView setAlpha:alpha];
    [_timeLabel setAlpha:alpha];
    [_secundsLabel setAlpha:alpha];
    [_descriptionLabel setAlpha:alpha];
}

- (void)showCellWithZoomInAnimation {
    CGAffineTransform transform = CGAffineTransformMakeScale(.86f, .86f);
    [_timeLabel setTransform:transform];
    [_secundsLabel setTransform:transform];
    [_descriptionLabel setTransform:transform];
    [UIView animateWithDuration:.6f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self elementsWithAlpha:1.f];
                         [_timeLabel setTransform:CGAffineTransformIdentity];
                         [_secundsLabel setTransform:CGAffineTransformIdentity];
                         [_descriptionLabel setTransform:CGAffineTransformIdentity];
                     }
                     completion:nil];
}

- (void)locationDidUpdateCurrentTime:(PPLocation *)location {
    if (location != _locationsModel.locations.firstObject) {
        return;
    }
    _astronomy = location.astronomy;
    if (!_astronomy) {
        return;
    }
    if (_astronomy.isPolarDayOrNight) {
        [_timeLabel setHidden:YES];
        [_layoutConstraintY setConstant:kConstantY];
        [self updateUIWithAstronomyView:PPAstronomyViewTypeGoldenHour
                           withInterval:0
                            withPercent:1.f
                         andDescription:LOCALIZE(@"polar_day_or_night")];
        return;
    } else {
        [_timeLabel setHidden:NO];
        [_layoutConstraintY setConstant:20.f];
    }
    if ([_astronomy.currentTime betweenfirstTime:_astronomy.sunrise
                                   andSecondTime:_astronomy.goldenHourEnd]) {
        NSUInteger duration = [_astronomy.sunrise intervalFromTime:_astronomy.goldenHourEnd] / 60;
        NSUInteger interval = [_astronomy.currentTime intervalFromTime:_astronomy.goldenHourEnd];
        CGFloat percent = [_astronomy.currentTime completePercentFromTime:_astronomy.sunrise
                                                                   toTime:_astronomy.sunriseEnd];//goldenHourEnd];
        [self updateUIWithAstronomyView:PPAstronomyViewTypeGoldenHour
                           withInterval:interval
                            withPercent:percent
                         andDescription:[NSString stringWithFormat:@"%@ %ld %@", LOCALIZE(@"duration"), (unsigned long)duration, LOCALIZE(@"min")]];
    }
    if ([_astronomy.currentTime betweenfirstTime:_astronomy.goldenHourEnd
                                   andSecondTime:_astronomy.goldenHour]) {
        NSString *description = [NSString stringWithFormat:@"%@ - %@", _astronomy.goldenHour.text, _astronomy.sunset.text];
        NSUInteger interval = [_astronomy.currentTime intervalFromTime:_astronomy.goldenHour];
        CGFloat percent = [_astronomy.currentTime completePercentFromTime:_astronomy.sunrise
                                                                   toTime:_astronomy.sunset];
        [self updateUIWithAstronomyView:PPAstronomyViewTypeSunset
                           withInterval:interval
                            withPercent:percent
                         andDescription:description];
    }
    if ([_astronomy.currentTime betweenfirstTime:_astronomy.goldenHour
                                   andSecondTime:_astronomy.sunset]) {
        NSUInteger duration = [_astronomy.goldenHour intervalFromTime:_astronomy.sunset] / 60;
        NSUInteger interval = [_astronomy.currentTime intervalFromTime:_astronomy.sunset];
        CGFloat percent = 1.f - [_astronomy.currentTime completePercentFromTime:_astronomy.sunsetStart//goldenHour];
                                                                         toTime:_astronomy.sunset];
        [self updateUIWithAstronomyView:PPAstronomyViewTypeGoldenHour
                           withInterval:interval
                            withPercent:percent
                         andDescription:[NSString stringWithFormat:@"%@ %ld %@", LOCALIZE(@"duration"), (unsigned long)duration, LOCALIZE(@"min")]];
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
        NSString *description = [NSString stringWithFormat:@"%@ - %@", _astronomy.sunrise.text, _astronomy.goldenHourEnd.text];
        NSInteger interval = day - [_astronomy.currentTime intervalFromTime:_astronomy.sunrise];
        NSInteger allInterval = day - [_astronomy.sunset intervalFromTime:_astronomy.sunrise];
        CGFloat percent = 1.f - (CGFloat)ABS(interval) / (CGFloat)ABS(allInterval);
        [self updateUIWithAstronomyView:PPAstronomyViewTypeSunrise
                           withInterval:ABS(interval)
                            withPercent:percent
                         andDescription:description];
    }
}

- (void)locationDidStopTimer:(PPLocation *)location {
    [self setLocation:_location];
}

- (void)switchViewsWithAstronomyViewType:(PPAstronomyViewType)astronomyViewType {
    NSArray *views = @[_sunriseView,
                       _sunsetView,
                       _goldenHourProgressView];
    for (NSUInteger i = 0; i <= views.count - 1; i++) {
        [views[i] setHidden:!(i == astronomyViewType)];
    }
    if (astronomyViewType == PPAstronomyViewTypeGoldenHour) {
        [_secundsLabel setHidden:YES];
        [_layoutConstraintX setConstant:0.f];
    } else {
        [_secundsLabel setHidden:NO];
        [_layoutConstraintX setConstant:kConstantX];
    }
}

- (void)updateUIWithAstronomyView:(PPAstronomyViewType)astronomyViewType
                     withInterval:(NSUInteger)interval
                      withPercent:(CGFloat)percent
                   andDescription:(NSString *)description {
    [self switchViewsWithAstronomyViewType:astronomyViewType];
    [_sunriseView setPercent:percent];
    [_sunsetView setPercent:percent];
    [_goldenHourProgressView setPercent:percent];
    VPTime *time = [[VPTime alloc] initWithInterval:interval];
    if (astronomyViewType == PPAstronomyViewTypeGoldenHour) {
        [_timeLabel setTextColor:RGB(255.f, 202.f, 42.f)];
        [_timeLabel setText:[NSString stringWithFormat:@"%02ld:%02ld", (unsigned long)time.minutes, (unsigned long)time.seconds]];
    } else {
        [_timeLabel setTextColor:[UIColor whiteColor]];
        [_timeLabel setText:[NSString stringWithFormat:@"%02ld:%02ld", (unsigned long)time.hours, (unsigned long)time.minutes]];
        [_secundsLabel setText:[NSString stringWithFormat:@":%02ld", (unsigned long)time.seconds]];
    }
    [_descriptionLabel setText:description];
    
}

@end
