//
//  PPSettingsTableViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 15.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


#define kSettingsItemRI (@"PPSettingsTableViewCell")


@protocol PPSettingsTableViewCellDelegate <NSObject>

@optional

- (void)didChangeSegmentedControlWithIndex:(NSUInteger)index
                              andIndexPath:(NSIndexPath *)indexPath;

@end


@interface PPSettingsTableViewCell : UITableViewCell

@property (strong, nonatomic) id<PPSettingsTableViewCellDelegate> delegate;

@property (assign, nonatomic) NSIndexPath *indexPath;

@property (assign, nonatomic) NSUInteger selectedSegment;

@property (assign, nonatomic) NSString *title;

@property (strong, nonatomic) NSArray <NSString *> *parameters;

@end
