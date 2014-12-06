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
#import "AppDelegate.h"
#import "Rider.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Socialize/Socialize.h>
#import "EventsTableViewController.h"
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate

{
    return YES;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
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
        Rider *myProfile;
        if ((myProfile = [[AppDelegate sharedDataController] favoriteRider])) {
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@", myProfile.name];
            cell.imageView.layer.masksToBounds = YES;
            cell.imageView.layer.cornerRadius = 5.0;
            
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[myProfile riderPhotoThumbUrl]] placeholderImage:[UIImage imageNamed:@"profile_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [cell.imageView setImage:[image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(35, 35) interpolationQuality:kCGInterpolationDefault]];
                [cell layoutSubviews];
            }];
            
            
        }
        else {
            cell.textLabel.text = @"My Rider Profile";
            [cell.imageView setImage:[[UIImage imageNamed:@"pelotonia-menu-icon"] thumbnailImage:25 transparentBorder:1 cornerRadius:5 interpolationQuality:kCGInterpolationHigh]];
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



#pragma mark - preparation for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToRegister"]) {
        PRPWebViewController *webVC = (PRPWebViewController *) [[segue destinationViewController] visibleViewController];

        // see the registration form
        webVC.url = [NSURL URLWithString:@"http://www.pelotonia.org/register"];
        webVC.showsDoneButton = NO;
        webVC.delegate = self;
        webVC.backgroundColor = [UIColor colorWithRed:0.151 green:0.151 blue:0.151 alpha:1.000];
    }
    if ([segue.identifier isEqualToString:@"SegueToVideo"]) {
        PRPWebViewController *webVC = (PRPWebViewController *) [[segue destinationViewController] visibleViewController];
        
        // see the registration form
        webVC.url = [NSURL URLWithString:@"http://www.pelotonia.org/ride/safety"];
        webVC.showsDoneButton = NO;
        webVC.delegate = self;
        webVC.backgroundColor = [UIColor colorWithRed:0.151 green:0.151 blue:0.151 alpha:1.000];
    }

    if ([segue.identifier isEqualToString:@"SegueToBlog"]) {
        PRPWebViewController *webVC = (PRPWebViewController *) [[segue destinationViewController] visibleViewController];
        
        // see the registration form
        webVC.url = [NSURL URLWithString:@"http://www.pelotonia.org/the-blog/"];
        webVC.showsDoneButton = NO;
        webVC.delegate = self;
        webVC.backgroundColor = [UIColor colorWithRed:0.151 green:0.151 blue:0.151 alpha:1.000];
    }
    
    if ([segue.identifier isEqualToString:@"SegueToEvents"]) {
        // update events database ...
        // no-op
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





@end
