//
//  UIViewController+PPCostomViewController.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UIViewController (PPCostomViewController)

- (void)applyNavigationBarWithFont:(UIFont *)font
                         withColor:(UIColor *)color;

- (void)openSchemes:(NSArray <NSString *> *)schemes;

- (void)createMenuBBI;
- (void)createCloseBBI;
- (void)createBackBBI;
- (void)createLogoBBI;
- (void)createDoneBBI;
- (void)createInfoBBI;
- (void)createSettingsBBI;

- (void)hideDoneBBIAnimated:(BOOL)animated;
- (void)showDoneBBIAnimated:(BOOL)animated;

@end
