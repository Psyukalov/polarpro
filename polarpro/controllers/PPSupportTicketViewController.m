//
//  PPSupportTicketViewController.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 08.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPSupportTicketViewController.h"

#import "Macros.h"
#import "UIViewController+PPCostomViewController.h"
#import "UITextField+PPCustomAttributedPlaceholder.h"
#import <MessageUI/MessageUI.h>
#import <AFNetworking/AFNetworking.h>

#import "PPUser.h"

#import "PPAlertView.h"


@interface PPSupportTicketViewController () <UITextFieldDelegate, UITextViewDelegate, PPAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSubject;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIButton *sendMessgeButton;

/*
 @property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraint;
 */

@property (assign, nonatomic) BOOL isKeyboard;

@property (strong, nonatomic) UIFont *placeholderFont;

@property (strong, nonatomic) PPUser *user;

@end


@implementation PPSupportTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self localize];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setup {
    _user = [PPUser sharedUser];
    [self.view setBackgroundColor:MAIN_COLOR];
    _placeholderFont = _textView.font;
    
    [[AFHTTPSessionManager manager].requestSerializer setAuthorizationHeaderFieldWithUsername:@"" password:@""];
    
    /*
     [_layoutConstraint setConstant:HEIGHT - self.navigationController.navigationBar.frame.size.height - kStatusBarHeight];
     */
    
    [_textFieldName setText:_user.name];
    [_textFieldEmail setText:_user.email];
    [_textFieldSubject setText:nil];
    [_textView setText:nil];
    [self.navigationItem setTitle:LOCALIZE(@"support")];
    [self applyNavigationBarWithFont:nil
                           withColor:nil];
    [self createBackBBI];
    [_sendMessgeButton.titleLabel setFont:[UIFont fontWithName:@"BN-Regular"
                                                          size:34.f]];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardWillShow:)
                               name:UIKeyboardWillShowNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardWillHide:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:UIKeyboardWillShowNotification
                                object:nil];
    [notificationCenter removeObserver:self
                                  name:UIKeyboardWillHideNotification
                                object:nil];
}

- (void)localize {
    [_tipLabel setText:LOCALIZE(@"support_ticket_tip")];
    [self checkTextFields:@[_textFieldName,
                            _textFieldEmail,
                            _textFieldSubject]
     withLocalizedStrings:@[@"placeholder_your_name",
                            @"placeholder_your_email",
                            @"placeholder_subject"]
                 andColor:RGB(90.f, 96.f, 108.f)];
    [_textView setText:LOCALIZE(@"placeholder_problem_description")];
    [_sendMessgeButton setTitle:LOCALIZE(@"send_message")
                       forState:UIControlStateNormal];
}

- (void)becomeFirstResponderForTextView {
    if ([_textView.text isEqualToString:LOCALIZE(@"placeholder_problem_description")] ||
        [_textView.text isEqualToString:LOCALIZE(@"error_placeholder_problem_description")]) {
        [_textView setText:nil];
    }
    [_textView becomeFirstResponder];
    [_textView setTextColor:[UIColor whiteColor]];
    [_textView setFont:[UIFont fontWithName:@"Montserrat-Regular"
                                       size:16.f]];
}

- (BOOL)checkTextFields:(NSArray <UITextField *> *)textFields
   withLocalizedStrings:(NSArray <NSString *> *)localizedStrings
               andColor:(UIColor *)color {
    if (textFields.count != localizedStrings.count) {
        NSLog(@"Error;");
        return NO;
    }
    BOOL result = YES;
    for (NSUInteger i = 0; i <= textFields.count - 1; i++) {
        if ([textFields [i].text isEqualToString:@""]) {
            [textFields [i] applyAttributedPlaceholderWithString:LOCALIZE(localizedStrings [i])
                                                        withFont:nil
                                                        andColor:color];
        }
    }
    return result;
}

