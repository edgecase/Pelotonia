//
//  FeedbackViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 9/26/13.
//
//

#import "FeedbackViewController.h"
#import <Socialize/Socialize.h>
#import "SendgridPassword.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
    NSString *feedback = self.feedbackText.text;
    // send the feedback to support@isandlot.com
    [self sendFeedback:feedback];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editingDidEnd:(id)sender {
    UITextField *tfEmail = (UITextField *)sender;
    
    [self.doneButton setEnabled:[self isValidEmail:tfEmail.text]];
}

- (void)sendFeedback:(NSString *)feedback {
    SendGrid *sendgrid = [SendGrid apiUser:SENDGRID_USERNAME apiKey:SENDGRID_PASSWORD];
    
    NSString *username = [[SZUserUtils currentUser] userName];
    NSString *displayName = [[SZUserUtils currentUser] displayName];
    SendGridEmail *email = [[SendGridEmail alloc] init];
    email.to = @"support@isandlot.com";
    email.from = self.userEmailAddress.text;
    email.subject = @"Pelotonia App Feedback";
    email.text = [NSString stringWithFormat:@"Name: %@\nUserName: %@\n%@", displayName, username, feedback];
    [sendgrid sendWithWeb:email];
}

- (BOOL)isValidEmail: (NSString *)address
{
    NSString *someRegexp = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", someRegexp];
    return [emailTest evaluateWithObject:address];
}

@end
