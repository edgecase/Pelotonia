//
//  PledgeViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "Rider.h"

@interface PledgeViewController : UIViewController <MFMailComposeViewControllerDelegate> {

}

@property (strong, nonatomic) Rider *rider;
@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *amountLabel;

- (IBAction)done:(id)sender;
- (IBAction)pledgePressed:(id)sender;

@end
