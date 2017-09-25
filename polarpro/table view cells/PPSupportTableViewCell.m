//
//  PPSupportTableViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPSupportTableViewCell.h"

#import "Macros.h"


@interface PPSupportTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *forwardImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end


@implementation PPSupportTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    //
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted
                 animated:animated];
    UIColor *color = highlighted ? RGB(34.f, 68.f, 76.f) : [UIColor whiteColor];
    [_titleLabel setTextColor:color];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //
}


- (void)setWithForwardImage:(BOOL)withForwardImage {
    _withForwardImage = withForwardImage;
    [_forwardImageView setHidden:!_withForwardImage];
}

- (void)setImageString:(NSString *)imageString {
    _imageString = imageString;
    [_iconImageView setImage:[UIImage imageNamed:_imageString]];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [_titleLabel setText:_title];
}

@end
