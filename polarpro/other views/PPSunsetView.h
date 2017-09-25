//
//  PPSunsetView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 22.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, PPSunsetViewType) {
    PPSunsetViewSmallType = 0,
    PPSunsetViewLargeType
};


@interface PPSunsetView : UIView

@property (assign, nonatomic) PPSunsetViewType type;

@property (assign, nonatomic) CGFloat angle;
@property (assign, nonatomic) CGFloat direction;
@property (assign, nonatomic) CGFloat percent;

- (void)setDirection:(CGFloat)direction
            animated:(BOOL)animated;

- (void)setDirection:(CGFloat)direction
            animated:(BOOL)animated
          completion:(void (^)(BOOL finished))completion;

@end
