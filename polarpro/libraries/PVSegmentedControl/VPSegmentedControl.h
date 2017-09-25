//
//  VPSegmentedControl.h
//
//  Created by Vladimir Psyukalov on 12.05.17.
//  Copyright © 2017 Vladimir Psyukalov. All rights reserved.
//


#import <UIKit/UIKit.h>


@class VPSegmentedControl;


@protocol VPSegmentedControlDelegate <NSObject>

@required

- (NSUInteger)numberOfItemsInSegmentedControl:(VPSegmentedControl *)segmentedControl;

- (UIButton *)segmentedControl:(VPSegmentedControl *)segmentedControl
               buttonWithIndex:(NSUInteger)index;

@optional

- (void)segmentedControl:(VPSegmentedControl *)segmentedControl didTouchUpInsideButtonWithIndex:(NSUInteger)index;

@end


@interface VPSegmentedControl : UIView

@property (strong, nonatomic) id<VPSegmentedControlDelegate> delegate;

@property (assign, nonatomic) NSUInteger selectedSegment;

- (void)reloadData;

@end
