//
//  PPStartView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 20.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPStartView.h"

#import "AppDelegate.h"

#import "Macros.h"


#define kPhotoCrossFadeDuration (.2f)
#define kWhiteLogoDuration (.68f)

@interface PPStartView ()

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *polarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *proImageView;

@property (weak, nonatomic) IBOutlet UILabel *sloganLabel;

@property (strong, nonatomic) NSArray <UIImage *> *photoImages;
@property (strong, nonatomic) NSArray <UIImage *> *mainImages;

@property (strong, nonatomic) NSArray *delays;

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) UIImageView *maskLogoImageView;
@property (strong, nonatomic) UIImageView *maskSloganImageView;
@property (strong, nonatomic) UIImageView *maskPolarImageView;
@property (strong, nonatomic) UIImageView *maskProImageView;

@property (assign, nonatomic) CGFloat duration;

@property (assign, nonatomic) BOOL isFinished;

@end


@implementation PPStartView

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
    [self setFrame:CGRectMake(0.f, 0.f, WIDTH, HEIGHT)];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *nib = [UINib nibWithNibName:@"PPStartView"
                                bundle:bundle];
    UIView *view = (UIView *)[nib instantiateWithOwner:self
                                               options:nil].firstObject;
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
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(stop)];
    [self setGestureRecognizers:@[tapGR]];
    NSString *model;
    CGFloat height = HEIGHT;
    CGFloat scale = 1.2f;
    if (height == 736.f) {
        model = @"7_plus";
    } else if (height == 667.f) {
        model = @"7";
    } else if (height == 568.f) {
        model = @"se";
        scale = 1.f;
    } else {
        model = @"4s";
        scale = 1.f;
    }
    
    [_mainImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"launch_screen_iphone_%@.png", model]]];
    
    _photoImages = @[[UIImage imageNamed:@"start_photo_i_0.png"],
                     [UIImage imageNamed:@"start_photo_i_1.png"],
                     [UIImage imageNamed:@"start_photo_i_2.png"],
                     [UIImage imageNamed:@"start_photo_i_3.png"],
                     [UIImage imageNamed:@"start_photo_i_4.png"]];
    _delays = @[@(.36f),
                @(.34f),
                @(.34f),
                @(.32f),
                @(.32f)];
    _duration = 0.f;
    for (NSNumber *number in _delays) {
        _duration += number.floatValue;
    }
    [_photoImageView setBackgroundColor:[UIColor clearColor]];
    _appDelegate = (AppDelegate *)[APPLICATION delegate];
    _maskLogoImageView = [[UIImageView alloc] init];
    [_maskLogoImageView setContentMode:UIViewContentModeCenter];
    [_maskLogoImageView setImage:[UIImage imageNamed:@"mask_logo_i.png"]];
    [_maskLogoImageView setFrame:CGRectMake(0.f, 0.f, WIDTH, WIDTH)];
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scale, scale), CGAffineTransformMakeTranslation(56.f, 0.f));
    [_maskLogoImageView setTransform:transform];
    [_photoImageView setMaskView:_maskLogoImageView];
    
    _maskPolarImageView = [[UIImageView alloc] init];
    [_maskPolarImageView setContentMode:UIViewContentModeCenter];
    [_maskPolarImageView setImage:[UIImage imageNamed:@"mask_logo_text_i.png"]];
    [_maskPolarImageView setFrame:CGRectMake(-39.f, 0.f, 78.f, 28.f)];
    [_polarImageView setMaskView:_maskPolarImageView];
    
    _maskProImageView = [[UIImageView alloc] init];
    [_maskProImageView setContentMode:UIViewContentModeCenter];
    [_maskProImageView setImage:[UIImage imageNamed:@"mask_logo_text_i.png"]];
    [_maskProImageView setFrame:CGRectMake(-39.f, 0.f, 78.f, 28.f)];
    [_proImageView setMaskView:_maskProImageView];
    
    [_sloganLabel setText:LOCALIZE(@"slogan")];
    [_sloganLabel sizeToFit];
    _maskSloganImageView = [[UIImageView alloc] init];
    [_maskSloganImageView setContentMode:UIViewContentModeCenter];
    [_maskSloganImageView setFrame:CGRectMake(-(412.f - _sloganLabel.frame.size.width), 0.f, 412.f, 28.f)];
    [_maskSloganImageView setImage:[UIImage imageNamed:@"mask_slogan_i.png"]];
    [_sloganLabel setMaskView:_maskSloganImageView];
}

