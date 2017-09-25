//
//  PPWeatherForecastTableViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 21.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


#define kWeatherForecastTableViewCellRI (@"PPWeatherForecastTableViewCell")


@interface PPWeatherForecastTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *weekday;
@property (strong, nonatomic) NSString *icon;

@property (assign, nonatomic) CGFloat maxTemperature;
@property (assign, nonatomic) CGFloat minTemperature;

@end
