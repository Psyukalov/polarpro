//
//  VPRefreshControl.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 28.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@class VPRefreshControl;


@protocol VPRefreshControlDelegate <NSObject>

@optional

- (void)didStartRefreshControl:(VPRefreshControl *)refreshControl;

@end


@interface VPRefreshControl : UIView

@property (weak, nonatomic) id<VPRefreshControlDelegate> delegate;

@property (assign, nonatomic) BOOL freezeThenStart;

- (void)fadeInOutWithScrollView:(UIScrollView *)scrollView;

- (void)endAnimating;

@end
