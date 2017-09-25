//
//  PPDeviceHeaderView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 12.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "FZAccordionTableView.h"


#define kDeviceHeaderViewRI (@"PPDeviceHeaderView")


@interface PPDeviceHeaderView : FZAccordionTableViewHeaderView

@property (strong, nonatomic) NSString *mark;
@property (strong, nonatomic) NSString *model;

@property (assign, nonatomic) BOOL isSelected;

@end
