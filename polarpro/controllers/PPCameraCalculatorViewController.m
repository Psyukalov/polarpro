//
//  PPCameraCalculatorViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 11.12.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPCameraCalculatorViewController.h"

#import "Macros.h"

#import "UIView+PPCustomView.h"
#import "UIViewController+PPCostomViewController.h"

#import "VPHorizontalPickerView.h"

#import "iCarousel.h"

#import "PPTipView.h"


@interface PPCameraCalculatorViewController () <VPHorizontalPickerViewDelegate, iCarouselDataSource, iCarouselDelegate>

@property (weak, nonatomic) IBOutlet UIView *filterResultContentView;

@property (weak, nonatomic) IBOutlet VPHorizontalPickerView *shutterSpeedPickerView;
@property (weak, nonatomic) IBOutlet VPHorizontalPickerView *filtersInstalledPickerView;

@property (weak, nonatomic) IBOutlet UILabel *shutterSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterInstalledLabel;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet iCarousel *carouselView;

@property (weak, nonatomic) IBOutlet UILabel *caption_0_Label;
@property (weak, nonatomic) IBOutlet UILabel *caption_1_Label;
@property (weak, nonatomic) IBOutlet UILabel *caption_2_Label;

@property (weak, nonatomic) IBOutlet UILabel *time_0_Label;
@property (weak, nonatomic) IBOutlet UILabel *time_1_Label;
@property (weak, nonatomic) IBOutlet UILabel *time_2_Label;

@property (weak, nonatomic) IBOutlet UILabel *unit_0_Label;
@property (weak, nonatomic) IBOutlet UILabel *unit_1_Label;
@property (weak, nonatomic) IBOutlet UILabel *unit_2_Label;

@property (weak, nonatomic) IBOutlet UIButton *info_0_Button;
@property (weak, nonatomic) IBOutlet UIButton *info_1_Button;

@property (weak, nonatomic) IBOutlet UIButton *timerButton;

@property (strong, nonatomic) NSArray *tips;

@end


@implementation PPCameraCalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self localize];
    [self setInterval:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //
}

- (void)setup {
    _tips = @[LOCALIZE(@"cc_tip_0"),
              LOCALIZE(@"cc_tip_1"),
              LOCALIZE(@"cc_tip_2"),
              LOCALIZE(@"cc_tip_3")];
    _pageControl.numberOfPages = _tips.count;
    self.navigationItem.title = LOCALIZE(@"cc_title");
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createBackBBI];
    self.view.backgroundColor = MAIN_COLOR;
    [_filterResultContentView applyCornerRadius:6.f];
    UIFont *defaultFont = [UIFont fontWithName:@"BN-Light"
                                          size:70.f];
    UIFont *selectedFont = [UIFont fontWithName:@"BN-Book"
                                           size:70.f];
    _filtersInstalledPickerView.useSecondTitle = YES;
    [_filtersInstalledPickerView setSecondFont:[UIFont fontWithName:@"BN-Light"
                                                               size:24.f]
                                      forState:VPDefaultState];
    [_filtersInstalledPickerView setSecondFont:[UIFont fontWithName:@"BN-Book"
                                                               size:24.f]
                                      forState:VPSelectedState];
    [_filtersInstalledPickerView setSecondColor:RGBA(238.f, 184.f, 24.f, 32.f)
                                       forState:VPDefaultState];
    [_filtersInstalledPickerView setSecondColor:RGB(4.f, 126.f, 140.f)
                                       forState:VPSelectedState];
    for (VPHorizontalPickerView *pickerView in @[_shutterSpeedPickerView,
                                                 _filtersInstalledPickerView]) {
        [pickerView setFont:defaultFont
                   forState:VPDefaultState];
        [pickerView setFont:selectedFont
                   forState:VPSelectedState];
        [pickerView setColor:RGBA(238.f, 184.f, 24.f, 32.f)
                    forState:VPDefaultState];
        [pickerView setColor:RGB(4.f, 126.f, 140.f)
                    forState:VPSelectedState];
        [pickerView setPadding:20.f];
        [pickerView setDelegate:self];
    }
    [_carouselView layoutIfNeeded];
    [_carouselView setDataSource:self];
    [_carouselView setDelegate:self];
    [_carouselView setDecelerationRate:.64f];
    [_carouselView setBounces:NO];
    _carouselView.type = iCarouselTypeLinear;
    for (UILabel *label in @[_time_0_Label,
                             _time_1_Label,
                             _time_2_Label]) {
        [label setFont:[UIFont fontWithName:@"BN-Regular"
                                       size:80.f]];
    }
    for (UILabel *label in @[_unit_0_Label,
                             _unit_1_Label,
                             _unit_2_Label]) {
        [label setFont:[UIFont fontWithName:@"BN-Book"
                                       size:26.f]];
    }
}

- (void)localize {
    _caption_0_Label.text = LOCALIZE(@"cc_caption_0");
    _caption_1_Label.text = LOCALIZE(@"cc_caption_1");
    _caption_2_Label.text = [LOCALIZE(@"cc_caption_2") uppercaseString];
}

