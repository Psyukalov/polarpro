//
//  PPKPIndexTableViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 13.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPKPIndexTableViewCell.h"


#import "Macros.h"
#import "UIView+PPCustomView.h"
#import "PPUtils.h"


@interface PPKPIndexTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end


@implementation PPKPIndexTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [PPUtils resizeLabelsInView:self.contentView];
    [PPUtils resizeMarginsInView:self.contentView];
}

- (void)setDate:(NSString *)date {
    _date = date;
    [_dateLabel setText:[self dayOfWeekByFormattedString:_date]];
}

- (void)setIndex:(CGFloat)index {
    _index = index;
    [_indexLabel setText:[NSString stringWithFormat:@"%1.0f", index]];
    if (index <= 3.f) {
        [_descriptionLabel setText:LOCALIZE(@"low_risk")];
        [_descriptionLabel setTextColor:RGB(100.f, 154.f, 168.f)];
    } else if (index > 3.f && index <= 5.f) {
        [_descriptionLabel setText:LOCALIZE(@"medium_risk")];
        [_descriptionLabel setTextColor:RGB(100.f, 154.f, 168.f)];
    } else {
        [_descriptionLabel setText:LOCALIZE(@"high_risk")];
        [_descriptionLabel setTextColor:RGB(238.f, 24.f, 24.f)];
    }
}

@end
