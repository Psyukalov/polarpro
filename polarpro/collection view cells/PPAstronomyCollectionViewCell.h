//
//  PPAstronomyCollectionViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 22.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "PPLocationsModel.h"


#define kAstronomyCollectionViewCellRI (@"PPAstronomyCollectionViewCell")


@interface PPAstronomyCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) PPLocation *location;

@end
