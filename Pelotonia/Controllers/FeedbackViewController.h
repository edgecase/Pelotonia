//
//  FeedbackViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 9/26/13.
//
//

#import <UIKit/UIKit.h>

@interface FeedbackViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *feedbackText;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@end
