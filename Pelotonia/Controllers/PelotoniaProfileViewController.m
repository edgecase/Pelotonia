//
//  PelotoniaProfileViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 2/22/14.
//
//

#import "NSDate+Helper.h"
#import "PelotoniaProfileViewController.h"
#import "PelotoniaWeb.h"
#import "CommentTableViewCell.h"
#import "TestFlight.h"
#import "NSNumber+Currency.h"

#define SECTION_1_HEADER_HEIGHT 50.0

@interface PelotoniaProfileViewController () {
    AAPullToRefresh *_tv;
}

@end

@implementation PelotoniaProfileViewController

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
    
    // get the pull to refresh working
    __weak PelotoniaProfileViewController *weakSelf = self;
    _tv = [self.tableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v) {
        [weakSelf refresh];
        [weakSelf reloadComments];
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.5f];
    }];
    _tv.imageIcon = [UIImage imageNamed:@"PelotoniaBadge"];
    _tv.borderColor = [UIColor whiteColor];
    
    // set up socialize
    self.entity = [SZEntity entityWithKey:@"http://www.pelotonia.org" name:@"Pelotonia"];
    [SZEntityUtils addEntity:self.entity success:^(id<SZEntity> serverEntity) {
        NSLog(@"Successfully updated entity meta for Pelotonia");
    } failure:^(NSError *error) {
        NSLog(@"Failure: %@", [error localizedDescription]);
    }];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Implementation
- (void) refresh {
    // get the updated amount of $$ raised
    [PelotoniaWeb getPelotoniaStatsOnComplete:^(NSString *amtRaised, NSString *numRiders) {
        NSLog(@"got stats back. amtRaised $%@.  Riders: %@", amtRaised, numRiders);
        self.numberRidersLabel.text = numRiders;
        self.amountRaisedLabel.text = amtRaised;
        NSLog(@"progress is %@%%", amtRaised);
        NSNumber *amtRaisedNumber = [NSNumber asString:amtRaised];
        self.amountRaisedProgressView.progress = ([amtRaisedNumber floatValue]/15000000.0);
    } onFailure:^(NSString *errorMessage) {
        NSLog(@"failed");
    }];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    else {
        return [self.pelotoniaActivities count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        // comments section
        CommentTableViewCell *_cell = [CommentTableViewCell cellForTableView:tableView];
        __weak CommentTableViewCell *cell = _cell;
        
        id<SZComment> activity = [self.pelotoniaActivities objectAtIndex:indexPath.row];
        if (activity)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.titleString = [NSString stringWithFormat:@"%@, %@", [[activity user] userName], [NSDate stringForDisplayFromDate:[activity date] prefixed:YES alwaysDisplayTime:NO]];
            cell.commentString = [activity text];
            
            [cell.imageView setImageWithURL:[NSURL URLWithString:[[activity user] smallImageUrl]]
                           placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
        }
        [cell layoutSubviews];
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        // create a view that says "Activity"
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, SECTION_1_HEADER_HEIGHT)];
        headerView.backgroundColor = PRIMARY_DARK_GRAY;
        
        UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width*0.60, SECTION_1_HEADER_HEIGHT)];
        sectionLabel.text = @"Pelotonia Wall";
        sectionLabel.backgroundColor = SECONDARY_GREEN;
        sectionLabel.textColor = [UIColor whiteColor];
        sectionLabel.font = [UIFont boldSystemFontOfSize:15];
        sectionLabel.textAlignment = NSTextAlignmentCenter;
        [headerView addSubview:sectionLabel];
        
        UIButton *writePostButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSInteger writeButtonW = (tableView.bounds.size.width * 0.40)-2;
        NSInteger writeButtonH = SECTION_1_HEADER_HEIGHT;
        [writePostButton setFrame:CGRectMake(sectionLabel.bounds.size.width + 2,
                                             0, writeButtonW, writeButtonH)];
        [writePostButton setBackgroundColor:PRIMARY_GREEN];
        writePostButton.tintColor = [UIColor whiteColor];
        [writePostButton setImage:[UIImage imageNamed:@"08-chat.png"] forState:UIControlStateNormal];
        [writePostButton addTarget:self action:@selector(manuallyShowCommentsList) forControlEvents:UIControlEventTouchUpInside];
        
        [headerView addSubview:writePostButton];
        return headerView;
    }
    else
    {
        return [super tableView:tableView viewForHeaderInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return SECTION_1_HEADER_HEIGHT;
    }
    else
    {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark -- implementation

- (void)manuallyShowCommentsList
{
    SZComposeCommentViewController *commentVC = [[SZComposeCommentViewController alloc] initWithEntity:self.entity];
    
    // Present however you want here
    [self presentViewController:commentVC animated:YES completion:nil];
}

- (void)reloadComments
{
    [SZCommentUtils getCommentsByEntity:self.entity success:^(NSArray *comments) {
        self.pelotoniaActivities = comments;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"Failed to fetch comments: %@", [error localizedDescription]);
    }];
}


- (IBAction)shareButtonPressed:(id)sender {
    
    NSString *descriptionText = @"Pelotonia is a grassroots bike tour with one goal: to end cancer. Donations can be made in support of riders and will fund essential research at The James Cancer Hospital and Solove Research Institute. See the purpose, check the progress, make a difference.";
    
    SZShareDialogViewController *shareDialog = [[SZShareDialogViewController alloc] initWithEntity:self.entity];
    shareDialog.title = @"Share Pelotonia";
    
    SZShareOptions *options = [SZShareUtils userShareOptions];
    
    options.willAttemptPostingToSocialNetworkBlock = ^(SZSocialNetwork network, SZSocialNetworkPostData *postData) {
        if (network == SZSocialNetworkTwitter) {
            SZShareOptions *twoptions = (SZShareOptions *)postData.options;
            NSString *entityURL = [[postData.propagationInfo objectForKey:@"twitter"] objectForKey:@"entity_url"];
            NSString *customStatus = [NSString stringWithFormat:@"%@ %@", twoptions.text, entityURL];
            
            [postData.params setObject:customStatus forKey:@"status"];
            
        } else if (network == SZSocialNetworkFacebook) {
            SZShareOptions *fboptions = (SZShareOptions *)postData.options;
            NSString *entityURL = [[postData.propagationInfo objectForKey:@"facebook"] objectForKey:@"entity_url"];
            NSString *displayName = [postData.entity displayName];
            NSString *customMessage = [NSString stringWithFormat:@"%@", fboptions.text];
            
            [postData.params setObject:customMessage forKey:@"caption"];
            [postData.params setObject:entityURL forKey:@"link"];
            [postData.params setObject:customMessage forKey:@"message"];
            [postData.params setObject:displayName forKey:@"name"];
            [postData.params setObject:descriptionText forKey:@"description"];
        }
        
        NSLog(@"Posting to %d", network);
    };
    
    options.didSucceedPostingToSocialNetworkBlock = ^(SZSocialNetwork network, id result) {
        NSLog(@"Posted %@ to %d", result, network);
    };
    
    options.didFailPostingToSocialNetworkBlock = ^(SZSocialNetwork network, NSError *error) {
        NSLog(@"Failed posting to %d", network);
    };
    
    shareDialog.shareOptions = options;
    
    shareDialog.completionBlock = ^(NSArray *shares) {
        // Dismiss however you want here
        [TestFlight passCheckpoint:@"SharePelotoniaProfile"];
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    shareDialog.cancellationBlock = ^() {
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self presentViewController:shareDialog animated:YES completion:nil];
}
@end
