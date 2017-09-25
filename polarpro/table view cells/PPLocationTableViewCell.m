//
//  PPLocationTableViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 16.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPLocationTableViewCell.h"

#import "Macros.h"


@interface PPLocationTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *dragImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end


@implementation PPLocationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setBackgroundColor:MAIN_COLOR];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [_titleLabel setText:_title];
}

- (IBAction)deleteButtonTUI:(UIButton *)sender {
    if (!_delegate || ![_delegate conformsToProtocol:@protocol(PPLocationTableViewCellDelegate)]) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(didDeleteLocationWithIndexPath:)]) {
        [_delegate didDeleteLocationWithIndexPath:_indexPath];
    }
}

@end
