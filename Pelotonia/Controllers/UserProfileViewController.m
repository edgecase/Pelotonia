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
#import <Socialize/Socialize.h>

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController


@synthesize currentUser;
@synthesize recentActions;

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
    self.currentUser = [SZUserUtils currentUser];
    [self getActionsByUserOnAllEntities];
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

- (void)getActionsByUserOnAllEntities {
    [SZActionUtils getActionsByUser:nil start:nil end:nil success:^(NSArray *actions) {
        self.recentActions = actions;

        for (id<SZActivity> action in actions) {
            NSLog(@"Found action %d by user %@ %@", [action objectID], [action.user firstName], [action.user lastName]);
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"Failure: %@", [error localizedDescription]);
    }];
}

- (void)configureView
{
    [self setUserNameCell:nil];
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self performSelector:NSSelectorFromString(segue.identifier) withObject:segue.destinationViewController];
}

- (void)showPelotoniaRiderProfile:(ProfileTableViewController *)profileTableViewController
{
    NSLog(@"executing showPelotoniaRiderProfile");
    NSString *riderID;
    
    Rider *rider = [[Rider alloc] initWithName:@"Mark Harris" andId:@"MH0015"];
    if (rider)
    {
        profileTableViewController.rider = rider;
    }
    else
    {
        NSLog(@"rider not found %@", riderID);
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            [SZUserUtils showUserSettingsInViewController:self completion:^{
                NSLog(@"Done showing settings");
            }];
        }
        else if (indexPath.row == 1)
        {
            
            // get the user's RiderID and get the rider object
            // fire up rider search box
            NSString *riderID = nil;
            
            if (nil != riderID)
            {
                // transition to the rider's profile
                /// execute segue
                [self performSegueWithIdentifier:@"showPelotoniaRiderProfile:" sender:self];
            }
            else
            {
                [self linkProfileToPelotonia];
            }
        }
    }
}

- (void)setUserNameCell:(__weak UITableViewCell *)cell
{
    
    self.userName.text  = [NSString stringWithFormat:@"%@ %@", [self.currentUser firstName], [self.currentUser lastName]];
    self.userType.text = [self.currentUser description];
    
    // this masks the photo to the tableviewcell
    self.userProfileImageView.layer.masksToBounds = YES;
    self.userProfileImageView.layer.cornerRadius = 5.0;
    [self.userProfileImageView setImageWithURL:[NSURL URLWithString:[self.currentUser large_image_uri]]
                   placeholderImage:[UIImage imageNamed:@"pelotonia-icon.png"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              [cell layoutSubviews];
                          }
     ];
}

- (void)linkProfileToPelotonia
{
    // prompt user for his/her credentials
    
    // post against the pelotonia login form
    
    // if it comes back OK, then add a user ID to the current user object
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *_cell;

    // only handle the dynamic section.  static cells handled in configureView
    if (indexPath.section == 0)
    {
        _cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    if (indexPath.section == 1)
    {
        // current activity
        
        _cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return _cell;
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
        return @"Activity";
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        NSInteger num = [self.recentActions count];
        NSLog(@"Section 1 has %d cells", num);
        return num;
    }
    else
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat sz = 26;
    
    if (indexPath.section == 1)
    {
        // figure out Pelotonia activity cell
        sz = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else
    {
        sz = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    return sz;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    
    // if dynamic section make all rows the same indentation level as row 0
    if (section == 1)
    {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    }
    else
    {
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



#pragma mark -- menu code
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)shareButtonPressed:(id)sender
{
    
}


- (void)viewDidUnload {
    [self setUserName:nil];
    [self setUserType:nil];
    [self setUserProfileImageView:nil];
    [self setShareButton:nil];
    [super viewDidUnload];
}
@end
