//
//  ProfileTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 9/5/12.
//
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <AAPullToRefresh/AAPullToRefresh.h>
#import <Social/Social.h>
#import <Socialize/Socialize.h>
#import "ProfileTableViewController.h"
#import "AppDelegate.h"
#import "RiderDataController.h"
#import "Pelotonia-Colors.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "SendPledgeModalViewController.h"
#import "ProfileDetailsTableViewController.h"
#import "NSDate+Helper.h"
#import "CommentTableViewCell.h"
#import "NSDictionary+JSONConversion.h"
#import "DonorsTableViewController.h"
#import "TestFlight.h"

#define SECTION_1_HEADER_HEIGHT   60.0


@interface ProfileTableViewController () {
    AAPullToRefresh *_tv;
}

@end

@implementation ProfileTableViewController

@synthesize donationProgress;
@synthesize nameAndRouteCell;
@synthesize riderComments;
@synthesize entity;

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
    __weak ProfileTableViewController *weakSelf = self;
    _tv = [self.tableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v) {
        [weakSelf refreshRider:v];
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:2.0f];
    }];
    _tv.imageIcon = [UIImage imageNamed:@"PelotoniaBadge"];
    _tv.borderColor = [UIColor whiteColor];
    
    // set up socialize
    self.entity = [SZEntity entityWithKey:self.rider.profileUrl name:self.rider.name];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.rider.story, @"szsd_description",
                            self.rider.riderPhotoThumbUrl, @"szsd_thumb",
                            self.rider.riderId, @"riderID",
                            nil];
    
    NSString *jsonString = [params toJSONString];
    entity.meta = jsonString;
    [SZEntityUtils addEntity:entity success:^(id<SZEntity> serverEntity) {
        NSLog(@"Successfully updated entity meta");
        NSLog(@"it has %d likes, %d comments, %d shares, %d views", [serverEntity likes], [serverEntity comments], [serverEntity shares], [serverEntity views]);

    } failure:^(NSError *error) {
        NSLog(@"Failure: %@", [error localizedDescription]);
    }];
}

- (void)viewDidUnload
{
    [self setDonationProgress:nil];
    [self setNameAndRouteCell:nil];
    [self setRaisedAmountLabel:nil];
    [self setRaisedLabel:nil];
    [self setStarFollowButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [SZViewUtils viewEntity:self.entity success:^(id<SocializeView> view) {
        NSLog(@"Entity recorded another view ");
    } failure:^(NSError *error) {
        NSLog(@"Unable to view entity %@", [self.entity displayName]);
    }];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self refreshRider:_tv];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//implementation
#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([self respondsToSelector:NSSelectorFromString(segue.identifier)]) {
        [self performSelector:NSSelectorFromString(segue.identifier) withObject:segue.destinationViewController];
    }
    else {
        NSLog(@"%@ is not recognized segue", segue.identifier);
    }
}

- (void)segueToDonorList:(DonorsTableViewController *)donorViewController {
    [TestFlight passCheckpoint:@"ShowDonorList"];
    donorViewController.donorList = self.rider.donors;
}

- (void)showPledge:(SendPledgeModalViewController *)pledgeViewController
{
    [TestFlight passCheckpoint:@"ShowPledgeMailDialog"];
    pledgeViewController.rider = self.rider;
    pledgeViewController.delegate = self;
}

- (void)showDetails:(ProfileDetailsTableViewController *)profileDetailsViewController
{
    [TestFlight passCheckpoint:@"ShowRiderStory"];
    profileDetailsViewController.rider = self.rider;
}

- (NSString *)getTitleFromComment:(id<SZComment>) comment
{
    return [NSString stringWithFormat:@"%@, %@", [[comment user] userName], [NSDate stringForDisplayFromDate:[comment date] prefixed:YES alwaysDisplayTime:NO]];
}

- (NSString *)getTextFromComment:(id<SZComment>) comment
{
    return [comment text];
}

- (NSURL *)getImageURLFromComment:(id<SZComment>) comment
{
    NSString *strURL = [[comment user] smallImageUrl];
    return [NSURL URLWithString:strURL];
}


