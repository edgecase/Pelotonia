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
#import "WorkoutListTableViewController.h"
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AAPullToRefresh/AAPullToRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <Socialize/Socialize.h>
#import "CommentTableViewCell.h"
#import "FindRiderViewController.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController {
    NSArray *_workouts;
    AAPullToRefresh *_tv;
}


@synthesize currentUser;
@synthesize recentComments;
@synthesize library;

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
    self.library = [[ALAssetsLibrary alloc] init];
    self.rider = [[AppDelegate sharedDataController] favoriteRider];
    _workouts = [[AppDelegate sharedDataController] workouts];

    __weak UserProfileViewController *weakSelf = self;
    _tv = [self.tableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v) {
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
    [self refreshUser];
}


- (void)viewDidUnload {
    [self setUserName:nil];
    [self setUserType:nil];
    [self setUserPhoto:nil];
    self.library = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- regular implementation

- (void) configureView {
    [self configureRecentPhotos];
    [self configureWorkoutCell];
    [self configureRiderCell];
}

- (NSInteger)workoutMiles {
    NSInteger sum = 0;
    for (Workout *w in _workouts) {
        sum += w.distanceInMiles;
    }
    return sum;
}
- (void)configureWorkoutCell
{
    // show details of most recent workout
    if ([_workouts count] > 0) {
        NSArray *workoutsSorted = [_workouts sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Workout *w1 = (Workout *)obj1;
            Workout *w2 = (Workout *)obj2;
            return [w2.date compare:w1.date];
        }];
        Workout *mostRecent = [workoutsSorted objectAtIndex:0];
        self.recentWorkoutDateLabel.text = [NSString stringWithFormat:@"%@ (%d Miles)", [mostRecent.date stringWithFormat:@"MMM dd"], mostRecent.distanceInMiles];
        self.milesThisYearLabel.text = [NSString stringWithFormat:@"%d", [self workoutMiles]];
    }
    else {
        self.recentWorkoutDateLabel.text = @"None Yet";
        self.milesThisYearLabel.text = @"0";
    }
}

- (void) setImageView:(UIImageView *)view fromPhotos:(NSArray *)photos atIndex:(NSInteger)index
{
    NSString *key = [[photos objectAtIndex:index] objectForKey:@"key"];
        // load the image from the asset library
        [self.library assetForURL:[NSURL URLWithString:key] resultBlock:^(ALAsset *asset) {
            [view setImage:[[UIImage imageWithCGImage:[asset thumbnail]] roundedCornerImage:5 borderSize:1]];
        } failureBlock:^(NSError *error) {
            NSLog(@"error loading image %@", [error localizedDescription]);
            [view setImage:[[UIImage imageNamed:@"profile_default_thumb"] resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:view.bounds.size  interpolationQuality:kCGInterpolationDefault]];
        }];
}

- (void)configureRecentPhotos
{
    NSArray *photos = [[AppDelegate sharedDataController] photoKeys];
    photos = [photos sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *photoDict1 = (NSDictionary *)obj1;
        NSDictionary *photoDict2 = (NSDictionary *)obj2;
        NSDate *date1 = [photoDict1 objectForKey:@"date"];
        NSDate *date2 = [photoDict2 objectForKey:@"date"];
        return [date2 compare:date1];
    }];
    
    if ([photos count] >= 1) {
        [self setImageView:self.recentImage1 fromPhotos:photos atIndex:0];
    }
    if ([photos count] >= 2) {
        [self setImageView:self.recentImage2 fromPhotos:photos atIndex:1];
    }
    if ([photos count] >= 3) {
        [self setImageView:self.recentImage3 fromPhotos:photos atIndex:2];
    }
}

