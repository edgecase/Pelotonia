//
//  RidersViewController.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "AppDelegate.h"
#import "RidersViewController.h"
#import "RiderDataController.h"
#import "ProfileViewController.h"
#import "SearchViewController.h"
#import "Pelotonia-Colors.h"
#import "PelotoniaWeb.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"


@interface RidersViewController ()
@property (nonatomic, strong) NSMutableDictionary *imagesCache;

- (void)loadImagesForOnScreenRows;
- (void)loadImageAtIndexPath:(NSIndexPath *)indexPath;


@end


@implementation RidersViewController

@synthesize dataController = _dataController;
@synthesize riderTableView = _riderTableView;
@synthesize imagesCache = _imagesCache;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.imagesCache = [NSMutableDictionary dictionary];

    // set the colors appropriately
    self.navigationController.navigationBar.tintColor = PRIMARY_DARK_GRAY; 
    
    // set the text in the navbar to use the Baksheesh font
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    titleLabel.textColor = PRIMARY_GREEN;
    titleLabel.font = PELOTONIA_FONT(24);
    titleLabel.text = [NSString stringWithFormat:@"%@", @"Pelotonia 2012"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter; 
    [titleLabel setShadowColor: PRIMARY_DARK_GRAY];
    [titleLabel setShadowOffset:CGSizeMake(0, -0.5)];
    
    self.navigationItem.titleView = titleLabel;
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"one-goal-wallpaper.jpg"]];
    self.tableView.opaque = NO;
    
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"one-goal-wallpaper.jpg"]];
    self.searchDisplayController.searchResultsTableView.opaque = YES;
    
    // set up the search results
    self.riderSearchResults = [[NSMutableArray alloc] initWithCapacity:1];
}

- (void)viewDidUnload
{
    self.riderTableView = nil;
    [self setRiderTableView:nil];
    [self setRiderSearchResults:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (RiderDataController *)dataController {
    if (_dataController == nil) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _dataController = appDelegate.riderDataController;
    }
    return _dataController;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self performSelector:NSSelectorFromString(segue.identifier) withObject:segue.destinationViewController];
}

- (void)prepareProfile:(ProfileViewController *)profileViewController
{
    Rider *rider = [self.dataController objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    profileViewController.rider = rider;
    [PelotoniaWeb profileForRider:rider onComplete:^(Rider *updatedRider) {
        profileViewController.rider = updatedRider;
    } onFailure:nil];
}


#pragma mark - Image handling
- (void)loadImagesForOnScreenRows
{
    NSArray *visiblePaths = [self.riderTableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths) {
        [self loadImageAtIndexPath:indexPath];
    }
}

- (void)loadImageAtIndexPath:(NSIndexPath *)indexPath
{
    Rider *rider = [self.dataController objectAtIndex:indexPath.row];
    
    if ([[self.imagesCache allKeys] containsObject:rider.riderPhotoThumbUrl]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableViewCell *cell = [self.riderTableView cellForRowAtIndexPath:indexPath];
            UIImage *riderPhotoThumb = [self.imagesCache valueForKey:rider.riderPhotoThumbUrl];
            cell.imageView.image = riderPhotoThumb;
        });
    } else {
        __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:rider.riderPhotoThumbUrl]];
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UITableViewCell *cell = [self.riderTableView cellForRowAtIndexPath:indexPath];
                UIImage *riderPhotoThumb = [UIImage imageWithData:[request responseData]];
                cell.imageView.image = riderPhotoThumb;
                [self.imagesCache setValue:riderPhotoThumb forKey:rider.riderPhotoThumbUrl];
            });
        }];
        [request startAsynchronous];
    }
}

- (UIImage *)imageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Rider *rider = [self.dataController objectAtIndex:indexPath.row];
    
    if ([[self.imagesCache allKeys] containsObject:rider.riderPhotoThumbUrl]) {
            UIImage *riderPhotoThumb = [self.imagesCache valueForKey:rider.riderPhotoThumbUrl];
            return riderPhotoThumb;
    } else {
        __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:rider.riderPhotoThumbUrl]];
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *riderPhotoThumb = [UIImage imageWithData:[request responseData]];
                [self.imagesCache setValue:riderPhotoThumb forKey:rider.riderPhotoThumbUrl];
            });
        }];
        [request startAsynchronous];
        return [UIImage imageNamed:@"profile_default_thumb.jpg"];
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
        return [self.dataController count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"riderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Rider *rider = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        rider = [self.riderSearchResults objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = rider.riderId;
        cell.textLabel.text = rider.name;
        cell.backgroundColor = PRIMARY_DARK_GRAY;
    }
    else {
        rider = [self.dataController objectAtIndex:indexPath.row];
        cell.textLabel.text = rider.name;
        if ([rider.pelotonGrandTotal length] > 0) {
            cell.detailTextLabel.text = rider.pelotonGrandTotal;
        }
        else {
            cell.detailTextLabel.text = rider.amountRaised;
        }
        cell.imageView.image = [self imageForRowAtIndexPath:indexPath];
    }
    cell.textLabel.font = PELOTONIA_FONT(19);
    cell.detailTextLabel.font = PELOTONIA_FONT(19);    
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
        
        // add the selected rider to the list of selected riders
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType != UITableViewCellAccessoryCheckmark) {
            Rider *rider = [self.riderSearchResults objectAtIndex:indexPath.row];
            [self.dataController addObject:rider];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            Rider *rider = [self.riderSearchResults objectAtIndex:indexPath.row];
            [self.dataController removeObject:rider];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    else {
        // do nothing.
    }
    
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    /*
     Update the filtered array based on the search text and scope.
     */    
    [self.riderSearchResults removeAllObjects];
    
    /*
     search the web for all riders matching the searchText
     */
    [PelotoniaWeb searchForRiderWithLastName:searchText riderId:@"" onComplete:^(NSArray *searchResults) {
        [self.riderSearchResults addObjectsFromArray:searchResults];
        [self.searchDisplayController.searchResultsTableView reloadData];
    } onFailure:nil];

}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:@""];
    
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:@""];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    [self.tableView reloadData];
}


@end
