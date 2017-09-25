//
//  PPLocalNotification.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 12.09.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPLocalNotification.h"


@implementation PPLocalNotification

- (void)setZmw:(NSString *)zmw {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:zmw
                     forKey:@"zmw"];
    if ([userDefaults synchronize]) {
        _zmw = zmw;
    }
}

- (NSString *)name {
    if (!_zmw) {
        _zmw = [[NSUserDefaults standardUserDefaults] stringForKey:@"zmw"];
    }
    return _zmw;
}

@end
