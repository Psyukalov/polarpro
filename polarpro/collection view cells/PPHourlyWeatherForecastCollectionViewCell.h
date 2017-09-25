//
//  PPHourlyWeatherForecastCollectionViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 21.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


#define kHourlyWeatherForecastCollectionViewCellRI (@"PPHourlyWeatherForecastCollectionViewCell")


@interface PPHourlyWeatherForecastCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *icon;

@property (assign, nonatomic) CGFloat temperature;

@end
