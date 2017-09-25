//
//  PPCurrentLocationTableViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 16.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


#define kCurrentLocationItemRI (@"PPCurrentLocationTableViewCell")


@protocol PPCurrentLocationTableViewCellDelegate <NSObject>

@optional

- (BOOL)didSwitchCurrentLocationWithIndexPath:(NSIndexPath *)indexPath;
 
@end


@interface PPCurrentLocationTableViewCell : UITableViewCell

@property (strong, nonatomic) id<PPCurrentLocationTableViewCellDelegate> delegate;

@property (assign, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) NSString *title;

@property (assign, nonatomic) BOOL useCurrentLocation;

@end
