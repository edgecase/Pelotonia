//
//  RidersViewController.h
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RiderDataController;

@interface RidersViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
    RiderDataController *_dataController;
    NSMutableArray *_riderSearchResults;
}

@property (strong, nonatomic) RiderDataController *dataController;
@property (strong, nonatomic) NSMutableArray *riderSearchResults;
@property (weak, nonatomic) IBOutlet UITableView *riderTableView;


@end
