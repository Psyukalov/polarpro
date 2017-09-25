//
//  PPAlertView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 27.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPAlertView.h"

#import "Macros.h"
#import "UIView+PPCustomView.h"


#define kActionButtonHeight (84.f)


@interface PPActionButton ()

//

@end


@implementation PPActionButton

+ (id)actionButtonTypeOkWithKey:(NSString *)key {
    return [[PPActionButton alloc] initWithKey:key
                                       andType:PPActionButtonTypeOk];
}

+ (id)actionButtonTypeCancelWithKey:(NSString *)key {
    return [[PPActionButton alloc] initWithKey:key
                                       andType:PPActionButtonTypeCancel];
}

- (instancetype)initWithKey:(NSString *)key
                    andType:(PPActionButtonType)type {
    self = [super init];
    if (self) {
        _key = key;
        _type = type;
        [self setup];
    }
    return self;
}

- (void)setup {
    [self changeType];
    [self addTarget:self
             action:@selector(button_TUI)
   forControlEvents:UIControlEventTouchUpInside];
}

- (void)changeType {
    switch (_type) {
        case PPActionButtonTypeOk: {
            [self.titleLabel setFont:[UIFont fontWithName:@"BN-Regular"
                                                     size:34.f]];
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            [self setTitleColor:RGB(54.f, 64.f, 78.f)
                       forState:UIControlStateHighlighted];
            [self setCaption:LOCALIZE(@"alert_ok")];
        }
            break;
        case PPActionButtonTypeCancel: {
            [self.titleLabel setFont:[UIFont fontWithName:@"BN-Regular"
                                                     size:34.f]];
            [self setTitleColor:RGB(84.f, 92.f, 98.f)
                       forState:UIControlStateNormal];
            [self setTitleColor:RGB(54.f, 64.f, 78.f)
                       forState:UIControlStateHighlighted];
            [self setCaption:LOCALIZE(@"alert_cancel")];
        }
            break;
        case PPActionButtonTypeNone:
            // Custom button design.
            break;
    }
}

- (void)setCaption:(NSString *)caption {
    _caption = caption;
    [self setTitle:_caption
          forState:UIControlStateNormal];
}

- (void)setType:(PPActionButtonType)type {
    _type = type;
    [self changeType];
}

- (void)button_TUI {
    if (_delegate) {
        if ([_delegate conformsToProtocol:@protocol(PPActionButtonDelegate)] ||
            [_delegate respondsToSelector:@selector(didActionWithActionButton:)]) {
            [_delegate didActionWithActionButton:self];
        }
    }
}

@end


@interface PPAlertView () <PPActionButtonDelegate>

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *alertView;

@property (weak, nonatomic) IBOutlet UIView *actionsView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionsViewLC;

@end


@implementation PPAlertView

- (instancetype)initWithTarget:(UIViewController *)target {
    self = [super init];
    if (self) {
        _target = target;
        [self loadViewFromNib];
        [self setup];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadViewFromNib];
        [self setup];
    }
    return self;
}
 
- (void)loadViewFromNib {
    [self setFrame:CGRectMake(0.f, 0.f, WIDTH, HEIGHT)];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *nib = [UINib nibWithNibName:@"PPAlertView"
                                bundle:bundle];
    UIView *view = (UIView *)[nib instantiateWithOwner:self
                                               options:nil].firstObject;
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:view];
    NSArray *attributes = @[@(NSLayoutAttributeLeft),
                            @(NSLayoutAttributeTop),
                            @(NSLayoutAttributeRight),
                            @(NSLayoutAttributeBottom)];
    for (NSNumber *attribute in attributes) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:[attribute unsignedIntegerValue]
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:[attribute unsignedIntegerValue]
                                                        multiplier:1.f
                                                          constant:0.f]];
    }
}

- (void)setup {
    [self setBackgroundColor:[UIColor clearColor]];
    [_mainView setBackgroundColor:RGBA(32.f, 38.f, 42.f, .96f * 255)];
    [_alertView setBackgroundColor:RGB(18.f, 20.f, 24.f)];
    [_alertView applyCornerRadius:6.f];
    [self hideUIState];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [_titleLabel setText:_title];
}

- (void)setMessage:(NSString *)message {
    _message = message;
    [_messageLabel setText:_message];
}

