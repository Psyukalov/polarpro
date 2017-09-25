//
//  PPSettingsViewController.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 12.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, PPSettingsType) {
    PPSettingsTypeNone = 0,
    PPSettingsTypeGoldenHour,
    PPSettingsTypeWeatherForecast,
    PPSettingsTypeWindCondition
};


@protocol PPSettingsViewControllerDelegate <NSObject>

- (void)didUpdateSettings;

@end


@interface PPSettingsViewController : UIViewController

@property (weak, nonatomic) id<PPSettingsViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (instancetype)initWithType:(PPSettingsType)type;

@end
