//
//  PPMenuViewController.m
//  polarpro
//
//  Created by Владимир Псюкалов on 05.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPMenuViewController.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"

#import "PPMenuModel.h"

#import "PPMenuItemTableViewCell.h"

#import "PPKPInfoViewController.h"

#import "PPFilterGuideViewController.h"

#import "PPHubViewController.h"

#import "PPAboutUsViewController.h"


@interface PPMenuViewController () <UITableViewDataSource, UITableViewDelegate> {
    
    CGFloat cellHeight;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *youtubeButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;
@property (weak, nonatomic) IBOutlet UIButton *vimeoButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (strong, nonatomic) PPMenuModel *menuModel;

@end


@implementation PPMenuViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _menuModel = [[PPMenuModel alloc] initMenuItems];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:RGB(24.f, 26.f, 30.f)];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setup {
    [self.view setBackgroundColor:RGB(24.f, 26.f, 30.f)];
    [self.navigationItem setTitle:_menuModel.title];
    [_versionLabel setText:_menuModel.version];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self.navigationController.navigationBar setBarTintColor:RGB(24.f, 26.f, 30.f)];
    [self createCloseBBI];
    [self createLogoBBI];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PPMenuItemTableViewCell class])
                                           bundle:nil]
     forCellReuseIdentifier:kMenuItemRI];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

#pragma mark - Actions

- (IBAction)homeButton_TUI:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)youtubeButton_TUI:(UIButton *)sender {
    [self openSchemes:@[@"youtube://www.youtube.com/PolarProFilters",
                        @"https://youtube.com/PolarProFilters"]];
}

- (IBAction)facebookButton_TUI:(UIButton *)sender {
    [self openSchemes:@[@"fb://profile/polarpro",
                        @"https://www.facebook.com/polarpro"]];
}

- (IBAction)instagramButton_TUI:(UIButton *)sender {
    [self openSchemes:@[@"instagram://user?username=polarpro",
                        @"https://instagram.com/polarpro"]];
}

- (IBAction)vimeoButton_TUI:(UIButton *)sender {
    [self openSchemes:@[@"vimeo://polarpro",
                        @"https://vimeo.com/polarpro"]];
}

- (IBAction)twitterButton_TUI:(UIButton *)sender {
    [self openSchemes:@[@"twitter://user?screen_name=_PolarPro",
                        @"https://twitter.com/_PolarPro"]];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    cellHeight = _tableView.frame.size.height / _menuModel.items.count;
    return _menuModel.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PPMenuItemTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kMenuItemRI
                                           forIndexPath:indexPath];
    if (_menuModel.items.count > 0) {
        [cell setTitle:_menuModel.items [indexPath.row].title];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_menuModel menuViewControllerActionWithTarget:self
                                          andIndex:indexPath.row];
}

@end
