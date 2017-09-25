//
//  VPChartView.h
//
//  Created by Vladimir Psyukalov on 13.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@class VPChartView;


@protocol VPChartViewDelegate <NSObject>

@required

- (NSUInteger)numberOfChartsForChartView:(VPChartView *)chartView;

- (CGFloat)minValueForChartView:(VPChartView *)chartView;
- (CGFloat)maxValueForChartView:(VPChartView *)chartView;

- (CGFloat)chartView:(VPChartView *)chartView
       valueForIndex:(NSUInteger)index;

@optional

- (CGFloat)dangerValueForChartView:(VPChartView *)chartView;

- (void)didCompleteAnimationForChartView:(VPChartView *)chartView;

@end


@interface VPChartView : UIView

@property (strong, nonatomic) id<VPChartViewDelegate> delegate;

@property (strong, nonatomic) UIColor *mainColor;
@property (strong, nonatomic) UIColor *defaultColor;
@property (strong, nonatomic) UIColor *dangerColor;

@property (assign, nonatomic) CGFloat chartWidth;
@property (assign, nonatomic) CGFloat chartCornerRadius;
@property (assign, nonatomic) CGFloat innerMargin;
@property (assign, nonatomic) CGFloat animationDelay;

- (void)reloadData;
- (void)reloadDataAnimated:(BOOL)animated;

@end
