//
//  PPAdView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 12.12.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPAdView.h"

#import "Macros.h"

#import "UIView+PPCustomView.h"

#import "UIImage+Gif.h"


@interface PPAdView ()

@property (weak, nonatomic) IBOutlet UIView *baseView;

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (weak, nonatomic) IBOutlet UILabel *siteLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (assign, nonatomic) NSUInteger index;

@property (strong, nonatomic) NSMutableArray <NSData *> *data;

@property (assign, nonatomic) BOOL isPlaying;

@end


@implementation PPAdView

- (void)loadViewFromNib {
    [super loadViewFromNib];
    [self setup];
}

- (void)setup {
    [self applyCornerRadius:6.f];
    [self setBackgroundColor:RGB(28.f, 30.f, 34.f)];
    _siteLabel.text = LOCALIZE(@"hub_site");
    _subtitleLabel.text = LOCALIZE(@"shop_now");
    _imageView.image = [UIImage imageNamed:@"site_i.png"];
    _data = [NSMutableArray new];
    _imageView.animationRepeatCount = 1;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(tapGR_TUI)]];
}

- (void)setAds:(NSArray <PPAd *> *)ads {
    _ads = ads;
    for (PPAd *ad in _ads) {
        [self loadWithURL:ad.URL
               completion:^(NSData *data,
                            NSError *error) {
                   if (data && !error) {
                       [_data addObject:data];
                   }
                   if (_autoplay && _ads.lastObject == ad) {
                       [self play];
                   }
               }];
    }
}

- (void)loadWithURL:(NSString *)URL
         completion:(void (^)(NSData *data, NSError *error))completion {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:URL]
                                            completionHandler:^(NSData *data,
                                                                NSURLResponse *response,
                                                                NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (completion) {
                                                        completion(data, error);
                                                    }
                                                });
                                            }];
    [dataTask resume];
}

- (void)play {
    if (_ads.count == 0) {
        return;
    }
    [self stop];
    _isPlaying = YES;
    [self setCurrentAd:_ads[_index]];
}

- (void)stop {
    _isPlaying = NO;
    _index = 0;
}

- (void)setCurrentAd:(PPAd *)ad {
    [self refresh];
    UIImage *image;
    CGFloat duration;
    SEL selector;
    if (ad.type == PPAdTypeImage) {
        image = [UIImage imageWithData:_data[_index]];
        duration = ad.showTime;
        selector = @selector(nextAd);
    } else {
        image = [UIImage gifWithData:_data[_index]];
        duration = image.duration;
        selector = @selector(stopGIF);
        _imageView.animationDuration = image.duration;
    }
    [self performSelector:selector
               withObject:nil
               afterDelay:duration];
    [UIView transitionWithView:_imageView
                      duration:1.f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if (ad.type == PPAdTypeImage) {
                            _imageView.image = image;
                        } else {
                            _imageView.animationImages = image.images;
                            [_imageView startAnimating];
                        }
                    }
                    completion:nil];
}

- (void)stopGIF {
    [_imageView stopAnimating];
    _imageView.image = _imageView.animationImages.lastObject;
    [self nextAd];
}

- (void)nextAd {
    _index = _index < _ads.count - 1 ? _index + 1 : 0;
    [self setCurrentAd:_ads[_index]];
}

- (void)refresh {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _imageView.image = nil;
    _imageView.animationImages = nil;
    _imageView.animationDuration = 0.f;
}

- (void)tapGR_TUI {
    if (_isPlaying) {
        if ([_delegate respondsToSelector:@selector(adView:didSelectAdAtIndex:)]) {
            [_delegate adView:self
           didSelectAdAtIndex:_index];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(didSelectDefaultAdInAdView:)]) {
            [_delegate didSelectDefaultAdInAdView:self];
        }
    }
}

@end
