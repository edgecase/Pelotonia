//
//  ProfileTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 9/5/12.
//
//

#import "ProfileTableViewController.h"

@interface ProfileTableViewController ()

@end

@implementation ProfileTableViewController
@synthesize pledgeAmountTextField;
@synthesize donorEmailTextField;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setPledgeAmountTextField:nil];
    [self setDonorEmailTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self.pledgeAmountTextField becomeFirstResponder];
        }
        else if (indexPath.row == 1)
        {
            [self.donorEmailTextField becomeFirstResponder];
        }
    }
}

@end
