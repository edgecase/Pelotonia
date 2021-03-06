//
//  RidersViewController.h
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

@import UIKit;
#import "PelotoniaWeb.h"
#import "FindRiderViewController.h"
#import "Rider.h"
#import <SDWebImage/UIImageView+WebCache.h>

@class RiderDataController;

@interface RidersViewController : UITableViewController <UISearchBarDelegate, UISearchResultsUpdating, FindRiderViewControllerDelegate> {
    NSMutableArray *_riderSearchResults;
}

@property (strong, nonatomic) NSMutableArray *riderSearchResults;
@property (weak, nonatomic) IBOutlet UITableView *riderTableView;
@property (strong, nonatomic) UISearchController *searchController;


@end