- (void)play {
    UIView *rootView = _appDelegate.window.rootViewController.view;
    [rootView addSubview:self];
    NSArray *attributes = @[@(NSLayoutAttributeLeft),
                            @(NSLayoutAttributeTop),
                            @(NSLayoutAttributeRight),
                            @(NSLayoutAttributeBottom)];
    for (NSNumber *attribute in attributes) {
        [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                             attribute:[attribute unsignedIntegerValue]
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:rootView
                                                             attribute:[attribute unsignedIntegerValue]
                                                            multiplier:1.f
                                                              constant:0.f]];
    }
    [self changePhoto];
    [self scaleLogo];
    [self translationLogoText];
    [self translationSloganMask];
}

- (void)stop {
    [UIView animateWithDuration:.6f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setAlpha:0.f];
                     }
                     completion:^(BOOL finished) {
                         if (_delegate) {
                             if ([_delegate conformsToProtocol:@protocol(PPStartViewDelegate)] &&
                                 [_delegate respondsToSelector:@selector(didCompleteStartAnimation)]) {
                                 [_delegate didCompleteStartAnimation];
                             }
                         }
                         [self removeFromSuperview];
                     }];
}

- (void)changePhoto {
    static NSUInteger index = 0;
    [UIView transitionWithView:_photoImageView
                      duration:kPhotoCrossFadeDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [_photoImageView setImage:_photoImages[index]];
                    }
                    completion:^(BOOL finished) {
                        index++;
                        SEL selector;
                        if (index <= _photoImages.count - 1) {
                            selector = @selector(changePhoto);
                        } else {
                            selector = @selector(whiteBackgroundForPhotoImageView);
                        }
                        [self performSelector:selector
                                   withObject:nil
                                   afterDelay:[_delays[index - 1] floatValue] - kPhotoCrossFadeDuration];
                    }];
}

- (void)whiteBackgroundForPhotoImageView {
    [_photoImageView setBackgroundColor:[UIColor whiteColor]];
    [UIView transitionWithView:_photoImageView
                      duration:kPhotoCrossFadeDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [_photoImageView setImage:nil];
                    }
                    completion:nil];
}

- (void)scaleLogo {
    [UIView animateWithDuration:_duration + kWhiteLogoDuration
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeScale(.35f, .35f), CGAffineTransformMakeTranslation(-16.f, 0.f));
                         [_maskLogoImageView setTransform:transform];
                     }
                     completion:nil];
}

- (void)translationLogoText {
    [UIView animateWithDuration:.8f
                          delay:2.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_maskPolarImageView setTransform:CGAffineTransformMakeTranslation(78.f, 0.f)];
                     }
                     completion:nil];
    [UIView animateWithDuration:1.f
                          delay:2.2f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_maskProImageView setTransform:CGAffineTransformMakeTranslation(78.f, 0.f)];
                     }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stop)
                                    withObject:nil
                                    afterDelay:.4f];
                     }];
}

- (void)translationSloganMask {
    [UIView animateWithDuration:1.2f
                          delay:2.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_maskSloganImageView setTransform:CGAffineTransformMakeTranslation(_maskSloganImageView.frame.size.width - _sloganLabel.frame.size.width, 0.f)];
                     }
                     completion:nil];
}

@end
