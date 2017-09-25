//
//  PPGoldenHourViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 22.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPGoldenHourViewController.h"

#import "AppDelegate.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "iCarousel.h"
#import "VPPageControl.h"
#import "VPTimer.h"
#import "VPRefreshControl.h"
#import "VPBarButtonItem.h"
#import <UserNotifications/UserNotifications.h>
#import "PPUser.h"

#import "PPSunriseView.h"
#import "PPSunsetView.h"

#import "PPGoldenHourItemView.h"

#import "PPCustomSettingsViewController.h"

#import "PPLocationsModel.h"

#import "PPAlertView.h"


@interface PPGoldenHourViewController () <iCarouselDataSource, iCarouselDelegate, PPCustomSettingsViewControllerDelegate, PPAlertViewDelegate, AppListener, UIScrollViewDelegate, VPRefreshControlDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet iCarousel *carouselView;

@property (weak, nonatomic) IBOutlet VPPageControl *pageControl;

@property (weak, nonatomic) IBOutlet VPRefreshControl *refreshControl;

@property (strong, nonatomic) PPLocationsModel *locationModel;

@property (strong, nonatomic) VPBarButtonItem *notificationBBI;

@property (strong, nonatomic) UNUserNotificationCenter *center;

@end


@implementation PPGoldenHourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupDidAppear];
    [((AppDelegate *)[APPLICATION delegate]) setListener:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!_locationModel.useCurrentLocation && _locationModel.locations.count > 1) {
        if (_carouselView.currentItemIndex != 0) {
            NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:_carouselView.currentItemIndex
                                                              inSection:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                        inSection:0];
            [_locationModel m_replaceLocationFromSourceIndexPath:sourceIndexPath
                                                     toIndexPath:indexPath];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [((AppDelegate *)[APPLICATION delegate]) setListener:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setup {
    _center = [UNUserNotificationCenter currentNotificationCenter];
    [_center setDelegate:(AppDelegate *)[UIApplication sharedApplication].delegate];
    [_scrollView setAlwaysBounceVertical:YES];
    [_refreshControl setDelegate:self];
    [_refreshControl setFreezeThenStart:YES];
    _locationModel = [PPLocationsModel sharedModel];
    [self.navigationItem setTitle:LOCALIZE(@"golden_hour")];
    [self.view setBackgroundColor:MAIN_COLOR];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createBackBBI];
    [self createSettingsBBI];
    [_pageControl setAlpha:0.f];
    [self.navigationItem.rightBarButtonItem setAction:@selector(settingsBBI_TUI)];
    [_pageControl setIndexForImage:0];
    [_pageControl setDefaultImage:[UIImage imageNamed:@"geo_dot_default_i.png"]];
    [_pageControl setSelectedImage:[UIImage imageNamed:@"geo_dot_selected_i.png"]];
    [_pageControl setPageIndicatorTintColor:RGB(46.f, 62.f, 70.f)];
    [_pageControl setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
    [_carouselView setDataSource:self];
    [_carouselView setDelegate:self];
    [_carouselView setDecelerationRate:.64f];
    [_carouselView setBounces:NO];
    [self setupNotificationBBI];
}

- (void)setupDidAppear {
    [self applyLocationsCount];
    if (_locationModel.locations.count == 0) {
        PPAlertView *alertView = [[PPAlertView alloc] initWithTarget:self];
        [alertView setTitle:LOCALIZE(@"no_locations_title")];
        [alertView setMessage:LOCALIZE(@"no_locations_message")];
        [alertView setDelegate:self];
        [alertView setActionButtons:@[[PPActionButton actionButtonTypeCancelWithKey:@"cancel"],
                                      [PPActionButton actionButtonTypeOkWithKey:@"ok"]]];
        [alertView show];
    }
    if (_pageControl.alpha == 0.f) {
        [UIView animateWithDuration:.6f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_pageControl setAlpha:1.f];
                         }
                         completion:nil];
    }
    [self checkLocalNotification];
}

