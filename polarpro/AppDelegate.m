//
//  AppDelegate.m
//  polarpro
//
//  Created by Владимир Псюкалов on 05.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "AppDelegate.h"

#import "Macros.h"
#import "VPNavigationController.h"
#import "VPTimer.h"

#import "PPHubViewController.h"

#import "PPLocationsModel.h"
#import "PPGeomagneticStormModel.h"


@interface AppDelegate ()

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setup];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [((PPLocationsModel *)[PPLocationsModel sharedModel]) clearAll];
    [((PPLocationsModel *)[PPLocationsModel sharedModel]) stopUpdatingLocation];
    [((PPGeomagneticStormModel *)[PPGeomagneticStormModel sharedModel]) stopTimersAndClear];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [((PPLocationsModel *)[PPLocationsModel sharedModel]) startUpdatingLocation];
    if (_listener) {
        if ([_listener conformsToProtocol:@protocol(AppListener)] &&
            [_listener respondsToSelector:@selector(didEnterForeground)]) {
            [_listener didEnterForeground];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //
}

- (void)setup {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setBackgroundColor:MAIN_COLOR];
    PPHubViewController *hubVC = [[PPHubViewController alloc] init];
    VPNavigationController *navigationController = [[VPNavigationController alloc] initWithRootViewController:hubVC];
    [navigationController.navigationBar setBarTintColor:MAIN_COLOR];
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [navigationController.navigationBar setTranslucent:NO];
    [navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                            forBarPosition:UIBarPositionAny
                                                barMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"Notification iOS 10 - Foreground;");
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response
         withCompletionHandler:(nonnull void (^)(void))completionHandler {
    NSLog(@"Notification iOS 10 - Background;");
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"Notification iOS 9;");
    
}

@end
