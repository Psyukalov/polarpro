//
//  PPStartView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 20.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@protocol PPStartViewDelegate <NSObject>

- (void)didCompleteStartAnimation;

@end


@interface PPStartView : UIView

@property (weak, nonatomic) id<PPStartViewDelegate> delegate;

- (void)play;
- (void)stop;

@end
