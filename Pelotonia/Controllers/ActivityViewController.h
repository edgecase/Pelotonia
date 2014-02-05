//
//  ActivityViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 4/26/13.
//
//

#import <UIKit/UIKit.h>
#import <Socialize/Socialize.h>
#import "UIImage+Alpha.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "RiderDataController.h"
#import "PullToRefreshView.h"


@interface ActivityViewController : UITableViewController<PullToRefreshViewDelegate> {
}

@property (strong, nonatomic) NSArray *recentActivity;
@property (strong, nonatomic) RiderDataController *dataController;


@end
