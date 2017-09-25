//
//  VPHorizontalPickerView.m
//
//  Created by Владимир Псюкалов on 18.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "VPHorizontalPickerView.h"

#import <AudioToolbox/AudioToolbox.h>

#import "PPUtils.h"


#define kMinMargin (0.f)

#define kRange


@interface VPHorizontalPickerView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) NSLayoutConstraint *leftPaddingLC;
@property (strong, nonatomic) NSLayoutConstraint *rightPaddingLC;

@property (strong, nonatomic) NSMutableArray <UILabel *> *labels;

@property (strong, nonatomic) UIFont *defaultFont;
@property (strong, nonatomic) UIFont *selectedFont;

@property (strong, nonatomic) UIColor *defaultColor;
@property (strong, nonatomic) UIColor *selectedColor;

@property (assign, nonatomic) NSUInteger count;

@property (assign, nonatomic) CGFloat margin;

@property (strong, nonatomic) UISelectionFeedbackGenerator *feedback;

@end


@implementation VPHorizontalPickerView

#pragma mark - Inits

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

#pragma mark - Setup

- (void)setup {
    _labels = [[NSMutableArray alloc] init];
    _defaultFont = [UIFont systemFontOfSize:14.f];
    _selectedFont = _defaultFont;
    _defaultColor = [UIColor lightGrayColor];
    _selectedColor = [UIColor blackColor];
    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setDelegate:self];
    [_scrollView setDecelerationRate:.64f];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_scrollView];
    [self createConstraints];
    _feedback = [UISelectionFeedbackGenerator new];
}

- (void)createConstraints {
    _leftPaddingLC = [NSLayoutConstraint constraintWithItem:_scrollView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.f
                                                   constant:_padding];
    [self addConstraint:_leftPaddingLC];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.f
                                                      constant:0.f]];
    _rightPaddingLC = [NSLayoutConstraint constraintWithItem:_scrollView
                                                   attribute:NSLayoutAttributeRight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1.f
                                                    constant:-_padding];
    [self addConstraint:_rightPaddingLC];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.f
                                                      constant:0.f]];
    [_scrollView setClipsToBounds:NO];
}

#pragma mark - Public methods

- (void)setSelectedIndex:(NSUInteger)selectedIndex
                animated:(BOOL)animated {
    if (_labels.count > 0 && selectedIndex <= _labels.count - 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_scrollView setContentOffset:_labels[selectedIndex].frame.origin
                                 animated:animated];
        });
    }
}

- (void)setFont:(UIFont *)font
       forState:(VPState)state {
    switch (state) {
        case VPDefaultState:
            _defaultFont = font;
            break;
        case VPSelectedState:
            _selectedFont = font;
            break;
        default:
            break;
    }
    if (_labels.count > 0) {
        for (UILabel *label in _labels) {
            [label setFont:_defaultFont];
            if (label.tag == _selectedIndex) {
                [label setFont:_selectedFont];
            }
        }
    }
}

- (void)setColor:(UIColor *)color
        forState:(VPState)state {
    switch (state) {
        case VPDefaultState:
            _defaultColor = color;
            break;
        case VPSelectedState:
            _selectedColor = color;
            break;
        default:
            break;
    }
    if (_labels.count > 0) {
        for (UILabel *label in _labels) {
            [label setTextColor:_defaultColor];
            [label setHighlightedTextColor:_selectedColor];
        }
    }
}

- (void)reloadData {
    if ([self checkDelegate] && [_delegate respondsToSelector:@selector(numberOfItemsInPickerView:)]) {
        _count = [_delegate numberOfItemsInPickerView:self];
        if (_count > 0) {
            [self removeData];
            _selectedIndex = 0;
            if ([self checkDelegate] && [_delegate respondsToSelector:@selector(marginBetweenItemsInPickerView:)]) {
                _margin = [_delegate marginBetweenItemsInPickerView:self];
            }
            if (_margin <= 0.f) {
                _margin = kMinMargin;
            }
            for (NSUInteger i = 0; i <= _count - 1; i++) {
                NSString *string;
                if ([self checkDelegate] && [_delegate respondsToSelector:@selector(pickerView:titleForItemAtIndex:)]) {
                    string = [_delegate pickerView:self
                               titleForItemAtIndex:i];
                }
                BOOL isFirstLabel = (i == 0);
                UILabel *label = [[UILabel alloc] init];
                [label setTag:i];
                [label setNumberOfLines:1];
                [label setLineBreakMode:NSLineBreakByWordWrapping];
                [label setText:string];
                [label setTextColor:_defaultColor];
                [label setHighlightedTextColor:_selectedColor];
                [label setFont:isFirstLabel ? _selectedFont : _defaultFont];
                [label setHighlighted:isFirstLabel];
                [label setTextAlignment:NSTextAlignmentLeft];
                [label sizeToFit];
                id element = isFirstLabel ? _scrollView : (id)_labels[i - 1];
                NSLayoutAttribute attribute = isFirstLabel ? NSLayoutAttributeLeft : NSLayoutAttributeRight;
                CGFloat leftMargin = isFirstLabel ? 0.f : _margin;
                [label setTranslatesAutoresizingMaskIntoConstraints:NO];
                [_scrollView addSubview:label];
                [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:element
                                                                        attribute:attribute
                                                                       multiplier:1.f
                                                                         constant:leftMargin]];
                [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_scrollView
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.f
                                                                         constant:0.f]];
                [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_scrollView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.f
                                                                         constant:0.f]];
                if (isFirstLabel) {
                    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                            attribute:NSLayoutAttributeCenterY
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollView
                                                                            attribute:NSLayoutAttributeCenterY
                                                                           multiplier:1.f
                                                                             constant:0.f]];
                }
                if (i == _count - 1) {
                    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollView
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1.f
                                                                             constant:0.f]];
                    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollView
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.f
                                                                             constant:0.f]];
                }
                [_labels addObject:label];
            }
            [self animate:NO];
        }
    }
}

