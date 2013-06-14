//
//  UserProfileViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 4/26/13.
//
//

#import "UserProfileViewController.h"
#import "PelotoniaLogInViewController.h"
#import "PelotoniaSignUpViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

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


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView
{
    // update the UI of the app appropriately.
    if ([PFUser currentUser]) { // user is logged in
        [self.signInOutButton setTitle:@"Log Out"];
        
    }
    else {
        [self.signInOutButton setTitle:@"Sign In/Up"];
    }
}

- (void)showSignInOutDialog
{
    // Create the log in view controller
    PelotoniaLogInViewController *logInViewController = [[PelotoniaLogInViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
    [logInViewController setFields: PFLogInFieldsDefault | PFLogInFieldsPasswordForgotten | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsDismissButton];
    
    // Create the sign up view controller
    PelotoniaSignUpViewController *signUpViewController = [[PelotoniaSignUpViewController alloc] init];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    [signUpViewController setFields: PFSignUpFieldsEmail | PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsSignUpButton | PFSignUpFieldsDismissButton];
    
    // Assign our sign up controller to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        // get the user's RiderID and get the rider object
        // fire up rider search box
        
        // copy properties from the rider object into this rider
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            // name/rider type cell
            if ([PFUser currentUser])
            {
                // user is logged in
                PFUser *currentUser = [PFUser currentUser];
                NSDictionary *profile = [currentUser objectForKey:@"profile"];
                if (profile)
                {
                    cell.textLabel.font = PELOTONIA_FONT(18);
                    cell.textLabel.text = [profile objectForKey:@"name"];
                    
                    // this masks the photo to the tableviewcell
                    cell.imageView.layer.masksToBounds = YES;
                    cell.imageView.layer.cornerRadius = 5.0;

                    __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [cell.imageView addSubview:activityIndicator];
                    activityIndicator.center = cell.imageView.center;
                    [activityIndicator startAnimating];

                    // get the user's photo from the profile object
                    NSURL *url = [NSURL URLWithString:[profile objectForKey:@"pictureURL"]];
                    [cell.imageView setImageWithURL:url
                                   placeholderImage:[UIImage imageNamed:@"pelotonia-icon.png"]
                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
                     {
                         if (error != nil) {
                             NSLog(@"ProfileTableViewController::configureView error: %@", error.localizedDescription);
                         }
                         [activityIndicator removeFromSuperview];
                         activityIndicator = nil;
                         [cell layoutSubviews];
                     }];
                }
                else
                {
                    cell.textLabel.text = currentUser.username;
                }
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 26;
    }
    else
    {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"Recent Activity";
    }
    else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 24)];
    label.textColor = PRIMARY_GREEN;
    label.font = PELOTONIA_FONT(24);
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor blackColor];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    
    [headerView addSubview:label];
    return headerView;
}

#pragma mark -- menu code
- (IBAction)revealMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)signInOutPressed:(id)sender
{
    if (![PFUser currentUser]) { // no one logged in
        [self showSignInOutDialog];
    }
    else {
        [PFUser logOut];
    }
    [self configureView];
}

- (IBAction)shareButtonPressed:(id)sender {
}


#pragma mark -- PFLoginController/PFSignUpController delegates
// update the user's information from facebook or twitter if we can
- (void)updateProfile:(PFUser *)user
{
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error)
        {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:4];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            if (userData[@"name"]) {
                userProfile[@"name"] = userData[@"name"];
            }
            
            if (userData[@"location"][@"name"]) {
                userProfile[@"location"] = userData[@"location"][@"name"];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] saveEventually];
            
        }
        else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString: @"OAuthException"])
        {
            // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        }
        else
        {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"We need your email and password before you can log in."
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    // just signed up & logged in with facebook/twitter/whatever, so get the user's info if we can
    if (!user)
    {
        NSLog(@"The user cancelled the Facebook login.");
    }
    else if (user.isNew)
    {
        NSLog(@"User with facebook signed up and logged in!");
        [self updateProfile:user];
    }
    else
    {
        NSLog(@"User with facebook logged in!");
        [self updateProfile:user];
    }
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}




- (void)viewDidUnload {
    [self setSignInOutButton:nil];
    [self setUserName:nil];
    [self setUserType:nil];
    [self setUserProfileImageView:nil];
    [self setShareButton:nil];
    [super viewDidUnload];
}
@end
