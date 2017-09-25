//
//  AppDelegate.h
//  polarpro
//
//  Created by Владимир Псюкалов on 05.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>

#import <UserNotifications/UserNotifications.h>


@protocol AppListener <NSObject>

@optional

- (void)didEnterForeground;

@end


@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) id<AppListener> listener;

@property (strong, nonatomic) UIWindow *window;

@end
