//
//  VPDraggableCollectionView.h
//
//  Created by Vladimir Psyukalov on 29.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@class VPDraggableCollectionView;


@protocol VPDraggableCollectionViewDelegate <NSObject>

@required

- (void)collectionView:(VPDraggableCollectionView *)collectionView dragCellFromSourceIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)indexPath;

@optional

- (void)collectionView:(VPDraggableCollectionView *)collectionView didLongPressCellAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(VPDraggableCollectionView *)collectionView didCancelLongPressCellAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)collectionView:(VPDraggableCollectionView *)collectionView canDragCellAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface VPDraggableCollectionView : UICollectionView

@property (strong, nonatomic) id<VPDraggableCollectionViewDelegate> draggableDelegate;

@end
