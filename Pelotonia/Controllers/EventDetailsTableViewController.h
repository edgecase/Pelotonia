//
//  EventDetailsTableViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 6/19/14.
//
//

#import <UIKit/UIKit.h>
@class Event;

@interface EventDetailsTableViewController : UITableViewController

@property (strong, nonatomic) Event *event;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTime;
@property (weak, nonatomic) IBOutlet UILabel *venue;
@property (weak, nonatomic) IBOutlet UITextView *venuTextView;

@end
