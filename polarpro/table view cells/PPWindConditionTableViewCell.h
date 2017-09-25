//
//  PPWindConditionTableViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 14.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


#define kWindConditionTableViewCellRI (@"PPWindConditionTableViewCell")


@interface PPWindConditionTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *weekday;
@property (strong, nonatomic) NSString *direction;
@property (strong, nonatomic) NSString *units;

@property (assign, nonatomic) CGFloat speed;

@end
