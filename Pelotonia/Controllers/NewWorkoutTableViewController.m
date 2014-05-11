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

@interface NewWorkoutTableViewController () {
    BOOL _isEditingRideDate;
    BOOL _isEditingWorkoutType;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // these have to be here to avoid stuttering when we configureView
    // as the user moves the slider around
    self.distanceSlider.value = (float)self.workout.distanceInMiles;
    self.timeSlider.value = (float)self.workout.timeInMinutes;
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
    self.distanceLabel.text = [NSString stringWithFormat:@"%ld Miles", (long)self.workout.distanceInMiles];
}

- (void)setTimeLabelText {
    self.timeLabel.text = [NSString stringWithFormat:@"%d:%02d", self.workout.timeInMinutes/60, self.workout.timeInMinutes % 60];
}

- (IBAction)distanceSliderChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSInteger val = floor(slider.value);
    self.workout.distanceInMiles = val;
    [self setDistanceLabelText];
}

- (IBAction)timeSliderChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    self.workout.timeInMinutes = slider.value;
    [self setTimeLabelText];
}

- (IBAction)rideDateChanged:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.workout.date = datePicker.date;
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
    
    // hide pickers if not editing them
    [self.datePicker setHidden:!_isEditingRideDate];
    [self.workoutTypePicker setHidden:!_isEditingWorkoutType];
}

#define TEXT_VIEW_CELL      0
#define DATE_CELL           1
#define WORKOUT_TYPE_CELL   3


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
            [self.datePicker setHidden:!_isEditingRideDate];
            [UIView animateWithDuration:.4 animations:^{
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView reloadData];
            }];
        }
        if (indexPath.row == WORKOUT_TYPE_CELL) { // the cell above the workout type picker
            _isEditingWorkoutType = !_isEditingWorkoutType;
            _isEditingRideDate = NO;
            [self.workoutTypePicker setHidden:!_isEditingWorkoutType];
            [UIView animateWithDuration:.4 animations:^{
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