- (void)setInterval:(NSUInteger)interval {
    [UIView animateWithDuration:.32f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _timerButton.alpha = interval > 2 ? 1.f : 0.f;
                     }
                     completion:nil];
    NSUInteger hours = interval / 3600;
    NSUInteger minutes = (interval / 60) % 60;
    NSUInteger seconds = interval % 60;
    NSUInteger days = hours / 24;
    _time_0_Label.text = nil;
    _time_1_Label.text = nil;
    _time_2_Label.text = nil;
    _unit_0_Label.text = nil;
    _unit_1_Label.text = nil;
    _unit_2_Label.text = nil;
    if (days > 0) {
        hours = (interval - days * 24 * 3600) / 3600;
        _time_0_Label.text = [NSString stringWithFormat:@"%ld", (unsigned long)days];
        _time_1_Label.text = [NSString stringWithFormat:@"%ld", (unsigned long)hours];
        _time_2_Label.text = [NSString stringWithFormat:@"%ld", (unsigned long)minutes];
        _unit_0_Label.text = LOCALIZE(@"cc_unit_d");
        _unit_1_Label.text = LOCALIZE(@"cc_unit_h");
        _unit_2_Label.text = LOCALIZE(@"cc_unit_m");
        return;
    }
    if (hours > 0) {
        _time_0_Label.text = [NSString stringWithFormat:@"%ld", (unsigned long)hours];
        _time_1_Label.text = [NSString stringWithFormat:@"%ld", (unsigned long)minutes];
        _time_2_Label.text = [NSString stringWithFormat:@"%ld", (unsigned long)seconds];
        _unit_0_Label.text = LOCALIZE(@"cc_unit_h");
        _unit_1_Label.text = LOCALIZE(@"cc_unit_m_max");
        _unit_2_Label.text = LOCALIZE(@"cc_unit_s");
        return;
    }
    if (minutes > 0) {
        _time_0_Label.text = [NSString stringWithFormat:@"%ld", (unsigned long)minutes];
        _time_1_Label.text = [NSString stringWithFormat:@"%ld", (unsigned long)seconds];
        _unit_0_Label.text = LOCALIZE(@"cc_unit_m_max");
        _unit_1_Label.text = LOCALIZE(@"cc_unit_s");
        return;
    }
    _time_0_Label.text = [NSString stringWithFormat:@"%ld", (unsigned long)seconds];
    _unit_0_Label.text = LOCALIZE(@"cc_unit_s_max");
}

#pragma mark - VPHorizontalPickerViewDelegate

- (NSUInteger)numberOfItemsInPickerView:(VPHorizontalPickerView *)pickerView {
    if (pickerView == _shutterSpeedPickerView) {
        return 8;
    }
    if (pickerView == _filtersInstalledPickerView) {
        return 8;
    }
    return 0;
}

- (NSString *)pickerView:(VPHorizontalPickerView *)pickerView titleForItemAtIndex:(NSUInteger)index {
    if (pickerView == _shutterSpeedPickerView) {
        return @"1/XXXX";
    }
    if (pickerView == _filtersInstalledPickerView) {
        return @"FILTER-XX";
    }
    return nil;
}

- (NSString *)pickerView:(VPHorizontalPickerView *)pickerView secondTitleForItemAtIndex:(NSUInteger)index {
    if (pickerView == _filtersInstalledPickerView) {
        return @"STOP-XX";
    }
    return nil;
}

- (CGFloat)marginBetweenItemsInPickerView:(VPHorizontalPickerView *)pickerView {
    return 28.f;
}

- (void)pickerView:(VPHorizontalPickerView *)pickerView didSelectItemAtIndex:(NSUInteger)index {
    NSArray *array = @[@(24 * 3600 + 84595),
                       @(18 * 3600 + 60),
                       @(60 * 50 + 6),
                       @(60 * 30 + 128),
                       @(60 * 3 + 16),
                       @(35),
                       @(8 * 24 * 3600 + 2048),
                       @(1)];
    [self setInterval:[array[index] integerValue]];
}

#pragma mark - iCarouselDataSource, iCarouselDelegate

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return _tips.count;
}

- (UIView *)carousel:(iCarousel *)carousel
  viewForItemAtIndex:(NSInteger)index
         reusingView:(UIView *)view {
    if (!view) {
        view = [[PPTipView alloc] initWithFrame:carousel.bounds];
    }
    ((PPTipView *)view).text = _tips[index];
    return view;
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    _pageControl.currentPage = carousel.currentItemIndex;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionVisibleItems:
            return 4.f;
            break;
        case iCarouselOptionSpacing:
            return 1.f * value;
            break;
        default:
            return value;
            break;
    }
}

#pragma mark - Actions

- (IBAction)timerButton_TUI:(UIButton *)sender {
    //
}

- (IBAction)info_0_Button_TUI:(UIButton *)sender {
    //
}

- (IBAction)info_1_Button_TUI:(UIButton *)sender {
    //
}

@end
