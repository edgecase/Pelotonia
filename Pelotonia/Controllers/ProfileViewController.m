//
//  ProfileViewController.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "RiderDataController.h"
#import "PelotoniaWeb.h"

@interface ProfileViewController ()
- (void)configureView;
- (void)sendPledgeMail;
- (BOOL)validateForm;
- (void)postAlert:(NSString *)msg;
@end

@implementation ProfileViewController

@synthesize supportButton = _supportButton;
@synthesize rider = _rider;
@synthesize nameLabel = _nameLabel;
@synthesize routeLabel = _routeLabel;
@synthesize raisedLabel = _raisedLabel;
@synthesize riderImageView = _riderImageView;
@synthesize donationField = _donationField;
@synthesize followButton = _followButton;
@synthesize donorEmailField = _donorEmailField;
@synthesize following = _following;

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
    [self setNameLabel:nil];
    [self setRiderImageView:nil];
    [self setRouteLabel:nil];
    [self setRaisedLabel:nil];
    [self setDonationField:nil];
    [self setDonorEmailField:nil];
    [self setSupportButton:nil];
    [self setFollowButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [PelotoniaWeb profileForRider:self.rider onComplete:^(Rider *updatedRider) {
        self.rider = updatedRider;
        [self configureView];
    } onFailure:^(NSString *error) {
        NSLog(@"Unable to get profile for rider. Error: %@", error);
    }];

    [self configureView];
}

- (void)setRider:(Rider *)rider
{
    _rider = rider;
    [self configureView];
}

- (BOOL)following
{
    // return true if current rider is in the dataController
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    RiderDataController *dataController = appDelegate.riderDataController;

    return [dataController containsRider:self.rider];
}

- (void)configureView
{
    // set the name & ID appropriately
    self.nameLabel.text = self.rider.name;
    self.routeLabel.text = self.rider.route;
    if ([self.rider.pelotonGrandTotal length] > 0) {
        self.raisedLabel.text = self.rider.pelotonGrandTotal;
    }
    else {
        self.raisedLabel.text = self.rider.amountRaised;
    }
    
    self.riderImageView.image = self.rider.riderPhoto;
    
    if (self.following) {
        [self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
    }
    else {
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
}

- (BOOL)validateForm
{
    return (([self.donorEmailField.text length] > 0) 
    && ([self.donationField.text length] > 0));
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

- (void)sendPledgeMail
{
    NSLog(@"Email sent to: %@", self.donorEmailField.text);
    NSLog(@"You have decided to sponsor %@ the amount %@", self.rider.name, self.donationField.text);
    
    MFMailComposeViewController *mailComposer; 
    mailComposer  = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setToRecipients:[NSArray arrayWithObject:self.donorEmailField.text]];
    [mailComposer setModalPresentationStyle:UIModalPresentationFormSheet];
    [mailComposer setSubject:@"Thank you for your support of Pelotonia"];
    
    NSString *msg = [NSString stringWithFormat:@"<HTML><BODY>Hello %@,<br/><br/> \
                     You have pledged to donate %@ to %@'s Pelotonia fund.  Please use \
                     the following link to complete your pledge: <a href=\"%@\">Rider Profile</a>. <br/><br/> \
                     Thanks! <br/><br/>\
                     %@ and Pelotonia 12</BODY></HTML>", self.donorEmailField.text, self.donationField.text, self.rider.name, self.rider.donateUrl, self.rider.name];
    
    NSLog(@"msgBody: %@", msg);
    [mailComposer setMessageBody:msg isHTML:YES];
    [self presentModalViewController:mailComposer animated:YES];

}

#pragma mark -- text field delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)tf
{
    [tf resignFirstResponder];
    [self sendPledgeMail];
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self validateForm]) {
        self.supportButton.enabled = YES;
    }
    else {
        self.supportButton.enabled = NO;
    }
}


#pragma mark - MFMailComposeViewDelegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error 
{ 
    if(error) {
        NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);    
    }
    else {
//        [self postAlert:[NSString stringWithFormat:@"An email has been sent to remind you to complete your pledge of $%@ for %@.", self.donationField.text, self.rider.name]];
    }
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)supportRider:(id)sender {
    if ([self validateForm]) {
        [self sendPledgeMail];
    }
}

- (IBAction)followRider:(id)sender {
    // add the current rider to the main list of riders 
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    RiderDataController *dataController = appDelegate.riderDataController;
    
    if (!self.following) {
        [dataController addObject:self.rider];
    }
    else {
        [dataController removeObject:self.rider];
    }
    [self configureView];
}
@end
