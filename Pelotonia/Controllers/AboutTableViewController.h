//
//  AboutTableViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 9/9/12.
//
//

#import <UIKit/UIKit.h>
#import "PRPWebViewControllerDelegate.h"

@interface AboutTableViewController : UITableViewController <UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextView *storyTextView;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

- (IBAction)twitterButtonClicked:(id)sender;
- (IBAction)done:(id)sender;

@end