#pragma mark - Table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        // comments section
        CommentTableViewCell *_cell = [CommentTableViewCell cellForTableView:tableView];
        __weak CommentTableViewCell *cell = _cell;
        
        id<SZComment> comment = [self.riderComments objectAtIndex:indexPath.row];
        if (comment)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.titleString = [self getTitleFromComment:comment];
            cell.commentString = [self getTextFromComment:comment];
            
            [cell.imageView setImageWithURL:[self getImageURLFromComment:comment]
                           placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
        }
        [cell layoutSubviews];
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        NSInteger num = [self.riderComments count];
        NSLog(@"Section 1 has %ld cells", (long)num);
        return num;
    }
    else
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 3)
        {
            // show the "share on..." dialog
            [self shareProfile:nil];
        }
    }
    if (indexPath.section == 1) {
        // open up a commentdetailview view
        id<SocializeActivity> comment = [riderComments objectAtIndex:indexPath.row];
        SocializeActivityDetailsViewController *avc = [[SocializeActivityDetailsViewController alloc] initWithActivity:comment];
        [self.navigationController pushViewController:avc animated:YES];
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [super numberOfSectionsInTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat sz = 40;
    
    if (indexPath.section == 0 && indexPath.row == 2)
    {
        // progress row -- hide if we're a volunteer rider
        if ([self.rider.riderType isEqualToString:@"Virtual Rider"] ||
            [self.rider.riderType isEqualToString:@"Volunteer"])
        {
            sz = 0;
        }
    }
    else if (indexPath.section == 1)
    {
        id<SZComment> riderComment = [self.riderComments objectAtIndex:indexPath.row];
        NSString *comment = [self getTextFromComment:riderComment];
        NSString *title = [self getTitleFromComment:riderComment];
        sz = [CommentTableViewCell getTotalHeightForCellWithCommentText:comment andTitle:title];
    }
    else
    {
        sz = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    return sz;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    // if dynamic section make all rows the same indentation level as row 0
    if (section == 1) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    } else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        // create a view that says "Activity"
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, SECTION_1_HEADER_HEIGHT)];
        headerView.backgroundColor = PRIMARY_DARK_GRAY;
        
        UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width*0.60, SECTION_1_HEADER_HEIGHT)];
        sectionLabel.text = @"Rider Wall";
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


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return [NSString stringWithFormat:@"Activity"];
    }
    else {
        return [super tableView:tableView titleForHeaderInSection:section];
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


#pragma mark -- view configuration
- (void)manuallyShowCommentsList
{
    SZComposeCommentViewController *commentVC = [[SZComposeCommentViewController alloc] initWithEntity:self.entity];
    
    // Present however you want here
    [self presentViewController:commentVC animated:YES completion:nil];
}

- (void)reloadComments
{
    [SZCommentUtils getCommentsByEntity:self.entity success:^(NSArray *comments) {
        self.riderComments = comments;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    } failure:^(NSError *error) {
        NSLog(@"Failed to fetch comments: %@", [error localizedDescription]);
    }];
}


- (void)refreshRider:(AAPullToRefresh *)v
{
    [self.rider refreshFromWebOnComplete:^(Rider *updatedRider) {
        self.rider = updatedRider;
        [self configureView];

        // update the comments in section 2 of our table
        [self reloadComments];
    }
    onFailure:^(NSString *error) {
        NSLog(@"Unable to get profile for rider. Error: %@", error);
        [self configureView];
    }];
}


- (BOOL)following
{
    // return true if current rider is in the dataController
    return [[AppDelegate sharedDataController] containsRider:self.rider];
}

- (void)configureView
{
    // configures the static cells to have the correct data
    
    // set the name & ID appropriately
    self.nameAndRouteCell.textLabel.text = self.rider.name;
    if ([self.rider.riderType isEqualToString:@"Virtual Rider"] ||
        [self.rider.riderType isEqualToString:@"Volunteer"] ||
        [self.rider.riderType isEqualToString:@"Super Peloton"] ||
        [self.rider.riderType isEqualToString:@"Peloton"]) {
        self.nameAndRouteCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.rider.riderType];
        self.raisedAmountLabel.text = [NSString stringWithFormat:@"%@", self.rider.totalRaised];
        self.donationProgress.hidden = YES;
    }
    else
    {
        // Riders and Pelotons are the only ones who get progress
        self.nameAndRouteCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.rider.route];
        self.raisedAmountLabel.text = [NSString stringWithFormat:@"%@ of %@", self.rider.totalRaised, self.rider.totalCommit];
        self.donationProgress.progress = [self.rider.pctRaised floatValue]/100.0;
    }
    
    self.nameAndRouteCell.textLabel.font = PELOTONIA_FONT(21);
    self.nameAndRouteCell.detailTextLabel.font = PELOTONIA_SECONDARY_FONT(17);
    
    if (self.following)
    {
        [self.starFollowButton setTitle:[NSString stringWithFormat:@"Following"] forState:UIControlStateNormal];
        [self.starFollowButton setImage:[UIImage imageNamed:@"28-green-star.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.starFollowButton setTitle:[NSString stringWithFormat:@"Follow"] forState:UIControlStateNormal];
        [self.starFollowButton setImage:[UIImage imageNamed:@"28-star.png"] forState:UIControlStateNormal];
    }
    
    // this masks the photo to the tableviewcell
    self.nameAndRouteCell.imageView.layer.masksToBounds = YES;
    self.nameAndRouteCell.imageView.layer.cornerRadius = 5.0;

    // now we resize the photo and the cell so that the photo looks right
    if (self.rider.riderPhotoUrl) {
        self.nameAndRouteCell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.nameAndRouteCell.imageView setImageWithURL:[NSURL URLWithString:self.rider.riderPhotoUrl]
                                        placeholderImage:[UIImage imageNamed:@"speedy_arrow"]
                                                 options:SDWebImageRefreshCached
                                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                                   if (error) {
                                                       NSLog(@"ProfileTableViewController::configureView error: %@", [error localizedDescription]);
                                                   }
                                                   else {
                                                       self.nameAndRouteCell.imageView.image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(120, 90) interpolationQuality:kCGInterpolationDefault];
                                                       [self.nameAndRouteCell layoutSubviews];
                                                   }
                                               } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
}

