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
#import "UIImage+Resize.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Socialize/Socialize.h>


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
    UITableViewCell *_cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    __weak UITableViewCell *cell = _cell;
    
    cell.textLabel.font = PELOTONIA_SECONDARY_FONT(20);
    if (indexPath.row == ID_PROFILE_MENU && indexPath.section == 0)
    {
        id<SZFullUser> currentUser = [SZUserUtils currentUser];
        if ([currentUser firstName]) {
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [currentUser firstName], [currentUser lastName]];
            cell.imageView.layer.masksToBounds = YES;
            cell.imageView.layer.cornerRadius = 5.0;

            [cell.imageView setImageWithURL:[NSURL URLWithString:[currentUser smallImageUrl]]
                           placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                [cell layoutSubviews];
            }];
        }
        else {
            cell.textLabel.text = @"Sign In";
            [cell.imageView setImage:[[UIImage imageNamed:@"pelotonia-menu-icon.png"] thumbnailImage:25 transparentBorder:1 cornerRadius:5 interpolationQuality:kCGInterpolationHigh]];
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
            case ID_ACTIVITY_MENU:
                // see all activity by all users
                newViewControllerName = @"ActivityViewController";
                break;
                
            case ID_PROFILE_MENU:
                // see my profile
                newViewControllerName = @"UserProfileViewController";
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
