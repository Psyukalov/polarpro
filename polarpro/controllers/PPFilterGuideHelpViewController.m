//
//  PPFilterGuideHelpViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 10.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPFilterGuideHelpViewController.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "UILabel+PPCustomAttributedString.h"
#import "PPUtils.h"


@interface PPFilterGuideHelpViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *howToUseTitle;
@property (weak, nonatomic) IBOutlet UILabel *howToUseDescription;
@property (weak, nonatomic) IBOutlet UILabel *tipsTitle;
@property (weak, nonatomic) IBOutlet UILabel *tipsDescription;
@property (weak, nonatomic) IBOutlet UILabel *faqTitle;
@property (weak, nonatomic) IBOutlet UILabel *faqDescription;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end


@implementation PPFilterGuideHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self localize];
    [PPUtils resizeLabelsInView:_contentView];
    [PPUtils resizeMarginsInView:_contentView];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setup {
    [self.view setBackgroundColor:MAIN_COLOR];
    [self.navigationItem setTitle:LOCALIZE(@"filter_guide_help")];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createBackBBI];
}

- (void)localize {
    [_howToUseTitle setText:LOCALIZE(@"how_to_use")];
    [_tipsTitle setText:LOCALIZE(@"tips")];
    [_faqTitle setText:LOCALIZE(@"faq")];
    [_howToUseDescription applyAttributedStringWithString:LOCALIZE(@"how_to_use_description")];
    [_tipsDescription applyAttributedStringWithString:LOCALIZE(@"tips_description")];
    [_faqDescription applyAttributedStringWithString:LOCALIZE(@"faq_description")];
}

@end
