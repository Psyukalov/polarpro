//
//  PPLocationTableViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 16.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


#define kLocationItemRI (@"PPLocationTableViewCell")


@protocol PPLocationTableViewCellDelegate <NSObject>

@optional

- (void)didDeleteLocationWithIndexPath:(NSIndexPath *)indexPath;

@end


@interface PPLocationTableViewCell : UITableViewCell

@property (strong, nonatomic) id<PPLocationTableViewCellDelegate> delegate;

@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) NSString *title;

@end
