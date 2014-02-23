//
//  PelotoniaProfileViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 2/22/14.
//
//

#import <UIKit/UIKit.h>
#import <Socialize/Socialize.h>
#import <AAPullToRefresh/AAPullToRefresh.h>
#import "ProfileTableViewController.h"

@interface PelotoniaProfileViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *amountRaisedLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberRidersLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *amountRaisedProgressView;

@property (strong, nonatomic) id<SZEntity> entity;
@property (strong, nonatomic) NSArray *pelotoniaActivities;

- (IBAction)shareButtonPressed:(id)sender;

@end
