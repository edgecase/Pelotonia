//
//  UserProfileViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 4/26/13.
//
//

#import "UserProfileViewController.h"
#import "PelotoniaLogInViewController.h"
#import "PelotoniaSignUpViewController.h"
#import "NSDate-Utilities.h"
#import "NSDate+Helper.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
#import "UIImage+Alpha.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Socialize/Socialize.h>
#import "CommentTableViewCell.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController


@synthesize currentUser;
@synthesize recentComments;

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
    
    self.currentUser = [SZUserUtils currentUser];
    
    // for pull to refresh view
    pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
    [pull setDelegate:self];
    [self.tableView addSubview:pull];
    
    self.navigationController.navigationBar.tintColor = PRIMARY_DARK_GRAY;
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = PRIMARY_DARK_GRAY;
        self.navigationController.navigationBar.tintColor = PRIMARY_GREEN;
        [self.navigationController.navigationBar setTranslucent:NO];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }
    
//    [self setNeedsStatusBarAppearanceUpdate];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.currentUser = [SZUserUtils currentUser];
    [self refreshUser];
}

- (void)viewWillAppear:(BOOL)animated {
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getActionsByUserOnAllEntities
{
    [SZCommentUtils getCommentsByUser:nil first:nil last:nil success:^(NSArray *comments) {
        NSLog(@"found comments %@", comments);
        self.recentComments = comments;
        [self.tableView reloadData];
        [pull finishedLoading];
    } failure:^(NSError *error) {
        NSLog(@"unable to get recent comments: %@", [error localizedDescription]);
        [pull finishedLoading];
    }];
}

- (void)configureView
{
    [self setUserNameCell:nil];
}

- (void)refreshUser
{
    [self getActionsByUserOnAllEntities];
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    [self performSelector:NSSelectorFromString(segue.identifier) withObject:segue.destinationViewController];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            [SZUserUtils showUserSettingsInViewController:self completion:^{
                NSLog(@"Done showing settings");
            }];
        }
    }
    else if (indexPath.section == 1)
    {
        id<SZComment> comment = [self.recentComments objectAtIndex:indexPath.row];
        [self manuallyShowCommentsListWithEntity:[comment entity]];
    }
}


- (void)setUserNameCell:(__weak UITableViewCell *)cell
{
    if ([self.currentUser firstName]) {
        
        self.userName.text  = [NSString stringWithFormat:@"%@ %@", [self.currentUser firstName], [self.currentUser lastName]];
        self.userType.text = [self.currentUser description];
        
        // this masks the photo to the tableviewcell
        self.userProfileImageView.layer.masksToBounds = YES;
        self.userProfileImageView.layer.cornerRadius = 5.0;
        [self.userProfileImageView setImageWithURL:[NSURL URLWithString:[self.currentUser large_image_uri]]
                       placeholderImage:[UIImage imageNamed:@"pelotonia-icon.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  [cell.imageView setImage:[image thumbnailImage:50 transparentBorder:1 cornerRadius:5 interpolationQuality:kCGInterpolationDefault]];
                                  [cell layoutSubviews];
                              }
         ];
    }
    else {
        self.userName.text = @"Sign In";
        self.userType.text = @"Support Pelotonia with your friends";
    }
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *_cell;

    // only handle the dynamic section.  static cells handled in configureView
    if (indexPath.section == 0)
    {
        _cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    if (indexPath.section == 1)
    {
        // current activity
        id<SZComment> activity = [self.recentComments objectAtIndex:indexPath.row];
        
        CommentTableViewCell *cell = [CommentTableViewCell cellForTableView:tableView];
        cell.titleString = [self getTitleFromComment:activity];
        cell.commentString = [self getTextFromComment:activity];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [cell.imageView setImageWithURL:[self getImageURLFromComment:activity]
                       placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];

        
        _cell = (UITableViewCell *)cell;
    }
    
    return _cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 26;
    }
    else
    {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        if ([self.recentComments count] > 0) {
            return @"Activity";
        }
        else {
            return @"";
        }
    }
    else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 24)];
    label.textColor = PRIMARY_GREEN;
    label.font = PELOTONIA_FONT(24);
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor blackColor];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    
    [headerView addSubview:label];
    return headerView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        NSInteger num = [self.recentComments count];
        NSLog(@"Section 1 has %d cells", num);
        return num;
    }
    else
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didDeselectRowAtIndexPath:indexPath];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat sz = 26;
    
    if (indexPath.section == 1)
    {
        // figure out Pelotonia activity cell
        id<SZComment> riderComment = [self.recentComments objectAtIndex:indexPath.row];
        NSString *comment = [self getTextFromComment:riderComment];
        NSString *title = [self getTitleFromComment:riderComment];
        sz = [CommentTableViewCell getTotalHeightForCellWithCommentText:comment andTitle:title];
    }
    else
    {
        sz = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    return sz;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    
    // if dynamic section make all rows the same indentation level as row 0
    if (section == 1)
    {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    }
    else
    {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}


- (void)viewDidUnload {
    [self setUserName:nil];
    [self setUserType:nil];
    [self setUserProfileImageView:nil];
    [super viewDidUnload];
}


#pragma mark -- PullToRefreshDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    [self performSelectorInBackground:@selector(refreshUser) withObject:nil];
}

-(void)manualRefresh:(NSNotification *)notification
{
    self.tableView.contentOffset = CGPointMake(0, -65);
    [pull setState:PullToRefreshViewStateLoading];
    [self performSelectorInBackground:@selector(refreshUser) withObject:nil];
}


@end
