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


@interface ActivityViewController : UITableViewController {
}

@property (strong, nonatomic) NSArray *recentActivity;
@property (strong, nonatomic) RiderDataController *dataController;


@end
