//
//  SendPledgeModalViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 4/21/13.
//
//

#import "SendPledgeModalViewController.h"

@interface SendPledgeModalViewController ()

@end

@implementation SendPledgeModalViewController

@synthesize delegate;
@synthesize rider;
@synthesize textViewAmount;
@synthesize textViewName;

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
    self.textViewName.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

#pragma mark - Table view data source
// static tables don't need any of this

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
    label.textColor = PRIMARY_GREEN;
    label.font = PELOTONIA_FONT(21);
    label.backgroundColor = [UIColor clearColor];

    label.text = [NSString stringWithFormat:@"Support %@", self.rider.name];
    [headerView addSubview:label];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"footer"];
    if (!footer) {
        footer = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"footer"];
    }

    [footer setFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    footer.textLabel.textColor = PRIMARY_GREEN_ALPHA(.75);
    footer.textLabel.backgroundColor = [UIColor clearColor];
    footer.textLabel.text = [NSString stringWithFormat:@"Send an email to the specified email address, with a link to %@'s Pelotonia Profile page, to make a donation", self.rider.name];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 90.0;
}

#pragma mark -- text field delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:self.tableView];
    rc.origin.x = 0 ;
    rc.origin.y -= 60 ;
    
    rc.size.height = 400;
    [self.tableView scrollRectToVisible:rc animated:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)tf
{
    [tf resignFirstResponder];
    [self done:self.textViewName];
    return YES;
}


- (IBAction)done:(id)sender
{
    [self.delegate sendPledgeModalViewControllerDidFinish:self];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate sendPledgeModalViewControllerDidCancel:self];
}
- (void)viewDidUnload {
    [self setTextViewAmount:nil];
    [self setTextViewName:nil];
    [super viewDidUnload];
}
@end
