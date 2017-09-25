//
//  VPDraggableTableView.m
//
//  Created by Vladimir Psyukalov on 16.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "VPDraggableTableView.h"


@implementation VPDraggableTableView

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
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:point];
    static UIView *snapshot = nil;
    static NSIndexPath *sourceIndexPath = nil;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                if ([self checkDelegate] && [_draggableDelegate respondsToSelector:@selector(tableView:canDragCellAtIndexPath:)]) {
                    if (![_draggableDelegate tableView:self
                                canDragCellAtIndexPath:indexPath]) {
                        [sender setEnabled:NO];
                        [sender setEnabled:YES];
                        return;
                    }
                }
                UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
                [self setUserInteractionEnabled:NO];
                snapshot = [self snapshotWithView:cell];
                __block CGPoint center = cell.center;
                [snapshot setCenter:center];
                [snapshot setAlpha:0.f];
                [self insertSubview:snapshot
                       belowSubview:self.tableHeaderView];
                [UIView animateWithDuration:.16f
                                 animations:^{
                                     center.y = point.y;
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
            snapshot.center = center;
            if (indexPath && indexPath != sourceIndexPath) {
                if ([self checkDelegate] && [_draggableDelegate respondsToSelector:@selector(tableView:canDragCellAtIndexPath:)]) {
                    if (![_draggableDelegate tableView:self
                                canDragCellAtIndexPath:indexPath]) {
                        return;
                    }
                }
                if ([self checkDelegate] && [_draggableDelegate respondsToSelector:@selector(tableView:dragCellFromSourceIndexPath:toIndexPath:)]) {
                    [_draggableDelegate tableView:self
                      dragCellFromSourceIndexPath:sourceIndexPath
                                      toIndexPath:indexPath];
                }
                [self moveRowAtIndexPath:sourceIndexPath
                             toIndexPath:indexPath];
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: {
            UITableViewCell *cell = [self cellForRowAtIndexPath:sourceIndexPath];
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
                                 [self reloadData];
                                 [self setUserInteractionEnabled:YES];
                                 snapshot = nil;
                                 sourceIndexPath = nil;
                             }];
            break;
        }
    }
}

#pragma mark - Other methods

- (BOOL)checkDelegate {
    if (!_draggableDelegate || ![_draggableDelegate conformsToProtocol:@protocol(VPDraggableTableViewDelegate)]) {
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
