//
//  SearchViewController.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsViewController.h"
#import "PelotoniaWeb.h"

@interface SearchViewController ()

@end

@implementation SearchViewController
@synthesize lastNameField;
@synthesize riderIdField;

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
  [self setLastNameField:nil];
  [self setRiderIdField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  [self performSelector:NSSelectorFromString(segue.identifier) withObject:segue.destinationViewController];
}

- (void)prepareSearchResults:(SearchResultsViewController *)searchResultsViewController
{
  [PelotoniaWeb searchForRiderWithLastName:lastNameField.text riderId:riderIdField.text onComplete:^(NSArray *searchResults) {
    searchResultsViewController.riders = searchResults;
  } onFailure:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)tf
{
    [self performSegueWithIdentifier:@"prepareSearchResults:" sender:self];
    [tf resignFirstResponder];
    return YES;
}

@end
