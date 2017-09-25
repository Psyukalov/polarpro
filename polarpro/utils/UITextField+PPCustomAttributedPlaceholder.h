//
//  UITextField+PPCustomAttributedPlaceholder.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UITextField (PPCustomAttributedPlaceholder)

- (void)applyAttributedPlaceholderWithString:(NSString *)string
                                    withFont:(UIFont *)font
                                    andColor:(UIColor *)color;

@end
