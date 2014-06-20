//
//  EventDetailsTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 6/19/14.
//
//

#import "EventDetailsTableViewController.h"
#import "Event.h"
#import "EventCategory.h"
#import "NSDate+Helper.h"

@interface EventDetailsTableViewController ()

@end

@implementation EventDetailsTableViewController

@synthesize event = _event;

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
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView
{
    self.navigationItem.title = self.event.title;
    self.titleLabel.text = self.event.title;
    self.titleLabel.font = PELOTONIA_SECONDARY_FONT_BOLD(21);
    self.dateTime.font = PELOTONIA_SECONDARY_FONT(18);
    self.dateTime.text = [NSString stringWithFormat:@"%@ to %@", [self.event.startDateTime stringWithFormat:@"MMM dd, yyyy h:mm a"], [self.event.endDateTime stringWithFormat:@"h:mm a"]];
    self.dateTime.textColor = PRIMARY_GREEN;
    self.venuTextView.text = self.event.address;
    self.venuTextView.font = PELOTONIA_SECONDARY_FONT(18);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
