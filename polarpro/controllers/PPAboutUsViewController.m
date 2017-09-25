//
//  PPAboutUsViewController.m
//  polarpro
//
//  Created by Владимир Псюкалов on 06.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPAboutUsViewController.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "UILabel+PPCustomAttributedString.h"
#import "PPUtils.h"

#import "PPWebViewController.h"

#import "PPAlertView.h"


@interface PPAboutUsViewController () <PPAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *siteButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end


@implementation PPAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    [self.view setBackgroundColor:MAIN_COLOR];
    /*
     
     if navigation item title is nil then use castom logo.
     
     See method applyNavigationBarWithFont:andColor: in category "+PPCostomViewController.h"
     
     */
    [self.navigationItem setTitle:LOCALIZE(@"about_us")];
    /*
     
     if font and/or color is nil then use custom font and/or color.
     
     More in category "+PPCostomViewController.h"
     
     */
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [_imageView setImage:[UIImage imageNamed:@"about_us_i.jpg"]];
    [_siteButton setTitle:@"www.polarpro.com"
                 forState:UIControlStateNormal];
    [_phoneButton setTitle:@"+1 949 220 9395"
                  forState:UIControlStateNormal];
    [_emailButton setTitle:@"support@polarpro.com"
                  forState:UIControlStateNormal];
    [_descriptionLabel applyAttributedStringWithString:LOCALIZE(@"about_us_description")];
    [self createBackBBI];
    [PPUtils resizeLabelsInView:_contentView];
    [PPUtils resizeMarginsInView:_contentView];
}

- (IBAction)siteButton_TUI:(UIButton *)sender {
    PPWebViewController *webVC = [[PPWebViewController alloc] initWithURL:@"https://www.polarprofilters.com/"];
    [self.navigationController pushViewController:webVC
                                         animated:YES];
}

- (IBAction)phoneButton_TUI:(UIButton *)sender {
    
    /*
    PPAlertView *alertView = [[PPAlertView alloc] initWithTarget:self];
    [alertView setDelegate:self];
    [alertView setTitle:LOCALIZE(@"main_phone_number")];
    [alertView setMessage:LOCALIZE(@"make_call")];
    PPActionButton *cancelActionButton = [PPActionButton actionButtonTypeCancelWithKey:@"cancel"];
    PPActionButton *callActionButton = [PPActionButton actionButtonTypeOkWithKey:@"call"];
    [callActionButton setCaption:LOCALIZE(@"call")];
    [alertView setActionButtons:@[cancelActionButton, callActionButton]];
    [alertView show];
     */
    
    [self openSchemes:@[@"tel:+19492209395"]];
}

- (IBAction)emailButton_TUI:(UIButton *)sender {
    [self openSchemes:@[[NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", @"support@polarpro.com", @"Support", @"Description"]]];
}

/*
#pragma mark - PPAlertView

- (void)alertView:(PPAlertView *)alertView didActionWithActionButton:(PPActionButton *)actionButton {
    if ([actionButton.key isEqualToString:@"cancel"]) {
        //
    } else if ([actionButton.key isEqualToString:@"call"]) {
        [self openSchemes:@[@"tel:+19492209395"]];
    }
}
 */

@end
