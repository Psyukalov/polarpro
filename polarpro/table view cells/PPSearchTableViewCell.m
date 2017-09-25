//
//  PPSearchTableViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 17.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPSearchTableViewCell.h"


@interface PPSearchTableViewCell  ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end


@implementation PPSearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [_titleLabel setText:_title];
}

@end
