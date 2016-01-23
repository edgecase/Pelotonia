//
//  NewsTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 6/29/14.
//
//

#import "NewsTableViewController.h"
#import "NewsDetailTableViewController.h"
#import "NewsItem.h"
#import "PelotoniaWeb.h"
#import <AAPullToRefresh/AAPullToRefresh.h>
#import "NSDate-Utilities.h"
#import "NSDate+Helper.h"
#import "NewsItemTableViewCell.h"

@interface NewsTableViewController (){
    AAPullToRefresh *_tv;
}

@end

@implementation NewsTableViewController

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
    __weak NewsTableViewController *weakSelf = self;
    _tv = [self.tableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v) {
        [weakSelf refresh];
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.5f];
    }];
    _tv.imageIcon = [UIImage imageNamed:@"PelotoniaBadge"];
    _tv.borderColor = [UIColor whiteColor];
    
    // on first load, there will be nothing in the local database, so we have to go to the network
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        [self refresh];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fetchAllEvents];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [self.tableView removeObserver:_tv forKeyPath:@"contentOffset"];
    [self.tableView removeObserver:_tv forKeyPath:@"contentSize"];
    [self.tableView removeObserver:_tv forKeyPath:@"frame"];
}

#pragma mark -- pull to refresh view
- (void)refresh
{
    // update the event list
    [PelotoniaWeb getPelotoniaNewsOnComplete:^{
        [self fetchAllEvents];
        [self.tableView reloadData];
    } onFailure:^(NSString *errorMessage) {
        NSLog(@"can't get pelotonia news");
    }];
    
}


- (void)fetchAllEvents
{
    // get all news for this current calendar year
    self.fetchedResultsController = [NewsItem MR_fetchAllSortedBy:@"dateTime" ascending:NO withPredicate:nil groupBy:nil delegate:self];
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
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsItemTableViewCell *cell = [NewsItemTableViewCell cellForTableView:tableView];
    
    cell.newsItem = (NewsItem *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    NewsItem *item = (NewsItem *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // event details path
    height = [NewsItemTableViewCell calculateHeightForNewsItem:item atWidth:tableView.bounds.size.width];
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toDetail"]) {
        NewsDetailTableViewController *newsDetailTVC = (NewsDetailTableViewController *)[segue destinationViewController];
        NewsItem *item = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        newsDetailTVC.item = item;
    }
}

@end
