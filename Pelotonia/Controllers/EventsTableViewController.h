//
//  EventsTableViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 6/18/14.
//
//

#import <UIKit/UIKit.h>

@interface EventsTableViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
