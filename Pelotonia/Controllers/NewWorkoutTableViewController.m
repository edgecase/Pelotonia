//
//  NewWorkoutTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 2/15/14.
//
//

#import <Social/Social.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import "NewWorkoutTableViewController.h"
#import "NSDate+Helper.h"
#import "Rider.h"

#define TEXT_VIEW_CELL      0
#define DATE_CELL           1
#define WORKOUT_TYPE_CELL   3
#define WORKOUT_MILES_CELL  5
#define WORKOUT_TIME_CELL   7


@interface NewWorkoutTableViewController () {
    BOOL _isEditingRideDate;
    BOOL _isEditingWorkoutType;
    BOOL _isEditingWorkoutTimeLength;
    BOOL _isEditingWorkoutDistance;
}

@end

@implementation NewWorkoutTableViewController

@synthesize rider;
@synthesize workout;
@synthesize delegate;
@synthesize isNewWorkout;

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
    _isEditingWorkoutTimeLength = NO;
    _isEditingWorkoutDistance = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isNewWorkout) {
        // set up the cancel/done buttons
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    else {
        // set up the "share" button
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
        self.navigationItem.rightBarButtonItem = shareButton;
    }
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

- (IBAction)share:(id)sender {
    // share the workout details over facebook or twitter

    // prompt for which service to share with (FB/Twitter/etc)
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Share workout to...?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Facebook", @"Twitter", nil];
    [sheet showFromBarButtonItem:[self.navigationItem rightBarButtonItem] animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) {
            [self shareCurrentWorkoutWithFacebook];
        }
        if (buttonIndex == 1) {
            [self shareCurrentWorkoutWithTwitter];
        }
    }
}

- (void)shareCurrentWorkoutWithFacebook
{
    
    // success - share the Workout via facebook
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:[NSString stringWithFormat:@"Pelotonia workout: %ld miles, %@", (long)self.workout.distanceInMiles, self.workout.description]];

        if (self.rider) {
            [controller addURL:[NSURL URLWithString:self.rider.profileUrl]];
        }
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)shareCurrentWorkoutWithTwitter
{
    
    // success - share the Workout via twitter
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *controller = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controller setInitialText:[NSString stringWithFormat:@"Pelotonia workout: %ld miles, %@", (long)self.workout.distanceInMiles, self.workout.description]];
        if (self.rider) {
            [controller addURL:[NSURL URLWithString:self.rider.profileUrl]];
        }
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}

- (void)setDistanceLabelText {
    self.workoutDistanceCell.textLabel.text = [NSString stringWithFormat:@"%ld Miles", (long)self.workout.distanceInMiles];
}

- (void)setTimeLabelText {
    self.workoutTimeLengthCell.textLabel.text = [NSString stringWithFormat:@"%d Hrs %02d Min", self.workout.timeInMinutes/60, self.workout.timeInMinutes % 60];
}


- (IBAction)rideDateChanged:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.workout.date = datePicker.date;
    [self configureView];
}

- (IBAction)workoutTimeLengthChanged:(id)sender {
    UIDatePicker *timeLengthPicker = (UIDatePicker *)sender;
    self.workout.timeInMinutes = timeLengthPicker.countDownDuration / 60.0;
    [self configureView];
}

- (void)configureView
{
    [self setTimeLabelText];
    [self setDistanceLabelText];
    self.descriptionTextView.text = self.workout.description;
    self.workoutTypeLabel.text = self.workout.typeDescription;
    self.dateLabel.text = [self.workout.date stringWithFormat:@"MM/dd/yyyy"];
    [self.datePicker setDate:self.workout.date];
    [self.workoutLengthPicker setCountDownDuration:(self.workout.timeInMinutes * 60)];
    
    // hide pickers if not editing them
    [self.datePicker setHidden:!_isEditingRideDate];
    [self.workoutTypePicker setHidden:!_isEditingWorkoutType];
    [self.workoutLengthPicker setHidden:!_isEditingWorkoutTimeLength];
    [self.workoutDistancePicker setHidden:!_isEditingWorkoutDistance];
}


