//
//  PPSupportViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPSupportViewController.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "UITableView+PPCustomHeaderFooterView.h"

#import "PPMenuModel.h"

#import "PPSupportTableViewCell.h"


@interface PPSupportViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *watermarkImageView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) PPViewControllerType viewControllerType;

@property (strong, nonatomic) PPMenuModel *menuModel;

@end


@implementation PPSupportViewController

- (instancetype)initWithViewControllerType:(PPViewControllerType)viewControllerType {
    self = [super init];
    if (self) {
        _viewControllerType = viewControllerType;
        _menuModel = [PPMenuModel alloc];
        switch (_viewControllerType) {
            case PPSupportViewCotrollerType:
                _menuModel = [_menuModel initSupportItems];
                break;
            case PPFilterGuideSettingsViewControllerType:
                _menuModel = [_menuModel initFilsterGuideSettingsItems];
                break;
            default:
                //
                break;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setup {
    [self.view setBackgroundColor:MAIN_COLOR];
    [self.navigationItem setTitle:_menuModel.title];
    [self applyNavigationBarWithFont:nil
                      withColor:nil];
    [self createBackBBI];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PPSupportTableViewCell class])
                                           bundle:nil]
     forCellReuseIdentifier:kSupportItemRI];
    [_tableView applyHeaderViewWithString:_menuModel.tip
                               andPadding:CGPaddingMake(20.f, 20.f, 20.f, 20.f)];
    [_tableView applySettings];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _menuModel.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PPSupportTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kSupportItemRI
                                           forIndexPath:indexPath];
    if (_menuModel.items.count > 0) {
        [cell setTitle:_menuModel.items [indexPath.row].title];
        [cell setWithForwardImage:_menuModel.items [indexPath.row].isPush];
        [cell setImageString:_menuModel.items [indexPath.row].imageString];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_viewControllerType) {
        case PPSupportViewCotrollerType:
            [_menuModel supportViewControllerActionWithTarget:self
                                                     andIndex:indexPath.row];
            break;
        case PPFilterGuideSettingsViewControllerType:
            [_menuModel filterGuideSettingsViewControllerActionWithTarget:self
                                                                 andIndex:indexPath.row];
            break;
        default:
            //
            break;
    }
}

@end
