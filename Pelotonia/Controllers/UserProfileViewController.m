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
#import "RiderDataController.h"
#import "AppDelegate.h"
#import <AAPullToRefresh/AAPullToRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <Socialize/Socialize.h>
#import "CommentTableViewCell.h"
#import "FindRiderViewController.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController {
//    AAPullToRefresh *_tv;
}


@synthesize currentUser;
@synthesize recentComments;

// property overloads

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
    self.rider = [[AppDelegate sharedDataController] favoriteRider];

    __weak UserProfileViewController *weakSelf = self;
    AAPullToRefresh *_tv = [self.tableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v) {
        [weakSelf refreshUser];
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.5f];
    }];
    
    _tv.imageIcon = [UIImage imageNamed:@"PelotoniaBadge"];
    _tv.borderColor = [UIColor whiteColor];
    
    // logo in title bar
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pelotonia_logo_22x216"]];
    self.navigationItem.titleView = imageView;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    self.currentUser = [SZUserUtils currentUser];
    if ([SZUserUtils userIsAuthenticated]) {
        self.navigationController.navigationBar.topItem.title = [self.currentUser displayName];
    }
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView
{
    [self setUserNameCell:nil];
    Rider *favorite = [AppDelegate sharedDataController].favoriteRider;
    [self setRiderCellValues:favorite];
}

- (void)refreshUser
{
    Rider *rider = [[AppDelegate sharedDataController] favoriteRider];
    if (rider) {
        
        [PelotoniaWeb searchForRiderWithLastName:nil riderId:rider.riderId onComplete:^(NSArray *searchResults) {
            if ([searchResults count] > 0) {
                Rider *foundRider = [searchResults objectAtIndex:0];
                [foundRider refreshFromWebOnComplete:^(Rider *rider) {
                    [[AppDelegate sharedDataController] setFavoriteRider:rider];
                    [self configureView];
                } onFailure:^(NSString *errorMessage) {
                    NSLog(@"Unable to refresh user");
                }];
            }
        } onFailure:^(NSString *errorMessage) {
            NSLog(@"Unable to refresh rider");
        }];
        
    }
    [self configureView];
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SegueToRiderProfile"]) {
        // seeing a rider profile next
        ProfileTableViewController *profVC = (ProfileTableViewController *)segue.destinationViewController;
        profVC.rider = [[AppDelegate sharedDataController] favoriteRider];
    }
    
    if ([[segue identifier] isEqualToString:@"SegueToLinkProfile"]) {
        NSLog(@"linking profile...");
        FindRiderViewController *findRiderVC = (FindRiderViewController *)segue.destinationViewController;
        findRiderVC.delegate = self;
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // clicked username cell
    if (indexPath.section == 0)
    {
        [SZUserUtils showUserSettingsInViewController:self completion:nil];
    }
    
    // clicked a linked profile
    if (indexPath.section == 1) {
        if ([[AppDelegate sharedDataController] favoriteRider]) {
            [self performSegueWithIdentifier:@"SegueToRiderProfile" sender:cell];
        }
        else {
            [self performSegueWithIdentifier:@"SegueToLinkProfile" sender:cell];
        }
    }
}

- (void)setRiderCellValues:(Rider *)rider
{
    if (rider) {
        self.rider = rider;
        self.riderName.text = self.rider.name;
        self.riderDistance.text = self.rider.route;
        
        [self.riderPhoto setImageWithURL:[NSURL URLWithString:self.rider.riderPhotoUrl] placeholderImage:[UIImage imageNamed:@"profile_default_thumb"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [self.riderPhoto setImage:[image thumbnailImage:90 transparentBorder:1 cornerRadius:5 interpolationQuality:kCGInterpolationDefault]];
            [self.RiderCell layoutSubviews];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    }
    else {
        // let them pick a rider
        self.riderName.text = @"Choose your Rider Profile";
        self.riderDistance.text = nil;
        [self.riderPhoto setImage:nil];
    }
}

- (void)setUserNameCell:(__weak UITableViewCell *)cell
{
    if ([self.currentUser firstName]) {
        
        self.userName.text  = [NSString stringWithFormat:@"%@ %@", [self.currentUser firstName], [self.currentUser lastName]];
        self.userType.text = [self.currentUser description];

        // this masks the photo to the tableviewcell
        [self.userPhoto setImageWithURL:[NSURL URLWithString:[self.currentUser large_image_uri]] placeholderImage:[UIImage imageNamed:@"profile_default_thumb"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [self.userPhoto setImage:[image thumbnailImage:90 transparentBorder:1 cornerRadius:5 interpolationQuality:kCGInterpolationDefault]];
            [self.UserCell layoutSubviews];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
    }
    else {
        self.userName.text = @"Sign In";
        self.userType.text = @"Support Pelotonia with your friends";
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *_cell;

    // only handle the dynamic section.  static cells handled in configureView
    if (indexPath.section == 0)
    {
        _cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    // rider profile cell
    if (indexPath.section == 1) {
        _cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        _cell.textLabel.font = PELOTONIA_FONT(21);
        _cell.detailTextLabel.font = PELOTONIA_FONT(12);
        _cell.textLabel.textColor = PRIMARY_GREEN;
        _cell.detailTextLabel.textColor = SECONDARY_GREEN;
    }
    
    
    return _cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [super tableView:tableView heightForHeaderInSection:section];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [super tableView:tableView titleForHeaderInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 10, 24)];
    label.textColor = [UIColor whiteColor];
    label.font = PELOTONIA_FONT(20);
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor blackColor];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    
    [headerView addSubview:label];
    return headerView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [super tableView:tableView numberOfRowsInSection:section];
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didDeselectRowAtIndexPath:indexPath];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if dynamic section make all rows the same indentation level as row 0
    return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
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
    [self setUserPhoto:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark -- FindRiderViewController methods

- (void)findRiderViewControllerDidCancel:(FindRiderViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)findRiderViewControllerDidSelectRider:(FindRiderViewController *)controller rider:(Rider *)rider
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [[AppDelegate sharedDataController] setFavoriteRider:rider];
    [self configureView];
}

@end
