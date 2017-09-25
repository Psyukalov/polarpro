//
//  PPSettingsTableViewCell.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 15.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPSettingsTableViewCell.h"

#import "Macros.h"
#import "VPSegmentedControl.h"
#import "PPUtils.h"


@interface PPSettingsTableViewCell () <VPSegmentedControlDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet VPSegmentedControl *segmentedControl;

@end


@implementation PPSettingsTableViewCell

@synthesize delegate;

@synthesize indexPath;

- (void)awakeFromNib {
    [super awakeFromNib];
    [_segmentedControl setDelegate:self];
    [PPUtils resizeLabelsInView:self.contentView];
    [PPUtils resizeMarginsInView:self.contentView];
}

#pragma mark - VPSegmentedControlDelegate

- (void)setTitle:(NSString *)title {
    _title = title;
    [_titleLabel setText:_title];
}

- (void)setParameters:(NSArray<NSString *> *)parameters {
    _parameters = parameters;
    [_segmentedControl reloadData];
}

- (NSUInteger)numberOfItemsInSegmentedControl:(VPSegmentedControl *)segmentedControl {
    return _parameters.count;
}

- (void)setSelectedSegment:(NSUInteger)selectedSegment {
    _selectedSegment = selectedSegment;
    [_segmentedControl setSelectedSegment:_selectedSegment];
}

- (UIButton *)segmentedControl:(VPSegmentedControl *)segmentedControl buttonWithIndex:(NSUInteger)index {
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundColor:[UIColor clearColor]];
    [button.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Medium"
                                               size:14.f * [PPUtils screenRate]]];
    [button setTitleColor:RGB(84.f, 100.f, 110.f)
                 forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor]
                 forState:UIControlStateSelected];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    if (index == _parameters.count - 1) {
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0.f, 0.f, 0.f, 20.f)];
    }
    if (_parameters.count > 0 && index <= _parameters.count - 1) {
        [button setTitle:_parameters[index]
                forState:UIControlStateNormal];
    }
    return button;
}

- (void)segmentedControl:(VPSegmentedControl *)segmentedControl didTouchUpInsideButtonWithIndex:(NSUInteger)index {
    if (!delegate || ![delegate conformsToProtocol:@protocol(PPSettingsTableViewCellDelegate)]) {
        return;
    }
    if ([delegate respondsToSelector:@selector(didChangeSegmentedControlWithIndex:andIndexPath:)]) {
        [delegate didChangeSegmentedControlWithIndex:index
                                        andIndexPath:indexPath];
    }
}

@end
