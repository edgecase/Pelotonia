//
//  MenuViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 4/14/13.
//
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "PRPWebViewControllerDelegate.h"


#define ID_PROFILE_MENU             0
#define ID_RIDERS_MENU              1

#define ID_ACTIVITY_MENU            0
#define ID_REGISTER_MENU            1
#define ID_SAFETY_MENU              2
#define ID_EVENTS_MENU              3
#define ID_ABOUT_PELOTONIA_MENU     4


@interface MenuViewController : UITableViewController <PRPWebViewControllerDelegate>
- (IBAction) unwindToMenuViewController:(UIStoryboardSegue *)segue;

@end
