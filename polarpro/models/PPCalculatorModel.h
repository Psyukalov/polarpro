//
//  PPCalculatorModel.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 22.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "PPDevicesModel.h"


@interface PPCalculatorModel : NSObject

- (void)calculateResultWithFPS:(NSString *)FPS
                    withFilter:(NSString *)filter
              withShutterSpeed:(NSString *)shutterSpeed
                 andCompletion:(void (^)(NSString *result_1,
                                         NSString *result_2,
                                         NSString *result_3))completion;

@end
