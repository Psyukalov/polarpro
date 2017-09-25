//
//  UICollectionView+PPCustomCollectionView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 19.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "UICollectionView+PPCustomCollectionView.h"


@implementation UICollectionView (PPCustomCollectionView)

- (void)fadeInOutVisibleCellsHidden:(BOOL)hidden
                           animated:(BOOL)animated {
    [self setHidden:hidden && !animated];
    if (self.visibleCells.count == 0) {
        return;
    }
    NSArray <NSIndexPath *> *indexPaths = [self indexPathsForVisibleItems];
    CGFloat alpha = hidden ? 0.f : 1.f;
    CGAffineTransform transform = hidden ? CGAffineTransformMakeScale(.92f, .92f) : CGAffineTransformIdentity;
    for (NSUInteger i = 0; i <= self.visibleCells.count - 1; i++) {
        UICollectionViewCell *cell = self.visibleCells[indexPaths[i].row];
        if (animated) {
            [UIView animateWithDuration:.4f
                                  delay:i * .08f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [cell setAlpha:alpha];
                                 [cell setTransform:transform];
                             }
                             completion:nil];
        } else {
            [cell setAlpha:alpha];
            [cell setTransform:transform];
        }
    }
}

@end
