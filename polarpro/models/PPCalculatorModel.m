//
//  PPCalculatorModel.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 22.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPCalculatorModel.h"

#import "Macros.h"


@interface PPCalculatorModel ()

@property (strong, nonatomic) NSDictionary *data;

@end


@implementation PPCalculatorModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data"
                                                     ofType:@"json"];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path];
    _data = [NSJSONSerialization JSONObjectWithData:data
                                            options:kNilOptions
                                              error:&error];
    if (error) {
        NSLog(@"Data error: %@;", error.localizedDescription);
    }
}

- (void)calculateResultWithFPS:(NSString *)FPS
                    withFilter:(NSString *)filter
              withShutterSpeed:(NSString *)shutterSpeed
                 andCompletion:(void (^)(NSString *, NSString *, NSString *))completion {
    if (!_data) {
        return;
    }
    NSDictionary *result = (NSDictionary *)_data[FPS][filter][shutterSpeed];
    if (!result) {
        result = @{@"res_1" : LOCALIZE(@"none"),
                   @"res_2" : LOCALIZE(@"enter_other_parameters"),
                   @"res_3" : @""};
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) {
            completion (result[@"res_1"], result[@"res_2"], result[@"res_3"]);
        }
    });
}

@end
