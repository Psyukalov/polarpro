//
//  VPBarButtonItem.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 12.09.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface VPBarButtonItem : UIBarButtonItem

@property (strong, nonatomic) UIImage *defaultImage;
@property (strong, nonatomic) UIImage *selectedImage;

@property (assign, nonatomic) BOOL selected;

- (instancetype)initWithDefaultImage:(UIImage *)defaultImage
                    andSelectedImage:(UIImage *)selectedImage;

@end
