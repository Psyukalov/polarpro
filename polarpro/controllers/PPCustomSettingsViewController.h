//
//  PPCustomSettingsViewController.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 13.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPLocationsViewController.h"

#import "PPSettingsViewController.h"


@protocol PPCustomSettingsViewControllerDelegate <NSObject>

@optional

- (void)didUpdateSettings;

@end


@interface PPCustomSettingsViewController : PPLocationsViewController

@property (strong, nonatomic) id<PPCustomSettingsViewControllerDelegate> delegate;

- (instancetype)initWithType:(PPSettingsType)type;

@end
