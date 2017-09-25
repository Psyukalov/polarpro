//
//  PPGoldenHourProgressView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 04.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface PPGoldenHourProgressView : UIView

@property (assign, nonatomic) NSUInteger type;

@property (assign, nonatomic) CGFloat angle;
@property (assign, nonatomic) CGFloat position;
@property (assign, nonatomic) CGFloat percent;

- (void)setPosition:(CGFloat)position
           animated:(BOOL)animated;

- (void)setPosition:(CGFloat)position
           animated:(BOOL)animated
         completion:(void (^)(BOOL))completion;

@end
