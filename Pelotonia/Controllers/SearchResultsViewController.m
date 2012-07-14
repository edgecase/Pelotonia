//
//  SearchResultsViewController.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "AppDelegate.h"
#import "SearchResultsViewController.h"
#import "Rider.h"

@interface SearchResultsViewController ()

@end

@implementation SearchResultsViewController
@synthesize searchResultsTable = _searchResultsTable;
@synthesize riders = _riders;
@synthesize dataController = _dataController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // prepare our set of selected people
    _ridersSelected = [[NSMutableSet alloc] init];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
  [self setSearchResultsTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)done:(id)sender {
    for (Rider *rider in _ridersSelected) {
        [self.dataController addObject:rider];
    }
    
    // make sure we save our newly modified list of riders
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate archiveData];
    
    // go back to our original view
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setRiders:(NSArray *)riders
{
  NSLog(@"setting riders");
  _riders = riders;
  [self.searchResultsTable reloadData];
}

- (RiderDataController *)dataController {
    if (_dataController == nil) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _dataController = appDelegate.riderDataController;
    }
    return _dataController;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.riders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"searchResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Rider *rider = [self.riders objectAtIndex:indexPath.row];
    cell.textLabel.text = rider.name;
    cell.accessoryType = ([_ridersSelected containsObject:rider])?UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // makes nice animation
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // put the rider object into the "_ridersSelected" set
    Rider *rider = [self.riders objectAtIndex:indexPath.row];
    [_ridersSelected addObject:rider];
    
    [self.tableView reloadData];

}

@end
