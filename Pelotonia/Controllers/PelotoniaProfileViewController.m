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
#import "NSDictionary+JSONConversion.h"


#define SECTION_1_HEADER_HEIGHT 50.0
#define PELOTONIA_TARGET_AMOUNT 15000000.0

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
    _tv = [self.tableView addPullToRefreshPosition:AAPullToRefreshPositionTop
                                     ActionHandler:^(AAPullToRefresh *v) {
                                         [weakSelf refreshPelotonia];
                                         [v performSelector:@selector(stopIndicatorAnimation)
                                                 withObject:nil afterDelay:1.5f];
                                     }];
    _tv.imageIcon = [UIImage imageNamed:@"PelotoniaBadge"];
    _tv.borderColor = [UIColor whiteColor];
    
    self.entity = [SZEntity entityWithKey:@"http://www.pelotonia.org" name:@"Pelotonia"];
    // set up socialize
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            pelotoniaStory, @"szsd_description",
                            @"http://pelotonia.org/wp-content/themes/pelotonia-2012/images/logo-pelotonia.png", @"szsd_thumb",
                            @"PELOTONIA", @"riderID",
                            nil];
    
    NSString *jsonString = [params toJSONString];
    self.entity.meta = jsonString;
    [SZEntityUtils addEntity:self.entity success:^(id<SZEntity> serverEntity) {
        NSLog(@"Successfully updated entity meta for Pelotonia");
    } failure:^(NSError *error) {
        NSLog(@"Failure: %@", [error localizedDescription]);
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [_tv manuallyTriggered];
}


#pragma mark - Implementation
- (void) refreshPelotonia {
    // get the updated amount of $$ raised
    [PelotoniaWeb getPelotoniaStatsOnComplete:^(NSString *amtRaised, NSString *numRiders) {
        self.numberRidersLabel.text = numRiders;
        self.amountRaisedLabel.text = amtRaised;
        NSNumber *amtRaisedNumber = [NSNumber asString:amtRaised];
        self.amountRaisedProgressView.progress = ([amtRaisedNumber floatValue]/PELOTONIA_TARGET_AMOUNT);
        [self reloadComments];
    } onFailure:^(NSString *errorMessage) {
        NSLog(@"failed");
    }];
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        // in the comment section - get the comment & view it
        id<SocializeActivity> activity = [self.pelotoniaActivities objectAtIndex:indexPath.row];
        SocializeActivityDetailsViewController *avc = [[SocializeActivityDetailsViewController alloc] initWithActivity:activity];
        [self.navigationController pushViewController:avc animated:YES];
    }
}

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
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

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else {
        id<SZComment> riderComment = [self.pelotoniaActivities objectAtIndex:indexPath.row];
        NSString *comment = [riderComment text];
        NSString *title = @"title";
        return [CommentTableViewCell getTotalHeightForCellWithCommentText:comment andTitle:title];
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if dynamic section make all rows the same indentation level as row 0
    if (indexPath.section == 1) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
    } else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}



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
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            NSString *displayName = @"Pelotonia";
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
