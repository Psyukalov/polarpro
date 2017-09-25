//
//  VPDraggableCollectionView.m
//
//  Created by Vladimir Psyukalov on 29.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "VPDraggableCollectionView.h"


@implementation VPDraggableCollectionView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [gestureRecognizer addTarget:self
                          action:@selector(longPressGestureRecognizer:)];
    [self addGestureRecognizer:gestureRecognizer];
}

- (void)longPressGestureRecognizer:(UILongPressGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    static UIView *snapshot = nil;
    static NSIndexPath *sourceIndexPath = nil;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                if ([self checkDelegate] && [_draggableDelegate respondsToSelector:@selector(collectionView:canDragCellAtIndexPath:)]) {
                    if (![_draggableDelegate collectionView:self
                                     canDragCellAtIndexPath:indexPath]) {
                        [sender setEnabled:NO];
                        [sender setEnabled:YES];
                        return;
                    }
                }
                if ([self checkDelegate] && [_draggableDelegate respondsToSelector:@selector(collectionView:didLongPressCellAtIndexPath:)]) {
                    [_draggableDelegate collectionView:self
                           didLongPressCellAtIndexPath:indexPath];
                }
                UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
                [self setUserInteractionEnabled:NO];
                snapshot = [self snapshotWithView:cell];
                __block CGPoint center = cell.center;
                [snapshot setCenter:center];
                [snapshot setAlpha:0.f];
                [self addSubview:snapshot];
                [UIView animateWithDuration:.16f
                                 animations:^{
                                     center.y = point.y;
                                     center.x = point.x;
                                     [snapshot setCenter:center];
                                     [snapshot setTransform:CGAffineTransformMakeScale(1.02f, 1.02f)];
                                     [snapshot setAlpha:.8f];
                                     [cell setAlpha:0.f];
                                     [cell setHidden:YES];
                                 }];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = point.y;
            center.x = point.x;
            snapshot.center = center;
            if (indexPath && indexPath != sourceIndexPath) {
                if ([self checkDelegate] && [_draggableDelegate respondsToSelector:@selector(collectionView:canDragCellAtIndexPath:)]) {
                    if (![_draggableDelegate collectionView:self
                                     canDragCellAtIndexPath:indexPath]) {
                        return;
                    }
                }
                if ([self checkDelegate] && [_draggableDelegate respondsToSelector:@selector(collectionView:dragCellFromSourceIndexPath:toIndexPath:)]) {
                    [_draggableDelegate collectionView:self
                           dragCellFromSourceIndexPath:sourceIndexPath
                                           toIndexPath:indexPath];
                }
                [self moveItemAtIndexPath:sourceIndexPath
                              toIndexPath:indexPath];
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: {
            UICollectionViewCell *cell = [self cellForItemAtIndexPath:sourceIndexPath];
            [cell setAlpha:0.f];
            [UIView animateWithDuration:.16f
                             animations:^{
                                 snapshot.center = cell.center;
                                 [snapshot setTransform:CGAffineTransformIdentity];
                                 [snapshot setAlpha:0.f];
                                 [cell setAlpha:1.f];
                             }
                             completion:^(BOOL finished) {
                                 [cell setHidden:NO];
                                 [snapshot removeFromSuperview];
                                 // TODO: Removed method reload data.
                                 [self setUserInteractionEnabled:YES];
                                 if ([self checkDelegate] && [_draggableDelegate respondsToSelector:@selector(collectionView:didCancelLongPressCellAtIndexPath:)]) {
                                     [_draggableDelegate collectionView:self
                                      didCancelLongPressCellAtIndexPath:sourceIndexPath];
                                 }
                                 snapshot = nil;
                                 sourceIndexPath = nil;
                             }];
            break;
        }
    }
}

#pragma mark - Other methods

- (BOOL)checkDelegate {
    if (!_draggableDelegate || ![_draggableDelegate conformsToProtocol:@protocol(VPDraggableCollectionViewDelegate)]) {
        return NO;
    }
    return YES;
}

- (UIView *)snapshotWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    [snapshot.layer setMasksToBounds:NO];
    [snapshot.layer setCornerRadius:0.f];
    [snapshot.layer setShadowOffset:CGSizeMake(-4.f, 0.f)];
    [snapshot.layer setShadowRadius:4.f];
    [snapshot.layer setShadowOpacity:.4f];
    return snapshot;
}

@end