- (void)refreshUser
{
    if (self.rider) {
        [self.rider refreshFromWebOnComplete:^(Rider *rider) {
            [[AppDelegate sharedDataController] setFavoriteRider:rider];
            [self configureView];
        } onFailure:^(NSString *errorMessage) {
            NSLog(@"Unable to refresh user");
        }];
    }
    else {
        [self configureView];
    }
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
    
    if ([[segue identifier] isEqualToString:@"SegueToShowWorkoutList"]) {
        WorkoutListTableViewController *workoutVC = (WorkoutListTableViewController *)segue.destinationViewController;
        workoutVC.navigationItem.backBarButtonItem.title = self.rider.name;
    }
    
    if ([[segue identifier] isEqualToString:@"SegueToNewWorkout"]) {
        // create a new workout
        NewWorkoutTableViewController *newWorkoutVC = (NewWorkoutTableViewController *)[[segue.destinationViewController viewControllers] objectAtIndex:0];
        newWorkoutVC.workout = [Workout defaultWorkout];
        newWorkoutVC.delegate = self;
        newWorkoutVC.isNewWorkout = YES;
    }
    
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // clicked a linked profile
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (self.rider) {
                [self performSegueWithIdentifier:@"SegueToRiderProfile" sender:self];
            }
            else {
                [self performSegueWithIdentifier:@"SegueToLinkProfile" sender:self];
            }
        }
    }
}

- (void)configureRiderCell
{
    if (self.rider) {
        self.riderName.text = self.rider.name;
        self.riderDistance.text = self.rider.route;
        
        self.riderPhoto.contentMode = UIViewContentModeScaleAspectFit;
        [self.riderPhoto setImageWithURL:[NSURL URLWithString:self.rider.riderPhotoThumbUrl]
                        placeholderImage:[UIImage imageNamed:@"speedy_arrow"]
                                 options:SDWebImageRefreshCached
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                   [self.riderProfileCell layoutSubviews];
                               } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    else {
        // let them pick a rider
        self.riderName.text = @"Your Rider Profile";
        self.riderDistance.text = nil;
        [self.riderPhoto setImage:[UIImage imageNamed:@"speedy_arrow"]];
    }
    self.riderName.font = PELOTONIA_FONT(21);
    self.riderDistance.font = PELOTONIA_FONT(16);

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
    return [super tableView:tableView viewForHeaderInSection:section];
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
    if (indexPath.row == 0) {
        return YES;
    }
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the dataController
        [[AppDelegate sharedDataController] setFavoriteRider:nil];
        self.rider = nil;
        [self configureRiderCell];
    }
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
    self.rider = rider;
    [self configureRiderCell];
}

- (IBAction)addPhotoToAlbum:(id)sender
{
    if (NO == [self startCameraControllerFromViewController:self usingDelegate:self]) {
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

- (IBAction)signIn:(id)sender {
    [SZUserUtils showUserSettingsInViewController:self completion:nil];
}



#pragma mark -- UIImagePicker methods
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    if ([[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    }
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate
{
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = YES;
    
    mediaUI.delegate = delegate;
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        // Save the new image (original or edited) to the Camera Roll
        [self.library writeImageToSavedPhotosAlbum:imageToSave.CGImage
                                          metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                                   completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"error writing image: %@", [error localizedDescription]);
            }
            else {
                // no error, so put it in the cache, and add to our list of images
                NSString *key = [assetURL absoluteString];
                [[SDImageCache sharedImageCache] storeImage:imageToSave forKey:key];
                [[[AppDelegate sharedDataController] photoKeys] addObject:@{@"key" : key, @"date" : [NSDate date]}];
                
                [picker dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

#pragma mark -- NewWorkouTableViewControllerDelegate
- (void)userDidCancelNewWorkout:(NewWorkoutTableViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidEnterNewWorkout:(NewWorkoutTableViewController *)vc workout:(Workout *)workout
{
    [[[AppDelegate sharedDataController] workouts] addObject:workout];
    _workouts = [[AppDelegate sharedDataController] workouts];
    [vc dismissViewControllerAnimated:YES completion:nil];
    [self configureWorkoutCell];
}


@end
