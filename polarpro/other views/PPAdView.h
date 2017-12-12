//
//  PPAdView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 12.12.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "CCView.h"


typedef NS_ENUM(NSUInteger, PPAdType) {
    PPAdTypeImage = 0,
    PPAdTypeGIF = 1
};


@interface PPAd : NSObject

@property (assign, nonatomic) PPAdType type;

@property (strong, nonatomic) NSString *URL;
@property (strong, nonatomic) NSString *actionURL;

@property (assign, nonatomic) CGFloat showTime;
@property (assign, nonatomic) CGFloat animationTime;

@end


@class PPAdView;


@protocol PPAdViewDelegate <NSObject>

- (void)didSelectDefaultAdInAdView:(PPAdView *)adView;

- (void)adView:(PPAdView *)adView didSelectAdAtIndex:(NSUInteger)index;

@end


@interface PPAdView : CCView

@property (strong, nonatomic) NSArray <PPAd *> *ads;

@property (weak, nonatomic) id<PPAdViewDelegate> delegate;

@property (assign, nonatomic) BOOL autoplay;

- (void)play;
- (void)stop;

@end
