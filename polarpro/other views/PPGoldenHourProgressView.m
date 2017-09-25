//
//  PPGoldenHourProgressView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 04.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPGoldenHourProgressView.h"

#import "Macros.h"


#define kRotateDuration (128.f)

#define kSmallMin (-28.f)
#define kLargeMin (-64.f)

#define kSmallMax (18.f)
#define kLargeMax (30.f)

#define kRotateAnimationKey (@"rotate_animation")


@interface PPGoldenHourProgressView ()

@property (weak, nonatomic) IBOutlet UIImageView *sunImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;

@property (weak, nonatomic) IBOutlet UILabel *angleLabel;

@property (strong, nonatomic) CABasicAnimation *animation;

@end


@implementation PPGoldenHourProgressView

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
    UINib *nib = [UINib nibWithNibName:@"PPGoldenHourProgressView"
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
                                         size:40.f]];
    [self setAngle:0.f];
}

- (void)setType:(NSUInteger)type {
    _type = type;
    UIImage *sunImage;
    UIImage *lineImage;
    BOOL angleHidden;
    switch (type) {
        case 0: {
            sunImage = [UIImage imageNamed:@"sun_i.png"];
            lineImage = [UIImage imageNamed:@"line_i.png"];
            angleHidden = YES;
        }
            break;
        case 1: {
            sunImage = [UIImage imageNamed:@"sun_big_i.png"];
            lineImage = [UIImage imageNamed:@"line_big_i.png"];
            angleHidden = NO;
        }
            break;
        default:
            sunImage = [UIImage imageNamed:@"sun_i.png"];
            lineImage = [UIImage imageNamed:@"line_i.png"];
            angleHidden = YES;
            break;
    }
    [_sunImageView setImage:sunImage];
    [_lineImageView setImage:lineImage];
    [_angleLabel setHidden:angleHidden];
    [self setAngle:_angle];
}

- (void)setAngle:(CGFloat)angle {
    _angle = angle;
    _angleLabel.hidden = (_angle == 0.f);
    [_angleLabel setText:[NSString stringWithFormat:@"%1.0f %@", _angle, kDegreeCharacter]];
}

- (void)setPosition:(CGFloat)position {
    [self setPosition:position
             animated:YES];
}

- (void)setPercent:(CGFloat)percent {
    if (percent < 0.f) {
        percent = 0.f;
    } else if (percent > 1.f) {
        percent = 1.f;
    }
    percent = 1 - percent;
    CGFloat min = (_type == 0) ? kSmallMin : kLargeMin;
    CGFloat max = (_type == 0) ? kSmallMax : kLargeMax;
    CGFloat position = (percent - 0.f) * (max - min) / (1.f - 0.f) + min;
    [self setPosition:position];
}

- (void)setPosition:(CGFloat)position
           animated:(BOOL)animated {
    [self setPosition:position
             animated:animated
           completion:nil];
}

- (void)setPosition:(CGFloat)position animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    _position = position;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.f, position);
    if (animated) {
        [UIView animateWithDuration:1.f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_sunImageView setTransform:transform];
                         }
                         completion:^(BOOL finished) {
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    } else {
        [_sunImageView setTransform:transform];
    }
}

@end
