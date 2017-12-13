//
//  PPAdModel.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 13.12.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, PPAdType) {
    PPAdTypeImage = 0,
    PPAdTypeGIF = 1
};


@interface PPAd : NSObject

@property (assign, nonatomic) PPAdType type;

@property (strong, nonatomic) NSString *URL;
@property (strong, nonatomic) NSString *actionURL;

@property (assign, nonatomic) CGFloat showTime;

@end


@interface PPAdModel : NSObject

- (void)adsWithCompletion:(void (^)(NSArray <PPAd *> *ads, NSError *error))completion;

@end
