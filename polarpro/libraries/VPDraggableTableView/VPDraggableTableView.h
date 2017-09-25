//
//  VPDraggableTableView.h
//
//  Created by Vladimir Psyukalov on 16.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@class VPDraggableTableView;


@protocol VPDraggableTableViewDelegate <NSObject>

@required

- (void)tableView:(VPDraggableTableView *)tableView dragCellFromSourceIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)indexPath;

@optional

- (BOOL)tableView:(VPDraggableTableView *)tableView canDragCellAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface VPDraggableTableView : UITableView

@property (strong, nonatomic) id<VPDraggableTableViewDelegate> draggableDelegate;

@end
