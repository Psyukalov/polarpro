//
//  PPMenuModel.h
//  polarpro
//
//  Created by Владимир Псюкалов on 05.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface PPMenuItem : NSObject

@property (strong, readonly, nonatomic) NSString *title;
@property (strong, readonly, nonatomic) NSString *imageString;

@property (assign, readonly, nonatomic) BOOL isPush;

@property (strong, readonly, nonatomic) Class viewControllerClass;

- (instancetype)initWithLocalizedString:(NSString *)localizedString
                        withImageString:(NSString *)imageString
                             withIsPush:(BOOL)isPush
                               andClass:(Class)viewControllerClass;

@end

@interface PPMenuModel : NSObject

@property (strong, readonly, nonatomic) NSString *title;
@property (strong, readonly, nonatomic) NSString *tip;
@property (strong, readonly, nonatomic) NSString *version;

@property (strong, readonly, nonatomic) NSMutableArray <PPMenuItem *> *items;

- (instancetype)initMenuItems;
- (instancetype)initSupportItems;
- (instancetype)initFilsterGuideSettingsItems;

- (void)menuViewControllerActionWithTarget:(id)target
                                  andIndex:(NSUInteger)index;
- (void)supportViewControllerActionWithTarget:(id)target
                                     andIndex:(NSUInteger)index;
- (void)filterGuideSettingsViewControllerActionWithTarget:(id)target
                                                 andIndex:(NSUInteger)index;

@end
