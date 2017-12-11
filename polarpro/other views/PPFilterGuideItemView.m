//
//  PPFilterGuideItemView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 19.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPFilterGuideItemView.h"

#import "Macros.h"
#import "UIView+PPCustomView.h"
#import "VPHorizontalPickerView.h"
#import "PPUtils.h"

#import "PPCalculatorModel.h"

#import "PPAlertView.h"

#import "PPWebViewController.h"


@interface PPFilterGuideItemView () <VPHorizontalPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *filterResultContentView;
@property (weak, nonatomic) IBOutlet UIView *shopNowView;

@property (weak, nonatomic) IBOutlet UILabel *filterResult_1_Label;
@property (weak, nonatomic) IBOutlet UILabel *filterResult_2_Label;

@property (weak, nonatomic) IBOutlet UILabel *filterResult_3_Label;

@property (weak, nonatomic) IBOutlet UILabel *FPSLabel;
@property (weak, nonatomic) IBOutlet UILabel *shutterSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterInstalledLabel;

@property (weak, nonatomic) IBOutlet UILabel *shopNowLabel;

@property (weak, nonatomic) IBOutlet VPHorizontalPickerView *FPSPickerView;
@property (weak, nonatomic) IBOutlet VPHorizontalPickerView *shutterSpeedPickerView;
@property (weak, nonatomic) IBOutlet VPHorizontalPickerView *filtersInstalledPickerView;

@property (strong, nonatomic) PPCalculatorModel *calculatorModel;

@property (assign, nonatomic) BOOL purchasedFilter;

@property (strong, nonatomic) NSString *URL;

@end


@implementation PPFilterGuideItemView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadViewFromNib];
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadViewFromNib];
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadViewFromNib];
        [self setup];
    }
    return self;
}

- (void)loadViewFromNib {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *nib = [UINib nibWithNibName:@"PPFilterGuideItemView" bundle:bundle];
    UIView *view = (UIView *)[nib instantiateWithOwner:self
                                               options:nil].firstObject;
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:view];
    NSArray *attributes = @[@(NSLayoutAttributeLeft),
                            @(NSLayoutAttributeTop),
                            @(NSLayoutAttributeRight),
                            @(NSLayoutAttributeBottom)];
    for (NSNumber *attribute in attributes) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:[attribute unsignedIntegerValue]
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:[attribute unsignedIntegerValue]
                                                        multiplier:1.f
                                                          constant:0.f]];
    }
}

- (void)setup {
    _calculatorModel = [[PPCalculatorModel alloc] init];
    [_filterResultContentView applyCornerRadius:6.f];
    [self localize];
    UIFont *defaultFont = [UIFont fontWithName:@"BN-Light"
                                          size:70.f * [PPUtils screenRate]];
    UIFont *selectedFont = [UIFont fontWithName:@"BN-Book"
                                           size:70.f * [PPUtils screenRate]];
    for (VPHorizontalPickerView *pickerView in @[_FPSPickerView,
                                                 _shutterSpeedPickerView,
                                                 _filtersInstalledPickerView]) {
        [pickerView setFont:defaultFont
                   forState:VPDefaultState];
        [pickerView setFont:selectedFont
                   forState:VPSelectedState];
        [pickerView setColor:RGBA(238.f, 184.f, 24.f, 32.f)
                    forState:VPDefaultState];
        [pickerView setColor:RGB(4.f, 126.f, 140.f)
                    forState:VPSelectedState];
        [pickerView setPadding:20.f * [PPUtils screenRate]];
        [pickerView setDelegate:self];
    }
    [_filterResult_1_Label setFont:[UIFont fontWithName:@"BN-Regular"
                                                   size:80.f]];
    
    [_filterResult_3_Label setFont:[UIFont fontWithName:@"BN-Book"
                                                   size:26.f]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer addTarget:self
                             action:@selector(shopNowView_TUI)];
    [_shopNowView setGestureRecognizers:@[tapGestureRecognizer]];
    [PPUtils resizeLabelsInView:self];
    [PPUtils resizeLabelsInView:_filterResultContentView];
}

- (void)localize {
    [_FPSLabel setText:LOCALIZE(@"fps")];
    [_shutterSpeedLabel setText:LOCALIZE(@"shutter_speed")];
    [_filterInstalledLabel setText:LOCALIZE(@"filters_installed")];
}

- (void)reloadView {
    [_FPSPickerView reloadData];
    [_shutterSpeedPickerView reloadData];
    [_filtersInstalledPickerView reloadData];
    [self applySavedParameters];
}

