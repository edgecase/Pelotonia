//
//  EventDetailsTableViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 6/19/14.
//
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@class Event;

@interface EventDetailsTableViewController : UITableViewController<TTTAttributedLabelDelegate, EKEventEditViewDelegate> {
}

@property (strong, nonatomic) Event *event;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *dateTime;

@property (weak, nonatomic) IBOutlet UITableViewCell *titleTableViewCell;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *venueLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *descriptionCell;

- (IBAction)actionButtonPressed:(id)sender;
@end
