//
//  AboutTableViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 9/9/12.
//
//

#import <UIKit/UIKit.h>

@interface AboutTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextView *storyTextView;

- (IBAction)done:(id)sender;
- (IBAction)sandlotPressed:(id)sender;
- (IBAction)newContextPressed:(id)sender;
- (void)openURLFromString:(NSString *)urlString;
- (IBAction)revealMenu:(id)sender;

@end
