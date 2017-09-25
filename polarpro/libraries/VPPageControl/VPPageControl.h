//
//  VPPageControl.h
//
//  Created by Vladimir Psyukalov on 20.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface VPPageControl : UIPageControl

@property (assign, nonatomic) BOOL useIndexForImage;

@property (strong, nonatomic) UIImage *defaultImage;
@property (strong, nonatomic) UIImage *selectedImage;

@property (assign, nonatomic) NSUInteger indexForImage;

@end
