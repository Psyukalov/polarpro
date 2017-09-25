//
//  PPHourlyWindConditionCollectionViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 14.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


#define kHourlyWindConditionCollectionViewCellRI (@"PPHourlyWindConditionCollectionViewCell")


@interface PPHourlyWindConditionCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *speed;
@property (strong, nonatomic) NSString *direction;

@end
