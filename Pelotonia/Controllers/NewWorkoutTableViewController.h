//
//  NewWorkoutTableViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 2/15/14.
//
//

#import <UIKit/UIKit.h>
#import "Workout.h"
#import "Rider.h"

@protocol NewWorkoutTableViewControllerDelegate;

@interface NewWorkoutTableViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIPickerView *workoutTypePicker;
@property (strong, nonatomic) id<NewWorkoutTableViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *workoutTypeLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *workoutDistancePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *workoutLengthPicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *workoutDistanceCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *workoutTimeLengthCell;

// values
@property (strong, nonatomic) Rider *rider;
@property (strong, nonatomic) Workout *workout;
@property (assign, nonatomic) BOOL isNewWorkout;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)rideDateChanged:(id)sender;
- (IBAction)workoutTimeLengthChanged:(id)sender;

@end

@protocol NewWorkoutTableViewControllerDelegate <NSObject>

- (void)userDidEnterNewWorkout:(NewWorkoutTableViewController *)vc workout:(Workout *)workout;
- (void)userDidCancelNewWorkout:(NewWorkoutTableViewController *)vc;

@end
