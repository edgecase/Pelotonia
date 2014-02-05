//
//  ActivityViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 4/26/13.
//
//

#import "AppDelegate.h"
#import "ActivityViewController.h"
#import "RiderDataController.h"
#import "CommentTableViewCell.h"
#import "NSDate+Helper.h"
#import "NSDate-Utilities.h"
#import <AAPullToRefresh/AAPullToRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "TestFlight.h"

@interface ActivityViewController ()

@end

@implementation ActivityViewController {
    AAPullToRefresh *_tv;
}

@synthesize recentActivity;
@synthesize dataController = _dataController;


// property overloads
- (RiderDataController *)dataController
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.riderDataController;
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
    
    __weak ActivityViewController *weakSelf = self;
    _tv = [self.tableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v) {
        [weakSelf getActionsForAllUsersOnAllRiders];
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:2.0f];
    }];
    
    _tv.imageIcon = [UIImage imageNamed:@"PelotoniaBadge"];
    _tv.borderColor = [UIColor whiteColor];

    
    self.navigationController.navigationBar.tintColor = PRIMARY_DARK_GRAY;
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = PRIMARY_DARK_GRAY;
        self.navigationController.navigationBar.tintColor = PRIMARY_GREEN;
        [self.navigationController.navigationBar setTranslucent:NO];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }

    [TestFlight passCheckpoint:@"ViewAllActivity"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self manualRefresh:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ActivityViewController stuff
- (void)getActionsForAllUsersOnAllRiders
{
    [SZCommentUtils getCommentsByApplicationWithFirst:nil last:nil success:^(NSArray *comments) {
        self.recentActivity = comments;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"getActionsByApplicationWithStart failed: %@", [error localizedDescription]);
    }];
}


- (NSString *)getTitleFromComment:(id<SZComment>) comment
{
    return [NSString stringWithFormat:@"%@, %@", [[comment user] userName], [NSDate stringForDisplayFromDate:[comment date] prefixed:YES alwaysDisplayTime:NO]];
}

- (NSString *)getTextFromComment:(id<SZComment>) comment
{
    return [comment text];
}

- (NSURL *)getImageURLFromComment:(id<SZComment>) comment
{
    NSString *strURL = [[comment user] smallImageUrl];
    return [NSURL URLWithString:strURL];
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
    return [self.recentActivity count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *_cell = [CommentTableViewCell cellForTableView:tableView];
    __weak CommentTableViewCell *cell = _cell;
    
    id<SZComment> comment = [self.recentActivity objectAtIndex:indexPath.row];
    if (comment)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.titleString = [self getTitleFromComment:comment];
        cell.commentString = [self getTextFromComment:comment];
        
        [cell.imageView setImageWithURL:[self getImageURLFromComment:comment]
                       placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
    }
    [cell layoutSubviews];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<SZComment> riderComment = [self.recentActivity objectAtIndex:indexPath.row];
    NSString *comment = [self getTextFromComment:riderComment];
    NSString *title = [self getTitleFromComment:riderComment];
    return [CommentTableViewCell getTotalHeightForCellWithCommentText:comment andTitle:title];
}


#pragma mark - Table view delegate
- (void)manuallyShowCommentsListWithEntity:(id<SZEntity>)entity
{
    SZCommentsListViewController *comments = [[SZCommentsListViewController alloc] initWithEntity:entity];
    comments.completionBlock = ^{
        
        // Dismiss however you want here
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    // Present however you want here
    [self presentViewController:comments animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<SZComment> comment = [self.recentActivity objectAtIndex:indexPath.row];
    [self manuallyShowCommentsListWithEntity:[comment entity]];
}

#pragma mark -- PullToRefreshDelegate

-(void)manualRefresh:(NSNotification *)notification
{
    [_tv manuallyTriggered];
}


@end
