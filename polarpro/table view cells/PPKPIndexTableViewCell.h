//
//  PPKPIndexTableViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 13.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


#define kKPIndexItemRI (@"PPKPIndexTableViewCell")


@interface PPKPIndexTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *date;

@property (assign, nonatomic) CGFloat index;

@end
