//
//  NewWorkoutTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 2/15/14.
//
//

#import "NewWorkoutTableViewController.h"
#import "NSDate+Helper.h"

@interface NewWorkoutTableViewController ()

@end

@implementation NewWorkoutTableViewController

@synthesize workout;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.workout == nil) {
        self.workout = [Workout defaultWorkout];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView
{
    self.descriptionTextView.text = self.workout.description;
    self.distanceSlider.value = (float)self.workout.distanceInMiles;
    [self.workoutTypePicker selectRow:self.workout.type inComponent:0 animated:NO];
    self.distanceLabel.text = [NSString stringWithFormat:@"%d Miles", self.workout.distanceInMiles];
    self.timeLabel.text = [NSString stringWithFormat:@"%d:%02d Hours", self.workout.timeInMinutes/60, self.workout.timeInMinutes % 60];
    self.timeSlider.value = (float)self.workout.timeInMinutes;
    self.dateLabel.text = [self.workout.date stringWithFormat:@"MM/dd/yyyy"];
}

#pragma mark - Table view data source

- (IBAction)done:(id)sender {
    [self.delegate userDidEnterNewWorkout:self];
}

- (IBAction)cancel:(id)sender {
    [self.delegate userDidCancelNewWorkout:self];
}

- (IBAction)distanceSliderChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSInteger val = floor(slider.value);
    
    self.workout.distanceInMiles = val;
    [self configureView];
}

- (IBAction)timeSliderChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    self.workout.timeInMinutes = slider.value;
    [self configureView];
    
}

#pragma mark -- UITableView stuff
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0) {
        [self.descriptionTextView resignFirstResponder];
    }
}

#pragma mark -- UIPickerView methods
// number of columns
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return [[Workout workoutTypes] count];
    }
    else {
        return 0;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [[Workout workoutTypes] objectAtIndex:row];
    }
    else {
        return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.descriptionTextView resignFirstResponder];
    if (component == 0) {
        self.workout.type = row;
    }
}

#pragma mark -- TextViewDelegate methods
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.descriptionTextView resignFirstResponder];
    self.workout.description = self.descriptionTextView.text;
    [textView resignFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}



@end
