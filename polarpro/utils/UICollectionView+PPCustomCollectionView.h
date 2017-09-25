//
//  UICollectionView+PPCustomCollectionView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 19.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UICollectionView (PPCustomCollectionView)

- (void)fadeInOutVisibleCellsHidden:(BOOL)hidden
                           animated:(BOOL)animated;

@end
