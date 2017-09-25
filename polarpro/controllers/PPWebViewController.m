//
//  PPWebViewController.m
//  polarpro
//
//  Created by Владимир Псюкалов on 06.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPWebViewController.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"


@interface PPWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong ,nonatomic) UIActivityIndicatorView *indicatorView;

@property (strong, nonatomic) NSString *URL;

@end


@implementation PPWebViewController

- (instancetype)initWithURL:(NSString *)URL {
    self = [super init];
    if (self) {
        _URL = URL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_URL]]];
    [self.view setBackgroundColor:MAIN_COLOR];
    [self.navigationItem setTitle:nil];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createBackBBI];
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *indicatorBBI = [[UIBarButtonItem alloc] initWithCustomView:_indicatorView];
    [self.navigationItem setRightBarButtonItem:indicatorBBI];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_indicatorView stopAnimating];
}

@end
