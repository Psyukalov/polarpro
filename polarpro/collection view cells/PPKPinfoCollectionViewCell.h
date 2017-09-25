//
//  PPKPinfoCollectionViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 29.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


#define kKPInfoCollectionViewCellRI (@"PPKPinfoCollectionViewCell")


@interface PPKPinfoCollectionViewCell : UICollectionViewCell

- (void)updateCell;

- (void)playAnimation;
- (void)stopAnimation;

@end
