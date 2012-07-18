//
//  PledgeViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PledgeViewController.h"

@interface PledgeViewController ()

@end

@implementation PledgeViewController
@synthesize emailLabel;
@synthesize amountLabel;
@synthesize rider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setEmailLabel:nil];
    [self setAmountLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)postAlert:(NSString *)msg {
    // alert that they need to authorize first
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you for your Pledge" 
                                                    message:msg 
                                                   delegate:self 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
}


- (IBAction)pledgePressed:(id)sender {
    NSLog(@"Email sent to: %@", self.emailLabel.text);
    NSLog(@"You have decided to sponsor %@ the amount %@", self.rider.name, self.amountLabel.text);
    
    MFMailComposeViewController *mailComposer; 
    mailComposer  = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setToRecipients:[NSArray arrayWithObject:self.emailLabel.text]];
    [mailComposer setModalPresentationStyle:UIModalPresentationFormSheet];
    [mailComposer setSubject:@"Thank you for your support of Pelotonia"];
    NSString *msg = [NSString stringWithFormat:@"<HTML><BODY>Thank you for sponsoring my Pelotonia ride.  To complete your $%@ pledge, please click <a href=\"%@\">here</a>.<br/><br/>100%% of your donation goes to support life saving research at the James Comprehensive Cancer Center at The Ohio State University.<br/><br/>Your support is priceless,<br/><br/>%@</body></html>", self.amountLabel.text, self.rider.donateUrl, self.rider.name];
    NSLog(@"msgBody: %@", msg);
    [mailComposer setMessageBody:msg isHTML:YES];
    [self presentModalViewController:mailComposer animated:YES];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error 
{ 
    if(error) {
        NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);    
        [self postAlert:[NSString stringWithFormat:@"Your email was cancelled."]];
    }
    else {
        [self postAlert:[NSString stringWithFormat:@"An email has been sent to remind you to complete your pledge of $%@ for %@.", self.amountLabel.text, self.rider.name]];
    }
    [self dismissModalViewControllerAnimated:YES];
}
@end
