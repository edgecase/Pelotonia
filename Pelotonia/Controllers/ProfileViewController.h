//
//  ProfileViewController.h
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "Rider.h"
#import "PullToRefreshView.h"

@interface ProfileViewController : UIViewController <MFMailComposeViewControllerDelegate, UITextFieldDelegate> {
    BOOL _following;
    PullToRefreshView *_pull;
}

@property (weak, nonatomic) IBOutlet UIButton *supportButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) Rider *rider;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UILabel *raisedLabel;
@property (weak, nonatomic) IBOutlet UILabel *commitLabel;
@property (weak, nonatomic) IBOutlet UIImageView *riderImageView;
@property (weak, nonatomic) IBOutlet UITextField *donationField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *followButton;
@property (weak, nonatomic) IBOutlet UITextField *donorEmailField;
@property (assign, nonatomic, readonly) BOOL following;
@property (weak, nonatomic) IBOutlet UIProgressView *donationProgress;
- (IBAction)supportRider:(id)sender;
- (IBAction)followRider:(id)sender;

@end

