//
//  Macros.h
//  polarpro
//
//  Created by Владимир Псюкалов on 05.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define kStatusBarHeight (20.f)

#define APPLICATION ([UIApplication sharedApplication])

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(VERSION)  ([[[UIDevice currentDevice] systemVersion] compare:VERSION options:NSNumericSearch] != NSOrderedAscending)

#define RGBA(R, G, B, A) ([UIColor colorWithRed:R / 255.f green:G / 255.f blue:B / 255.f alpha:A / 255.f])
#define RGB(R, G, B) ([UIColor colorWithRed:R / 255.f green:G / 255.f blue:B / 255.f alpha:1.f])

#define WIDTH ([UIScreen mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define LOCALIZE(STRING) (NSLocalizedString(STRING, nil))

#define DEGREES_TO_RADIANS(DEGREES) (DEGREES * M_PI / 180.f)
#define RADIANS_TO_DEGREES(RADIANS) (RADIANS * 180.f / M_PI)

#define SYSTEM_VERSION_GRATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_GRATER_THAN_OR_EQUAL_TO_IOS_10 ([[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending)

// Macros for current project

#define MAIN_COLOR ([UIColor colorWithRed:32.f / 255.f green:36.f / 255.f blue:40.f / 255.f alpha:1.f])

#define kCellHeight (64.f)

#define kResultApiKey (@"RESULTS")

#define kAPIKey (@"7d020a55bd451a25") // Distribution key 7d020a55bd451a25, second key ec8905901bc0acfe, third key 00f2d00d96d04cee, 4th key 6c7712742bfa4a9b

#define kMaxWindSpeed (20.f) // Kilometer per second. // 36.f
#define kMinWindSpeed (0.f)

#define kMaxRotateWindDuration (28.f)
#define kMinRotateWindDuration (2.f) // 12.f

#define kMaxRotateKPDuration (28.f)
#define kMinRotateKPDuration (2.f)

#define kHourlyForecastCount (8)

#define kDay (24)
#define kWeek (5)
#define kKPIndexesInOneDay (8)
#define kMaxCityCount (5)
#define kUpdateInterval (1800)

#define kDegreeCharacter (@"\u00B0")

#define kMailgunAPIKey (@"key-10186dc7995f1d6072a103ac7701a9a6")
#define kMailgunBaseURL (@"https://api.mailgun.net/v3")
#define kMaingunDomainURL (@"sandbox1b81e5b3bc314ea689439d568d631d41.mailgun.org")

// Distribution Email - support@polarpro.com, development Email - psyukalov@gmail.com
#define kSupportEmail (@"support@polarpro.com")

#endif /* Macros_h */
