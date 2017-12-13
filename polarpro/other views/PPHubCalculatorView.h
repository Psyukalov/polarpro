//
//  PPHubCalculatorView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 11.12.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "CCView.h"


@class PPHubCalculatorView;


@protocol PPHubCalculatorViewDelegate <NSObject>

@optional

- (void)didTapHubCalculatorView:(PPHubCalculatorView *)hubCalculatorView withType:(NSUInteger)type;

@end


@interface PPHubCalculatorView : CCView

@property (weak, nonatomic) id<PPHubCalculatorViewDelegate> delegate;

@property (assign, nonatomic) NSUInteger type;

@end
