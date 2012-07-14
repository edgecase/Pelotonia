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
    NSString *xPath = @"//table[@id='search-results']/tr";
    NSArray *riderTableRows = [parser searchWithXPathQuery:xPath];
    
    NSMutableArray *riders = [NSMutableArray array];
    for (TFHppleElement *riderTableRow in riderTableRows) {
      Rider *rider = [[Rider alloc] init];
      for (TFHppleElement *riderAttributeColumn in [riderTableRow children]) {
        NSString *classAttribute = [[riderAttributeColumn attributes] valueForKey:@"class"];
        
        if ([classAttribute isEqualToString:@"rider"]) {
          rider.name = [[[[riderAttributeColumn children] objectAtIndex:1] firstChild] content];
        } else if ([classAttribute isEqualToString:@"id"]) {
          rider.riderId = [[riderAttributeColumn firstChild] content];
        } else if ([classAttribute isEqualToString:@"photo"]) {
          NSString *relativeUrl = [[[[[[riderAttributeColumn children] objectAtIndex:1] children] objectAtIndex:1] attributes] valueForKey:@"src"];
          rider.riderPhotoThumbUrl = [NSString stringWithFormat:@"https://www.mypelotonia.org/%@", relativeUrl];
        } else if ([classAttribute isEqualToString:@"donate"]) {
          NSString *relativeUrl = [[[[riderAttributeColumn children] objectAtIndex:1] attributes] valueForKey:@"href"];
          rider.donateUrl = [NSString stringWithFormat:@"https://www.mypelotonia.org/%@", relativeUrl];
        } else if ([classAttribute isEqualToString:@"profile"]) {
          NSString *relativeUrl = [[[[riderAttributeColumn children] objectAtIndex:1] attributes] valueForKey:@"href"];
          rider.profileUrl = [NSString stringWithFormat:@"https://www.mypelotonia.org/%@", relativeUrl];
        } else if ([classAttribute isEqualToString:@"type"]) {
          rider.riderType = [[[[riderAttributeColumn children] objectAtIndex:1] attributes] valueForKey:@"alt"];
        }
      }
      
      if (rider.name) {
        [riders addObject:rider];
      }
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
