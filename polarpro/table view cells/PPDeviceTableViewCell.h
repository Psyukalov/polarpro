//
//  PPDeviceTableViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 11.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


#define kDeviceItemRI (@"PPDeviceTableViewCell")


@interface PPDeviceTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *mark;
@property (strong, nonatomic) NSString *model;

@end
