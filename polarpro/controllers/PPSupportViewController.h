//
//  PPSupportViewController.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


/*
 
 Also view controller use for filter guide settings module
 
 */

typedef NS_ENUM(NSUInteger, PPViewControllerType) {
    PPSupportViewCotrollerType,
    PPFilterGuideSettingsViewControllerType
};

@interface PPSupportViewController : UIViewController

- (instancetype)initWithViewControllerType:(PPViewControllerType)viewControllerType;

@end
