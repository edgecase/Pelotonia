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
#import "Pelotonia-Colors.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SHKActivityIndicator.h"
#import <Socialize/Socialize.h>

@interface ProfileViewController ()
- (void)configureView;
- (void)sendPledgeMail;
- (BOOL)validateForm;
- (void)postAlert:(NSString *)msg;
- (void)refreshRider;
- (void)customizeFacebook:(id)sender;
- (void)customizeTwitter:(id)sender;
@end

@implementation ProfileViewController

@synthesize supportButton = _supportButton;
@synthesize scrollView = _scrollView;
@synthesize rider = _rider;
@synthesize nameLabel = _nameLabel;
@synthesize routeLabel = _routeLabel;
@synthesize raisedLabel = _raisedLabel;
@synthesize commitLabel = _commitLabel;
@synthesize supportLabel = _supportLabel;
@synthesize riderImageView = _riderImageView;
@synthesize donationField = _donationField;
@synthesize followButton = _followButton;
@synthesize donorEmailField = _donorEmailField;
@synthesize following = _following;
@synthesize donationProgress = _donationProgress;
@synthesize entity = _entity;
@synthesize actionBar = _actionBar;

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
    // set up the scroll view
    self.scrollView.contentSize=CGSizeMake(320, 960);
    self.scrollView.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
    [self refreshRider];
    
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
    [self setCommitLabel:nil];
    [self setDonationProgress:nil];
    [self setScrollView:nil];
    [self setSupportLabel:nil];
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



- (void)refreshRider
{
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Refreshing..."];
    // start an asynchronous web request to update the rider information
    [PelotoniaWeb profileForRider:self.rider onComplete:^(Rider *updatedRider) {
        self.rider = updatedRider;
        [self configureView];
        [[SHKActivityIndicator currentIndicator] hide];
    } onFailure:^(NSString *error) {
        NSLog(@"Unable to get profile for rider. Error: %@", error);
        [[SHKActivityIndicator currentIndicator] displayCompleted:@"Error"];
    }];
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
    self.raisedLabel.text = self.rider.totalRaised;
    self.commitLabel.text = self.rider.totalCommit;
    
    [self.rider getRiderPhotoOnComplete:^(UIImage *image) {
        self.riderImageView.image = image;
    }];

    self.nameLabel.font = PELOTONIA_SECONDARY_FONT(21);
    self.routeLabel.font = PELOTONIA_SECONDARY_FONT(17);
    self.raisedLabel.font = PELOTONIA_SECONDARY_FONT(17);
    self.commitLabel.font = PELOTONIA_SECONDARY_FONT(17);
    self.supportLabel.font = PELOTONIA_SECONDARY_FONT(17);
    
    self.donationProgress.progress = [self.rider.pctRaised floatValue]/100.0;
    
    if (self.following) {
        [self.followButton setTitle:@"Unfollow"];

        // configure the action bar
        if (self.actionBar == nil) {
            self.entity = [SZEntity entityWithKey:self.rider.riderId name:self.rider.name];
            self.actionBar = [SZActionBar defaultActionBarWithFrame:CGRectNull entity:self.entity viewController:self];
            
            UIButton *fbButton = [[UIButton alloc] initWithFrame:CGRectZero];
            [fbButton setImage:[UIImage imageNamed:@"f_logo.png"] forState:UIControlStateNormal];
            [fbButton sizeToFit];
            [fbButton addTarget:self action:@selector(customizeFacebook:) forControlEvents:UIControlEventTouchUpInside];
            
            self.actionBar.itemsRight = [NSArray arrayWithObjects:fbButton, [SZActionButton commentButton], nil];
            
            UIButton *twitterButton = [[UIButton alloc] initWithFrame:CGRectZero];
            [twitterButton setImage:[UIImage imageNamed:@"twitterbird.png"] forState:UIControlStateNormal];
            [twitterButton sizeToFit];
            [twitterButton addTarget:self action:@selector(customizeTwitter:) forControlEvents:UIControlEventTouchUpInside];
            self.actionBar.itemsLeft = [NSArray arrayWithObjects:[SZActionButton viewsButton], twitterButton, nil];
            
            [self.view addSubview:self.actionBar];
        }
    
    }
    else {
        [self.followButton setTitle:@"Follow"];
    }

    [self.supportButton setTintColor:PRIMARY_GREEN];
    
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
    
    NSString *amountFormat;
    if ([self.donationField.text length] > 0) {
        amountFormat = @"$%@";
    }
    else {
        amountFormat = @"%@";
    }
    NSString *amount = [NSString stringWithFormat:amountFormat, self.donationField.text];
    
    NSString *msg = [NSString stringWithFormat:@"<HTML><BODY>Hello %@,<br/><br/> \
                     You have pledged to donate %@ to %@'s Pelotonia fund.  Please use \
                     the following link to complete your pledge: <a href=\"%@\">Rider Profile</a>. <br/><br/> \
                     Thanks! <br/><br/>\
                     %@ and Pelotonia 12</BODY></HTML>", self.donorEmailField.text, amount, self.rider.name, self.rider.donateUrl, self.rider.name];
    
    NSLog(@"msgBody: %@", msg);
    [mailComposer setMessageBody:msg isHTML:YES];
    [self presentModalViewController:mailComposer animated:YES];

}

#pragma mark -- text field delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)tf
{
    [tf resignFirstResponder];
    if (tf == self.donorEmailField) {
        [self sendPledgeMail];
    }
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

- (void)customizeFacebook:(id)sender {
    
    NSMutableDictionary *postData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"Please help %@ reach their %@ goal for Pelotonia!", self.rider.name, self.rider.totalCommit], @"message",
                                     [NSString stringWithFormat:@"%@", self.rider.profileUrl], @"link",
                                     @"Pelotonia is a grassroots bike tour with one goal: to end cancer. Donations can be made in support of riders and will fund essential research at The James Cancer Hospital and Solove Research Institute. See the purpose, check the progress, make a difference.", @"description",
                                     @"http://pelotonia.resource.com/facebook/images/pelotonia_352x310_v2.png", @"picture",
                                     @"http://pelotonia.resource.com/facebook/images/pelotonia_352x310_v2.png", @"icon",
                                     nil];
    
    [SZFacebookUtils postWithGraphPath:@"me/feed" params:postData success:^(id post) {
        NSLog(@"Posted %@!", post);
    } failure:^(NSError *error) {
        NSLog(@"Facebook post failed: %@, %@", [error localizedDescription], [error userInfo]);
    }];
}

- (void)customizeTwitter:(id)sender {
    
    NSString *text = [NSString stringWithFormat:@"%3.1f%% of goal! Support %@'s Pelotonia Ride:%@",
                      [self.rider.pctRaised doubleValue] , self.rider.name, self.rider.profileUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:text forKey:@"status"];
    
    [SZTwitterUtils postWithPath:@"/1/statuses/update.json" params:params success:^(id result) {
        NSLog(@"Posted to Twitter feed: %@", result);
    } failure:^(NSError *error) {
        NSLog(@"Failed to post to Twitter feed: %@ / %@", [error localizedDescription], [error userInfo]);
    }];
}

@end
