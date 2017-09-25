//
//  PPWindCollectionViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 29.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPWindCollectionViewCell.h"

#import "Macros.h"
#import "UIView+PPCustomView.h"
#import "VPActivityIndicatorView.h"
#import "PPUtils.h"


#define kRotateAnimationKey (@"rotate_animation")


@interface PPWindCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *outerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *innerImageView;

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet VPActivityIndicatorView *activityIndicator;

@property (assign, nonatomic) CGFloat windSpeed;

@property (strong, nonatomic) CABasicAnimation *animation;

@property (strong, nonatomic) PPLocationsModel *locationsModel;

@end


@implementation PPWindCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _locationsModel = [PPLocationsModel sharedModel];
    [self setBackgroundColor:RGB(28.f, 30.f, 34.f)];
    [self applyCornerRadius:6.f];
    [_valueLabel setFont:[UIFont fontWithName:@"BN-Book"
                                         size:70.f]];
    [_unitsLabel setFont:[UIFont fontWithName:@"BN-Book"
                                         size:20.f]];
    [self elementsWithAlpha:0.f];
    [self setupAnimation];
    [PPUtils resizeLabelsInView:self.contentView];
    [PPUtils resizeMarginsInView:self.contentView];
}

- (void)elementsWithAlpha:(CGFloat)alpha {
    [_outerImageView setAlpha:alpha];
    [_innerImageView setAlpha:alpha];
    [_valueLabel setAlpha:alpha];
    [_unitsLabel setAlpha:alpha];
    [_descriptionLabel setAlpha:alpha];
}

- (void)setupAnimation {
    _animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    _animation.fromValue = @0;
    _animation.toValue = @(2 * M_PI);
    _animation.duration = 0.f;
    _animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    _animation.repeatCount = INFINITY;
}

- (void)setLocation:(PPLocation *)location {
    [self stopAnimation];
    if (_location != location || !location.hourlyForecast) {
        _location = location;
        [UIView animateWithDuration:.4f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self elementsWithAlpha:0.f];
                         }
                         completion:^(BOOL finished) {
                             [_activityIndicator start];
                             [location updateHourlyForecstWeatherWithCompletion:^(NSArray <PPWeather *> *hourlyForecast) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (!hourlyForecast) {
                                         return;
                                     }
                                     [_activityIndicator stopWithComlpetion:^{
                                         _windSpeed = hourlyForecast.firstObject.wind_kph;
                                         CGFloat duration;
                                         if (_windSpeed > kMaxWindSpeed) {
                                             duration = kMinRotateWindDuration;
                                         } else if (_windSpeed <= 0.f) {
                                             duration = FLT_MAX;
                                         } else {
                                             CGFloat k = (kMaxRotateWindDuration - kMinRotateWindDuration) / (kMaxWindSpeed - kMinWindSpeed);
                                             duration = -k * _windSpeed + kMaxRotateWindDuration;
                                         }
                                         if (_animation) {
                                             _animation.duration = duration;
                                         }
                                         [_valueLabel setText:[NSString stringWithFormat:@"%1.0f", hourlyForecast.firstObject.wind_kph]];
                                         [_unitsLabel setText:hourlyForecast.firstObject.localizedSpeedUnits];
                                         [_descriptionLabel setText:LOCALIZE(hourlyForecast.firstObject.wind_dir)];
                                         if (_outerImageView.alpha == 0.f) {
                                             [self showCellWithZoomInAnimation];
                                         } else {
                                             [self playAnimation];
                                         }
                                     }];
                                 });
                             }];
                         }];
    } else {
        [self playAnimation];
        [_valueLabel setText:[NSString stringWithFormat:@"%1.0f", _location.hourlyForecast.firstObject.wind_kph]];
        [_unitsLabel setText:_location.hourlyForecast.firstObject.localizedSpeedUnits];
    }
}

- (void)showCellWithZoomInAnimation {
    CGAffineTransform transform = CGAffineTransformMakeScale(.86f, .86f);
    [_outerImageView setTransform:transform];
    [_innerImageView setTransform:transform];
    [_valueLabel setTransform:transform];
    [_unitsLabel setTransform:transform];
    [_descriptionLabel setTransform:transform];
    [UIView animateWithDuration:.6f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self elementsWithAlpha:1.f];
                         [_outerImageView setTransform:CGAffineTransformIdentity];
                         [_innerImageView setTransform:CGAffineTransformIdentity];
                         [_valueLabel setTransform:CGAffineTransformIdentity];
                         [_unitsLabel setTransform:CGAffineTransformIdentity];
                         [_descriptionLabel setTransform:CGAffineTransformIdentity];
                     }
                     completion:^(BOOL finished) {
                         [self playAnimation];
                     }];
}

- (void)playAnimation {
    [self stopAnimation];
    [_outerImageView.layer addAnimation:_animation
                                 forKey:kRotateAnimationKey];
}

- (void)stopAnimation {
    [_outerImageView.layer removeAnimationForKey:kRotateAnimationKey];
    [_outerImageView.layer setValue:@(2 * M_PI)
                             forKey:@"transform.rotation.z"];
}

@end
