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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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

- (void)configureView
{
    self.distanceLabel.text = [NSString stringWithFormat:@"%d Miles", self.workout.distanceInMiles];
    self.distanceSlider.value = (float)self.workout.distanceInMiles;
    self.descriptionTextView.text = self.workout.description;
    self.timeLabel.text = [NSString stringWithFormat:@"%d:%02d Hours", self.workout.timeInMinutes/60, self.workout.timeInMinutes % 60];
    self.timeSlider.value = (float)self.workout.timeInMinutes;
}

- (NSString *)cellIDForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cellIDs = @[@"DescriptionCellID", @"DateCellID", @"WorkoutTypeCellID", @"DistanceCellID", @"TimeCellID"];
    return [cellIDs objectAtIndex:indexPath.row];
}

#pragma mark -- UITableView stuff
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0) {
        [self.descriptionTextView resignFirstResponder];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *height;
    if (!height) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[self cellIDForIndexPath:indexPath]];
        height = @(cell.bounds.size.height);
    }
    return [height floatValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:[self cellIDForIndexPath:indexPath]];
    
    if (indexPath.row == 0) {
        // description cell
        self.descriptionTextView = (UITextView *)[_cell viewWithTag:100];
        self.descriptionTextView.delegate = self;
    }
    else if (indexPath.row == 1) {
        // date cell
        _cell.detailTextLabel.text = [self.workout.date stringWithFormat:@"MM/dd/yyyy"];
    }
    else if (indexPath.row == 2) {
        _cell.textLabel.text = self.workout.typeDescription;
    }
    else if (indexPath.row == 3) {
        // distance slider row
        self.distanceLabel = (UILabel *)[_cell viewWithTag:100];
        self.distanceSlider = (UISlider *)[_cell viewWithTag:101];
        [self.distanceSlider addTarget:self action:@selector(distanceSliderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    else if (indexPath.row == 4) {
        // time cell
        self.timeLabel = (UILabel *)[_cell viewWithTag:100];
        self.timeSlider = (UISlider *)[_cell viewWithTag:101];
        [self.timeSlider addTarget:self action:@selector(timeSliderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    [self configureView];
    
    return _cell;
    
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
