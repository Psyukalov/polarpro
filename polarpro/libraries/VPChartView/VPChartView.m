//
//  VPChartView.m
//
//  Created by Vladimir Psyukalov on 13.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "VPChartView.h"

#import "UIView+PPCustomView.h"


@interface VPChartView ()

@property (strong, nonatomic) NSMutableArray <UIView *> *charts;

@end


@implementation VPChartView

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
    _mainColor = [UIColor colorWithRed:94.f / 255.f
                                 green:100.f / 255.f
                                  blue:106.f / 255.f
                                 alpha:1.f];
    _defaultColor = [UIColor colorWithRed:238.f / 255.f
                                    green:184.f / 255.f
                                     blue:24.f / 255.f
                                    alpha:1.f];
    _dangerColor = [UIColor colorWithRed:228.f / 255.f
                                   green:24.f / 255.f
                                    blue:24.f / 255.f
                                   alpha:1.f];
    _chartWidth = 4.f;
    _chartCornerRadius = 2.f;
    _innerMargin = .4f;
}

- (void)reloadData {
    [self reloadDataAnimated:YES];
}

- (void)reloadDataAnimated:(BOOL)animated {
    [self reloadDataAnimated:animated
                withDuration:1.f];
}

- (void)reloadDataAnimated:(BOOL)animated
              withDuration:(CGFloat)duration {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    NSUInteger count = 0;
    CGFloat maxValue = 0.f;
    CGFloat minValue = 0.f;
    CGFloat dangerValue = 0.f;
    if (![self checkDelegate]) {
        return;
    }
    if ([self checkDelegate] && [_delegate respondsToSelector:@selector(numberOfChartsForChartView:)]) {
        count = [_delegate numberOfChartsForChartView:self];
    }
    if ([_delegate respondsToSelector:@selector(minValueForChartView:)]) {
        minValue = [_delegate minValueForChartView:self];
    }
    if ([_delegate respondsToSelector:@selector(maxValueForChartView:)]) {
        maxValue = [_delegate maxValueForChartView:self];
    }
    if ([_delegate respondsToSelector:@selector(dangerValueForChartView:)]) {
        dangerValue = [_delegate dangerValueForChartView:self];
        if (dangerValue > maxValue) {
            dangerValue = maxValue;
        }
        if (dangerValue < minValue) {
            dangerValue = minValue;
        }
    }
    CGFloat leftMargin = (self.frame.size.width - count * _chartWidth) / (count - 1);
    for (NSUInteger i = 0; i <= count - 1; i++) {
        if ([_delegate respondsToSelector:@selector(chartView:valueForIndex:)]) {
            CGFloat value = [_delegate chartView:self
                                   valueForIndex:i];
            CGFloat percent = value / maxValue;
            UIView *outerView = [[UIView alloc] init];
            outerView.center = CGPointMake(.5f * outerView.frame.size.width, 1.f * outerView.frame.size.height);
            outerView.layer.anchorPoint = CGPointMake(.5f, 1.f);
            [outerView setFrame:CGRectMake(i * (_chartWidth + leftMargin),
                                           0.f,
                                           _chartWidth,
                                           self.frame.size.height)];
            [outerView setBackgroundColor:_mainColor];
            [outerView applyCornerRadius:_chartCornerRadius];
            [outerView setClipsToBounds:NO];
            CGRect frame = outerView.frame;
            UIView *innerView = [[UIView alloc] init];
            innerView.center = CGPointMake(.5f * innerView.frame.size.width, 1.f * innerView.frame.size.height);
            innerView.layer.anchorPoint = CGPointMake(.5f, 1.f);
            [innerView setFrame:CGRectMake(_innerMargin,
                                           _innerMargin,
                                           frame.size.width - 2 * _innerMargin,
                                           frame.size.height - 2 * _innerMargin)];
            innerView.backgroundColor = (value <= dangerValue) ? _defaultColor : _dangerColor;
            [innerView applyCornerRadius:_chartCornerRadius];
            [outerView addSubview:innerView];
            [self addSubview:outerView];
            if (animated) {
                [innerView setTransform:CGAffineTransformMakeScale(1.f, 0.f)];
                [outerView setTransform:CGAffineTransformMakeScale(1.f, 0.f)];
                [UIView animateWithDuration:duration
                                      delay:i * duration / count
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     [outerView setTransform:CGAffineTransformIdentity];
                                 }
                                 completion:^(BOOL finished) {
                                     if (i == count - 1) {
                                         if ([_delegate respondsToSelector:@selector(didCompleteAnimationForChartView:)]) {
                                             [_delegate didCompleteAnimationForChartView:self];
                                         }
                                     }
                                     [UIView animateWithDuration:duration / 2.f
                                                           delay:0.f
                                                         options:UIViewAnimationOptionCurveEaseInOut
                                                      animations:^{
                                                          [innerView setTransform:CGAffineTransformMakeScale(1.f, percent)];
                                                      }
                                                      completion:nil];
                                 }];
            } else {
                [innerView setTransform:CGAffineTransformMakeScale(1.f, percent)];
            }
        }
    }
}

- (BOOL)checkDelegate {
    if (!_delegate || ![_delegate conformsToProtocol:@protocol(VPChartViewDelegate)]) {
        return NO;
    }
    return YES;
}

@end
