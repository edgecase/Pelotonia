//
//  ProfileDetailsTableViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 6/13/13.
//
//

#import <UIKit/UIKit.h>
#import "Rider.h"

@interface ProfileDetailsTableViewController : UITableViewController

@property (strong, nonatomic) Rider *rider;
@property (weak, nonatomic) IBOutlet UITextView *riderStoryTextView;

@end
