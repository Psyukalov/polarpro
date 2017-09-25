//
//  PPKPinfoCollectionViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 29.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPKPinfoCollectionViewCell.h"

#import "Macros.h"
#import "UIView+PPCustomView.h"
#import "VPActivityIndicatorView.h"
#import "PPUtils.h"

#import "PPGeomagneticStormModel.h"


#define kRotateAnimationKey (@"rotate_animation")


@interface PPKPinfoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *outerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *innerImageView;

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet VPActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) CABasicAnimation *animation;

@property (strong, nonatomic) PPGeomagneticStormModel *stormModel;

@end


@implementation PPKPinfoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _stormModel = [PPGeomagneticStormModel sharedModel];
    [self setBackgroundColor:RGB(28.f, 30.f, 34.f)];
    [self applyCornerRadius:6.f];
    [_valueLabel setFont:[UIFont fontWithName:@"BN-Book"
                                         size:70.f]];
    [_unitsLabel setFont:[UIFont fontWithName:@"BN-Book"
                                         size:20.f]];
    [_unitsLabel setText:@"KP"];
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
    _animation.duration = kMaxRotateKPDuration;
    _animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    _animation.repeatCount = INFINITY;
}

- (void)updateCell {
    [self stopAnimation];
    if (_stormModel.isThreeDaysKP) {
        [self playAnimation];
        return;
    }
    [UIView animateWithDuration:.4f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self elementsWithAlpha:0.f];
                     }
                     completion:^(BOOL finished) {
                         [_activityIndicator start];
                         [_stormModel updateThreeDaysForecastWithCompletion:^(BOOL success, NSArray *dates, NSArray *values) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (!success) {
                                     return;
                                 }
                                 [_activityIndicator stopWithComlpetion:^{
                                     CGFloat summ = 0.f;
                                     for (NSUInteger i = 0; i <= kKPIndexesInOneDay - 1; i++) {
                                         summ += [values[i] floatValue];
                                     }
                                     CGFloat index = summ / kKPIndexesInOneDay;
                                     CGFloat duration;
                                     if (index > 9.f) {
                                         duration = kMinRotateKPDuration;
                                     } else if (index <= 0.f) {
                                         duration = FLT_MAX;
                                     } else {
                                         CGFloat k = (kMaxRotateKPDuration - kMinRotateKPDuration) / 9.f;
                                         duration = -k * index + kMaxRotateKPDuration;
                                     }
                                     if (_animation) {
                                         _animation.duration = duration;
                                     }
                                     [_valueLabel setText:[NSString stringWithFormat:@"%1.0f", index]];
                                     if (index <= 3.f) {
                                         [_descriptionLabel setText:LOCALIZE(@"low_risk")];
                                         [_descriptionLabel setTextColor:RGB(238.f, 184.f, 24.f)];
                                     } else if (index > 3.f && index <= 5.f) {
                                         [_descriptionLabel setText:LOCALIZE(@"medium_risk")];
                                         [_descriptionLabel setTextColor:RGB(238.f, 184.f, 24.f)];
                                     } else {
                                         [_descriptionLabel setText:LOCALIZE(@"high_risk")];
                                         [_descriptionLabel setTextColor:RGB(238.f, 24.f, 24.f)];
                                     }
                                     if (_outerImageView.alpha == 0.f) {
                                         [self showCellWithZoomInAnimation];
                                     } else {
                                         [self playAnimation];
                                     }
                                 }];
                             });
                         }];
                     }];
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
}

@end
