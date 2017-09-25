//
//  PPWindConditionTableViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 14.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPWindConditionTableViewCell.h"

#import "Macros.h"
#import "UIView+PPCustomView.h"
#import "PPUtils.h"


@interface PPWindConditionTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end


@implementation PPWindConditionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [PPUtils resizeLabelsInView:self.contentView];
    [PPUtils resizeMarginsInView:self.contentView];
}

- (void)setDate:(NSString *)date {
    _date = date;
    [_dateLabel setText:[self dayOfWeekByFormattedString:_date]];
}

- (void)setWeekday:(NSString *)weekday {
    _weekday = weekday;
    [_dateLabel setText:_weekday];
}

- (void)setDirection:(NSString *)direction {
    _direction = direction;
    [_descriptionLabel setText:_direction];
}

- (void)setUnits:(NSString *)units {
    _units = [units uppercaseString];
    [_unitsLabel setText:_units];
}

- (void)setSpeed:(CGFloat)speed {
    _speed = speed;
    [_speedLabel setText:[NSString stringWithFormat:@"%1.0f", _speed]];
}

@end
