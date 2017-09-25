//
//  PPSunriseView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 22.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPSunriseView.h"

#import "Macros.h"


#define kLarge (-54.f)
#define kSmall (-26.f)

#define kMinAngle (122.f)
#define kMaxAngle (238.f)


@interface PPSunriseView ()

@property (weak, nonatomic) IBOutlet UIImageView *circleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;

@property (weak, nonatomic) IBOutlet UILabel *angleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraint;

@end


@implementation PPSunriseView

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
    UINib *nib = [UINib nibWithNibName:@"PPSunriseView"
                                bundle:bundle];
    UIView *view = (UIView *)[nib instantiateWithOwner:self
                                               options:nil].firstObject;
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setBackgroundColor:view.backgroundColor];
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
    [_angleLabel setFont:[UIFont fontWithName:@"BN-Light"
                                         size:30.f]];
    [self setDirection:90.f
              animated:NO];
    [self setType:PPSunriseViewSmallType];
}

- (void)setType:(PPSunriseViewType)type {
    UIImage *circleImage;
    UIImage *lineImage;
    CGFloat constant;
    BOOL angleHidden;
    switch (type) {
        case PPSunriseViewSmallType: {
            circleImage = [UIImage imageNamed:@"sun_circle_i.png"];
            lineImage = [UIImage imageNamed:@"line_i.png"];
            constant = kSmall;
            angleHidden = YES;
        }
            break;
        case PPSunriseViewLargeType: {
            circleImage = [UIImage imageNamed:@"sun_big_circle_i.png"];
            lineImage = [UIImage imageNamed:@"line_big_i.png"];
            constant = kLarge;
            angleHidden = NO;
        }
            break;
        default:
            //
            break;
    }    [_circleImageView setImage:circleImage];
    [_lineImageView setImage:lineImage];
    [_layoutConstraint setConstant:constant];
    [_angleLabel setHidden:angleHidden];
}

- (void)setAngle:(CGFloat)angle {
    _angle = angle;
    [_angleLabel setText:[NSString stringWithFormat:@"%1.0f%@", _angle, kDegreeCharacter]];
}

- (void)setDirection:(CGFloat)direction {
    [self setDirection:direction
              animated:YES];
}

- (void)setPercent:(CGFloat)percent {
    if (percent < 0.f || percent > 1.f) {
        percent = 0.f;
    }
    CGFloat direction = (percent - 0.f) * (kMaxAngle - kMinAngle) / (1.f - 0.f) + kMinAngle;
    [self setDirection:direction];
}

- (void)setDirection:(CGFloat)direction
            animated:(BOOL)animated {
    [self setDirection:direction
              animated:animated
            completion:nil];
}

- (void)setDirection:(CGFloat)direction
            animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    _direction = direction;
    if (animated) {
        [UIView animateWithDuration:1.f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_circleImageView setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(_direction))];
                         }
                         completion:^(BOOL finished) {
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    } else {
        [_circleImageView setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(_direction))];
    }
}

@end
