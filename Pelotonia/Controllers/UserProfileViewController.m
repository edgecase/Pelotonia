//
//  UserProfileViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 4/26/13.
//
//
//  This is the view that you see when you launch the application.
//  it displays the user's picture, recent photos & workouts, and
//  their current fundraising tally.

@import Photos;

#import <MobileCoreServices/MobileCoreServices.h>
#import <AAPullToRefresh/AAPullToRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <Socialize/Socialize.h>
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
#import "CommentTableViewCell.h"
#import "FindRiderViewController.h"
#import "IntroViewController.h"
#import "Pelotonia-Swift.h"

#ifndef DEBUG
#define DEBUG   0
#endif

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController {
    NSArray *_workouts;
    AAPullToRefresh *_tv;
    
    PHAssetCollection *assetCollection;
    bool albumFound;
    PHObjectPlaceholder *assetCollectionPlaceholder;
    PHAssetCollection *collection;
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
    self.library = [[AppDelegate sharedDataController] sharedAssetsLibrary];
    self.rider = [[AppDelegate sharedDataController] favoriteRider];
    _workouts = [[AppDelegate sharedDataController] workouts];

    __weak UserProfileViewController *weakSelf = self;
    _tv = [self.tableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v) {
        [weakSelf refreshUser];
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.5f];
    }];
    
    _tv.imageIcon = [UIImage imageNamed:@"PelotoniaBadge"];
    _tv.borderColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // if this is our first time loading, pop up the "this is how you use me" screen
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (nil == [defaults objectForKey:@"firstRun"] || ([self showInDebug])) {
        [defaults setObject:[NSDate date] forKey:@"firstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSegueWithIdentifier:@"SegueToIntroViewController" sender:self];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureView];
}


- (BOOL)showInDebug
{
    BOOL retval = FALSE;
    
    NSDate *lastRun = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"];
    
    if ( DEBUG && ([lastRun daysAgo] > 1)) {
        return TRUE;
    }
    
    return retval;
}

- (void)viewDidUnload {
    [self setUserName:nil];
    [self setUserType:nil];
    [self setUserPhoto:nil];
    self.library = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [self.tableView removeObserver:_tv forKeyPath:@"contentOffset"];
    [self.tableView removeObserver:_tv forKeyPath:@"contentSize"];
    [self.tableView removeObserver:_tv forKeyPath:@"frame"];
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
        self.recentWorkoutDateLabel.text = [NSString stringWithFormat:@"%@ (%ld Miles)", [mostRecent.date stringWithFormat:@"MMM dd"], (long)mostRecent.distanceInMiles];
        self.milesThisYearLabel.text = [NSString stringWithFormat:@"%ld", (long)[self workoutMiles]];
    }
    else {
        self.recentWorkoutDateLabel.text = @"None Yet";
        self.milesThisYearLabel.text = @"0";
    }
}

- (void)setImageView:(UIImageView *)view toPhoto:(PHAsset *)photo withManager:(PHImageManager *)manager
{
    UIImage *defaultImage =
    [[UIImage imageNamed:@"profile_default_thumb"] resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                                        bounds:self.recentImage1.bounds.size
                                                          interpolationQuality:kCGInterpolationDefault];

    [manager requestImageForAsset:photo targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result != nil) {
            [view setImage:[result roundedCornerImage:5 borderSize:1]];
        }
        else {
            [view setImage:[defaultImage roundedCornerImage:5 borderSize:1]];
        }
    }];
}

- (void)configureRecentPhotos
{
    [[AppDelegate pelotoniaPhotoLibrary] images:^(PHFetchResult * _Nonnull photos) {
        PHImageManager *manager = [PHImageManager defaultManager];
        
        if (photos.count > 0) {
            [self setImageView:self.recentImage1 toPhoto:[photos objectAtIndex:0] withManager:manager];
        }
        if (photos.count > 1) {
            [self setImageView:self.recentImage2 toPhoto:[photos objectAtIndex:1] withManager:manager];
        }
        if (photos.count > 2) {
            [self setImageView:self.recentImage3 toPhoto:[photos objectAtIndex:2] withManager:manager];
        }
    }];
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
    NSString *segueID = [segue identifier];
    
    if ([segueID isEqualToString:@"SegueToRiderProfile"]) {
        // seeing a rider profile next
        ProfileTableViewController *profVC = (ProfileTableViewController *)segue.destinationViewController;
        profVC.rider = [[AppDelegate sharedDataController] favoriteRider];
    }
    
    if ([segueID isEqualToString:@"SegueToLinkProfile"]) {
        NSLog(@"linking profile...");
        FindRiderViewController *findRiderVC = (FindRiderViewController *)segue.destinationViewController;
        findRiderVC.delegate = self;
    }
    
    if ([segueID isEqualToString:@"SegueToShowWorkoutList"]) {
        WorkoutListTableViewController *workoutVC = (WorkoutListTableViewController *)segue.destinationViewController;
        workoutVC.navigationItem.backBarButtonItem.title = self.rider.name;
        workoutVC.rider = self.rider;
    }
    
    if ([segueID isEqualToString:@"SegueToNewWorkout"]) {
        // create a new workout
        NewWorkoutTableViewController *newWorkoutVC = (NewWorkoutTableViewController *)[[segue.destinationViewController viewControllers] objectAtIndex:0];
        newWorkoutVC.workout = [Workout defaultWorkout];
        newWorkoutVC.delegate = self;
        newWorkoutVC.isNewWorkout = YES;
    }
    
    if ([segueID isEqualToString:@"SegueToIntroViewController"]) {
        // no-op, nothing to do
//        IntroViewController *introViewController = (IntroViewController *)segue.destinationViewController;
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
        
        [self.riderPhoto setImageWithURL:[NSURL URLWithString:self.rider.riderPhotoThumbUrl] placeholderImage:[UIImage imageNamed:@"speedy_arrow"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
    self.navigationItem.title = self.riderName.text;
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
    // show action sheet allowing picking or taking image
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // do what we do when we choose photo
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"Take Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // do what we do when we take picture
        [self startCameraControllerFromViewController:self usingDelegate:self];
    }]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:sheet animated:YES completion:nil];
}

- (IBAction)signIn:(id)sender {
    // if the user is not yet linked to any social network, ensure that they do so
    if (![SZUserUtils userIsLinked]) {
        [SZUserUtils showLinkDialogWithViewController:self
                                           completion:^(SZSocialNetwork selectedNetwork) {
            NSLog(@"Linked!");
        } cancellation:^{
            NSLog(@"Not linked!");
        }];
    }
    // if they are already linked, show their profile
    else {
        [SZUserUtils showUserProfileInViewController:self user:[SZUserUtils currentUser] completion:^(id<SocializeFullUser> user) {
            NSLog(@"Showing user profile");
        }];
    }
}

#pragma mark -- UIImagePicker methods
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) ||
        (delegate == nil) || (controller == nil)) {
        return NO;
    }
    
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
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)showImages
{
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    
    [assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isMemberOfClass:[PHAsset class]]) {
            PHAsset *asset = obj;
            CGSize imageSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
            
            [imageManager requestImageForAsset:asset
                                    targetSize:imageSize
                                   contentMode:PHImageContentModeAspectFill
                                       options:options
                                 resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                     // add image data to list of images for the profile
                                     
            }];
        }
    }];
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
        
        [[AppDelegate pelotoniaPhotoLibrary] saveImage:imageToSave completion:^(NSURL * _Nullable url, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"error writing image: %@", [error localizedDescription]);
            }
            else {
                [self showImages];
            }
            [picker dismissViewControllerAnimated:YES completion:nil];
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
