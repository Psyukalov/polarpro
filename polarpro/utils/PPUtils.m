//
//  PPUtils.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 28.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPUtils.h"

#import "Macros.h"

@implementation PPUtils

+ (CGFloat)screenRate {
    static NSNumber *rate = nil;
    if (!rate) {
        rate = [NSNumber numberWithDouble:HEIGHT / 667.f]; // Designed for iPhone 6, 7 screens.
        return [rate floatValue];
    }
    return [rate floatValue];
}

+ (void)resizeLabelsInView:(UIView *)view {
    return;
    CGFloat rate = PPUtils.screenRate;
    if (rate == 1.f) {
        return;
    }
    for (id label in view.subviews) {
        if ([label isKindOfClass:[UILabel class]]) {
            UIFont *font = ((UILabel *)label).font;
            font = [font fontWithSize:(NSUInteger)(font.pointSize * rate)];
            [((UILabel *)label) setFont:font];
        }
        if ([label isKindOfClass:[UIButton class]]) {
            UIFont *font = ((UIButton *)label).titleLabel.font;
            font = [font fontWithSize:(NSUInteger)(font.pointSize * rate)];
            [((UIButton *)label).titleLabel setFont:font];
        }
    }
}

+ (void)resizeMarginsInView:(UIView *)view {
    return;
    CGFloat rate = PPUtils.screenRate;
    if (rate == 1.f) {
        return;
    }
    for (NSLayoutConstraint *constraint in view.constraints) {
        if (constraint.constant != 0.f) {
            if (constraint.firstAttribute != NSLayoutAttributeWidth &&
                constraint.firstAttribute != NSLayoutAttributeHeight/* &&
                constraint.firstAttribute != NSLayoutAttributeCenterX &&
                constraint.firstAttribute != NSLayoutAttributeCenterY*/) {
                [constraint setConstant:constraint.constant * rate];
            }
        }
    }
}

@end
