//
//  MenuViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 4/14/13.
//
//

#import "MenuViewController.h"

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

//    cell.textLabel.text = "";
    cell.textLabel.font = PELOTONIA_SECONDARY_FONT(16);
    return cell;
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
                
            case ID_ABOUT_PELOTONIA_MENU:
                // go to the about controller
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
