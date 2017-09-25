//
//  VPPageControl.m
//
//  Created by Vladimir Psyukalov on 20.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "VPPageControl.h"


@implementation VPPageControl



- (void)setCurrentPage:(NSInteger)currentPage {
    [super setCurrentPage:currentPage];
    UIImageView *dotImage = [self imageViewFromView:self.subviews[_indexForImage]];
    if (!_useIndexForImage) {
        self.subviews[_indexForImage].backgroundColor = (_indexForImage == self.currentPage) ? self.currentPageIndicatorTintColor : self.pageIndicatorTintColor;
        [dotImage setHidden:YES];
    } else {
        for (NSUInteger i = 0; i <= self.subviews.count - 1; i++) {
            if (i == _indexForImage) {
                [self.subviews[i] setBackgroundColor:[UIColor clearColor]];
            } else {
                self.subviews[i].backgroundColor = (i == self.currentPage) ? self.currentPageIndicatorTintColor : self.pageIndicatorTintColor;
            }
        }
        if (_indexForImage == self.currentPage) {
            [dotImage setImage:_selectedImage];
        } else {
            [dotImage setImage:_defaultImage];
        }
        [dotImage setHidden:NO];
    }
}

- (UIImageView *)imageViewFromView:(UIView *)view {
    UIImageView *imageView;
    if ([view isKindOfClass:[UIView class]]) {
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                imageView = (UIImageView *)subview;
                break;
            }
        }
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, view.frame.size.width, view.frame.size.height)];
            [view addSubview:imageView];
        }
    } else {
        imageView = (UIImageView *)view;
    }
    return imageView;
}

@end
