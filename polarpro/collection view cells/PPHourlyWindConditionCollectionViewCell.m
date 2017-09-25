//
//  PPHourlyWindConditionCollectionViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 14.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPHourlyWindConditionCollectionViewCell.h"

#import "Macros.h"
#import "PPUtils.h"


@interface PPHourlyWindConditionCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;

@end


@implementation PPHourlyWindConditionCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [PPUtils resizeLabelsInView:self.contentView];
    [PPUtils resizeMarginsInView:self.contentView];
}

- (void)setTime:(NSString *)time {
    _time = time;
    [_timeLabel setText:_time];
}

- (void)setSpeed:(NSString *)speed {
    _speed = speed;
    [_speedLabel setText:_speed];
}

- (void)setDirection:(NSString *)direction {
    _direction = direction;
    [_directionLabel setText:_direction];
}

@end
