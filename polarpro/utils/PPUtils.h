//
//  PPUtils.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 28.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>


@interface PPUtils : NSObject

+ (CGFloat)screenRate;

+ (void)resizeLabelsInView:(UIView *)view;

+ (void)resizeMarginsInView:(UIView *)view;

@end
