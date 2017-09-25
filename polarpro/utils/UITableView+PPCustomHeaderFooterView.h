//
//  UITableView+PPCustomHeaderFooterView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 11.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


typedef struct CGPadding {
    CGFloat left;
    CGFloat top;
    CGFloat right;
    CGFloat bottom;
} CGPadding;

CG_INLINE CGPadding
CGPaddingMake(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom) {
    CGPadding padding;
    padding.left = left;
    padding.top = top;
    padding.right = right;
    padding.bottom = bottom;
    return padding;
}

CG_INLINE CGPadding
CGPaddingZero() {
    CGPadding padding;
    padding = CGPaddingMake(0.f, 0.f, 0.f, 0.f);
    return padding;
}

@interface UITableView (PPCustomHeaderFooterView)

- (void)applySettings;
- (void)applyScrollingEnable;

- (void)applyHeaderViewWithString:(nonnull NSString *)string
                       andPadding:(CGPadding)padding;

- (void)fadeInOutVisibleCellsHidden:(BOOL)hidden
                           animated:(BOOL)animated;

@end
