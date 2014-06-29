//
//  AboutTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 9/9/12.
//
//

#import "AboutTableViewController.h"
#import "PRPWebViewController.h"
#import "ECSlidingViewController.h"
#import "Pelotonia-Colors.h"
#import "PelotoniaWeb.h"
#import "TestFlight.h"
#import <Social/Social.h>

@interface AboutTableViewController ()

@end

@implementation AboutTableViewController
@synthesize versionLabel;
@synthesize doneButton;
@synthesize storyTextView;

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

    // Do any additional setup after loading the view.
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@.%@",
                              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    self.versionLabel.font = PELOTONIA_FONT(17);
    
    // set the colors appropriately
    self.navigationController.navigationBar.tintColor = PRIMARY_DARK_GRAY;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        self.navigationController.navigationBar.tintColor = PRIMARY_GREEN;
        self.navigationController.navigationBar.barTintColor = PRIMARY_DARK_GRAY;
        [self.navigationController.navigationBar setTranslucent:NO];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    self.tableView.backgroundColor = PRIMARY_DARK_GRAY;
    self.tableView.opaque = YES;
    
}

- (void)viewDidUnload
{
    [self setVersionLabel:nil];
    [self setStoryTextView:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.storyTextView.backgroundColor = [UIColor clearColor];
    self.storyTextView.opaque = NO;
    self.storyTextView.text = pelotoniaStory;
    self.storyTextView.font = PELOTONIA_SECONDARY_FONT(17);
    self.storyTextView.textColor = PRIMARY_DARK_GRAY;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view delegate

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
    label.textColor = PRIMARY_GREEN;
    label.font = PELOTONIA_FONT(21);
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = SECONDARY_GREEN;
    
    [headerView addSubview:label];
    return headerView;
}


#pragma mark -- Custom Functionality
- (IBAction)twitterButtonClicked:(id)sender {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            // For the sake of brevity, we'll assume there is only one Twitter account present.
            // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
            if ([accountsArray count] > 0) {
                // Grab the initial Twitter account to tweet from.
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                                
                NSDictionary *values = @{@"screen_name": @"Pelotonia", @"follow": @"true"};
                
                //requestForServiceType
                
                SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                            requestMethod:SLRequestMethodPOST
                                                                      URL:[NSURL URLWithString:@"https://api.twitter.com/1/friendships/create.json"] parameters:values];
                [postRequest setAccount:twitterAccount];
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *output = [NSString stringWithFormat:@"HTTP response status: %i Error %d",
                                        [urlResponse statusCode],error.code];
                    NSLog(@"%@error %@", output,error.description);
                }];
            }
            
        }
    }];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setupWebViewController:(PRPWebViewController *)webVC forURL:(NSString *)url
{
    // see the registration form
    webVC.url = [NSURL URLWithString:url];
    webVC.showsDoneButton = NO;
    webVC.delegate = self;
    webVC.backgroundColor = [UIColor colorWithRed:0.151 green:0.151 blue:0.151 alpha:1.000];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToFAQ"]) {
        [self setupWebViewController:segue.destinationViewController forURL:@"http://www.pelotonia.org/ride/faq"];
    }
    
    if ([segue.identifier isEqualToString:@"SegueToPelotonia"]) {
        [self setupWebViewController:segue.destinationViewController forURL:@"http://www.pelotonia.org"];
    }
    
    if ([segue.identifier isEqualToString:@"SegueToSandlot"]) {
        [self setupWebViewController:segue.destinationViewController forURL:@"http://www.isandlot.com/about-us"];
    }

}


#pragma mark - PRPWebViewControllerDelegate
- (void)webControllerDidFinishLoading:(PRPWebViewController *)controller {
    NSLog(@"webControllerDidFinishLoading!");
}

- (void)webController:(PRPWebViewController *)controller didFailLoadWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil]  show];
}


@end
