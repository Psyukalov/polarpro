//
//  VPSegmentedControl.h
//
//  Created by Vladimir Psyukalov on 12.05.17.
//  Copyright © 2017 Vladimir Psyukalov. All rights reserved.
//


#import "VPSegmentedControl.h"


@interface VPSegmentedControl ()

@property (assign, nonatomic) NSUInteger segmentCount;

@property (strong, nonatomic) NSMutableArray <UIButton *> *buttons;

@end


@implementation VPSegmentedControl

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _buttons = [[NSMutableArray alloc] init];
    _useSizeByCharectersCount = YES;
}

- (void)reloadData {
    if (!_delegate || ![_delegate conformsToProtocol:@protocol(VPSegmentedControlDelegate)]) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(numberOfItemsInSegmentedControl:)]) {
        _segmentCount = [_delegate numberOfItemsInSegmentedControl:self];
    }
    if (_segmentCount == 0) {
        return;
    }
    for (UIButton *button in _buttons) {
        [button removeFromSuperview];
    }
    [_buttons removeAllObjects];
    CGFloat allWidth = 0.f;
    for (NSUInteger i = 0; i <= _segmentCount - 1; i++) {
        if ([_delegate respondsToSelector:@selector(segmentedControl:buttonWithIndex:)]) {
            UIButton *button = [_delegate segmentedControl:self
                                           buttonWithIndex:i];
            [_buttons addObject:button];
            UILabel *titleLabel = button.titleLabel;
            [titleLabel sizeToFit];
            allWidth += titleLabel.frame.size.width;
        }
    }
    for (NSUInteger i = 0; i <= _segmentCount - 1; i++) {
        UIButton *button = _buttons[i];
        if (!button) {
            button = [[UIButton alloc] init];
            [button setTitle:[NSString stringWithFormat:@"Segment: %ld", (unsigned long)i]
                    forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blueColor]
                         forState:UIControlStateSelected];
        }
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setTag:i];
        [button addTarget:self
                   action:@selector(touchUpInside:)
         forControlEvents:UIControlEventTouchUpInside];
        id item;
        NSLayoutAttribute attribute;
        if (i == 0) {
            item = self;
            attribute = NSLayoutAttributeLeft;
        } else {
            item = (id)_buttons[i - 1];
            attribute = NSLayoutAttributeRight;
        }
        [self addSubview:button];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:item
                                                         attribute:attribute
                                                        multiplier:1.f
                                                          constant:0.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.f
                                                          constant:0.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.f
                                                          constant:0.f]];
        UILabel *titleLabel = button.titleLabel;
        [titleLabel sizeToFit];
        CGFloat percent = allWidth == 0.f ? 1.f / _segmentCount : titleLabel.frame.size.width / allWidth;
        CGFloat multiplier = _useSizeByCharectersCount ? percent : 1.f / _segmentCount;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:multiplier
                                                          constant:0.f]];
    }
}

- (void)setDelegate:(id<VPSegmentedControlDelegate>)delegate {
    _delegate = delegate;
    [self reloadData];
}

- (void)setSelectedSegment:(NSUInteger)selectedSegment {
    if (_buttons.count == 0) {
        return;
    }
    if (selectedSegment <= _buttons.count - 1) {
        if (_selectedSegment <= _buttons.count - 1) {
            [_buttons[_selectedSegment] setSelected:NO];
        }
        _selectedSegment = selectedSegment;
        [_buttons[_selectedSegment] setSelected:YES];
    }
}

- (void)touchUpInside:(UIButton *)button {
    [self setSelectedSegment:button.tag];
    if (!_delegate || ![_delegate conformsToProtocol:@protocol(VPSegmentedControlDelegate)]) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(segmentedControl:didTouchUpInsideButtonWithIndex:)]) {
        [_delegate segmentedControl:self didTouchUpInsideButtonWithIndex:button.tag];
    }
}

@end
