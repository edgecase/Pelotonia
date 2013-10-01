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
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"footer"];

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
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 45)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, tableView.bounds.size.width - 10, 25)];
    label.textColor = PRIMARY_GREEN;
    label.font = PELOTONIA_FONT(21);
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor clearColor];

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
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, self.tableView.bounds.size.width-20, 70.0)];
    footerLabel.font = PELOTONIA_SECONDARY_FONT(17);
    footerLabel.text = [NSString stringWithFormat:@"Enter an email address to send a notification with %@'s Pelotonia Profile", self.rider.name];
    footerLabel.textColor = PRIMARY_GREEN;
    footerLabel.numberOfLines = 4;
    footerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [footer.contentView addSubview:footerLabel];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 70.0;
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