- (BOOL)checkTextView {
    BOOL result = YES;
    if ([_textView.text isEqualToString:@""] ||
        [_textView.text isEqualToString:LOCALIZE(@"placeholder_problem_description")] ||
        [_textView.text isEqualToString:LOCALIZE(@"error_placeholder_problem_description")]) {
        [_textView setText:LOCALIZE(@"error_placeholder_problem_description")];
        [_textView setTextColor:RGB(248.f, 10.f, 32.f)];
        [_textView setFont:_placeholderFont];
        result = NO;
    }
    return result;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (!_isKeyboard) {
        NSTimeInterval keyboardAnimationTime = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        [UIView animateWithDuration:keyboardAnimationTime
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_scrollView setContentInset:UIEdgeInsetsMake(0.f, 0.f, keyboardHeight, 0.f)];
                         }
                         completion:^(BOOL finished) {
                             _isKeyboard = YES;
                         }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSTimeInterval keyboardAnimationTime = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:keyboardAnimationTime
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_scrollView setContentInset:UIEdgeInsetsZero];
                     }
                     completion:^(BOOL finished) {
                         _isKeyboard = NO;
                     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _textFieldName) {
        [_textFieldEmail becomeFirstResponder];
        return NO;
    }
    if (textField == _textFieldEmail) {
        [_textFieldSubject becomeFirstResponder];
        return NO;
    }
    if (textField == _textFieldSubject) {
        [self becomeFirstResponderForTextView];
        return NO;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self becomeFirstResponderForTextView];
}

#pragma mark - Actions

- (IBAction)sendMessageButton_TUI:(UIButton *)sender {
    
    BOOL textFieldsCheck = [self checkTextFields:@[_textFieldName,
                                                   _textFieldEmail,
                                                   _textFieldSubject]
                            withLocalizedStrings:@[@"error_placeholder_your_name",
                                                   @"error_placeholder_your_email",
                                                   @"error_placeholder_subject"]
                                        andColor:RGB(248.f, 10.f, 32.f)];
    BOOL textViewCheck = [self checkTextView];
    if (textFieldsCheck && textViewCheck) {
        
        [sender setEnabled:NO];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"api"
                                                                  password:kMailgunAPIKey];
        [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
        [manager POST:[NSString stringWithFormat:@"%@/%@/messages", kMailgunBaseURL, kMaingunDomainURL]
           parameters:@{@"from" : [NSString stringWithFormat:@"%@ <%@>", _textFieldName.text, _textFieldEmail.text],
                        @"to" : kSupportEmail,
                        @"subject" : [NSString stringWithFormat:@"PolarPro app support: %@", _textFieldSubject.text],
                        @"text" : _textView.text}
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  if (responseObject &&
                      responseObject[@"message"] &&
                      [responseObject[@"message"] isEqualToString:@"Queued. Thank you."]) {
                      
                      PPAlertView *alertView = [[PPAlertView alloc] initWithTarget:self];
                      [alertView setDelegate:self];
                      [alertView setTitle:LOCALIZE(@"thank_you_title")];
                      [alertView setMessage:LOCALIZE(@"thank_you_message")];
                      PPActionButton *actionButton = [PPActionButton actionButtonTypeOkWithKey:@"ok"];
                      [alertView setActionButtons:@[actionButton]];
                      [alertView show];
                      
                  } else {
                      
                      [self showError:nil];
                      
                  }
                  [sender setEnabled:YES];
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  [self showError:error];
                  [sender setEnabled:YES];
              }];
        
        [_user setName:_textFieldName.text];
        [_user setEmail:_textFieldEmail.text];
        
    }
}

- (void)showError:(NSError *)error {
    PPAlertView *alertView = [[PPAlertView alloc] initWithTarget:self];
    [alertView setDelegate:self];
    [alertView setTitle:LOCALIZE(@"error")];
    [alertView setMessage:error.localizedDescription];
    PPActionButton *actionButton = [PPActionButton actionButtonTypeOkWithKey:@"ok"];
    [alertView setActionButtons:@[actionButton]];
    [alertView show];
}

- (void)alertView:(PPAlertView *)alertView didActionWithActionButton:(PPActionButton *)actionButton {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
