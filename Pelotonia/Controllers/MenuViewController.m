//
//  MenuViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 4/14/13.
//
//

#import "MenuViewController.h"
#import "Pelotonia-Colors.h"
#import "UIImage+Resize.h"
#import "AppDelegate.h"
#import "Rider.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Socialize/Socialize.h>
#import "EventsTableViewController.h"
#import "UIColor+LightAndDark.h"


static NSInteger kProfileButton     = 0;
static NSInteger kRegisterButton  = 1;
static NSInteger kVideoButton     = 2;
static NSInteger kClassifiedsButton = 0;
static NSInteger kBlogButton = 4;


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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
    if (indexPath.row == kProfileButton && indexPath.section == 0)
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
    label.textColor = SECONDARY_LIGHT_GRAY;
    label.font = PELOTONIA_FONT_BOLD(21);
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
    if (indexPath.section == 1) {
        
        if (indexPath.row == kRegisterButton) {
            // due to apple developer guidelines, am not allowed to launch within the browser control directly.
            // at some point in the near future, allow users to register from their profiles directly, using some
            // web forms submitted directly to the Pelotonia site
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.pelotonia.org/register"]];
        }
        else if (indexPath.row == kClassifiedsButton) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://pelotonia.org/classifieds"]];
        }
        else if (indexPath.row == kBlogButton) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.pelotonia.org/the-blog"]];
        }
        else if (indexPath.row == kVideoButton) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.pelotonia.org/ride/safety"]];
        }
    }
    
}

#pragma mark - preparation for segue
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    
//    if ([segue.identifier isEqualToString:@"SegueToEvents"]) {
//        // update events database ...
//        // no-op
//    }
//
//}



@end
