//
//  MenuViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 4/14/13.
//
//

#import "MenuViewController.h"
#import "Pelotonia-Colors.h"

@interface MenuViewController ()

@end

@implementation MenuViewController


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
    self.tableView.backgroundColor = PRIMARY_DARK_GRAY;
    self.tableView.opaque = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
// static tables don't need all this


#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    cell.textLabel.font = PELOTONIA_SECONDARY_FONT(16);
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header-background.png"]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 21)];
    label.textColor = PRIMARY_GREEN;
    label.font = PELOTONIA_FONT(17);
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = SECONDARY_LIGHT_GRAY;

    label.text = [super tableView:tableView titleForHeaderInSection:section];
    [headerView addSubview:label];
    return headerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *newTopViewController = nil;
    NSString *newViewControllerName = nil;
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
            case ID_PROFILE_MENU:
                // see my profile
                newViewControllerName = @"UserProfileViewController";
                break;
                
            case ID_ACTIVITY_STREAM_MENU:
                // see pelotonia
                newViewControllerName = @"ActivityViewController";
                break;
                
            case ID_RIDERS_MENU:
                // go to my followers (riders' list)
                newViewControllerName = @"RidersNavViewController";
                break;
                
            default:
                newViewControllerName = @"AboutTableViewController";
        }
    }
    
    if (indexPath.section == 1)
    {
        switch (indexPath.row) {
            case ID_ABOUT_PELOTONIA_MENU:
                // go to the about controller
                newViewControllerName = @"AboutTableViewController";
                break;
                
            case ID_REGISTER_MENU:
                // see the registration form
                newViewControllerName = @"AboutTableViewController";
                [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:[NSURL URLWithString:@"http://pelotonia.org/register/"] afterDelay:1.0];
                
                
            case ID_SAFETY_MENU:
                // open safari to the safety site
                newViewControllerName = @"AboutTableViewController";
                [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:[NSURL URLWithString:@"http://pelotonia.org/ride/safety"] afterDelay:1.0];
                break;
                
            default:
                newViewControllerName = @"AboutTableViewController";
                break;
        }
    }
    
    newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:newViewControllerName];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

@end
