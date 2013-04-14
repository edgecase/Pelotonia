//
//  AboutTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 9/9/12.
//
//

#import "AboutTableViewController.h"
#import "Pelotonia-Colors.h"

@interface AboutTableViewController ()

@end

@implementation AboutTableViewController
@synthesize versionLabel;
@synthesize storyLabel;
@synthesize doneButton;

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
    self.storyLabel.font = PELOTONIA_SECONDARY_FONT(17);
    
}

- (void)viewDidUnload
{
    [self setVersionLabel:nil];
    [self setStoryLabel:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if (indexPath.section == 0) {
        if (indexPath.row == 0 || indexPath.row == 1) {
            [self pelotoniaPressed:tableView];
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self sandlotPressed:tableView];
        }
        if (indexPath.row == 1) {
            [self newContextPressed:tableView];
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
        label.text = [NSString stringWithFormat:@"Created for Pelotonia By"];
    }
    [headerView addSubview:label];
    return headerView;
}


#pragma mark -- Custom Functionality
- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)openURLFromString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (![[UIApplication sharedApplication] openURL:url])
        
    NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

- (IBAction)revealMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}


- (void)sandlotPressed:(id)sender {
    [self openURLFromString:@"http://www.isandlot.com"];
}

- (void)newContextPressed:(id)sender {
    [self openURLFromString:@"http://www.newcontext.com"];
}

- (void)pelotoniaPressed:(id)sender {
    [self openURLFromString:@"http://www.pelotonia.org"];
}

@end
