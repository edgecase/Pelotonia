//
//  ProfileTableViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 9/5/12.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Socialize/Socialize.h>

#import "Rider.h"
#import "PelotoniaWeb.h"
#import "SendPledgeModalViewController.h"
#import "ProfileDetailsTableViewController.h"


#define kShareActionSheet 100

@interface ProfileTableViewController : UITableViewController<MFMailComposeViewControllerDelegate, UITextFieldDelegate, SendPledgeModalViewControllerDelegate> {
    BOOL _following;
}

// UI properties
@property (weak, nonatomic) IBOutlet UIProgressView *donationProgress;
@property (weak, nonatomic) IBOutlet UITableViewCell *nameAndRouteCell;
@property (weak, nonatomic) IBOutlet UILabel *raisedAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *raisedLabel;

// non-UI properties
@property (strong, nonatomic) Rider *rider;
@property (assign, nonatomic, readonly) BOOL following;
@property (strong, nonatomic) NSArray *riderComments;

// for the Socialize Action Bar
@property (nonatomic, strong) id<SZEntity> entity;
@property (nonatomic, assign) NSInteger numLikes;

// UI actions
- (void)showPledge:(SendPledgeModalViewController *)pledgeViewController;
- (void)showDetails:(ProfileDetailsTableViewController *)profileDetailsViewController;
- (IBAction)shareProfile:(id)sender;
- (void)done;


@end
