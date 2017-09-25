//
//  UITableView+PPCustomHeaderFooterView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 11.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "UITableView+PPCustomHeaderFooterView.h"

#import "Macros.h"


@implementation UITableView (PPCustomHeaderFooterView)

- (void)applySettings {
    [self applyScrollingEnable];
    [self setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)applyScrollingEnable {
    if (self.delegate) {
        self.scrollEnabled = self.contentSize.height >= self.frame.size.height - self.tableHeaderView.frame.size.height;
    }
}

- (void)applyHeaderViewWithString:(nonnull NSString *)string
                       andPadding:(CGPadding)padding {
    UILabel *label = [[UILabel alloc] init];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setNumberOfLines:0];
    [label setTextColor:RGB(78.f, 84.f, 94.f)];
    [label setFont:[UIFont fontWithName:@"Montserrat-ExtraLightItalic"
                                   size:14.f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:string];
    [label sizeToFit];
    [label sizeThatFits:CGSizeMake(WIDTH - (padding.left + padding.right), FLT_MAX)];
    [label setFrame:CGRectMake(padding.left, padding.top, WIDTH - (padding.left + padding.right), label.frame.size.height)];
    CGRect frame = CGRectMake(0.f, 0.f, WIDTH, label.frame.size.height + padding.top + padding.bottom);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [self setTableHeaderView:view];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableHeaderView addSubview:label];
    [self.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.tableHeaderView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.f
                                                                      constant:padding.left]];
    [self.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.tableHeaderView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.f
                                                                      constant:padding.top]];
    [self.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.tableHeaderView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.f
                                                                      constant:-padding.right]];
    [self.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.tableHeaderView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.f
                                                                      constant:-padding.bottom]];
}

- (void)fadeInOutVisibleCellsHidden:(BOOL)hidden
                           animated:(BOOL)animated {
    self.hidden = hidden && !animated;
    CGFloat alpha = hidden ? 0.f : 1.f;
    CGAffineTransform transform = hidden ? CGAffineTransformMakeScale(.92f, .92f) : CGAffineTransformMakeScale(1.f, 1.f);
    if (self.visibleCells.count > 0) {
        for (NSUInteger i = 0; i <= self.visibleCells.count - 1; i++) {
            UITableViewCell *cell = self.visibleCells[i];
            if (animated) {
                [UIView animateWithDuration:.6f
                                      delay:i * .08f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [cell setAlpha:alpha];
                                     [cell setTransform:transform];
                                 }
                                 completion:^(BOOL finished) {
                                     //
                                 }];
            } else {
                [cell setAlpha:alpha];
                [cell setTransform:transform];
            }
        }
    }
}

@end
