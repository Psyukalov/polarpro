//
//  VPNavigationController.m
//
//  Created by Vladimir Psyukalov on 29.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "VPNavigationController.h"


@interface VPNavigationController ()

@end


@implementation VPNavigationController

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

@end
