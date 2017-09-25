//
//  PPHourlyWeatherForecastCollectionViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 21.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPHourlyWeatherForecastCollectionViewCell.h"

#import "Macros.h"
#import "UIView+PPCustomView.h"
#import "PPUtils.h"


@interface PPHourlyWeatherForecastCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end


@implementation PPHourlyWeatherForecastCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_iconImageView setTintColor:RGB(238.f, 184.f, 24.f)];
    [PPUtils resizeLabelsInView:self.contentView];
    [PPUtils resizeMarginsInView:self.contentView];
}

- (void)setTime:(NSString *)time {
    _time = time;
    [_timeLabel setText:_time];
}

- (void)setIcon:(NSString *)icon {
    _icon = icon;
    UIImage *image = [[UIImage imageNamed:_icon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_iconImageView setImage:image];
}

- (void)setTemperature:(CGFloat)temperature {
    _temperature = temperature;
    [_temperatureLabel setText:[NSString stringWithFormat:@"%1.0f%@", _temperature, kDegreeCharacter]];
}

@end
