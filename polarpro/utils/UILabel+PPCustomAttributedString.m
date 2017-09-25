//
//  UILabel+PPCustomAttributedString.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "UILabel+PPCustomAttributedString.h"

#import "Macros.h"


@implementation UILabel (PPCustomAttributedString)


- (void)applyAttributedStringWithString:(NSString *)string {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4.f];
    [paragraphStyle setParagraphSpacing:32.f];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    UIFont *font = [UIFont fontWithName:@"Montserrat-Light"
                                   size:14.f];
    NSDictionary *attributes = @{NSParagraphStyleAttributeName : paragraphStyle,
                                 NSFontAttributeName : font,
                                 NSForegroundColorAttributeName : [UIColor whiteColor]};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string
                                                                           attributes:attributes];
    [self setAttributedText:attributedString];
}

@end
