//
//  PPMessageCollectionViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 21.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPMessageCollectionViewCell.h"

#import "Macros.h"
#import "UIView+PPCustomView.h"


@interface PPMessageCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;

@end


@implementation PPMessageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setBackgroundColor:RGB(28.f, 30.f, 34.f)];
    [self applyCornerRadius:6.f];
    [_titleLabel setText:LOCALIZE(@"no_locations_in_hub_title")];
    [_descriptionLabel setText:LOCALIZE(@"no_locations_in_hub_message")];
    [_buttonAdd.titleLabel setFont:[UIFont fontWithName:@"BN-Regular"
                                                   size:34.f]];
    [_buttonAdd setTitle:[LOCALIZE(@"add") uppercaseString]
                forState:UIControlStateNormal];
}

- (IBAction)buttonAdd_TUI:(UIButton *)sender {
    if (_delegate) {
        if ([_delegate conformsToProtocol:@protocol(PPMessageCollectionViewCellDelegate)] &&
            [_delegate respondsToSelector:@selector(didActionWithButton:)]) {
            [_delegate didActionWithButton:sender];
        }
    }
}

@end
