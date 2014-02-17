//
//  UserProfileViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 4/26/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfileTableViewController.h"
#import "FindRiderViewController.h"
#import "NewWorkoutTableViewController.h"
#import <Socialize/Socialize.h>

@interface UserProfileViewController : UITableViewController<FindRiderViewControllerDelegate, NewWorkoutTableViewControllerDelegate> {
}
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userType;
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *riderName;
@property (weak, nonatomic) IBOutlet UILabel *riderDistance;
@property (weak, nonatomic) IBOutlet UIImageView *riderPhoto;
@property (weak, nonatomic) IBOutlet UITableViewCell *RiderCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *UserCell;

// non-UI properties
@property (strong, nonatomic) id<SZFullUser> currentUser;
@property (strong, nonatomic) Rider *rider;
@property (strong, nonatomic) NSArray *recentComments;

- (IBAction)addPhotoToAlbum:(id)sender;
- (IBAction)recordWorkout:(id)sender;

@end
