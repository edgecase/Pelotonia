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
    [self postAlert:[NSString stringWithFormat:@"An email has been sent to remind you to complete your pledge of $%@ for %@.", self.amountLabel.text, self.rider.name]];
    [self dismissModalViewControllerAnimated:YES];
}
@end
