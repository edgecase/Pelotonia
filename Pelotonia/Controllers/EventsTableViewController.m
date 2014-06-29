//
//  EventsTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 6/18/14.
//
//

#import <AAPullToRefresh/AAPullToRefresh.h>
#import "EventsTableViewController.h"
#import "EventTableViewCell.h"
#import "Event.h"
#import "EventCategory.h"
#import "PelotoniaWeb.h"
#import "EventDetailsTableViewController.h"
#import "NSDate-Utilities.h"
#import "NSDate+Helper.h"

@interface EventsTableViewController ()
- (void)refresh;

@end

@implementation EventsTableViewController {
    AAPullToRefresh *_tv;
}

@synthesize fetchedResultsController;

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
    
    // set up pull to refresh view
    __weak EventsTableViewController *weakSelf = self;
    _tv = [self.tableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v) {
        [weakSelf refresh];
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.5f];
    }];
    _tv.imageIcon = [UIImage imageNamed:@"PelotoniaBadge"];
    _tv.borderColor = [UIColor whiteColor];

    // get the events from local database
    [self fetchAllEvents];
    
    // on first load, there will be nothing in the local database, so we have to go to the network
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        [self refresh];
    }
    else {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -- pull to refresh view
- (void)refresh
{
    // update the event list
    [PelotoniaWeb getPelotoniaEventsOnComplete:^{
        [self fetchAllEvents];
        [self.tableView reloadData];
    } onFailure:^(NSString *errorMessage) {
        NSLog(@"can't get pelotonia events");
    }];
    
}


- (void)fetchAllEvents
{
    // get all events for this current calendar year
    NSString *begOfYear = [NSString stringWithFormat:@"%ld-01-01", (long)[[NSDate date] year]];
    NSString *endOfYear = [NSString stringWithFormat:@"%ld-01-01", (long)[[NSDate date] year] + 1];
    NSDate *dateBegOfYear = [NSDate dateFromString:begOfYear withFormat:@"YYYY-MM-DD"];
    NSDate *dateEndOfYear = [NSDate dateFromString:endOfYear withFormat:@"YYYY-MM-DD"];
    NSPredicate *thisYear = [NSPredicate predicateWithFormat:@"(%@ <= startDateTime) AND (startDateTime < %@)",
                             dateBegOfYear, dateEndOfYear];
    self.fetchedResultsController = [Event fetchAllSortedBy:@"category,startDateTime" ascending:YES withPredicate:thisYear groupBy:@"category" delegate:self];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSArray *objects = [sectionInfo objects];
    Event *object = [objects objectAtIndex:0];
    return object.category.name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTableViewCell *cell = [EventTableViewCell cellForTableView:tableView];
    
    cell.event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // section title
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 60.0)];
    headerView.backgroundColor = PRIMARY_GREEN;

    // white text on green background
    UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width-10, 60.0)];
    sectionTitleLabel.textColor = [UIColor whiteColor];
    sectionTitleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    sectionTitleLabel.backgroundColor = [UIColor clearColor];
    sectionTitleLabel.font = PELOTONIA_SECONDARY_FONT(21);
    
    [headerView addSubview:sectionTitleLabel];
    return headerView;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [event deleteEntity];
    }
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SegueToEventDetails"]) {
        // pass the current event to the new screen
        EventDetailsTableViewController *eventDetailsVC = (EventDetailsTableViewController *) segue.destinationViewController;
        Event *selectedEvent = (Event *)[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        eventDetailsVC.event = selectedEvent;
    }
}

@end
