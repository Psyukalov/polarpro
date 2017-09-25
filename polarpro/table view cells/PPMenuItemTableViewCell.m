//
//  PPMenuItemTableViewCell.m
//  polarpro
//
//  Created by Владимир Псюкалов on 05.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPMenuItemTableViewCell.h"

#import "Macros.h"


@interface PPMenuItemTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end


@implementation PPMenuItemTableViewCell

@synthesize title = _title;

- (void)awakeFromNib {
    [super awakeFromNib];
    [_titleLabel setFont:[UIFont fontWithName:@"BN-Regular"
                                         size:34.f]];
    [_titleLabel setTextColor:[UIColor whiteColor]];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted
                 animated:animated];
    UIColor *color = highlighted ? RGB(34.f, 68.f, 76.f) : [UIColor whiteColor];
    [_titleLabel setTextColor:color];
}

- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated {
    [super setSelected:selected
              animated:animated];
    //
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [_titleLabel setText:title];
}

@end
