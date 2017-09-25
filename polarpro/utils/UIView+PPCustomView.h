//
//  UIView+PPCustomView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 17.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UIView (PPCustomView)

- (void)applyCornerRadius:(CGFloat)cornerRadius;

- (NSString *)dayOfWeekByFormattedString:(NSString *)string;

- (void)createGradientLayersForView:(UIView *)view
                         withColors:(NSArray *)colors;

@end