#pragma mark - Other methods

- (BOOL)checkDelegate {
    if (!_delegate || ![_delegate conformsToProtocol:@protocol(VPHorizontalPickerViewDelegate)]) {
        return NO;
    }
    return YES;
}

- (void)removeData {
    if (_labels.count > 0) {
        for (UILabel *label in _labels) {
            [label removeFromSuperview];
        }
        [_labels removeAllObjects];
    }
}

- (NSUInteger)findNearestItemIndex {
    NSUInteger nearestItemIndex = 0;
    CGFloat distance = FLT_MAX;
    for (UILabel *label in _labels) {
        CGFloat currentDistance = ABS(label.frame.origin.x - _scrollView.contentOffset.x);
        if (distance > currentDistance) {
            distance = currentDistance;
            nearestItemIndex = label.tag;
        }
    }
    return nearestItemIndex;
}

- (void)changeSelection:(NSUInteger)selectedIndex
               animated:(BOOL)animated {
    if (_selectedIndex == selectedIndex) {
        return;
    }
    UILabel *labelToDeselect = _labels[_selectedIndex];
    [labelToDeselect setFont:_defaultFont];
    [labelToDeselect setHighlighted:NO];
    UILabel *labelToSelect = _labels[selectedIndex];
    [labelToSelect setFont:_selectedFont];
    [labelToSelect setHighlighted:YES];
    _selectedIndex = selectedIndex;
    if (animated) {
        AudioServicesPlaySystemSound(1306);
        [_feedback selectionChanged];
    }
    [self animate:animated];
    if ([self checkDelegate] && [_delegate respondsToSelector:@selector(pickerView:didSelectItemAtIndex:)]) {
        [_delegate pickerView:self
         didSelectItemAtIndex:_selectedIndex];
    }
}

- (void)animate:(BOOL)animated {
    for (NSUInteger i = 0; i <= _labels.count - 1; i++) {
        if (i < _selectedIndex) {
            CGFloat percent;
            switch (_selectedIndex - i) {
                case 1:
                    percent = .8f;
                    break;
                case 2:
                    percent = .6f;
                    break;
                case 3:
                    percent = .2f;
                    break;
                default:
                    percent = .1f;
                    break;
            }
            [self setFadeWithLabel:_labels[i]
                       withPercent:percent
                          animated:animated];
        } else if (i > _selectedIndex) {
            CGFloat percent;
            switch (i - _selectedIndex) {
                case 1:
                    percent = .8f;
                    break;
                case 2:
                    percent = .6f;
                    break;
                case 3:
                    percent = .2f;
                    break;
                default:
                    percent = .1f;
                    break;
            }
            [self setFadeWithLabel:_labels[i]
                       withPercent:percent
                          animated:animated];
        } else {
            [self setFadeWithLabel:_labels[i]
                       withPercent:1.f
                          animated:animated];
        }
    }
}

- (void)setFadeWithLabel:(UILabel *)label
             withPercent:(CGFloat)percent
                animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:.2f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [label setAlpha:percent];
                         }
                         completion:nil];
    } else {
        [label setAlpha:percent];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_feedback prepare];
    [self changeSelection:[self findNearestItemIndex]
                 animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [_scrollView setContentOffset:_labels[[self findNearestItemIndex]].frame.origin
                             animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_scrollView setContentOffset:_labels[[self findNearestItemIndex]].frame.origin
                         animated:YES];
}

#pragma mark - Custom accessors

- (void)setDelegate:(id<VPHorizontalPickerViewDelegate>)delegate {
    _delegate = delegate;
    [self reloadData];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex
                  animated:YES];
}

- (void)setPadding:(CGFloat)padding {
    _padding = padding;
    [_leftPaddingLC setConstant:_padding];
    [_rightPaddingLC setConstant:-_padding];
}

@end
