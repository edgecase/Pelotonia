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
#import "MenuViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <AAPullToRefresh/AAPullToRefresh.h>


@interface RidersViewController ()

- (void)reloadTableData;

@end


@implementation RidersViewController {
    AAPullToRefresh *_tv;
}

@synthesize riderTableView = _riderTableView;
@synthesize riderSearchResults = _riderSearchResults;

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
    
    // set up pull to refresh
    __weak RidersViewController *weakSelf = self;
    _tv = [self.tableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v) {
        [weakSelf refresh];
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.5f];
    }];
    _tv.imageIcon = [UIImage imageNamed:@"PelotoniaBadge"];
    _tv.borderColor = [UIColor whiteColor];

    // set up the search results
    self.riderSearchResults = [[NSMutableArray alloc] initWithCapacity:0];
        
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

- (void)dealloc
{
    [self.tableView removeObserver:_tv forKeyPath:@"contentOffset"];
    [self.tableView removeObserver:_tv forKeyPath:@"contentSize"];
    [self.tableView removeObserver:_tv forKeyPath:@"frame"];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -- pull to refresh view
- (void)refresh
{
    // update all riders in the list
    for (Rider *rider in [[AppDelegate sharedDataController] allRiders]) {
        [rider refreshFromWebOnComplete:^(Rider *rider) {
            [self reloadTableData];
        } onFailure:nil];
    }
}

- (void)reloadTableData
{
    NSSortDescriptor* desc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [[AppDelegate sharedDataController] sortRidersUsingDescriptors:[NSArray arrayWithObject:desc]];
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"prepareProfile:"]) {
        [self prepareProfile:(ProfileTableViewController *)segue.destinationViewController];
    }
}

- (void)prepareProfile:(ProfileTableViewController *)profileTableViewController
{
    Rider *rider = nil;
    if ([self.searchDisplayController isActive]) {
        rider = [self.riderSearchResults objectAtIndex:[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow].row];
        profileTableViewController.rider = rider;
    }
    else {
        rider = [[AppDelegate sharedDataController] objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        profileTableViewController.rider = rider;
    }
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
        return [[AppDelegate sharedDataController] count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // it's a "regular" cell
    static NSString *CellIdentifier = @"riderCell";
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (_cell == nil)
    {
        _cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // this trick with the temporary variable silences the warning about capturing cell strongly in the block below
    __weak UITableViewCell *cell = _cell;
    
    // Configure the cell...
    Rider *rider = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // we only have so much information in the search view
        rider = [self.riderSearchResults objectAtIndex:indexPath.row];
    }
    else {
        // looking at the "regular" view, so get rider info from our list of riders
        rider = [[AppDelegate sharedDataController] objectAtIndex:indexPath.row];
    }
    _cell.textLabel.textColor = PRIMARY_DARK_GRAY;
    _cell.textLabel.text = [NSString stringWithFormat:@"%@", rider.name];
    _cell.detailTextLabel.textColor = PRIMARY_GREEN;
    _cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",rider.route];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:rider.riderPhotoThumbUrl]
                   placeholderImage:[UIImage imageNamed:@"profile_default"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,
                                      NSURL *imageURL) {
        if (error) {
            NSLog(@"RidersViewController::cellforrowatindexpath error: %@",
                  error.localizedDescription);
        }
        [cell.imageView setImage:[image thumbnailImage:60 transparentBorder:1 cornerRadius:5 interpolationQuality:kCGInterpolationDefault]];
        
        [cell layoutSubviews];
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    cell.textLabel.font = PELOTONIA_FONT(21);
    cell.detailTextLabel.font = PELOTONIA_FONT(15);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0;
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
        [[AppDelegate sharedDataController] removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}




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


@end
