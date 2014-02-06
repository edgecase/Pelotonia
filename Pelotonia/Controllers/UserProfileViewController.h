//
//  UserProfileViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 4/26/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfileTableViewController.h"
#import "PullToRefreshView.h"
#import <Socialize/Socialize.h>

@interface UserProfileViewController : UITableViewController <PullToRefreshViewDelegate> {
    PullToRefreshView *pull;
}
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userType;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;

// non-UI properties
@property (strong, nonatomic) id<SZFullUser> currentUser;
@property (strong, nonatomic) NSArray *recentComments;


@end
