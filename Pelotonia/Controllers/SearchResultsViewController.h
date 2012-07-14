//
//  SearchResultsViewController.h
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RiderDataController.h"

@interface SearchResultsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableSet *_ridersSelected;
    RiderDataController *_dataController;
}

@property (strong, nonatomic) RiderDataController *dataController;
@property (strong, nonatomic) IBOutlet UITableView *searchResultsTable;
@property (nonatomic, strong) NSArray *riders;
@end
