//
//  CCView.h
//
//
//  Created by Vladimir Psyukalov on 01.10.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface CCView : UIView

@property (strong, nonatomic) UIView *contentView;

- (void)loadViewFromNib;

@end
