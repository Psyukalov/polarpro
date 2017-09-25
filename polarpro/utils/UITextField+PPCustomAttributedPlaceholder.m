//
//  UITextField+PPCustomAttributedPlaceholder.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "UITextField+PPCustomAttributedPlaceholder.h"


@implementation UITextField (PPCustomAttributedPlaceholder)

- (void)applyAttributedPlaceholderWithString:(NSString *)string
                                    withFont:(UIFont *)font
                                    andColor:(UIColor *)color {
    if (!string) {
        string = @"Error: Empty string;";
    }
    if (!font) {
        font = [UIFont fontWithName:@"Montserrat-LightItalic"
                               size:16.f];
    }
    if (!color) {
        color = [UIColor whiteColor];
    }
    NSDictionary *attributes = @{NSForegroundColorAttributeName : color,
                                 NSFontAttributeName : font};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string
                                                                           attributes:attributes];
    [self setAttributedPlaceholder:attributedString];
}

@end
