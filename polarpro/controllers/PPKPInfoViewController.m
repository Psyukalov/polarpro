//
//  PPKPInfoViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPKPInfoViewController.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "UILabel+PPCustomAttributedString.h"
#import "PPUtils.h"


@interface PPKPInfoViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *watermarkImageView;

@end


@implementation PPKPInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    [self.view setBackgroundColor:MAIN_COLOR];
    [self.navigationItem setTitle:LOCALIZE(@"kp_information")];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createBackBBI];
    [_descriptionLabel applyAttributedStringWithString:LOCALIZE(@"kp_information_description")];
    [PPUtils resizeLabelsInView:_contentView];
    [PPUtils resizeMarginsInView:_contentView];
}

@end
