//
//  VPRefreshControl.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 28.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "VPRefreshControl.h"

#define kMinY (16.f)
#define kMaxY (84.f)

#define kMinAlpha (0.f)
#define kMaxAlpha (1.f)

#define kMinScale (.6f)
#define kMaxScale (1.f)

#define KAnimationKey (@"refresh_control_rotate_animation")


@interface VPRefreshControl ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) CABasicAnimation *animation;

@property (assign, nonatomic) BOOL isAnimating;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (assign, nonatomic) BOOL freezed;

@end


@implementation VPRefreshControl

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
    UINib *nib = [UINib nibWithNibName:@"VPRefreshControl"
                                bundle:bundle];
    UIView *view = (UIView *)[nib instantiateWithOwner:self
                                               options:nil].firstObject;
    [self setBackgroundColor:view.backgroundColor];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
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
    _freezeThenStart = NO;
    [self applyAlphaAndScale];
    _animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    _animation.fromValue = @0.f;
    _animation.toValue = @(2 * M_PI);
    _animation.duration = 1.f;
    _animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    _animation.repeatCount = INFINITY;
}

- (void)applyAlphaAndScale {
    [_imageView setAlpha:kMinAlpha];
    [_imageView setTransform:CGAffineTransformMakeScale(kMinScale, kMinScale)];
}

- (void)fadeInOutWithScrollView:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    if (y >= 0.f) {
        [self applyAlphaAndScale];
        return;
    }
    y = ABS(y);
    if (y >= kMinY && y <= kMaxY) {
        CGFloat currenAlpha = y * (kMaxAlpha - kMinAlpha) / (kMaxY - kMinY) + kMinAlpha;
        CGFloat currenScale = y * (kMaxScale - kMinScale) / (kMaxY - kMinY) + kMinScale;
        [_imageView setAlpha:currenAlpha];
        [_imageView setTransform:CGAffineTransformMakeScale(currenScale, currenScale)];
        if (_isAnimating && _freezeThenStart && _freezed) {
            _scrollView = scrollView;
            [_scrollView setContentOffset:CGPointMake(0.f, -kMaxY)
                                 animated:NO];
        }
    } else if (y > kMaxY) {
        [self startRotate];
    } else {
        [self applyAlphaAndScale];
        [self stopRotate];
    }
}

- (void)startRotate {
    if (!_isAnimating) {
        _freezed = _freezeThenStart;
        _isAnimating = YES;
        [_imageView.layer removeAnimationForKey:KAnimationKey];
        [_imageView.layer addAnimation:_animation
                                forKey:KAnimationKey];
        if (_delegate) {
            if ([_delegate conformsToProtocol:@protocol(VPRefreshControlDelegate)] &&
                [_delegate respondsToSelector:@selector(didStartRefreshControl:)]) {
                [_delegate didStartRefreshControl:self];
            }
        }
    }
}

- (void)stopRotate {
    if (_isAnimating) {
        _isAnimating = NO;
        [_imageView.layer removeAnimationForKey:KAnimationKey];
    }
}

- (void)endAnimating {
    _freezed = NO;
    [_scrollView setContentOffset:CGPointZero
                         animated:YES];
}

@end
