//
//  PPSettingsHeaderView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 15.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPSettingsHeaderView.h"

#import "PPUtils.h"


@interface PPSettingsHeaderView ()

@property (weak, nonatomic) IBOutlet UIView *view;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation PPSettingsHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [PPUtils resizeLabelsInView:self.contentView];
        [PPUtils resizeMarginsInView:self.contentView];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [_titleLabel setText:_title];
}

@end
