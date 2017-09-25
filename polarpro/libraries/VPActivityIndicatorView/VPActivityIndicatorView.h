//
//  VPActivityIndicatorView.h
//
//  Created by Vladimir Psyukalov on 26.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface VPActivityIndicatorView : UIImageView

- (void)start;
- (void)stopWithComlpetion:(void (^)())completion;

@end
