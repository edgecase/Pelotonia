//
//  FindRiderViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 2/13/14.
//
//

#import <UIKit/UIKit.h>
#import "Rider.h"

@protocol FindRiderViewControllerDelegate;

@interface FindRiderViewController : UITableViewController <UISearchBarDelegate> {
    NSArray *_searchResults;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) id<FindRiderViewControllerDelegate> delegate;

- (IBAction)cancelPressed:(id)sender;

@end

@protocol FindRiderViewControllerDelegate <NSObject>

- (void)findRiderViewControllerDidSelectRider:(FindRiderViewController *)controller rider:(Rider *)rider;
- (void)findRiderViewControllerDidCancel:(FindRiderViewController *)controller;

@end

