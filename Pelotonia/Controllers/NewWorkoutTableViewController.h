//
//  NewWorkoutTableViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 2/15/14.
//
//

#import <UIKit/UIKit.h>
#import "Workout.h"

@protocol NewWorkoutTableViewControllerDelegate;

@interface NewWorkoutTableViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIPickerView *workoutTypePicker;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) id<NewWorkoutTableViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *workoutTypeLabel;

// values
@property (strong, nonatomic) Workout *workout;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)distanceSliderChanged:(id)sender;
- (IBAction)timeSliderChanged:(id)sender;

@end

@protocol NewWorkoutTableViewControllerDelegate <NSObject>

- (void)userDidEnterNewWorkout:(NewWorkoutTableViewController *)vc workout:(Workout *)workout;
- (void)userDidCancelNewWorkout:(NewWorkoutTableViewController *)vc;

@end
