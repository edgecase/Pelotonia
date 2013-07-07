//
//  UserProfileViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 4/26/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfileTableViewController.h"

@interface UserProfileViewController : UITableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *signInOutButton;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userType;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

- (IBAction)revealMenu:(id)sender;
- (IBAction)signInOutPressed:(id)sender;
- (IBAction)shareButtonPressed:(id)sender;

@end
