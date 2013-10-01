//
//  ProfileDetailsTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 6/13/13.
//
//

#import "ProfileDetailsTableViewController.h"
#import "UIImage+Resize.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ProfileDetailsTableViewController ()

@end

@implementation ProfileDetailsTableViewController

@synthesize rider = _rider;

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

    // configure the UI appearance of the window
    self.navigationController.navigationBar.tintColor = PRIMARY_DARK_GRAY;
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = PRIMARY_DARK_GRAY;
        [self.navigationController.navigationBar setTintColor:PRIMARY_GREEN];
        [self.navigationController.navigationBar setTranslucent:NO];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we're using static cells, so get the cell from the parent
    UITableViewCell *_cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    __weak UITableViewCell *cell = _cell;
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0) {
        // name/id cell
        cell.textLabel.font = PELOTONIA_FONT(21);
        cell.detailTextLabel.font = PELOTONIA_SECONDARY_FONT(17);
        cell.textLabel.textColor = PRIMARY_GREEN;
        cell.textLabel.text = self.rider.name;
        cell.detailTextLabel.text = self.rider.route;
        
        // this masks the photo to the tableviewcell
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 5.0;
        
        // now we resize the photo and the cell so that the photo looks right
        __block UIActivityIndicatorView *activityIndicator;
        [cell.imageView addSubview:activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
        activityIndicator.center = cell.imageView.center;
        [activityIndicator startAnimating];
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:self.rider.riderPhotoUrl]
                       placeholderImage:[UIImage imageNamed:@"pelotonia-icon.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             if (error != nil) {
                 NSLog(@"ProfileDetailsTableViewController::configureView error: %@", error.localizedDescription);
             }
             [activityIndicator removeFromSuperview];
             activityIndicator = nil;
             [cell.imageView setImage:[image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(100, 100) interpolationQuality:kCGInterpolationDefault]];
             [cell layoutSubviews];
         }];

        
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        self.riderStoryTextView.text = self.rider.story;
        self.riderStoryTextView.textColor = PRIMARY_DARK_GRAY;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1) {
            UIFont *font = [UIFont systemFontOfSize:16];
            if ([font respondsToSelector:@selector(preferredFontForTextStyle:)]) {
                font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            }
            CGSize initialSize = CGSizeMake(self.riderStoryTextView.bounds.size.width, MAXFLOAT);
            CGSize sz = [self.rider.story sizeWithFont:font constrainedToSize:initialSize lineBreakMode:NSLineBreakByWordWrapping];
            return sz.height+40;
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
