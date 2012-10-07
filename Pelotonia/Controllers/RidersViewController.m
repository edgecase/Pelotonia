//
//  RidersViewController.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//
#import "AppDelegate.h"
#import "RidersViewController.h"
#import "RiderDataController.h"
#import "ProfileTableViewController.h"
#import "AboutTableViewController.h"
#import "SearchViewController.h"
#import "Pelotonia-Colors.h"
#import "PelotoniaWeb.h"
#import "UIImage+Resize.h"


@interface RidersViewController ()

//- (void)loadImagesForOnScreenRows;
- (void)reloadTableData;

@end


@implementation RidersViewController

@synthesize dataController = _dataController;
@synthesize riderTableView = _riderTableView;
@synthesize riderSearchResults = _riderSearchResults;

// property overloads
- (RiderDataController *)dataController {
    if (_dataController == nil) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _dataController = appDelegate.riderDataController;
    }
    return _dataController;
}


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

    // set the colors appropriately
    self.navigationController.navigationBar.tintColor = PRIMARY_DARK_GRAY; 
    self.tableView.backgroundColor = PRIMARY_DARK_GRAY;
    self.tableView.opaque = YES;
    
    // set up the search results
    self.riderSearchResults = [[NSMutableArray alloc] initWithCapacity:1];
    
    // logo in title bar
    UIImage *image = [UIImage imageNamed: @"Pelotonia_logo_22x216.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    self.navigationItem.titleView = imageView;
}

- (void)viewDidUnload
{
    self.riderTableView = nil;
    [self setRiderTableView:nil];
    [self setRiderSearchResults:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadTableData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -- pull to refresh view
- (void)reloadTableData
{
    NSSortDescriptor* desc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [self.dataController sortRidersUsingDescriptors:[NSArray arrayWithObject:desc]];
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self performSelector:NSSelectorFromString(segue.identifier) withObject:segue.destinationViewController];
}

- (void)prepareProfile:(ProfileTableViewController *)profileTableViewController
{
    Rider *rider = nil;
    if ([self.searchDisplayController isActive]) {
        rider = [self.riderSearchResults objectAtIndex:[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow].row];
        profileTableViewController.rider = rider;
        [profileTableViewController manualRefresh:nil];
    }
    else {
        rider = [self.dataController objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        profileTableViewController.rider = rider;
    }
}

- (void)showAbout:(AboutTableViewController *)aboutViewController
{
    // do nothing
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return the number of riders in our data source or in the search results
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.riderSearchResults count];
    }
    else {
        return [self.dataController count];
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row == 0) {
//        return 101.0;
//    }
//    else {
//        return 62.0;
//    }
//}
//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        // it's a "regular" cell
        static NSString *CellIdentifier = @"riderCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        Rider *rider = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            // we only have so much information in the search view
            rider = [self.riderSearchResults objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",rider.riderType];
        }
        else {
            // looking at the "regular" view, so show all our information
            rider = [self.dataController objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", rider.route];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@", rider.name];
        cell.imageView.image = rider.riderPhotoThumb;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        cell.textLabel.font = PELOTONIA_FONT(21);
        cell.detailTextLabel.font = PELOTONIA_FONT(12);   
        cell.textLabel.textColor = PRIMARY_GREEN;
        cell.detailTextLabel.textColor = SECONDARY_GREEN;
        return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return NO;
    }
    else {
        return YES;
    }
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the dataController
        [self.dataController removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
//{
//
//}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // take us to the profile view
        [self performSegueWithIdentifier:@"prepareProfile:" sender:self];
    }
    else {
        // do nothing, this is handled by our segue in the storyboard
    }
    
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSLog(@"Searching for content %@", searchText);
    /*
     Update the filtered array based on the search text and scope.
     */    
    [self.riderSearchResults removeAllObjects];

    /*
     search the web for all riders matching the searchText
     */
    if ([scope isEqualToString:@"ID"]) {
        NSLog(@"Searching for %@ by ID", searchText);
        [PelotoniaWeb searchForRiderWithLastName:@"" riderId:searchText onComplete:^(NSArray *searchResults) {
            [self.riderSearchResults addObjectsFromArray:searchResults];
            [self.searchDisplayController.searchResultsTableView reloadData];
        } onFailure:^(NSString *errorMessage) {
            NSLog(@"%@", errorMessage);
        }];
        
    }
    else {
        NSLog(@"Searching for %@ by Name", searchText);
        [PelotoniaWeb searchForRiderWithLastName:searchText riderId:@"" onComplete:^(NSArray *searchResults) {
            [self.riderSearchResults addObjectsFromArray:searchResults];
            [self.searchDisplayController.searchResultsTableView reloadData];
        } onFailure:^(NSString *errorMessage) {
            NSLog(@"%@", errorMessage);
        }];
    }
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.backgroundColor = self.tableView.backgroundColor;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    NSLog(@"Pelotonia: searchBarSearchButtonClicked %@", searchBar);
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView 
{
    [self reloadTableData];
}


#pragma mark -- RiderPhotoUpdate delegates
- (void)riderPhotoThumbDidUpdate:(UIImage *)image
{
    if ([self.searchDisplayController isActive]) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else {
        [self reloadTableData];
    }
}

- (void)riderPhotoDidUpdate:(UIImage *)image
{
    // do nothing
}

@end
