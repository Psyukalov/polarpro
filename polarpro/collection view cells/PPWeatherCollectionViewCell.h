//
//  PPWeatherCollectionViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 20.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "PPLocationsModel.h"


#define kWeatherCollectionViewCellRI (@"PPWeatherCollectionViewCell")


@interface PPWeatherCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) PPLocation *location;

@end
