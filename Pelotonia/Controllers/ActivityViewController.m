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
    return [AppDelegate sharedDataController];
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
    _tv = [[AAPullToRefresh alloc] init];
    __weak ActivityViewController *weakSelf = self;
    _tv = [self.tableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v) {
        [weakSelf getActionsForAllUsersOnPelotonia];
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:2.0f];
    }];
    
    _tv.imageIcon = [UIImage imageNamed:@"PelotoniaBadge"];
    _tv.borderColor = [UIColor whiteColor];

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
- (void)getActionsForAllUsersOnPelotonia
{
    [SZEntityUtils getEntityWithKey:@"http://www.pelotonia.org" success:^(id<SocializeEntity> entity) {
        // get actions on the Pelotonia entity
        if (entity) {
            [SZActionUtils getActionsByEntity:entity start:[NSNumber numberWithInt:0] end:[NSNumber numberWithInt:100]
                success:^(NSArray *actions) {
                    // add the actions to the activity array
                    self.recentActivity =
                    [actions sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        SZActivity *act1 = (SZActivity *)obj1;
                        SZActivity *act2 = (SZActivity *)obj2;
                        NSComparisonResult result = [act1.date compare:act2.date];
                        if (result == NSOrderedDescending || result == NSOrderedSame) {
                            return NSOrderedAscending;
                        }
                        else {
                            return NSOrderedDescending;
                        }
                    }];
                    [self.tableView reloadData];
                }
                failure:^(NSError *error) {
                    NSLog(@"unable to get actions for Pelotonia");
                }];
        }
    } failure:^(NSError *error) {
        NSLog(@"unable to get Pelotonia entity");
    }];
    
}

- (NSString *)getTitleFromComment:(id<SZComment>) comment
{
    
    return [NSString stringWithFormat:@"%@, %@", [[comment user] userName], [NSDate stringForDisplayFromDate:[comment date] prefixed:YES alwaysDisplayTime:YES]];
}

- (NSString *)getTextFromComment:(id<SZComment>) comment
{
    NSString *text = [NSString stringWithFormat:@"%@ commented on %@: %@", [comment.user userName], [[comment entity] displayName], [comment text]];
    return text;
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
    CommentTableViewCell *cell = [CommentTableViewCell cellForTableView:tableView];
    id<SZActivity> activity = [self.recentActivity objectAtIndex:indexPath.row];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[[activity user] smallImageUrl]] placeholderImage:[UIImage imageNamed:@"profile_default"]];
    
    if ([activity isMemberOfClass:[SocializeShare class]])
    {
        SZShare *riderShare = (SZShare *)activity;
        cell.commentString = [NSString stringWithFormat:@"%@ shared %@'s profile", [[riderShare user] displayName],
                   [[riderShare entity] displayName]];
        cell.titleString = [NSString stringWithFormat:@"Shared at %@", [NSDate stringForDisplayFromDate:[riderShare date] prefixed:YES alwaysDisplayTime:YES]];
    }
    else if ([activity isMemberOfClass:[SocializeComment class]])
        {
            SZComment *comment = (SZComment *)activity;
            cell.titleString = [self getTitleFromComment:comment];
            cell.commentString = [self getTextFromComment:comment];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    else if ([activity isMemberOfClass:[SZLike class]])
    {
        SZLike *riderLike = (SZLike *)activity;
        cell.commentString = [NSString stringWithFormat:@"%@ is now following %@", [[riderLike user] displayName], [[riderLike entity] displayName]];
        cell.titleString = [NSString stringWithFormat:@"Shared at %@", [NSDate stringForDisplayFromDate:[riderLike date] prefixed:YES alwaysDisplayTime:YES]];
    }
    else
    {
        cell.commentString = @"Unknown";
        cell.titleString = @"Unknown";
    }
    [cell layoutSubviews];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<SZActivity> riderActivity = [self.recentActivity objectAtIndex:indexPath.row];
    NSString *comment;
    NSString *title;
    
    if ([riderActivity isMemberOfClass:[SZComment class]]) {
        SZComment *riderComment = (SZComment *)riderActivity;
        comment = [self getTextFromComment:riderComment];
        title = [self getTitleFromComment:riderComment];
    }
    else if ([riderActivity isMemberOfClass:[SZShare class]]) {
        SZShare *riderShare = (SZShare *)riderActivity;
        comment = [NSString stringWithFormat:@"%@ shared %@'s profile", [[riderShare user] displayName],
                              [[riderShare entity] displayName]];
        title = [NSString stringWithFormat:@"Shared at %@", [NSDate stringForDisplayFromDate:[riderShare date] prefixed:YES alwaysDisplayTime:YES]];
    }
    else if ([riderActivity isMemberOfClass:[SZLike class]]) {
        SZLike *riderLike = (SZLike *)riderActivity;
        comment = [NSString stringWithFormat:@"%@ is now following %@", [[riderLike user] displayName], [[riderLike entity] displayName]];
        title = [NSString stringWithFormat:@"Followed at %@", [NSDate stringForDisplayFromDate:[riderLike date] prefixed:YES alwaysDisplayTime:YES]];
    }
    else
    {
        comment = @"Unknown";
        title = @"Unknown";
    }
    
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
    id<SZActivity> comment = [self.recentActivity objectAtIndex:indexPath.row];
    if ([comment isMemberOfClass:[SZComment class]]) {
        [self manuallyShowCommentsListWithEntity:[comment entity]];
    }
}

#pragma mark -- PullToRefreshDelegate

-(void)manualRefresh:(NSNotification *)notification
{
    [_tv manuallyTriggered];
}


@end
