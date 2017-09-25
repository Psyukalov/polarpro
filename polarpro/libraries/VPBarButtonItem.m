//
//  VPBarButtonItem.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 12.09.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "VPBarButtonItem.h"

#import "Macros.h"


@implementation VPBarButtonItem

- (instancetype)initWithDefaultImage:(UIImage *)defaultImage
                    andSelectedImage:(UIImage *)selectedImage {
    self = [super init];
    if (self) {
        _defaultImage = defaultImage;
        _selectedImage = selectedImage;
        _selectedImage = [_selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIButton *view = [UIButton new];
        [view setBackgroundColor:[UIColor clearColor]];
        [view setBackgroundImage:nil
                        forState:UIControlStateSelected];
        [view setBackgroundImage:nil
                        forState:UIControlStateNormal];
        [view setImage:_defaultImage
              forState:UIControlStateNormal];
        [view setImage:_selectedImage
              forState:UIControlStateSelected];
        [view.imageView setTintColor:RGB(238.f, 184.f, 24.f)];
        [self setCustomView:view];
    }
    return self;
}

- (void)setAction:(SEL)action {
    [super setAction:action];
    [self.customView addTarget:self.target
                        action:self.action
              forControlEvents:UIControlEventTouchUpInside];
}

- (void)setTarget:(id)target {
    [super setTarget:target];
    [self.customView addTarget:self.target
                        action:self.action
              forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [((UIButton *)self.customView) setSelected:_selected];
}

@end