- (void)setupNotificationBBI {
    _notificationBBI = [[VPBarButtonItem alloc] initWithDefaultImage:[UIImage imageNamed:@"notification_bbi.png"]
                                                    andSelectedImage:[UIImage imageNamed:@"notification_bbi_selected.png"]];
    [_notificationBBI setTarget:self];
    [_notificationBBI setAction:@selector(notificationBBI_TUI)];
    [self.navigationItem setRightBarButtonItems:@[self.navigationItem.rightBarButtonItem,
                                                  _notificationBBI]];
}

#pragma mark - iCarouselDataSource, iCarouselDelegate

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return _locationModel.locations.count;
}

- (UIView *)carousel:(iCarousel *)carousel
  viewForItemAtIndex:(NSInteger)index
         reusingView:(UIView *)view {
    if (!view) {
        view = [[PPGoldenHourItemView alloc] initWithFrame:carousel.bounds];
    }
    PPGoldenHourItemView *goldenHourItemView = (PPGoldenHourItemView *)view;
    if (_locationModel.locations.count > 0 && index <= _locationModel.locations.count - 1) {
        [goldenHourItemView setLocation:_locationModel.locations[index]];
    }
    return goldenHourItemView;
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    [_pageControl setCurrentPage:carousel.currentItemIndex];
    [_notificationBBI setEnabled:NO];
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel {
    [self checkLocalNotification];
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self checkLocalNotification];
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    [self checkLocalNotification];
}

- (void)checkLocalNotification {
    
    PPLocation *location = _locationModel.locations[_carouselView.currentItemIndex];
    
    if (location.astronomy.isPolarDayOrNight) {
        return;
    }
    
    if (SYSTEM_VERSION_GRATER_THAN_OR_EQUAL_TO_IOS_10) {
        
        [_center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_notificationBBI setEnabled:YES];
                [_notificationBBI setSelected:NO];
                for (UNNotificationRequest *request in requests) {
                    if ([request.identifier isEqualToString:location.zmw] ||
                        [request.identifier isEqualToString:[NSString stringWithFormat:@"%@_20", location.zmw]]) {
                        [_notificationBBI setSelected:YES];
                        break;
                    }
                }
            });
        }];
        
    } else {
        
        [_notificationBBI setEnabled:YES];
        [_notificationBBI setSelected:NO];
        for (UILocalNotification *localNotification in APPLICATION.scheduledLocalNotifications) {
            if ([location.zmw isEqualToString:localNotification.userInfo[@"zmw"]]) {
                [_notificationBBI setSelected:YES];
                break;
            }
        }
        
    }
    
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionVisibleItems:
            return 3;
            break;
        case iCarouselOptionSpacing:
            return 1.68f * value;
            break;
        default:
            return value;
            break;
    }
}

#pragma mark - Actions

