//
//  PPSettingsModel.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 15.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface PPSettingsOption : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *key;

@property (strong, nonatomic) NSArray *parameters;

@property (assign, nonatomic) NSUInteger currentParameter;

- (instancetype)initWithTitle:(NSString *)title
                      withKey:(NSString *)key
                   andParameters:(NSArray <NSString *> *)parameters;

@end

@interface PPSettingsGroup : NSObject

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSMutableArray <PPSettingsOption *> *options;

- (instancetype)initWithTitle:(NSString *)title;

@end

@interface PPSettingsModel : NSObject

+ (id)sharedModel;

@property (strong, nonatomic) NSMutableArray <PPSettingsGroup *> *groups;

- (void)m_saveOptionWithGroup:(NSUInteger)group
                   withOption:(NSUInteger)option
                 andParameter:(NSUInteger)parameter;

@end


@interface PPNotificationOption : PPSettingsOption

@end
