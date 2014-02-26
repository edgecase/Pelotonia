//
//  WorkoutListTableViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 2/15/14.
//
//

#import <UIKit/UIKit.h>
#import "Workout.h"
#import "Rider.h"
#import "NewWorkoutTableViewController.h"
#import "AppDelegate.h"

@interface WorkoutListTableViewController : UITableViewController<NewWorkoutTableViewControllerDelegate>

@property (strong, nonatomic) Rider *rider;

@end