- (void)notificationBBI_TUI {
    
    PPLocation *location = _locationModel.locations[_carouselView.currentItemIndex];
    if (location.astronomy.isPolarDayOrNight) {
        return;
    }
    
    [_notificationBBI setSelected:!_notificationBBI.selected];
    
    if (_notificationBBI.selected) {
        
        PPAstronomy *astronomy = location.astronomy;
        
        VPTime *duration = [[VPTime alloc] initWithInterval:[astronomy.nearestGoldenHour intervalFromTime:astronomy.nearestGoldenHourEnd]];
        
        NSString *body = [NSString stringWithFormat:@"%@. %@: %@. %@: %@. %@: %@ %@",
                          location.name,
                          LOCALIZE(@"start"),
                          [astronomy.nearestGoldenHour textWithTimeFormat:VPTimeHoursAndMinutesFormat],
                          LOCALIZE(@"finish"),
                          [astronomy.nearestGoldenHourEnd textWithTimeFormat:VPTimeHoursAndMinutesFormat],
                          LOCALIZE(@"duration"),
                          [duration textWithTimeFormat:VPTimeMinutesFormat],
                          LOCALIZE(@"min")];
        
        NSLog(@"Local notification body: %@;", body);
        
        NSInteger interval = astronomy.intervalToGoldenHour - 1200;
        
        if (SYSTEM_VERSION_GRATER_THAN_OR_EQUAL_TO_IOS_10) {
            
            NSLog(@"Notification request for iOS 10;");
            
            [_center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                        [self showDisabledPushNotificationsAlert];
                        [_notificationBBI setSelected:NO];
                    }
                });
            }];
            
            [_center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
                                   completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                       if (granted && !error) {
                                           
                                           if (interval > 0) {
                                               
                                               UNMutableNotificationContent *notifictionContent_20_min = [[UNMutableNotificationContent alloc] init];
                                               notifictionContent_20_min.title = LOCALIZE(@"notification_title_20_min");
                                               notifictionContent_20_min.body = body;
                                               notifictionContent_20_min.sound = [UNNotificationSound defaultSound];
                                               
                                               NSDateComponents *dateComponents = [self dateComponentsWithDate:[[NSDate date] dateByAddingTimeInterval:interval]];
                                               UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents
                                                                                                                                                 repeats:NO];
                                               
                                               UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"%@_20", location.zmw]
                                                                                                                     content:notifictionContent_20_min
                                                                                                                     trigger:trigger];
                                               
                                               [_center addNotificationRequest:request
                                                         withCompletionHandler:^(NSError * _Nullable error) {
                                                             if (!error) {
                                                                 NSLog(@"iOS 10 local notification (20 min) created;");
                                                             } else {
                                                                 NSLog(@"iOS 10 local notification (20 min) not created; Error: %@;", error.localizedDescription);
                                                             }
                                                         }];
                                               
                                           }
                                           
                                           UNMutableNotificationContent *notifictionContent = [[UNMutableNotificationContent alloc] init];
                                           notifictionContent.title = LOCALIZE(@"notification_title_now");
                                           notifictionContent.body = body;
                                           notifictionContent.sound = [UNNotificationSound defaultSound];
                                           
                                           NSDateComponents *dateComponents = [self dateComponentsWithDate:[[NSDate date] dateByAddingTimeInterval:astronomy.intervalToGoldenHour]];
                                           UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents
                                                                                                                                             repeats:NO];
                                           
                                           UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:location.zmw
                                                                                                                 content:notifictionContent
                                                                                                                 trigger:trigger];
                                           
                                           [_center addNotificationRequest:request
                                                     withCompletionHandler:^(NSError * _Nullable error) {
                                                         if (!error) {
                                                             NSLog(@"iOS 10 local notification created;");
                                                         } else {
                                                             NSLog(@"iOS 10 local notification not created; Error: %@;", error.localizedDescription);
                                                         }
                                                     }];
                                           
                                       }
                                   }];
            
        } else {
            
            NSLog(@"Notification request for iOS 9;");
            
            UIUserNotificationSettings *setting = [APPLICATION currentUserNotificationSettings];
            BOOL registred = setting.types != UIUserNotificationTypeNone;
            if (!registred) {
                [self showDisabledPushNotificationsAlert];
                [_notificationBBI setSelected:NO];
                return;
            }
            
            if (interval > 0) {
                UILocalNotification *localNotification_20_min = [[UILocalNotification alloc] init];
                NSDate *date_20_min = [[NSDate date] dateByAddingTimeInterval:interval];
                localNotification_20_min.fireDate = date_20_min;
                localNotification_20_min.alertTitle = LOCALIZE(@"notification_title_20_min");
                localNotification_20_min.alertBody = body;
                localNotification_20_min.timeZone = [NSTimeZone defaultTimeZone];
                localNotification_20_min.userInfo = @{@"zmw" : location.zmw};
                [APPLICATION scheduleLocalNotification:localNotification_20_min];
            }
            
            UILocalNotification *localNotificationNow = [[UILocalNotification alloc] init];
            NSDate *dateNow = [[NSDate date] dateByAddingTimeInterval:astronomy.intervalToGoldenHour];
            localNotificationNow.fireDate = dateNow;
            localNotificationNow.alertTitle = LOCALIZE(@"notification_title_now");
            localNotificationNow.alertBody = body;
            localNotificationNow.timeZone = [NSTimeZone defaultTimeZone];
            localNotificationNow.userInfo = @{@"zmw" : location.zmw};
            [APPLICATION scheduleLocalNotification:localNotificationNow];
            
        }
        
    } else {
        
        if (SYSTEM_VERSION_GRATER_THAN_OR_EQUAL_TO_IOS_10) {
            
            [_center removePendingNotificationRequestsWithIdentifiers:@[location.zmw]];
            [_center removePendingNotificationRequestsWithIdentifiers:@[[NSString stringWithFormat:@"%@_20", location.zmw]]];
            
        } else {
            
            for (UILocalNotification *localNotification in APPLICATION.scheduledLocalNotifications) {
                if ([location.zmw isEqualToString:localNotification.userInfo[@"zmw"]]) {
                    [APPLICATION cancelLocalNotification:localNotification];
                }
            }
            
        }
        
    }
}

