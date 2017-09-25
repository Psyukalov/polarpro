//
//  PPWeatherCollectionViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 20.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPWeatherCollectionViewCell.h"

#import "Macros.h"
#import "UIView+PPCustomView.h"
#import "VPActivityIndicatorView.h"
#import "PPUtils.h"


@interface PPWeatherCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;


@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

/*
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
 */
 
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

/*
@property (weak, nonatomic) IBOutlet UIImageView *dropImageView;
 */

@property (weak, nonatomic) IBOutlet VPActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) PPLocationsModel *locationsModel;

@end


@implementation PPWeatherCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _locationsModel = [PPLocationsModel sharedModel];
    [self setBackgroundColor:RGB(28.f, 30.f, 34.f)];
    [self applyCornerRadius:6.f];
    [_temperatureLabel setFont:[UIFont fontWithName:@"BN-Book"
                                               size:70.f]];
    
    /*
    [_humidityLabel setFont:[UIFont fontWithName:@"BN-Light"
                                            size:26.f]];
    [_percentLabel setFont:[UIFont fontWithName:@"BN-Book"
                                           size:14.f]];
     */
    
    [self elementsWithAlpha:0.f];
    [PPUtils resizeLabelsInView:self.contentView];
    [PPUtils resizeMarginsInView:self.contentView];
}

- (void)setLocation:(PPLocation *)location {
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
                             [_cityLabel setText:location.name];
                             [location updateHourlyForecstWeatherWithCompletion:^(NSArray <PPWeather *> *hourlyForecast) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (!hourlyForecast) {
                                         return;
                                     }
                                     [_activityIndicator stopWithComlpetion:^{
                                         [_temperatureLabel setText:[NSString stringWithFormat:@"%1.0f%@", hourlyForecast.firstObject.temp, kDegreeCharacter]];
                                         
                                         /*
                                         [_humidityLabel setText:[NSString stringWithFormat:@"%1.0f", hourlyForecast.firstObject.humidity]];
                                          */
                                         
                                         [_iconImageView setImage:[[UIImage imageNamed:[NSString stringWithFormat:@"%@_i.png", hourlyForecast.firstObject.icon]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                                         [_iconImageView setTintColor:RGB(86.f, 130.f, 142.f)];
                                         [self showCellWithZoomInAnimation];
                                     }];
                                 });
                             }];
                         }];
    } else {
        [_temperatureLabel setText:[NSString stringWithFormat:@"%1.0f%@", _location.hourlyForecast.firstObject.temp, kDegreeCharacter]];
    }
}

- (void)elementsWithAlpha:(CGFloat)alpha {
    [_temperatureLabel setAlpha:alpha];
    
    /*
    [_humidityLabel setAlpha:alpha];
    [_percentLabel setAlpha:alpha];
     */
    
    [_cityLabel setAlpha:alpha];
    [_iconImageView setAlpha:alpha];
    
    /*
    [_dropImageView setAlpha:alpha];
     */
     
}

- (void)showCellWithZoomInAnimation {
    CGAffineTransform transform = CGAffineTransformMakeScale(.86f, .86f);
    [_temperatureLabel setTransform:transform];
    
    /*
    [_humidityLabel setTransform:transform];
    [_percentLabel setTransform:transform];
     */
    
    [_cityLabel setTransform:transform];
    [_iconImageView setTransform:transform];
    
    /*
    [_dropImageView setTransform:transform];
     */
    
    [UIView animateWithDuration:.6f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self elementsWithAlpha:1.f];
                         [_temperatureLabel setTransform:CGAffineTransformIdentity];
                         
                         /*
                         [_humidityLabel setTransform:CGAffineTransformIdentity];
                         [_percentLabel setTransform:CGAffineTransformIdentity];
                          */
                          
                         [_cityLabel setTransform:CGAffineTransformIdentity];
                         [_iconImageView setTransform:CGAffineTransformIdentity];
                         
                         /*
                         [_dropImageView setTransform:CGAffineTransformIdentity];
                          */
                         
                     }
                     completion:nil];
}

@end
