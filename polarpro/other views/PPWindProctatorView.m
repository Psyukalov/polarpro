//
//  PPWindProctatorView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 01.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPWindProctatorView.h"

#import "Macros.h"


@interface PPWindProctatorView ()

@property (strong, nonatomic) UIImageView *directionImageView;

@end


@implementation PPWindProctatorView

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
    [self setImage:[UIImage imageNamed:@"proctator_i.png"]];
    [self setContentMode:UIViewContentModeScaleToFill];
    _directionImageView = [[UIImageView alloc] init];
    [_directionImageView setImage:[UIImage imageNamed:@"proctator_direction_i.png"]];
    [_directionImageView setContentMode:UIViewContentModeScaleToFill];
    [_directionImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_directionImageView];
    
    /*
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_directionImageView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_directionImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.f]];
     */
    
    NSArray *attributes = @[@(NSLayoutAttributeLeft),
                            @(NSLayoutAttributeTop),
                            @(NSLayoutAttributeRight),
                            @(NSLayoutAttributeBottom)];
    for (NSNumber *attribute in attributes) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_directionImageView
                                                         attribute:[attribute unsignedIntegerValue]
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:[attribute unsignedIntegerValue]
                                                        multiplier:1.f
                                                          constant:0.f]];
    }
}

- (void)setDirection:(CGFloat)direction {
    [self setDirection:direction
              animated:YES];
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
                             [_directionImageView setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(_direction))];
                         }
                         completion:^(BOOL finished) {
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    } else {
        [_directionImageView setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(_direction))];
    }
}

@end
