//
//  PPSupportTableViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


#define kSupportItemRI (@"PPSupportTableViewCell")


@interface PPSupportTableViewCell : UITableViewCell

@property (assign, nonatomic) BOOL withForwardImage;

@property (strong, nonatomic) NSString *imageString;
@property (strong, nonatomic) NSString *title;

@end
