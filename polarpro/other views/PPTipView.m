//
//  PPTipView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 11.12.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPTipView.h"


@interface PPTipView ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end


@implementation PPTipView

- (void)setText:(NSString *)text {
    _text = text;
    _textLabel.text = _text;
}

@end
