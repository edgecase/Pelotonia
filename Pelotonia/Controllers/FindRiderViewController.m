//
//  FindRiderViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 2/13/14.
//
//

#import "AppDelegate.h"
#import "FindRiderViewController.h"
#import "RiderTableViewCell.h"
#import "RiderDataController.h"
#import "PelotoniaWeb.h"

@interface FindRiderViewController ()

@end

@implementation FindRiderViewController

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_searchResults count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // signal that we chose this rider
    [self.delegate findRiderViewControllerDidSelectRider:self rider:[_searchResults objectAtIndex:indexPath.row]];
    
    // and close the list view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Rider *rider = [_searchResults objectAtIndex:indexPath.row];
    
    // Configure the cell...
    RiderTableViewCell *cell = [RiderTableViewCell cellForTableView:tableView];
    cell.rider = rider;
    
    return cell;
}

- (void)reloadTableData
{
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    
    [self.delegate findRiderViewControllerDidCancel:self];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some
    // api that you are using to do the search
    /*
     search the web for all riders matching the searchText
     */
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;

    NSString *searchText = searchBar.text;
    
    if ([[searchBar.scopeButtonTitles objectAtIndex:searchBar.selectedScopeButtonIndex ] isEqualToString:@"ID"]) {
        NSLog(@"Searching for %@ by ID", searchText);
        [PelotoniaWeb searchForRiderWithLastName:@"" riderId:searchText onComplete:^(NSArray *searchResults) {
            _searchResults = searchResults;
            [self reloadTableData];
        } onFailure:^(NSString *errorMessage) {
            NSLog(@"%@", errorMessage);
        }];
        
    }
    else {
        NSLog(@"Searching for %@ by Name", searchText);
        [PelotoniaWeb searchForRiderWithLastName:searchText riderId:@"" onComplete:^(NSArray *searchResults) {
            _searchResults = searchResults;
            [self reloadTableData];
        } onFailure:^(NSString *errorMessage) {
            NSLog(@"%@", errorMessage);
        }];
    }
}

- (IBAction)cancelPressed:(id)sender {
    [self.delegate findRiderViewControllerDidCancel:self];
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
