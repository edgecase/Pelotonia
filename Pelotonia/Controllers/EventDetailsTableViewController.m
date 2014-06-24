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
#import <AFNetworking/AFNetworking.h>
#import "PelotoniaWeb.h"

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
    self.titleLabel.font = PELOTONIA_FONT_BOLD(21);
    self.dateTime.font = PELOTONIA_SECONDARY_FONT(18);
    self.dateTime.text = [NSString stringWithFormat:@"%@ -> %@ to %@",
                          [self.event.startDateTime stringWithFormat:@"MMM dd, yyyy "],
                          [self.event.startDateTime stringWithFormat:@"h:mm a"],
                          [self.event.endDateTime stringWithFormat:@"h:mm a"]];
    self.dateTime.textColor = [UIColor whiteColor];
    self.venuTextView.text = self.event.address;
    self.venuTextView.font = PELOTONIA_SECONDARY_FONT(18);
    self.descriptionCell.textLabel.font = PELOTONIA_SECONDARY_FONT(15);
    
    if (self.event.eventDesc == nil) {
        [PelotoniaWeb getEventDescription:self.event onComplete:^(Event *e) {
            NSLog(@"got event description: %@", e.eventDesc);
            self.descriptionCell.textLabel.text = self.event.eventDesc;
            [self.tableView reloadData];
        } onFailure:^(NSString *errorText) {
            NSLog(@"issues getting event description :%@", errorText);
            self.descriptionCell.textLabel.text = @"Unable to load event description";
        }];
    }
    else {
        self.descriptionCell.textLabel.text = self.event.eventDesc;
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3 && self.event.eventDesc) { // event details path
        UIFont *font = PELOTONIA_SECONDARY_FONT(15);
        CGSize initialSize = CGSizeMake(self.tableView.bounds.size.width, CGFLOAT_MAX);
        
        NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:self.event.eventDesc
                                        attributes:@{NSFontAttributeName:font}];
        
        CGRect rect = [attributedText boundingRectWithSize:initialSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   context:nil];
        return ceilf(rect.size.height);
    }
    else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
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
