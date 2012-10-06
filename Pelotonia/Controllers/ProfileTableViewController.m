//
//  ProfileTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 9/5/12.
//
//

#import "ProfileTableViewController.h"
#import "AppDelegate.h"
#import "RiderDataController.h"
#import "SHKActivityIndicator.h"
#import "Pelotonia-Colors.h"


@interface ProfileTableViewController ()

@end

@implementation ProfileTableViewController 
@synthesize pledgeAmountTextField;
@synthesize donorEmailTextField;
@synthesize donationProgress;
@synthesize storyTextView;
@synthesize followButton;
@synthesize nameAndRouteCell;
@synthesize raisedAmountCell;
@synthesize supportRiderButton;

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
    [pull setDelegate:self];
    [self.tableView addSubview:pull];
}

- (void)viewDidUnload
{
    [self setPledgeAmountTextField:nil];
    [self setDonorEmailTextField:nil];
    [self setDonationProgress:nil];
    [self setStoryTextView:nil];
    [self setFollowButton:nil];
    [self setNameAndRouteCell:nil];
    [self setRaisedAmountCell:nil];
    [self setSupportRiderButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self configureView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self.pledgeAmountTextField becomeFirstResponder];
        }
        else if (indexPath.row == 1)
        {
            [self.donorEmailTextField becomeFirstResponder];
        }
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
    label.textColor = PRIMARY_GREEN;
    label.font = PELOTONIA_FONT(21);
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = SECONDARY_GREEN;
    
    if (section == 1)
    {
        label.text = [NSString stringWithFormat:@"Support %@", self.rider.name];
    }
    else if (section == 2)
    {
        label.text = @"My Story";
    }
    [headerView addSubview:label];
    return headerView;
}

#pragma mark -- view configuration

- (void)refreshRider
{
    // start an asynchronous web request to update the rider information
    [PelotoniaWeb profileForRider:self.rider onComplete:^(Rider *updatedRider) {
        self.rider = updatedRider;
        [self configureView];
        [pull finishedLoading];
    } onFailure:^(NSString *error) {
        NSLog(@"Unable to get profile for rider. Error: %@", error);
        [[SHKActivityIndicator currentIndicator] displayCompleted:@"Error"];
        [pull finishedLoading];
    }];
}


- (BOOL)following
{
    // return true if current rider is in the dataController
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    RiderDataController *dataController = appDelegate.riderDataController;
    
    return [dataController containsRider:self.rider];
}

- (void)configureView
{
    // set the name & ID appropriately
    self.nameAndRouteCell.textLabel.text = self.rider.name;
    if ([self.rider.riderType isEqualToString:@"Virtual Rider"] ||
        [self.rider.riderType isEqualToString:@"Volunteer"] ||
        [self.rider.riderType isEqualToString:@"Peloton"]) {
        self.nameAndRouteCell.detailTextLabel.text = self.rider.riderType;
        self.raisedAmountCell.detailTextLabel.text = self.rider.totalRaised;
        self.donationProgress.hidden = YES;
    }
    else
    {
        // Riders and Pelotons are the only ones who get progress
        self.nameAndRouteCell.detailTextLabel.text = self.rider.route;
        self.raisedAmountCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ of %@", self.rider.totalRaised, self.rider.totalCommit];
        self.donationProgress.progress = [self.rider.pctRaised floatValue]/100.0;
    }
    NSLog(@"story = %@", self.rider.story);
    self.storyTextView.text = self.rider.story;
    
    self.nameAndRouteCell.textLabel.font = PELOTONIA_FONT(21);
    self.nameAndRouteCell.detailTextLabel.font = PELOTONIA_SECONDARY_FONT(17);
    self.raisedAmountCell.textLabel.font = PELOTONIA_FONT(21);
    self.raisedAmountCell.detailTextLabel.font = PELOTONIA_SECONDARY_FONT(17);
    self.storyTextView.font = PELOTONIA_SECONDARY_FONT(17);
    
    if (self.following) {
        [self.followButton setTitle:@"Unfollow"];
    }
    else {
        [self.followButton setTitle:@"Follow"];
    }
    
    
    [self.rider getRiderPhotoOnComplete:^(UIImage *image) {
        self.nameAndRouteCell.imageView.image = image;
    }];

}

