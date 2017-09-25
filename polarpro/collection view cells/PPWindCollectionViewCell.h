//
//  PPWindCollectionViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 29.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "PPLocationsModel.h"


#define kWindCollectionViewCellRI (@"PPWindCollectionViewCell")


@interface PPWindCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) PPLocation *location;

- (void)playAnimation;
- (void)stopAnimation;

@end
