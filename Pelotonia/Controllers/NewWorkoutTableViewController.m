//
//  NewWorkoutTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 2/15/14.
//
//

#import "NewWorkoutTableViewController.h"
#import "NSDate+Helper.h"

@interface NewWorkoutTableViewController () {
    BOOL _isEditingRideDate;
    BOOL _isEditingWorkoutType;
}

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
    _isEditingRideDate = NO;
    _isEditingWorkoutType = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.distanceSlider.value = (float)self.workout.distanceInMiles;
    self.timeSlider.value = (float)self.workout.timeInMinutes;

    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (IBAction)done:(id)sender {
    [self.delegate userDidEnterNewWorkout:self workout:self.workout];
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

- (IBAction)rideDateChanged:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.workout.date = datePicker.date;
    [self configureView];
}

- (void)configureView
{
    self.distanceLabel.text = [NSString stringWithFormat:@"%d Miles", self.workout.distanceInMiles];
    self.descriptionTextView.text = self.workout.description;
    self.timeLabel.text = [NSString stringWithFormat:@"%d:%02d Hours", self.workout.timeInMinutes/60, self.workout.timeInMinutes % 60];
    self.workoutTypeLabel.text = self.workout.typeDescription;
    self.dateLabel.text = [self.workout.date stringWithFormat:@"MM/dd/yyyy"];
    [self.datePicker setDate:self.workout.date];
}


#pragma mark -- UITableView stuff
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0) {
        [self.descriptionTextView resignFirstResponder];
    }
    if (indexPath.section == 0 && indexPath.row == 1) { // this is my date cell above the picker cell
        _isEditingRideDate = !_isEditingRideDate;
        _isEditingWorkoutType = NO;
        [UIView animateWithDuration:.4 animations:^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }];
    }
    if (indexPath.section == 0 && indexPath.row == 3) { // the cell above the workout type picker
        _isEditingWorkoutType = !_isEditingWorkoutType;
        _isEditingRideDate = NO;
        [UIView animateWithDuration:.4 animations:^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 2) { // this is my date picker cell
        if (_isEditingRideDate) {
            return 162;
        }
        else {
            return 0;
        }
    }
    else if (indexPath.section == 0 && indexPath.row == 4) {
        if (_isEditingWorkoutType) {
            return 162;
        }
        else {
            return 0;
        }
    }
    else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
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
        [self configureView];
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
