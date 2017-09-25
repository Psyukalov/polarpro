//
//  PPWindProctatorView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 01.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface PPWindProctatorView : UIImageView

@property (assign, nonatomic) CGFloat direction;

- (void)setDirection:(CGFloat)direction
            animated:(BOOL)animated;

- (void)setDirection:(CGFloat)direction
            animated:(BOOL)animated
          completion:(void (^)(BOOL finished))completion;

@end
