//
//  PPMenuModel.m
//  polarpro
//
//  Created by Владимир Псюкалов on 05.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPMenuModel.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "polarpro-Swift.h"

#import "PPDevicesViewController.h"
#import "PPSettingsViewController.h"
#import "PPLocationsViewController.h"
#import "PPFiltersViewController.h"
#import "PPSupportViewController.h"
#import "PPSupportTicketViewController.h"
#import "PPWebViewController.h"

#import "PPCustomSettingsViewController.h"

#import "PPDevicesViewController.h"
#import "PPFiltersViewController.h"
#import "PPFilterGuideHelpViewController.h"

#import "PPAlertView.h"


@implementation PPMenuItem

- (instancetype)initWithLocalizedString:(NSString *)localizedString
                        withImageString:(NSString *)imageString
                             withIsPush:(BOOL)isPush
                               andClass:(__unsafe_unretained Class)viewControllerClass{
    self = [super init];
    if (self) {
        _title = LOCALIZE(localizedString);
        _imageString = imageString;
        _isPush = isPush;
        _viewControllerClass = viewControllerClass;
    }
    return self;
}

@end


@interface PPMenuModel () <PPAlertViewDelegate>

@end


@implementation PPMenuModel

- (instancetype)initMenuItems {
    self = [super init];
    if (self) {
        _title = LOCALIZE(@"menu");
        NSString *version = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
        _version = [NSString stringWithFormat:@"%@ %@", LOCALIZE(@"version"), version];
        _items = [[NSMutableArray alloc] init];
        _items = @[[[PPMenuItem alloc] initWithLocalizedString:@"menu_item_devices"
                                               withImageString:nil
                                                    withIsPush:YES
                                                      andClass:[PPDevicesViewController class]],
                   [[PPMenuItem alloc] initWithLocalizedString:@"menu_item_settings"
                                               withImageString:nil
                                                    withIsPush:YES
                                                      andClass:[PPSettingsViewController class]],
                   [[PPMenuItem alloc] initWithLocalizedString:@"menu_item_locations"
                                               withImageString:nil
                                                    withIsPush:YES
                                                      andClass:[PPLocationsViewController class]],
                   [[PPMenuItem alloc] initWithLocalizedString:@"menu_item_filters"
                                               withImageString:nil
                                                    withIsPush:YES
                                                      andClass:[PPFiltersViewController class]],
                   [[PPMenuItem alloc] initWithLocalizedString:@"menu_item_support"
                                               withImageString:nil
                                                    withIsPush:YES
                                                      andClass:[PPSupportViewController class]],
                   [[PPMenuItem alloc] initWithLocalizedString:@"menu_item_pro_team"
                                               withImageString:nil
                                                    withIsPush:YES
                                                      andClass:[PPWebViewController class]]].mutableCopy;
    }
    return self;
}

- (instancetype)initSupportItems {
    self = [super init];
    if (self) {
        _title = LOCALIZE(@"support");
        _tip = LOCALIZE(@"support_tip");
        _items = [[NSMutableArray alloc] init];
        _items = @[[[PPMenuItem alloc] initWithLocalizedString:@"menu_item_call_us"
                                               withImageString:@"phone_i.png"
                                                    withIsPush:NO
                                                      andClass:nil],
                   [[PPMenuItem alloc] initWithLocalizedString:@"menu_item_write_to_us"
                                               withImageString:@"pen_i.png"
                                                    withIsPush:YES
                                                      andClass:[PPSupportTicketViewController class]]].mutableCopy;
    }
    return self;
}

- (instancetype)initFilsterGuideSettingsItems {
    self = [super init];
    if (self) {
        _title = LOCALIZE(@"filter_guide_settings");
        _tip = LOCALIZE(@"filter_guide_settings_tip");
        _items = [[NSMutableArray alloc] init];
        _items = @[[[PPMenuItem alloc] initWithLocalizedString:@"menu_item_choose_devices"
                                               withImageString:@"drone_i.png"
                                                    withIsPush:YES
                                                      andClass:[PPDevicesViewController class]],
                   [[PPMenuItem alloc] initWithLocalizedString:@"menu_item_choose_filters"
                                               withImageString:@"filter_i.png"
                                                    withIsPush:YES
                                                      andClass:[PPFiltersViewController class]],
                   [[PPMenuItem alloc] initWithLocalizedString:@"menu_item_help_with_guide"
                                               withImageString:@"info_i.png"
                                                    withIsPush:YES
                                                      andClass:[PPFilterGuideHelpViewController class]]].mutableCopy;
    }
    return self;
}

