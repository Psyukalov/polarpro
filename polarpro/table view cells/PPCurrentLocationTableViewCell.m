//
//  PPCurrentLocationTableViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 16.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPCurrentLocationTableViewCell.h"

#import "PPSettingsModel.h"
#import "PPLocationsModel.h"

#import "Macros.h"


@interface PPCurrentLocationTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

@end


@implementation PPCurrentLocationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setBackgroundColor:MAIN_COLOR];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(gestureRecognizer:)]];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [_titleLabel setText:_title];
}

- (void)setUseCurrentLocation:(BOOL)useCurrentLocation {
    _useCurrentLocation = useCurrentLocation;
    [_checkImageView setHighlighted:_useCurrentLocation];
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)sender {
    [_checkImageView setHighlighted:NO];
    if ([self checkDelegate] && [_delegate respondsToSelector:@selector(didSwitchCurrentLocationWithIndexPath:)]) {
        [_checkImageView setHighlighted:[_delegate didSwitchCurrentLocationWithIndexPath:_indexPath]];
    }
}

- (BOOL)checkDelegate {
    return _delegate && [_delegate conformsToProtocol:@protocol(PPCurrentLocationTableViewCellDelegate)];
}

@end