- (void)setActionButtons:(NSArray <PPActionButton *> *)actionButtons {
    _actionButtons = actionButtons;
    for (UIView *view in _actionsView.subviews) {
        [view removeFromSuperview];
    }
    if (!_actionButtons || _actionButtons.count == 0) {
        PPActionButton *actionButton = [PPActionButton actionButtonTypeOkWithKey:nil];
        [actionButton setDelegate:self];
        _actionButtons = @[actionButton];
    }
    CGFloat constant = kActionButtonHeight;
    if (_actionButtons.count == 2) {
        
        [_actionsViewLC setConstant:constant];
        
        PPActionButton *button_0 = _actionButtons[0];
        [button_0 setDelegate:self];
        button_0.backgroundColor = (button_0.type == PPActionButtonTypeOk) || (button_0.type == PPActionButtonTypeCancel) ? _alertView.backgroundColor : button_0.backgroundColor;
        
        [button_0 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_actionsView addSubview:button_0];
        [_actionsView addConstraint:[NSLayoutConstraint constraintWithItem:button_0
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_actionsView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.f
                                                                  constant:0.f]];
        [_actionsView addConstraint:[NSLayoutConstraint constraintWithItem:button_0
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_actionsView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.f
                                                                  constant:0.f]];
        [_actionsView addConstraint:[NSLayoutConstraint constraintWithItem:button_0
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_actionsView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.f
                                                                  constant:0.f]];
        [_actionsView addConstraint:[NSLayoutConstraint constraintWithItem:button_0
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_actionsView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:.5f
                                                                  constant:0.f]];
        
        PPActionButton *button_1 = _actionButtons[1];
        [button_1 setDelegate:self];
        button_1.backgroundColor = (button_1.type == PPActionButtonTypeOk) || (button_1.type == PPActionButtonTypeCancel) ? _alertView.backgroundColor : button_1.backgroundColor;
        
        [button_1 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_actionsView addSubview:button_1];
        [_actionsView addConstraint:[NSLayoutConstraint constraintWithItem:button_1
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_actionsView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.f
                                                                  constant:0.f]];
        [_actionsView addConstraint:[NSLayoutConstraint constraintWithItem:button_1
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_actionsView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.f
                                                                  constant:0.f]];
        [_actionsView addConstraint:[NSLayoutConstraint constraintWithItem:button_1
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:button_0
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.f
                                                                  constant:0.f]];
        [_actionsView addConstraint:[NSLayoutConstraint constraintWithItem:button_1
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_actionsView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.f
                                                                  constant:0.f]];
        
    } else {
        
        constant = _actionButtons.count * kActionButtonHeight;
        [_actionsViewLC setConstant:constant];
        UIView *previosElement = _actionsView;
        
        for (NSUInteger i = 0; i <= _actionButtons.count - 1; i++) {
            PPActionButton *button = _actionButtons[i];
            button.backgroundColor = (button.type == PPActionButtonTypeOk) || (button.type == PPActionButtonTypeCancel) ? _alertView.backgroundColor : button.backgroundColor;
            [button setDelegate:self];
            
            [button setTranslatesAutoresizingMaskIntoConstraints:NO];
            [_actionsView addSubview:button];
            NSLayoutAttribute attribute = (i == 0) ? NSLayoutAttributeTop : NSLayoutAttributeBottom;
            [_actionsView addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:previosElement
                                                                     attribute:attribute
                                                                    multiplier:1.f
                                                                      constant:0.f]];
            [_actionsView addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_actionsView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.f
                                                                      constant:0.f]];
            [_actionsView addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_actionsView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.f
                                                                      constant:0.f]];
            [_actionsView addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.f
                                                                      constant:kActionButtonHeight]];
            previosElement = button;
        }
    }
}

- (void)showUIState {
    [self applyAlpha:1.f
            andScale:1.f];
}

- (void)hideUIState {
    [self applyAlpha:0.f
            andScale:.8f];
}

- (void)applyAlpha:(CGFloat)alpha
          andScale:(CGFloat)scale {
    [_mainView setAlpha:alpha];
    [_alertView setAlpha:alpha];
    [_alertView setTransform:CGAffineTransformMakeScale(scale, scale)];
}

- (void)show {
    if (!_target) {
        _target = ((UINavigationController *)[APPLICATION delegate].window.rootViewController).visibleViewController;
    }
    UIView *rootView = _target.view;
    if (_target.navigationController) {
        rootView = _target.navigationController.view;
    }
    if ([rootView.subviews.lastObject isKindOfClass:[PPAlertView class]]) {
        NSLog(@"Alert view alredy shown;");
        return;
    }
    [rootView addSubview:self];
    NSArray *attributes = @[@(NSLayoutAttributeLeft),
                            @(NSLayoutAttributeTop),
                            @(NSLayoutAttributeRight),
                            @(NSLayoutAttributeBottom)];
    for (NSNumber *attribute in attributes) {
        [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                             attribute:[attribute unsignedIntegerValue]
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:rootView
                                                             attribute:[attribute unsignedIntegerValue]
                                                            multiplier:1.f
                                                              constant:0.f]];
    }
    [UIView animateWithDuration:.2f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_mainView setAlpha:1.f];
                     }
                     completion:nil];
    [UIView animateWithDuration:.4f
                          delay:.2f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_alertView setAlpha:1.f];
                         [_alertView setTransform:CGAffineTransformIdentity];
                     }
                     completion:nil];
}

- (void)hide {
    [UIView animateWithDuration:.2f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_mainView setAlpha:0.f];
                     }
                     completion:nil];
    [UIView animateWithDuration:.4f
                          delay:.2f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_alertView setAlpha:0.f];
                         [_alertView setTransform:CGAffineTransformMakeScale(.8f, .8f)];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark - PPActionButtonDelegate

- (void)didActionWithActionButton:(PPActionButton *)actionButton {
    if (_delegate) {
        if ([_delegate conformsToProtocol:@protocol(PPAlertViewDelegate)] &&
            [_delegate respondsToSelector:@selector(alertView:didActionWithActionButton:)]) {
            [_delegate alertView:self didActionWithActionButton:actionButton];
        }
    }
    [self hide];
}

#pragma marks - Static methods

+ (void)showErrorAlertViewWithMessage:(NSString *)message {
    PPAlertView *alertView = [[PPAlertView alloc] init];
    [alertView setTitle:LOCALIZE(@"error")];
    [alertView setMessage:message];
    [alertView setActionButtons:@[[PPActionButton actionButtonTypeOkWithKey:@"ok"]]];
    [alertView show];
}

@end
