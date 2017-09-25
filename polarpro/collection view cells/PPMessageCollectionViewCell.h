//
//  PPMessageCollectionViewCell.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 21.07.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#define kMessageCollectionViewCellRI (@"PPMessageCollectionViewCell")


#import <UIKit/UIKit.h>


@protocol PPMessageCollectionViewCellDelegate <NSObject>

@optional

- (void)didActionWithButton:(UIButton *)button;

@end


@interface PPMessageCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) id<PPMessageCollectionViewCellDelegate> delegate;

@end
