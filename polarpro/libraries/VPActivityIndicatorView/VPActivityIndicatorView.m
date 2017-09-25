//
//  VPActivityIndicatorView.m
//
//  Created by Vladimir Psyukalov on 26.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "VPActivityIndicatorView.h"


#import "Macros.h"


#define KAnimationKey (@"activity_indicator_view_rotate_animation")


@interface VPActivityIndicatorView ()

@property (strong, nonatomic) CABasicAnimation *animation;

@property (assign, nonatomic) BOOL isAnimating;

@end


@implementation VPActivityIndicatorView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setAlpha:0.f];
    [self setTransform:CGAffineTransformMakeScale(.8f, .8f)];
    _animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    _animation.fromValue = @0.f;
    _animation.toValue = @(2 * M_PI);
    _animation.duration = 1.f;
    _animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    _animation.repeatCount = INFINITY;
}

- (void)start {
    if (_isAnimating) {
        return;
    }
    _isAnimating = YES;
    [self.layer removeAnimationForKey:KAnimationKey];
    [self.layer addAnimation:_animation
                      forKey:KAnimationKey];
    [UIView animateWithDuration:.4f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setTransform:CGAffineTransformIdentity];
                         [self setAlpha:1.f];
                     }
                     completion:nil];
}

- (void)stopWithComlpetion:(void (^)())completion {
    if (!_isAnimating) {
        if (completion) {
            completion();
        }
        return;
    }
    _isAnimating = NO;
    [UIView animateWithDuration:.4f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setTransform:CGAffineTransformMakeScale(.8f, .8f)];
                         [self setAlpha:0.f];
                     }
                     completion:^(BOOL finished) {
                         [self.layer removeAnimationForKey:KAnimationKey];
                         if (completion) {
                             completion();
                         }
                     }];
}

@end
