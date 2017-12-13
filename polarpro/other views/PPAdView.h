//
//  PPAdView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 12.12.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "CCView.h"

#import "PPAdModel.h"


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
