//
//  MenuViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 4/14/13.
//
//

#import "MenuViewController.h"
#import "PRPWebViewController.h"
#import "Pelotonia-Colors.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define USER_PROFILE_ROW 1

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

    cell.textLabel.font = PELOTONIA_SECONDARY_FONT(20);
    if (indexPath.row == USER_PROFILE_ROW && indexPath.section == 0) {
        // name/rider type cell
        if ([PFUser currentUser])
        {
            // user is logged in
            PFUser *currentUser = [PFUser currentUser];
            NSDictionary *profile = [currentUser objectForKey:@"profile"];
            if (profile)
            {
                cell.textLabel.text = [profile objectForKey:@"name"];
                NSURL *url = [NSURL URLWithString:[profile objectForKey:@"pictureURL"]];
                
                // this masks the photo to the tableviewcell
                cell.imageView.layer.masksToBounds = YES;
                cell.imageView.layer.cornerRadius = 5.0;
                
                __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [cell.imageView addSubview:activityIndicator];
                activityIndicator.center = cell.imageView.center;
                [activityIndicator startAnimating];
                
                [cell.imageView setImageWithURL:url
                               placeholderImage:[UIImage imageNamed:@"pelotonia-icon.png"]
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
                 {
                     if (error != nil) {
                         NSLog(@"ProfileTableViewController::configureView error: %@", error.localizedDescription);
                     }
                     [activityIndicator removeFromSuperview];
                     activityIndicator = nil;
                     [cell layoutSubviews];
                 }];
            } else {
                cell.textLabel.text = currentUser.username;
            }

        } else {
            cell.textLabel.text = @"Sign In";
            [cell.imageView setImage:nil];
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header-background.png"]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 21)];
    label.textColor = PRIMARY_GREEN;
    label.font = PELOTONIA_FONT(21);
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = SECONDARY_LIGHT_GRAY;

    label.text = [super tableView:tableView titleForHeaderInSection:section];
    [headerView addSubview:label];
    return headerView;
}

- (void)slideToStoryboardViewControllerNamed:(NSString *)newViewControllerName
{
    if (newViewControllerName == nil) {
        // just close the sliding view controller
        [self.slidingViewController resetTopView];
        return;
    }
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:newViewControllerName];
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

- (void)openWebViewWithURL:(NSString *)url
{
    // see the registration form
    PRPWebViewController *webVC = [[PRPWebViewController alloc] init];
    webVC.url = [NSURL URLWithString:url];
    webVC.showsDoneButton = NO;
    webVC.delegate = self;
    webVC.backgroundColor = [UIColor colorWithRed:0.151 green:0.151 blue:0.151 alpha:1.000];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:webVC];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = navc;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
                break;
        }
        [self slideToStoryboardViewControllerNamed:newViewControllerName];
    }
    
    if (indexPath.section == 1)
    {
        switch (indexPath.row) {
            case ID_ABOUT_PELOTONIA_MENU: {
                // go to the about controller
                newViewControllerName = @"AboutTableViewController";
                [self slideToStoryboardViewControllerNamed:newViewControllerName];
                break;
            }
            case ID_REGISTER_MENU: 
                [self openWebViewWithURL:@"http://www.pelotonia.org/register"];
                break;
                
            case ID_SAFETY_MENU:
                // open safari to the safety site
                [self openWebViewWithURL:@"http://www.pelotonia.org/ride/safety"];
                break;
                
            default:
                break;
        }
        

    }
    
    
}


#pragma mark - PRPWebViewControllerDelegate
- (void)webControllerDidFinishLoading:(PRPWebViewController *)controller {
    NSLog(@"webControllerDidFinishLoading!");
}

- (void)webController:(PRPWebViewController *)controller didFailLoadWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil]  show];
}

- (BOOL)webController:(PRPWebViewController *)controller shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return [self shouldAutorotateToInterfaceOrientation:orientation];
}



@end
