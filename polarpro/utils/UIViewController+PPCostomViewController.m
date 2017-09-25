//
//  UIViewController+PPCostomViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "UIViewController+PPCostomViewController.h"

#import "Macros.h"
#import "VPNavigationController.h"
#import "ICGSlideAnimation.h"

#import "PPHubViewController.h"

#import "PPMenuViewController.h"
#import "PPAboutUsViewController.h"
#import "PPKPInfoViewController.h"
#import "PPSupportViewController.h"


@implementation UIViewController (PPCostomViewController)

- (void)applyNavigationBarWithFont:(UIFont *)font
                         withColor:(UIColor *)color {
    [self.navigationController.navigationBar setBarTintColor:MAIN_COLOR];
    if (!self.navigationItem.title) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImage:[UIImage imageNamed:@"polarpro_i.png"]];
        [imageView sizeToFit];
        [self.navigationItem setTitleView:imageView];
        return;
    }
    if (!font) {
        font = [UIFont fontWithName:@"Montserrat-Regular"
                               size:16.f];
    }
    if (!color) {
        color = [UIColor whiteColor];
    }
    UILabel *label = [[UILabel alloc] init];
    NSDictionary *attributes = @{NSFontAttributeName : font,
                                 NSForegroundColorAttributeName : color};
    label.attributedText = [[NSAttributedString alloc] initWithString:self.navigationItem.title
                                                           attributes:attributes];
    [label sizeToFit];
    [self.navigationItem setTitleView:label];
}

- (void)openSchemes:(NSArray <NSString *> *)schemes {
    UIApplication *application = APPLICATION;
    BOOL iOS_10_0 = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0");
    for (NSString *scheme in schemes) {
        NSURL *URL = [NSURL URLWithString:scheme];
        if ([application canOpenURL:URL]) {
            if (iOS_10_0) {
                [application openURL:URL
                             options:@{}
                   completionHandler:nil];
            } else {
                [application openURL:URL];
            }
            return;
        }
    }
}

- (void)createMenuBBI {
    UIBarButtonItem *menuBBI = [[UIBarButtonItem alloc] init];
    [menuBBI setTarget:self];
    [menuBBI setAction:@selector(menuBBI_TUI)];
    [menuBBI setImage:[UIImage imageNamed:@"menu_bbi.png"]];
    [self.navigationItem setLeftBarButtonItem:menuBBI];
}

- (void)createCloseBBI {
    UIBarButtonItem *closeBBI = [[UIBarButtonItem alloc] init];
    [closeBBI setTarget:self];
    [closeBBI setAction:@selector(closeBBI_TUI)];
    [closeBBI setImage:[UIImage imageNamed:@"close_bbi.png"]];
    [self.navigationItem setLeftBarButtonItem:closeBBI];
}

- (void)createBackBBI {
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    UIBarButtonItem *backBBI = [[UIBarButtonItem alloc] init];
    [backBBI setTarget:self];
    [backBBI setAction:@selector(backBBI_TUI)];
    [backBBI setImage:[UIImage imageNamed:@"back_bbi.png"]];
    [self.navigationItem setLeftBarButtonItem:backBBI];
}

- (void)createLogoBBI {
    UIBarButtonItem *logoBBI = [[UIBarButtonItem alloc] init];
    [logoBBI setTarget:self];
    [logoBBI setAction:@selector(logoBBI_TUI)];
    [logoBBI setImage:[UIImage imageNamed:@"logo_bbi.png"]];
    [self.navigationItem setRightBarButtonItem:logoBBI];
}

- (void)createDoneBBI {
    UIBarButtonItem *doneBBI = [[UIBarButtonItem alloc] init];
    [doneBBI setTarget:self];
    [doneBBI setAction:@selector(backBBI_TUI)];
    [doneBBI setTitle:LOCALIZE(@"done")];
    [doneBBI setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"BN-Regular"
                                                                            size:22.f]}
                           forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:doneBBI];
}

- (void)createInfoBBI {
    UIBarButtonItem *infoBBI = [[UIBarButtonItem alloc] init];
    [infoBBI setTarget:self];
    [infoBBI setAction:@selector(infoBBI_TUI)];
    [infoBBI setImage:[UIImage imageNamed:@"info_bbi.png"]];
    [self.navigationItem setRightBarButtonItem:infoBBI];
}

- (void)createSettingsBBI {
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    UIBarButtonItem *settingBBI = [[UIBarButtonItem alloc] init];
    [settingBBI setTarget:self];
    [settingBBI setAction:@selector(settingsBBI_TUI)];
    [settingBBI setImage:[UIImage imageNamed:@"settings_bbi.png"]];
    [self.navigationItem setRightBarButtonItem:settingBBI];
}

- (void)menuBBI_TUI {
    PPMenuViewController *menuVC = [[PPMenuViewController alloc] init];
    VPNavigationController *navigationController = [[VPNavigationController alloc] initWithRootViewController:menuVC];
    [navigationController.navigationBar setBarTintColor:RGB(24.f, 26.f, 30.f)];
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [navigationController.navigationBar setTranslucent:NO];
    [navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                            forBarPosition:UIBarPositionAny
                                                barMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    ICGViewController *selfVC = (ICGViewController *)self;
    selfVC.interactionEnabled = YES;
    selfVC.animationController = [[ICGSlideAnimation alloc] init];
    selfVC.animationController.type = ICGSlideAnimationFromLeft;
    
    if ([self respondsToSelector:@selector(setTransitioningDelegate:)]){
        navigationController.transitioningDelegate = self.transitioningDelegate;
    }
    
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

- (void)closeBBI_TUI {    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)backBBI_TUI {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)logoBBI_TUI {
    PPAboutUsViewController *aboutUsVC = [[PPAboutUsViewController alloc] init];
    [self.navigationController pushViewController:aboutUsVC
                                         animated:YES];
}

- (void)hideDoneBBIAnimated:(BOOL)animated {
    [self switchDoneBBI:animated
              withAlpha:0.f];
}

- (void)showDoneBBIAnimated:(BOOL)animated {
    [self switchDoneBBI:animated
              withAlpha:255.f];
}

- (void)switchDoneBBI:(BOOL)animated withAlpha:(CGFloat)alpha {
    UIBarButtonItem *doneBBI = self.navigationItem.rightBarButtonItem;
    if (!doneBBI) {
        return;
    }
    if (animated) {
        [UIView animateWithDuration:.6f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [doneBBI setTintColor:RGBA(255.f, 255.f, 255.f, alpha)];
                         }
                         completion:nil];
    } else {
        [doneBBI setTintColor:RGBA(255.f, 255.f, 255.f, alpha)];
    }
}

- (void)infoBBI_TUI {
    PPKPInfoViewController *KPInfoVC = [[PPKPInfoViewController alloc] init];
    [self.navigationController pushViewController:KPInfoVC
                                         animated:YES];
}

- (void)settingsBBI_TUI {
    PPSupportViewController *filterGuideHelpVC = [[PPSupportViewController alloc] initWithViewControllerType:PPFilterGuideSettingsViewControllerType];
    [self.navigationController pushViewController:filterGuideHelpVC
                                         animated:YES];
}

@end
