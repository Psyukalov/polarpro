//
//  PPAlertView.h
//  polarpro
//
//  Created by Vladimir Psyukalov on 27.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


@class PPAlertView;
@class PPActionButton;


typedef NS_ENUM(NSUInteger, PPActionButtonType) {
    PPActionButtonTypeNone = 0,
    PPActionButtonTypeCancel,
    PPActionButtonTypeOk
};


@protocol PPAlertViewDelegate <NSObject>

@optional

- (void)alertView:(PPAlertView *)alertView didActionWithActionButton:(PPActionButton *)actionButton;

@end


@protocol PPActionButtonDelegate <NSObject>

@optional

- (void)didActionWithActionButton:(PPActionButton *)actionButton;

@end


@interface PPActionButton : UIButton

@property (strong, nonatomic) id<PPActionButtonDelegate> delegate;

@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSString *key; // For defining action.

@property (assign, nonatomic) PPActionButtonType type;

+ (id)actionButtonTypeOkWithKey:(NSString *)key;
+ (id)actionButtonTypeCancelWithKey:(NSString *)key;

- (instancetype)initWithKey:(NSString *)key
                    andType:(PPActionButtonType)type;

@end


@interface PPAlertView : UIView

@property (strong, nonatomic) id<PPAlertViewDelegate> delegate;

@property (strong, nonatomic) UIViewController *target;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;

@property (strong, nonatomic) NSArray <PPActionButton *> *actionButtons;

+ (void)showErrorAlertViewWithMessage:(NSString *)message;

- (instancetype)initWithTarget:(UIViewController *)target;

- (instancetype)init; // __attribute__((deprecated("Use initWithTarget instead.")));

- (void)show;
- (void)hide;

@end
