//
//  SendPledgeModalViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 4/21/13.
//
//

#import <UIKit/UIKit.h>
#import "Rider.h"

@class SendPledgeModalViewController;

@protocol SendPledgeModalViewControllerDelegate <NSObject>
- (void)sendPledgeModalViewControllerDidFinish:(SendPledgeModalViewController *)controller;
- (void)sendPledgeModalViewControllerDidCancel:(SendPledgeModalViewController *)controller;
@end


@interface SendPledgeModalViewController : UITableViewController<UITextFieldDelegate>

@property (strong, nonatomic) id <SendPledgeModalViewControllerDelegate> delegate;
@property (strong, nonatomic) Rider *rider;
@property (weak, nonatomic) IBOutlet UITextField *textViewAmount;
@property (weak, nonatomic) IBOutlet UITextField *textViewName;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
