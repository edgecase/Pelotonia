//
//  ProfileViewController.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "ASIHTTPRequest.h"

@interface ProfileViewController ()
- (void)configureView;
- (void)sendPledgeMail;
- (void)postAlert:(NSString *)msg;
@end

@implementation ProfileViewController

@synthesize rider = _rider;
@synthesize nameLabel = _nameLabel;
@synthesize routeLabel = _routeLabel;
@synthesize raisedLabel = _raisedLabel;
@synthesize riderImageView = _riderImageView;
@synthesize donationField = _donationField;
@synthesize donorEmailField = _donorEmailField;

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
    [self configureView];
}

- (void)setRider:(Rider *)rider
{
    _rider = rider;
    [self configureView];
}

- (void)configureView
{
    // set the name & ID appropriately
    self.nameLabel.text = self.rider.name;
    self.routeLabel.text = self.rider.route;
    self.raisedLabel.text = self.rider.amountRaised;
    
    if (!self.riderImageView.image) {
        self.riderImageView.image = [UIImage imageNamed:@"profile_default.jpg"];
    }
    
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:self.rider.riderPhotoUrl]];
    [request setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *riderPhoto = [UIImage imageWithData:[request responseData]];
            self.riderImageView.image = riderPhoto;
            [self.view setNeedsDisplay];
        });
    }];
    [request startAsynchronous];
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

- (BOOL)textFieldShouldReturn:(UITextField *)tf
{
    [tf resignFirstResponder];
    [self sendPledgeMail];
    return YES;
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
        [self postAlert:[NSString stringWithFormat:@"An email has been sent to remind you to complete your pledge of $%@ for %@.", self.donationField.text, self.rider.name]];
    }
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)supportRider:(id)sender {
    [self sendPledgeMail];
}
@end