- (void)postAlert:(NSString *)msg {
    // alert that they need to authorize first
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you for your Pledge"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)sendPledgeMailToEmail:(NSString *)email withAmount:(NSString *)amount
{
    if (email && amount) {
        
        NSLog(@"Email sent to: %@", email);
        NSLog(@"You have decided to sponsor %@ the amount %@", self.rider.name, amount);
        
        MFMailComposeViewController *mailComposer;
        mailComposer  = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setToRecipients:[NSArray arrayWithObject:email]];
        [mailComposer setModalPresentationStyle:UIModalPresentationFormSheet];
        [mailComposer setSubject:@"Thank you for your support of Pelotonia"];
        
        NSString *msg = [NSString stringWithFormat:@"<HTML><BODY>Thank you!  Please visit my <a href=%@>profile</a> to complete your pledge of $%@ to %@'s Pelotonia ride.<br/><br/>Pelotonia is a grassroots bike tour with one goal: to end cancer. More than 10,000 supporters are expected to be a part of Pelotonia 12 on August 10-12, 2012. The ride will span two days and will cover as many as 180 miles. In its first three years, Pelotonia has attracted over 8,300 riders from 38 states, over 2,800 volunteers, hundreds of thousands of donors and raised $25.4 million for cancer research. In 2011 alone, a record $13.1 million was raised. Because operational expenses are covered by Pelotonia funding partners, 100%% of every dollar raised is donated directly to life-saving cancer research at The Ohio State University Comprehensive Cancer Center-James Cancer Hospital and Solove Research Institute. I am writing to ask you to help me raise funds for this incredible event. Large or small, every donation makes a difference.<br/><br/>We all know someone who has been affected by cancer. One of every two American men and one of every three American women will be diagnosed with cancer at some point in their lives. By supporting Pelotonia and me, you will help improve lives through innovative research with the ultimate goal of winning the war against cancer. I would love to have your support, as this is truly a unique opportunity to be a part of something special.<br/><br/>When you follow the link below, you will find my personal rider profile and a simple and secure way to make any size donation you wish.<br/><br/>Think of this as a donation not to me, or Pelotonia, but directly to The OSUCCC-James to fund cancer research. Please consider supporting my effort and this great cause. My rider profile can be found at the following link: <a href='%@'>%@</a><br/><br/>Thanks for the support!<br/><br/>Sincerely,<br/>%@</BODY></HTML>", self.rider.donateUrl, amount, self.rider.name, self.rider.donateUrl, self.rider.donateUrl, self.rider.name];
        
        NSLog(@"msgBody: %@", msg);
        [mailComposer setMessageBody:msg isHTML:YES];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }

    
}

#pragma mark - MFMailComposeViewDelegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [TestFlight passCheckpoint:@"SentPledgeMail"];
    if(error) {
        NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma Socialize stuff

- (IBAction)followRider:(id)sender
{
    // add the current rider to the main list of riders
    RiderDataController *dataController = [AppDelegate sharedDataController];
    
    if (self.following) {
        [TestFlight passCheckpoint:@"UnfollowRider"];
        [dataController removeObject:self.rider];
    }
    else {
        [TestFlight passCheckpoint:@"FollowRider"];
        [dataController addObject:self.rider];
    }
    [self configureView];
}


- (IBAction)shareProfile:(id)sender
{
    
    NSString *descriptionText = @"Pelotonia is a grassroots bike tour with one goal: to end cancer. Donations can be made in support of riders and will fund essential research at The James Cancer Hospital and Solove Research Institute. See the purpose, check the progress, make a difference.";

    SZShareDialogViewController *shareDialog = [[SZShareDialogViewController alloc] initWithEntity:self.entity];
    shareDialog.title = [NSString stringWithFormat:@"Share %@", self.rider.name];
    
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
        [TestFlight passCheckpoint:@"ShareRiderProfile"];
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    shareDialog.cancellationBlock = ^() {
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self presentViewController:shareDialog animated:YES completion:nil];
    
}



#pragma mark -- PhotoUpdateDelegate
- (void)riderPhotoDidUpdate:(UIImage *)image
{
    [self configureView];
}

- (void)riderPhotoThumbDidUpdate:(UIImage *)image
{
    [self configureView];
}

#pragma mark -- SendPledgeViewControllerDelegate
- (void)sendPledgeModalViewControllerDidCancel:(SendPledgeModalViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendPledgeModalViewControllerDidFinish:(SendPledgeModalViewController *)controller
{

    NSString *email = controller.textViewName.text;
    NSString *amount = controller.textViewAmount.text;
    
    [controller dismissViewControllerAnimated:YES completion:^(void){
        [self sendPledgeMailToEmail:email withAmount:amount];
    }];
}

#pragma mark -- for when we're launched as a dialog
- (void)done
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)manuallyTriggered {
    [_tv manuallyTriggered];
}


@end
