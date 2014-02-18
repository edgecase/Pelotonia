//
//  WorkoutListTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 2/15/14.
//
//

#import "WorkoutListTableViewController.h"
#import "Workout.h"
#import "NSDate+Helper.h"

@interface WorkoutListTableViewController () {
    NSMutableArray *_workouts;
}

@end

@implementation WorkoutListTableViewController

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
    _workouts = [[AppDelegate sharedDataController] workouts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1 + [_workouts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"totalDistanceCell"];
        NSInteger distance = 0;
        for (Workout *w in _workouts) {
            distance += w.distanceInMiles;
        }
        _cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Miles", distance];
        _cell.textLabel.text = @"Total";
        [_cell.imageView setImage:[UIImage imageNamed:@"13-bicycle"]];
        return _cell;
    }
    else
    {
        // create a workout record cell & return that
        Workout *w = [_workouts objectAtIndex:indexPath.row-1];
        UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"workoutCell"];
        _cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Miles", w.distanceInMiles];
        _cell.textLabel.text = [w.date stringWithFormat:@"MM/dd/yyyy"];
        if ((w.type == ID_INDOOR) || (w.type == ID_CYCLING)) {
            [_cell.imageView setImage:[UIImage imageNamed:@"13-bicycle"]];
        }
        else {
            [_cell.imageView setImage:[UIImage imageNamed:@"63-runner"]];
        }
        
        return _cell;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return (indexPath.row != 0);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Delete the row from the data source
            [_workouts removeObjectAtIndex:indexPath.row-1];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView reloadData];
        }
        else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -- NewWorkoutViewControllerDelegate methods
- (void)userDidCancelNewWorkout:(NewWorkoutTableViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidEnterNewWorkout:(NewWorkoutTableViewController *)vc workout:(Workout *)workout
{
    [_workouts addObject:workout];
    NSInteger i = [_workouts indexOfObject:workout];
    [vc dismissViewControllerAnimated:YES completion:nil];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(i + 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SegueToNewWorkout"]) {
        // open new workout dialog
        NewWorkoutTableViewController *newWorkoutVC = (NewWorkoutTableViewController *)[[segue.destinationViewController viewControllers] objectAtIndex:0];
        newWorkoutVC.delegate = self;
        newWorkoutVC.workout = [Workout defaultWorkout];
    }

    if ([[segue identifier] isEqualToString:@"SegueToEditWorkout"]) {
        // open new workout dialog
        NewWorkoutTableViewController *newWorkoutVC = (NewWorkoutTableViewController *)[[segue.destinationViewController viewControllers] objectAtIndex:0];
        newWorkoutVC.delegate = self;
        NSIndexPath *i = [self.tableView indexPathForSelectedRow];
        newWorkoutVC.workout = [_workouts objectAtIndex:(i.row - 1)];
    }
}



@end
