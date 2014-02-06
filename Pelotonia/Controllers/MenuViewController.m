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
#import "TestFlight.h"
#import "UIColor+LightAndDark.h"


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


#pragma mark - ECSlidingViewController unwind segue thing
- (IBAction) unwindToMenuViewController:(UIStoryboardSegue *)segue { }


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
    headerView.backgroundColor = [PRIMARY_DARK_GRAY darkerColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 21)];
    label.textColor = PRIMARY_GREEN;
    label.font = PELOTONIA_FONT(21);
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor clearColor];

    label.text = [super tableView:tableView titleForHeaderInSection:section];
    [headerView addSubview:label];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - preparation for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToRegister"]) {
        [TestFlight passCheckpoint:@"ShowRegistrationDialog"];
        PRPWebViewController *webVC = (PRPWebViewController *) [[segue destinationViewController] visibleViewController];

        // see the registration form
        webVC.url = [NSURL URLWithString:@"http://www.pelotonia.org/register"];
        webVC.showsDoneButton = NO;
        webVC.delegate = self;
        webVC.backgroundColor = [UIColor colorWithRed:0.151 green:0.151 blue:0.151 alpha:1.000];
    }
    if ([segue.identifier isEqualToString:@"SegueToVideo"]) {
        [TestFlight passCheckpoint:@"ShowSafetyVideo"];
        PRPWebViewController *webVC = (PRPWebViewController *) [[segue destinationViewController] visibleViewController];
        
        // see the registration form
        webVC.url = [NSURL URLWithString:@"http://www.pelotonia.org/ride/safety"];
        webVC.showsDoneButton = NO;
        webVC.delegate = self;
        webVC.backgroundColor = [UIColor colorWithRed:0.151 green:0.151 blue:0.151 alpha:1.000];
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
    return [self shouldAutorotate];
}

- (BOOL)shouldAutorotate {
    return YES;
}



@end
