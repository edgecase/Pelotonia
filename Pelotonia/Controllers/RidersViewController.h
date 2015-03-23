//
//  RidersViewController.h
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PelotoniaWeb.h"
#import "FindRiderViewController.h"
#import "Rider.h"
#import <SDWebImage/UIImageView+WebCache.h>

@class RiderDataController;

@interface RidersViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, FindRiderViewControllerDelegate> {
    NSMutableArray *_riderSearchResults;
}

@property (strong, nonatomic) NSMutableArray *riderSearchResults;
@property (weak, nonatomic) IBOutlet UITableView *riderTableView;


@end