- (BOOL)validateForm
{
    return (([self.donorEmailTextField.text length] > 0)
            && ([self.pledgeAmountTextField.text length] > 0));
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

- (void)sendPledgeMail
{
    NSLog(@"Email sent to: %@", self.donorEmailTextField.text);
    NSLog(@"You have decided to sponsor %@ the amount %@", self.rider.name, self.donorEmailTextField.text);
    
    MFMailComposeViewController *mailComposer;
    mailComposer  = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setToRecipients:[NSArray arrayWithObject:self.donorEmailTextField.text]];
    [mailComposer setModalPresentationStyle:UIModalPresentationFormSheet];
    [mailComposer setSubject:@"Thank you for your support of Pelotonia"];
    
    NSString *amountFormat;
    if ([self.pledgeAmountTextField.text length] > 0) {
        amountFormat = @"$%@";
    }
    else {
        amountFormat = @"%@";
    }
    NSString *amount = [NSString stringWithFormat:amountFormat, self.pledgeAmountTextField.text];
    
    NSString *msg = [NSString stringWithFormat:@"<HTML><BODY>Thank you for your <a href=%@>pledge</a> of %@ to my Pelotonia ride.<br/><br/>Pelotonia is a grassroots bike tour with one goal: to end cancer. More than 10,000 supporters are expected to be a part of Pelotonia 12 on August 10-12, 2012. The ride will span two days and will cover as many as 180 miles. In its first three years, Pelotonia has attracted over 8,300 riders from 38 states, over 2,800 volunteers, hundreds of thousands of donors and raised $25.4 million for cancer research. In 2011 alone, a record $13.1 million was raised. Because operational expenses are covered by Pelotonia funding partners, 100%% of every dollar raised is donated directly to life-saving cancer research at The Ohio State University Comprehensive Cancer Center-James Cancer Hospital and Solove Research Institute. I am writing to ask you to help me raise funds for this incredible event. Large or small, every donation makes a difference.<br/><br/>We all know someone who has been affected by cancer. One of every two American men and one of every three American women will be diagnosed with cancer at some point in their lives. By supporting Pelotonia and me, you will help improve lives through innovative research with the ultimate goal of winning the war against cancer. I would love to have your support, as this is truly a unique opportunity to be a part of something special.<br/><br/>When you follow the link below, you will find my personal rider profile and a simple and secure way to make any size donation you wish.<br/><br/>Think of this as a donation not to me, or Pelotonia, but directly to The OSUCCC-James to fund cancer research. Please consider supporting my effort and this great cause. My rider profile can be found at the following link: <a href='%@'>%@</a><br/><br/>Thanks for the support!<br/><br/>Sincerely,<br/>%@</BODY></HTML>", self.rider.donateUrl, amount, self.rider.donateUrl, self.rider.donateUrl, self.rider.name];
    
    NSLog(@"msgBody: %@", msg);
    [mailComposer setMessageBody:msg isHTML:YES];
    [self presentModalViewController:mailComposer animated:YES];
    
}



#pragma mark -- text field delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)tf
{
    [tf resignFirstResponder];
    if (tf == self.donorEmailTextField) {
        [self sendPledgeMail];
    }
    return YES;
}


#pragma mark - MFMailComposeViewDelegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    if(error) {
        NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    }
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)supportRider:(id)sender {
    if ([self validateForm]) {
        [self sendPledgeMail];
    }
}

- (IBAction)followRider:(id)sender {
    // add the current rider to the main list of riders
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    RiderDataController *dataController = appDelegate.riderDataController;
    
    if (!self.following) {
        [dataController addObject:self.rider];
    }
    else {
        [dataController removeObject:self.rider];
    }
    [self configureView];
}

#pragma mark -- PullToRefreshDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    [self refreshRider];
}



@end
