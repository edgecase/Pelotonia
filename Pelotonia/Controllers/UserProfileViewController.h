//
//  UserProfileViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 4/26/13.
//
//

#import <UIKit/UIKit.h>

@interface UserProfileViewController : UITableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *signInOutButton;

- (IBAction)revealMenu:(id)sender;
- (IBAction)signInOutPressed:(id)sender;

@end
