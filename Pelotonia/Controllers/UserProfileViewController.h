//
//  UserProfileViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 4/26/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfileTableViewController.h"
#import <Socialize/Socialize.h>

@interface UserProfileViewController : UITableViewController {
}
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userType;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *riderName;
@property (weak, nonatomic) IBOutlet UILabel *riderDistance;
@property (weak, nonatomic) IBOutlet UITableViewCell *RiderCell;

// non-UI properties
@property (strong, nonatomic) id<SZFullUser> currentUser;
@property (strong, nonatomic) Rider *rider;
@property (strong, nonatomic) NSArray *recentComments;


@end
