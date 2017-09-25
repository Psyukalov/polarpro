//
//  PPDeviceHeaderView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 12.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPDeviceHeaderView.h"

#import "Macros.h"


@interface PPDeviceHeaderView ()

@property (weak, nonatomic) IBOutlet UIView *view;

@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelLabel;

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

@end

@implementation PPDeviceHeaderView

- (void)setMark:(NSString *)mark {
    _mark = mark;
    [_markLabel setText:_mark];
}

- (void)setModel:(NSString *)model {
    _model = model;
    [_modelLabel setText:_model];
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (_isSelected) {
        [self select];
    } else {
        [self deselect];
    }
}

- (void)select {
    [UIView animateWithDuration:.4f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_checkImageView setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90.f))];
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
}

- (void)deselect {
    [UIView animateWithDuration:.4f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_checkImageView setTransform:CGAffineTransformIdentity];
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
}

@end