- (void)settingsBBI_TUI {
    PPCustomSettingsViewController *settingVC = [[PPCustomSettingsViewController alloc] initWithType:PPSettingsTypeGoldenHour];
    [settingVC setDelegate:self];
    [self.navigationController pushViewController:settingVC
                                         animated:YES];
}

#pragma mark - PPCustomSettingsViewControllerDelegate

- (void)didUpdateSettings {
    [_carouselView reloadData];
    [self applyLocationsCount];
    [_pageControl setAlpha:0.f];
}

#pragma mark - Other methods

- (void)applyLocationsCount {
    [_pageControl setUseIndexForImage:(_locationModel.useCurrentLocation && _locationModel.currentLocation)];
    if (_locationModel.locations.count != 0) {
        [_pageControl setNumberOfPages:_locationModel.locations.count];
        [_pageControl setCurrentPage:_carouselView.currentItemIndex];
    }
}

#pragma mark - PPAlertViewDelegate

- (void)alertView:(PPAlertView *)alertView didActionWithActionButton:(PPActionButton *)actionButton {
    if ([actionButton.key isEqualToString:@"ok"]) {
        [self settingsBBI_TUI];
    } else if ([actionButton.key isEqualToString:@"cancel"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - AppListener

- (void)didEnterForeground {
    
    /* Disabled  in this screen;
     
     [self setupDidAppear];
     [_carouselView reloadData];
     
     */
    
}

#pragma mark - UIScrollViewDelegate & VPRefreshControlDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshControl fadeInOutWithScrollView:scrollView];
}

- (void)didStartRefreshControl:(VPRefreshControl *)refreshControl {
    [_locationModel clearAll];
    [_carouselView reloadData];
    [self performSelector:@selector(stopRefreshControl)
               withObject:nil
               afterDelay:1.f];
}

- (void)stopRefreshControl {
    [_refreshControl endAnimating];
}

#pragma mark - Other methods

- (NSDateComponents *)dateComponentsWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay |
                                                             NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond |
                                                             NSCalendarUnitTimeZone)
                                                   fromDate:date];
    return dateComponents;
}

- (void)showDisabledPushNotificationsAlert {
    PPAlertView *alertView = [[PPAlertView alloc] initWithTarget:self];
    [alertView setTitle:LOCALIZE(@"this_app_not_allow_to_use_push_notification_title")];
    [alertView setMessage:LOCALIZE(@"this_app_not_allow_to_use_push_notification_message")];
    [alertView setActionButtons:@[[PPActionButton actionButtonTypeOkWithKey:@"ok"]]];
    [alertView show];
}

@end
