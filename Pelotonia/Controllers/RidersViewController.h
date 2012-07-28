//
//  RidersViewController.h
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshView.h"

@class RiderDataController;

@interface RidersViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, PullToRefreshViewDelegate> {
    RiderDataController *_dataController;
    NSMutableArray *_riderSearchResults;
    PullToRefreshView *_pull;
}

@property (strong, nonatomic) RiderDataController *dataController;
@property (strong, nonatomic) NSMutableArray *riderSearchResults;
@property (weak, nonatomic) IBOutlet UITableView *riderTableView;


@end
