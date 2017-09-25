//
//  PPWeatherForecastTableViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 21.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPWeatherForecastTableViewCell.h"

#import "Macros.h"
#import "PPUtils.h"


@interface PPWeatherForecastTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTemperatureLabel;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end


@implementation PPWeatherForecastTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_iconImageView setTintColor:RGB(238.f, 184.f, 24.f)];
    [PPUtils resizeLabelsInView:self.contentView];
    [PPUtils resizeMarginsInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //
}

- (void)setWeekday:(NSString *)weekday {
    _weekday = weekday;
    [_weekdayLabel setText:_weekday];
}

- (void)setMaxTemperature:(CGFloat)maxTemperature {
    _maxTemperature = maxTemperature;
    [_maxTemperatureLabel setText:[NSString stringWithFormat:@"%1.0f%@", _maxTemperature, kDegreeCharacter]];
}

- (void)setMinTemperature:(CGFloat)minTemperature {
    _minTemperature = minTemperature;
    [_minTemperatureLabel setText:[NSString stringWithFormat:@"%1.0f%@", _minTemperature, kDegreeCharacter]];
}

- (void)setIcon:(NSString *)icon {
    _icon = icon;
    UIImage *image = [[UIImage imageNamed:_icon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_iconImageView setImage:image];
}

@end
