//
//  PPLocationsViewController.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 16.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "VPDraggableTableView.h"


#define kHeightSearchTextField (60.f)


@interface PPLocationsViewController : UIViewController

@property (weak, nonatomic) IBOutlet VPDraggableTableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;

@property (strong, nonatomic) UITextField *searchTextField;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(VPDraggableTableView *)tableView dragCellFromSourceIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)indexPath;

- (BOOL)didSwitchCurrentLocationWithIndexPath:(NSIndexPath *)indexPath;
- (void)didDeleteLocationWithIndexPath:(NSIndexPath *)indexPath;

- (void)didFindNearestCityByLastCoordinate;

- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;

@end
