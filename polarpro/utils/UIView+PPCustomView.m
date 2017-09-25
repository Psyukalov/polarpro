//
//  UIView+PPCustomView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 17.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "UIView+PPCustomView.h"

#import "Macros.h"


@implementation UIView (PPCustomView)

- (void)applyCornerRadius:(CGFloat)cornerRadius {
    [self.layer setCornerRadius:cornerRadius];
    [self setClipsToBounds:YES];
}

- (NSString *)dayOfWeekByFormattedString:(NSString *)string {
    NSDateFormatter *dateFormatted = [[NSDateFormatter alloc] init];
    [dateFormatted setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatted setDateFormat:@"yyyy MMM dd"];
    NSDate *date = [dateFormatted dateFromString:string];
    /*
     
     [dateFormatted setLocale:[NSLocale currentLocale]];
     
     */
    [dateFormatted setDateFormat:@"EEEE"];
    return [dateFormatted stringFromDate:date];
}

- (void)createGradientLayersForView:(UIView *)view
                         withColors:(NSArray *)colors {
    CAGradientLayer *leftGradientLayer = [CAGradientLayer layer];
    [leftGradientLayer setFrame:view.bounds];
    leftGradientLayer.colors = colors;
    leftGradientLayer.locations = @[@(0.f), @(1.f)];
    [leftGradientLayer setStartPoint:CGPointMake(0.f, .5f)];
    [leftGradientLayer setEndPoint:CGPointMake(1.f, .5f)];
    [view.layer addSublayer:leftGradientLayer];
}

@end
