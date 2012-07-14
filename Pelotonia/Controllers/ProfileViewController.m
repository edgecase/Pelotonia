//
//  ProfileViewController.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()
- (void)configureView;
@end

@implementation ProfileViewController

@synthesize rider = _rider;
@synthesize nameLabel = _nameLabel;
@synthesize riderIdLabel = _riderIdLabel;
@synthesize emailLabel = _emailLabel;
@synthesize donationLabel = _donationLabel;

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
    [self setRiderIdLabel:nil];
    [self setEmailLabel:nil];
    [self setDonationLabel:nil];
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

- (void)configureView
{
    // set the name & ID appropriately
    self.riderIdLabel.text = self.rider.riderId;
    self.nameLabel.text = self.rider.name;
}

- (IBAction)donatePressed:(id)sender {
    NSLog(@"sending mail to :%@", self.emailLabel.text);
    NSLog(@"you have decided to pledge %@", self.donationLabel.text);
}
@end
