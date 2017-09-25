//
//  PPDeviceTableViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 11.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPDeviceTableViewCell.h"

#import "Macros.h"


@interface PPDeviceTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelLabel;

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

@end


@implementation PPDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_checkImageView setImage:[UIImage imageNamed:@"check_default_i.png"]];
    [_checkImageView setHighlightedImage:[UIImage imageNamed:@"check_selected_i.png"]];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted
                 animated:animated];
    UIColor *color = highlighted ? RGB(34.f, 68.f, 76.f) : [UIColor whiteColor];
    [_markLabel setTextColor:color];
    [_modelLabel setTextColor:color];
}

- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated {
    [super setSelected:selected
              animated:animated];
    [_checkImageView setHighlighted:selected];
}

- (void)setMark:(NSString *)mark {
    _mark = mark;
    [_markLabel setText:_mark];
}

- (void)setModel:(NSString *)model {
    _model = model;
    [_modelLabel setText:_model];
}

@end
