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
#import <SDWebImage/UIImageView+WebCache.h>

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

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


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView
{
    [self.tableView reloadData];
    // update the UI of the app appropriately.
    [self.signInOutButton setTitle:@"Log In"];
}

- (void)showSignInOutDialog
{
    // do nothing for now
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self performSelector:NSSelectorFromString(segue.identifier) withObject:segue.destinationViewController];
}

- (void)showPelotoniaRiderProfile:(ProfileTableViewController *)profileTableViewController
{
    NSLog(@"executing showPelotoniaRiderProfile");
    NSString *riderID;
    
    Rider *rider = [[Rider alloc] initWithName:@"Mark Harris" andId:@"MH0015"];
    if (rider)
    {
        profileTableViewController.rider = rider;
    }
    else
    {
        NSLog(@"rider not found %@", riderID);
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        // get the user's RiderID and get the rider object
        // fire up rider search box
        NSString *riderID = nil;
        
        if (nil != riderID)
        {
            // transition to the rider's profile
            /// execute segue
            [self performSegueWithIdentifier:@"showPelotoniaRiderProfile:" sender:self];
        }
        else
        {
            [self linkProfileToPelotonia];
        }
    }
}

- (void)setUserNameCell:(__weak UITableViewCell *)cell
{
    cell.textLabel.font = PELOTONIA_FONT(20);
    cell.textLabel.text = @"CHANGE ME";
    
    // this masks the photo to the tableviewcell
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 5.0;
    [cell.imageView setImage:[UIImage imageNamed:@"pelotonia-icon.png"]];
    [cell layoutSubviews];
}

- (void)linkProfileToPelotonia
{
    // prompt user for his/her credentials
    
    // post against the pelotonia login form
    
    // if it comes back OK, then add a user ID to the current user object
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *_cell;
    
    if (indexPath.section == 0)
    {
        _cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        __weak UITableViewCell *cell = _cell;
        if (indexPath.row == 0)
        {
            [self setUserNameCell:cell];
        }
    }
    else
    {
        // current activity
        _cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return _cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
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
        return @"Recent Activity";
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

#pragma mark -- menu code
- (IBAction)revealMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)signInOutPressed:(id)sender
{
    [self configureView];
}

- (IBAction)shareButtonPressed:(id)sender {
}


- (void)viewDidUnload {
    [self setSignInOutButton:nil];
    [self setUserName:nil];
    [self setUserType:nil];
    [self setUserProfileImageView:nil];
    [self setShareButton:nil];
    [super viewDidUnload];
}
@end
