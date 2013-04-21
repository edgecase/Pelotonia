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

#import "Rider.h"
#import "PelotoniaWeb.h"
#import "PullToRefreshView.h"
#import "SendPledgeModalViewController.h"

@interface ProfileTableViewController : UITableViewController<MFMailComposeViewControllerDelegate, UITextFieldDelegate, PullToRefreshViewDelegate, SendPledgeModalViewControllerDelegate> {
    PullToRefreshView *pull;
    BOOL _following;
}

// UI properties
@property (weak, nonatomic) IBOutlet UITextField *pledgeAmountTextField;
@property (weak, nonatomic) IBOutlet UITextField *donorEmailTextField;
@property (weak, nonatomic) IBOutlet UIProgressView *donationProgress;
@property (weak, nonatomic) IBOutlet UITextView *storyTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *followButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *nameAndRouteCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *raisedAmountCell;
@property (weak, nonatomic) IBOutlet UIButton *supportRiderButton;
@property (weak, nonatomic) IBOutlet UIButton *shareOnFacebookButton;

// non-UI properties
@property (strong, nonatomic) Rider *rider;
@property (assign, nonatomic, readonly) BOOL following;

- (IBAction)supportRider:(id)sender;
- (IBAction)followRider:(id)sender;
- (IBAction)shareOnFacebook:(id)sender;
- (IBAction)revealMenu:(id)sender;

- (void)refreshRider;
- (void)manualRefresh:(NSNotification *)notification;


@end
