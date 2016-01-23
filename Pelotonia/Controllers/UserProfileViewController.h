//
//  UserProfileViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 4/26/13.
//
//

@import UIKit;
@import Photos;

#import "ProfileTableViewController.h"
#import "FindRiderViewController.h"
#import "NewWorkoutTableViewController.h"
#import <Socialize/Socialize.h>


@interface UserProfileViewController : UITableViewController<FindRiderViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NewWorkoutTableViewControllerDelegate, UIActionSheetDelegate> {
}
@property (weak, nonatomic) IBOutlet UITableViewCell *riderProfileCell;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userType;
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *riderName;
@property (weak, nonatomic) IBOutlet UILabel *riderDistance;
@property (weak, nonatomic) IBOutlet UIImageView *riderPhoto;
@property (weak, nonatomic) IBOutlet UITableViewCell *RiderCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *UserCell;
@property (strong, nonatomic) PHPhotoLibrary *library;
@property (weak, nonatomic) IBOutlet UILabel *recentWorkoutDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *recentImage1;
@property (weak, nonatomic) IBOutlet UIImageView *recentImage2;
@property (weak, nonatomic) IBOutlet UIImageView *recentImage3;
@property (weak, nonatomic) IBOutlet UILabel *milesThisYearLabel;

// non-UI properties
@property (strong, nonatomic) id<SZFullUser> currentUser;
@property (strong, nonatomic) Rider *rider;
@property (strong, nonatomic) NSArray *recentComments;
@property (strong, nonatomic) NSMutableArray *photos;

- (IBAction)addPhotoToAlbum:(id)sender;
- (IBAction)signIn:(id)sender;

@end