- (void)applySavedParameters {
    if (_selectedParameters.count > 0 && _selectedParameters.count - 1 <= 2) {
        NSUInteger parameter_0 = [_selectedParameters[0] integerValue];
        NSUInteger parameter_1 = [_selectedParameters[1] integerValue];
        NSUInteger parameter_2 = [_selectedParameters[2] integerValue];
        if (parameter_0 == 0 &&
            parameter_1 == 0 &&
            parameter_2 == 0) {
            [self calculate];
            return;
        }
        [_FPSPickerView setSelectedIndex:0
                                animated:NO];
        [_shutterSpeedPickerView setSelectedIndex:0
                                         animated:NO];
        [_filtersInstalledPickerView setSelectedIndex:0
                                             animated:NO];
        [_FPSPickerView setSelectedIndex:parameter_0
                                animated:NO];
        [_shutterSpeedPickerView setSelectedIndex:parameter_1
                                         animated:NO];
        [_filtersInstalledPickerView setSelectedIndex:parameter_2
                                             animated:NO];
    }
}

- (NSUInteger)numberOfItemsInPickerView:(VPHorizontalPickerView *)pickerView {
    if (pickerView == _FPSPickerView) {
        return _FPS.count;
    }
    if (pickerView == _shutterSpeedPickerView) {
        return _shutterSpeed.count;
    }
    if (pickerView == _filtersInstalledPickerView) {
        return _filtersInstalled.count + 1;
    }
    return 0;
}

- (NSString *)pickerView:(VPHorizontalPickerView *)pickerView titleForItemAtIndex:(NSUInteger)index {
    if (pickerView == _FPSPickerView) {
        if (_FPS.count > 0 && index <= _FPS.count - 1) {
            return _FPS[index];
        }
    }
    if (pickerView == _shutterSpeedPickerView) {
        if (_shutterSpeed.count > 0 && index <= _shutterSpeed.count - 1) {
            return _shutterSpeed[index];
        }
    }
    if (pickerView == _filtersInstalledPickerView) {
        if (index == 0) {
            return @"NONE";
        } else {
            if (_filtersInstalled.count > 0 && index - 1 <= _filtersInstalled.count - 1) {
                return _filtersInstalled[index - 1];
            }
        }
    }
    return nil;
}

- (CGFloat)marginBetweenItemsInPickerView:(VPHorizontalPickerView *)pickerView {
    return 28.f * [PPUtils screenRate];
}

- (void)pickerView:(VPHorizontalPickerView *)pickerView didSelectItemAtIndex:(NSUInteger)index {
    if (_delegate && [_delegate conformsToProtocol:@protocol(PPFilterGuideItemViewDelegate)]) {
        if ([_delegate respondsToSelector:@selector(didChangeCalculatorParameters:withIdentifier:)]) {
            [_delegate didChangeCalculatorParameters:@[@(_FPSPickerView.selectedIndex),
                                                       @(_shutterSpeedPickerView.selectedIndex),
                                                       @(_filtersInstalledPickerView.selectedIndex)]
                                      withIdentifier:_identifier];
        }
    }
    [self calculate];
}

- (void)calculate {
    NSString *FPS = _FPS[_FPSPickerView.selectedIndex];
    NSString *shutterSpeed = _shutterSpeed[_shutterSpeedPickerView.selectedIndex];
    NSString *filter = @"NONE";
    if (_filtersInstalled.count > 0 &&
        _filtersInstalledPickerView.selectedIndex != 0) {
        filter = _filtersInstalled[_filtersInstalledPickerView.selectedIndex - 1];
    }
    [_calculatorModel calculateResultWithFPS:FPS
                                  withFilter:filter
                            withShutterSpeed:shutterSpeed
                               andCompletion:^(NSString *result_1, NSString *result_2, NSString *result_3) {
                                   
                                   [_filterResult_1_Label setText:result_1];
                                   [_filterResult_2_Label setText:result_2];
                                   [_filterResult_3_Label setText:result_3];
                                   
                                   PPDevicesModel *deviceModel = [PPDevicesModel sharedDevicesModel];
                                   PPFilter *filter = [deviceModel m_filterWithName:result_1
                                                                  forDeviceWithName:_device];
                                   _purchasedFilter = filter ? filter.isAvailable : YES;
                                   _URL = filter.URL;
                                   if ([result_1 isEqualToString:@"NO FILTER"] ||
                                       [result_1 isEqualToString:@"NONE"] ||
                                       _purchasedFilter) {
                                       [_shopNowLabel setText:nil];
                                   } else {
                                       [_shopNowLabel setText:LOCALIZE(@"shop_now")];
                                   }
                               }];
}

- (void)shopNowView_TUI {
    if (_purchasedFilter) {
        return;
    }
    if (!_URL || [_URL isEqualToString:@""]) {
        _URL = @"https://www.polarprofilters.com";
    }
    PPWebViewController *webVC = [[PPWebViewController alloc] initWithURL:_URL];
    [((UIViewController *)_delegate).navigationController pushViewController:webVC
                                                                    animated:YES];
}

@end
