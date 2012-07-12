//
//  SearchViewController.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsViewController.h"
#import "ASIHTTPRequest.h"
#import "TFHpple.h"
#import "Rider.h"

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
  NSString *queryString = [NSString stringWithFormat:@"https://www.mypelotonia.org/riders_searchresults.jsp?SearchType=&LastName=%@&RiderID=%@&RideDistance=&ZipCode=&", self.lastNameField.text, self.riderIdField.text];

  // do a post with the queryString
  NSURL *url = [NSURL URLWithString:queryString];
  __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request setCompletionBlock:^{
    TFHpple *parser = [TFHpple hppleWithHTMLData:[request responseData]];
    NSString *xPath = @"//td[@class='rider']/a";
    NSArray *riderNodes = [parser searchWithXPathQuery:xPath];
    
    NSMutableArray *riders = [NSMutableArray array];
    for (TFHppleElement *riderElement in riderNodes) {
      Rider *rider = [[Rider alloc] init];
      rider.name = [[riderElement firstChild] content];
      [riders addObject:rider];
    }
    
    searchResultsViewController.riders = riders;
  }];
  
  [request setFailedBlock:^{
    NSError *error = [request error];
    NSLog(@"%@", error);
  }];
  [request startAsynchronous];  
  
  // parse the returned values
  
}

-(IBAction)search:(id)sender {
}
@end
