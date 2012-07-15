//
//  ProfileViewController.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "PledgeViewController.h"
#import "ASIHTTPRequest.h"

@interface ProfileViewController ()
- (void)configureView;
@end

@implementation ProfileViewController

@synthesize rider = _rider;
@synthesize nameLabel = _nameLabel;
@synthesize riderIdLabel = _riderIdLabel;
@synthesize riderImageView = _riderImageView;

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
    [self setRiderImageView:nil];
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
    self.riderIdLabel.text = self.rider.riderId;
    self.nameLabel.text = self.rider.name;
    self.riderImageView.image = [UIImage imageNamed:@"profile_default.jpg"];
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

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self performSelector:NSSelectorFromString(segue.identifier) withObject:segue.destinationViewController];
}

- (void)showPledge:(PledgeViewController *)pledgeViewController
{
    pledgeViewController.rider = self.rider;
}

@end
