//
//  NewsDetailTableViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 6/29/14.
//
//

#import <UIKit/UIKit.h>
#import "NewsItem.h"

@interface NewsDetailTableViewController : UITableViewController

@property (nonatomic, strong) NewsItem *item;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

- (IBAction)actionButtonPressed:(id)sender;


@end
