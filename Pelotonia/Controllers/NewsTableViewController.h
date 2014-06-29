//
//  NewsTableViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 6/29/14.
//
//

#import <UIKit/UIKit.h>

@interface NewsTableViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
