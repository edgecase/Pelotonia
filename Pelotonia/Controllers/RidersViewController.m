//
//  RidersViewController.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "AppDelegate.h"
#import "RidersViewController.h"
#import "RiderDataController.h"
#import "ProfileViewController.h"
#import "SearchViewController.h"
#import "Pelotonia-Colors.h"
#import "PelotoniaWeb.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"


@interface RidersViewController ()
@property (nonatomic, strong) NSMutableDictionary *imagesCache;

- (void)loadImagesForOnScreenRows;
- (void)loadImageAtIndexPath:(NSIndexPath *)indexPath;


@end


@implementation RidersViewController

@synthesize dataController = _dataController;
@synthesize riderTableView = _riderTableView;
@synthesize imagesCache = _imagesCache;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.imagesCache = [NSMutableDictionary dictionary];

    // set the colors appropriately
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:84.0/255.0 green:94.0/255.0 blue:101.0/255.0 alpha:1.0];
    
    // set the text in the navbar to use the Baksheesh font
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    titleLabel.textColor = PRIMARY_GREEN;
    titleLabel.font = PELOTONIA_FONT(22);
    titleLabel.text = [NSString stringWithFormat:@"%@", @"PELOTONIA"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter; 
    [titleLabel setShadowColor:[UIColor darkGrayColor]];
    [titleLabel setShadowOffset:CGSizeMake(0, -0.5)];
    
    self.navigationItem.titleView = titleLabel;
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"one-goal-wallpaper.jpg"]];
    self.tableView.opaque = NO;
}

- (void)viewDidUnload
{
    self.riderTableView = nil;
    [self setRiderTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (RiderDataController *)dataController {
    if (_dataController == nil) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _dataController = appDelegate.riderDataController;
    }
    return _dataController;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self performSelector:NSSelectorFromString(segue.identifier) withObject:segue.destinationViewController];
}

- (void)prepareProfile:(ProfileViewController *)profileViewController
{
    Rider *rider = [self.dataController objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    profileViewController.rider = rider;
    [PelotoniaWeb profileForRider:rider onComplete:^(Rider *updatedRider) {
        profileViewController.rider = updatedRider;
    } onFailure:nil];
}

- (void)prepareSearch:(SearchViewController *)searchViewController
{
    
}


#pragma mark - Image handling
- (void)loadImagesForOnScreenRows
{
    NSArray *visiblePaths = [self.riderTableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths) {
        [self loadImageAtIndexPath:indexPath];
    }
}

- (void)loadImageAtIndexPath:(NSIndexPath *)indexPath
{
    Rider *rider = [self.dataController objectAtIndex:indexPath.row];
    
    if ([[self.imagesCache allKeys] containsObject:rider.riderPhotoThumbUrl]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableViewCell *cell = [self.riderTableView cellForRowAtIndexPath:indexPath];
            UIImage *riderPhotoThumb = [self.imagesCache valueForKey:rider.riderPhotoThumbUrl];
            cell.imageView.image = riderPhotoThumb;
        });
    } else {
        __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:rider.riderPhotoThumbUrl]];
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UITableViewCell *cell = [self.riderTableView cellForRowAtIndexPath:indexPath];
                UIImage *riderPhotoThumb = [UIImage imageWithData:[request responseData]];
                cell.imageView.image = riderPhotoThumb;
                [self.imagesCache setValue:riderPhotoThumb forKey:rider.riderPhotoThumbUrl];
            });
        }];
        [request startAsynchronous];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataController count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"riderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Rider *rider = [self.dataController objectAtIndex:indexPath.row];
    cell.textLabel.text = rider.name;
    cell.textLabel.font = PELOTONIA_FONT(17);
    cell.detailTextLabel.text = rider.amountRaised;
    cell.detailTextLabel.font = PELOTONIA_FONT(17);
    cell.imageView.image = [UIImage imageNamed:@"profile_default_thumb.jpg"];
    [self loadImageAtIndexPath:indexPath];

    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the dataController
        [self.dataController removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
//{
//
//}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