#pragma mark -- UITableView stuff
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row != 0) {
            [self.descriptionTextView resignFirstResponder];
        }
        if (indexPath.row == DATE_CELL) { // this is my date cell above the picker cell
            _isEditingRideDate = !_isEditingRideDate;
            _isEditingWorkoutType = NO;
            _isEditingWorkoutDistance = NO;
            _isEditingWorkoutTimeLength = NO;
            [self.datePicker setHidden:!_isEditingRideDate];
            [UIView animateWithDuration:.4 animations:^{
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:DATE_CELL+1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView reloadData];
            }];
        }
        if (indexPath.row == WORKOUT_TYPE_CELL) { // the cell above the workout type picker
            _isEditingWorkoutType = !_isEditingWorkoutType;
            _isEditingRideDate = NO;
            _isEditingWorkoutDistance = NO;
            _isEditingWorkoutTimeLength = NO;
            [self.workoutTypePicker setHidden:!_isEditingWorkoutType];
            [UIView animateWithDuration:.4 animations:^{
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:WORKOUT_TYPE_CELL+1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView reloadData];
            }];
        }
        if (indexPath.row == WORKOUT_TIME_CELL) { // the cell above the workout type picker
            _isEditingWorkoutTimeLength = !_isEditingWorkoutTimeLength;
            _isEditingRideDate = NO;
            _isEditingWorkoutType = NO;
            _isEditingWorkoutDistance = NO;
            [self.workoutLengthPicker setHidden:!_isEditingWorkoutTimeLength];
            [UIView animateWithDuration:.4 animations:^{
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:WORKOUT_TIME_CELL+1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView reloadData];
            }];
        }
        if (indexPath.row == WORKOUT_MILES_CELL) { // the cell above the workout type picker
            _isEditingWorkoutDistance = !_isEditingWorkoutDistance;
            _isEditingRideDate = NO;
            _isEditingWorkoutTimeLength = NO;
            _isEditingWorkoutType = NO;
            [self.workoutDistancePicker setHidden:!_isEditingWorkoutDistance];
            [UIView animateWithDuration:.4 animations:^{
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:WORKOUT_MILES_CELL+1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView reloadData];
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat retval = 0.0;
    if (indexPath.section == 0) {
        if (indexPath.row == (DATE_CELL+1)) { // this is my date picker cell
            retval =  _isEditingRideDate ? 162.0 : 0.0;
        }
        else if (indexPath.row == (WORKOUT_TYPE_CELL+1)) {
            retval =  _isEditingWorkoutType ? 162.0 : 0.0;
        }
        else if (indexPath.row == (WORKOUT_MILES_CELL+1)) {
            retval = _isEditingWorkoutDistance ? 162.0 : 0.0;
        }
        else if (indexPath.row == (WORKOUT_TIME_CELL + 1)) {
            retval = _isEditingWorkoutTimeLength ? 162.0 : 0.0;
        }
        else {
            retval = [super tableView:tableView heightForRowAtIndexPath:indexPath];
        }
    }
    return retval;
}

#pragma mark -- UIPickerView methods
// number of columns
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSInteger retval = 1;
    // yes, I know these are the same branch.  i'm trying to be explicit.
    if (pickerView == self.workoutDistancePicker) {
        retval = 1;
    }
    else if (pickerView == self.workoutTypePicker) {
        retval = 1;
    }
    
    return retval;
}

// number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger retval = 0;
    if (pickerView == self.workoutDistancePicker) {
        // configure distance picker for 1-100 miles, by 5's
        if (component == 0) {
            // return 20 (5, 10, 15, ... 95, 100)
            retval = 105/5;
        }
    }
    else if (pickerView == self.workoutTypePicker) {
        // configure workout type picker
        if (component == 0) {
            retval = [[Workout workoutTypes] count];
        }
    }
    return retval;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *retval = nil;
    if (pickerView == self.workoutTypePicker) {
        if (component == 0) {
            retval = [[Workout workoutTypes] objectAtIndex:row];
        }
    }
    else if (pickerView == self.workoutDistancePicker) {
        if (component == 0) {
            // title is 5 * the row we're asking for (0, 5, 10, ... 95, 100)
            retval = [NSString stringWithFormat:@"%d Miles", (row * 5)];
        }
    }
    return retval;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.descriptionTextView resignFirstResponder];
    if (pickerView == self.workoutTypePicker) {
        if (component == 0) {
            self.workout.type = row;
        }
    }
    else if (pickerView == self.workoutDistancePicker) {
        if (component == 0) {
            self.workout.distanceInMiles = (row * 5);
        }
    }
    [self configureView];
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
