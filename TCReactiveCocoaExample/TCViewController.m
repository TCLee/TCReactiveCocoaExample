//
//  TCViewController.m
//  TCReactiveCocoaExample
//
//  Created by Lee Tze Cheun on 1/8/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCViewController.h"

@interface TCViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation TCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Signal of boolean values to indicate whether the form's fields are
    // valid or not.
    RACSignal *isFormValidSignal = [self isFormValidSignal];

    // Create the command and associate it with the button.
    RACCommand *buttonCommand = [self createAccountCommandWithEnabledSignal:isFormValidSignal];
    self.createAccountButton.rac_command = buttonCommand;

    // Text field's properties are bound to the command executing signal.
    RACSignal *commandExecutingSignal = buttonCommand.executing;
    [self bindTextFieldsToCommandExecutingSignal:commandExecutingSignal];

    // Activity indicator is shown only if the command is currently executing.
    [self bindActivityIndicatorToCommandExecutingSignal:commandExecutingSignal];

    // Network results signal events will be delivered on a main thread, in
    // order to update the view.
    RACSignal *networkResultsSignal = [[buttonCommand.executionSignals flatten]
                                       deliverOn:[RACScheduler mainThreadScheduler]];

    // Status label's properties are bound to the network results signal.
    [self bindStatusLabelToNetworkResultsSignal:networkResultsSignal];
}

/**
 * Returns a signal of boolean values. A YES value to indicate that all the 
 * form's fields are valid; NO otherwise.
 */
- (RACSignal *)isFormValidSignal
{
    return [RACSignal combineLatest:@[self.emailField.rac_textSignal,
                                      self.passwordField.rac_textSignal,
                                      self.confirmPasswordField.rac_textSignal]
                      reduce:^(NSString *email, NSString *password, NSString *confirmPassword) {
                          return @(email.length > 0 &&
                                   password.length > 0 &&
                                   confirmPassword.length > 0 &&
                                   [password isEqualToString:confirmPassword]);
                      }];
}

/**
 * Returns a command to be associated with the Create Account button.
 *
 * @param enabledSignal The signal of BOOLs to indicate when the command is 
 *                      enabled or disabled.
 */
- (RACCommand *)createAccountCommandWithEnabledSignal:(RACSignal *)enabledSignal
{
    return [[RACCommand alloc]
            initWithEnabled:enabledSignal
            signalBlock:^RACSignal *(id input) {
                // Call `materialize` to convert a signal event into a value.
                return [[self createAccountForEmail:self.emailField.text
                                           password:self.passwordField.text]
                        materialize];
            }];;
}

/**
 * Returns a signal of a mocked up network request.
 */
- (RACSignal *)createAccountForEmail:(NSString *)email
                            password:(NSString *)password
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // Fake a network request with a small delay.
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [subscriber sendCompleted];
        });

        return [RACDisposable disposableWithBlock:^{
            // Nothing to clean up, since this is a fake network request.
        }];
    }];
}

- (void)bindTextFieldsToCommandExecutingSignal:(RACSignal *)commandExecutingSignal
{
    // Text field's text color depends on whether the command is currently executing.
    RACSignal *fieldTextColorSignal = [commandExecutingSignal map:^(NSNumber *executingValue) {
        return executingValue.boolValue ? [UIColor lightGrayColor] : [UIColor blackColor];
    }];
    RAC(self.emailField, textColor) = fieldTextColorSignal;
    RAC(self.passwordField, textColor) = fieldTextColorSignal;
    RAC(self.confirmPasswordField, textColor) = fieldTextColorSignal;

    // Text fields are only enabled when the command is not currently executing.
    RACSignal *commandNotExecutingSignal = [commandExecutingSignal not];
    RAC(self.emailField, enabled) = commandNotExecutingSignal;
    RAC(self.passwordField, enabled) = commandNotExecutingSignal;
    RAC(self.confirmPasswordField, enabled) = commandNotExecutingSignal;
}

- (void)bindActivityIndicatorToCommandExecutingSignal:(RACSignal *)commandExecutingSignal
{
    // Activity indicator is shown only if the command is currently executing.
    [commandExecutingSignal subscribeNext:^(NSNumber *executingValue) {
        executingValue.boolValue ? [self.activityIndicator startAnimating] : [self.activityIndicator stopAnimating];
    }];
}

- (void)bindStatusLabelToNetworkResultsSignal:(RACSignal *)networkResultsSignal
{
    // Status label is hidden while network request is in progress.
    RAC(self.statusLabel, hidden) =
        // Network results signal gets its values asycnhronously. So, we have
        // to give the signal an initial value.
        [[networkResultsSignal startWith:[RACEvent eventWithValue:nil]] map:^id(RACEvent *event) {
            // Network request is considered completed when it returns an
            // event of RACEventTypeCompleted or RACEventTypeError.
            return @(event.eventType == RACEventTypeNext);
        }];

    // Show success text on status label if network response is successful;
    // show error message otherwise.
    RAC(self.statusLabel, text) =
        [networkResultsSignal map:^(RACEvent *event) {
            return event.eventType == RACEventTypeCompleted ?
                   NSLocalizedString(@"Thanks for signing up! :-)", nil) :
                   event.error.localizedDescription;
        }];

    // Status label's text color depends on whether the network response
    // is successful or not.
    RAC(self.statusLabel, textColor) =
        [networkResultsSignal map:^id(RACEvent *event) {
            return event.eventType == RACEventTypeCompleted ?
                   [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f] :
                   [UIColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:1.0f];
        }];
}

@end
