//
//  PPFilterGuideItemView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 19.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@protocol PPFilterGuideItemViewDelegate <NSObject>

@optional

- (void)didChangeCalculatorParameters:(NSArray <NSNumber *> *)parameters
                       withIdentifier:(NSUInteger)identifier;

@end


@interface PPFilterGuideItemView : UIView

@property (strong, nonatomic) id<PPFilterGuideItemViewDelegate> delegate;

@property (assign, nonatomic) NSUInteger identifier;

@property (strong, nonatomic) NSArray <NSNumber *> *selectedParameters;

@property (strong, nonatomic) NSString *device;

@property (strong, nonatomic) NSArray <NSString *> *FPS;
@property (strong, nonatomic) NSArray <NSString *> *shutterSpeed;
@property (strong, nonatomic) NSArray <NSString *> *filtersInstalled;

- (void)reloadView;

@end
