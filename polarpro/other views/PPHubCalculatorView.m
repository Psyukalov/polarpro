//
//  PPHubCalculatorView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 11.12.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPHubCalculatorView.h"

#import "Macros.h"

#import "PPUtils.h"

#import "UIView+PPCustomView.h"


@interface PPHubCalculatorView ()

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end


@implementation PPHubCalculatorView

- (void)loadViewFromNib {
    [super loadViewFromNib];
    _mainView.backgroundColor = RGB(28.f, 30.f, 34.f);
    [_mainView applyCornerRadius:6];
    [_titleLabel setFont:[UIFont fontWithName:@"BN-Regular"
                                         size:34.f]];
    [PPUtils resizeLabelsInView:_mainView];
    [self setType:0];
}

- (void)setType:(NSUInteger)type {
    _type = type;
    NSString *title;
    NSString *subtitle;
    UIImage *image;
    switch (_type) {
        case 0: {
            title = LOCALIZE(@"hub_guide_0");
            subtitle = LOCALIZE(@"hub_guide_tip_0");
            image = [UIImage imageNamed:@"filters_i.png"];
        }
            break;
        case 1: {
            title = LOCALIZE(@"hub_guide_1");
            subtitle = LOCALIZE(@"hub_guide_tip_1");
            image = [UIImage imageNamed:@"filters_i.png"];
        }
            break;
        default:
            //
            break;
    }
    _titleLabel.text = title;
    _subtitleLabel.text = subtitle;
    _imageView.image = image;
    _pageControl.currentPage = _type;
}

@end