- (void)menuViewControllerActionWithTarget:(id)target
                                  andIndex:(NSUInteger)index {
    if (!_items [index].isPush) {
        switch (index) {
            case 0:
                //
                break;
            case 1:
                //
                break;
            case 2:
                //
                break;
            case 3:
                //
                break;
            case 4:
                //
                break;
            case 5:
                //
                break;
            default:
                //
                break;
        }
        return;
    }
    if (_items.count == 0 || !_items [index].viewControllerClass) {
        /*
        [((UINavigationController *)target) pushViewController:[[UIViewController alloc] init]
                                                      animated:NO];
        [((UINavigationController *)target).viewControllers.lastObject dismissViewControllerAnimated:YES
                                                                                          completion:nil];
         */
        return;
    }
    UIViewController *viewController = [_items [index].viewControllerClass alloc];
    switch (index) {
        case 0:
            viewController = [viewController init];
            break;
        case 1:
            viewController = [viewController init];
            break;
        case 2:
            viewController = [viewController init];
            break;
        case 3:
            viewController = [viewController init];
            break;
        case 4:
            viewController = [(PPSupportViewController *)viewController initWithViewControllerType:PPSupportViewCotrollerType];
            break;
        case 5:
            viewController = [(PPWebViewController *)viewController initWithURL:@"https://www.polarprofilters.com/pages/pro-team/"];
            break;
        default:
            //
            break;
    }
    /*
    [((UINavigationController *)target) pushViewController:viewController
                                                  animated:NO];
    [((UINavigationController *)target).viewControllers.lastObject dismissViewControllerAnimated:YES
                                                                                      completion:nil];
     */
    [((UIViewController *)target).navigationController pushViewController:viewController
                                                                 animated:YES];
}

- (void)supportViewControllerActionWithTarget:(id)target
                                     andIndex:(NSUInteger)index {
    if (!_items [index].isPush) {
        switch (index) {
            case 0: {
                
                /*
                PPAlertView *alertView = [[PPAlertView alloc] initWithTarget:((UIViewController *)target)];
                [alertView setDelegate:self];
                [alertView setTitle:LOCALIZE(@"main_phone_number")];
                [alertView setMessage:LOCALIZE(@"make_call")];
                PPActionButton *cancelActionButton = [PPActionButton actionButtonTypeCancelWithKey:@"cancel"];
                PPActionButton *callActionButton = [PPActionButton actionButtonTypeOkWithKey:@"call"];
                [callActionButton setCaption:LOCALIZE(@"call")];
                [alertView setActionButtons:@[cancelActionButton, callActionButton]];
                [alertView show];
                 */
                
                /*
                [EZAlertController alert:@"+1 (959) 220 9395"
                                 message:@"Make call?"
                                 buttons:@[LOCALIZE(@"cancel"),
                                           LOCALIZE(@"call")]
                                tapBlock:^(UIAlertAction * _Nonnull alertAction, NSInteger tag) {
                                    switch (tag) {
                                        case 0:
                                            break;
                                        case 1: {
                                            [(UIViewController *)target openSchemes:@[@"tel:+19492209395"]];
                                        }
                                            break;
                                        default:
                                            break;
                                    }
                                }];
                 */
                
                UIViewController *viewController = [[UIViewController alloc] init];
                [viewController openSchemes:@[@"tel:+19492209395"]];
            }
                break;
            case 1:
                //
                break;
            default:
                //
                break;
        }
        return;
    }
    if (_items.count == 0 || !_items [index].viewControllerClass) {
        [((UIViewController *)target).navigationController pushViewController:[[UIViewController alloc] init]
                                                                     animated:YES];
        return;
    }
    UIViewController *viewController = [_items [index].viewControllerClass alloc];
    switch (index) {
        case 0:
            //
            break;
        case 1:
            viewController = [viewController init];
            break;
        default:
            //
            break;
    }
    [((UIViewController *)target).navigationController pushViewController:viewController
                                                                 animated:YES];
}

- (void)filterGuideSettingsViewControllerActionWithTarget:(id)target
                                                 andIndex:(NSUInteger)index {
    if (!_items [index].isPush) {
        switch (index) {
            case 0:
                //
                break;
            case 1:
                //
                break;
            case 2:
                //
                break;
            default:
                //
                break;
        }
        return;
    }
    if (_items.count == 0 || !_items [index].viewControllerClass) {
        [((UIViewController *)target).navigationController pushViewController:[[UIViewController alloc] init]
                                                                     animated:YES];
        return;
    }
    UIViewController *viewController = [_items [index].viewControllerClass alloc];
    switch (index) {
        case 0:
            viewController = [viewController init];
            break;
        case 1:
            viewController = [viewController init];
            break;
        case 2:
            viewController = [viewController init];
            break;
        default:
            //
            break;
    }
    [((UIViewController *)target).navigationController pushViewController:viewController
                                                                 animated:YES];
}

/*
#pragma mark - PPAlertView

- (void)alertView:(PPAlertView *)alertView didActionWithActionButton:(PPActionButton *)actionButton {
    if ([actionButton.key isEqualToString:@"cancel"]) {
        //
    } else if ([actionButton.key isEqualToString:@"call"]) {
        UIViewController *viewController = [[UIViewController alloc] init];
        [viewController openSchemes:@[@"tel:+19492209395"]];
    }
}
 */

@end
