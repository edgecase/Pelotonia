//
//  NewsDetailTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 6/29/14.
//
//

#import "NewsDetailTableViewController.h"
#import "NSDate+Helper.h"
#import "NSDate-Utilities.h"
#import "PelotoniaWeb.h"

@interface NewsDetailTableViewController ()

@end

@implementation NewsDetailTableViewController

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
    [PelotoniaWeb getPelotoniaNewsDetailOnComplete:self.item onComplete:^(NewsItem *i) {
        [self configureView];
    } onFailure:^(NSString *e) {
        NSLog(@"unable to retrieve news detail: %@", e);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView
{
    self.titleLabel.text = self.item.title;
    self.titleLabel.font = PELOTONIA_FONT_BOLD(21);
    self.dateLabel.text = [self.item.dateTime stringWithFormat:@"MMM dd, yyyy"];
    self.dateLabel.font = PELOTONIA_SECONDARY_FONT(18);
    self.detailLabel.text = self.item.detail;
    self.detailLabel.font = PELOTONIA_SECONDARY_FONT(18);
    [self.tableView reloadData];
}

- (CGFloat) calculateTableRowSizeForString:(NSString *)string usingFont:(UIFont *)font forWidth:(CGFloat)width
{
    CGSize initialSize = CGSizeMake(width, CGFLOAT_MAX);
    
    NSAttributedString *attributedText =
    [[NSAttributedString alloc] initWithString:string
                                    attributes:@{NSFontAttributeName:font}];
    
    CGRect rect = [attributedText boundingRectWithSize:initialSize
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               context:nil];
    return ceilf(rect.size.height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    if (indexPath.row == 0 && self.item.title) {
        height = [self calculateTableRowSizeForString:self.item.title
                                            usingFont:self.titleLabel.font
                                             forWidth:self.tableView.bounds.size.width];
    }
    else if (indexPath.row == 2 && self.item.detail) {
        height = [self calculateTableRowSizeForString:self.item.detail
                                            usingFont:PELOTONIA_SECONDARY_FONT(18)
                                             forWidth:self.tableView.bounds.size.width];
        height += 10.0;
    }
    else {
        height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return height;
}
- (IBAction)actionButtonPressed:(id)sender {
    NSString *dash = [NSString stringWithUTF8String:"\xe2\x80\x93"];
    NSRange range = [self.item.detail rangeOfString:dash];
    NSString *teaser;
    if (range.location == NSNotFound) {
        teaser = [[self.item.detail substringToIndex:70] stringByAppendingString:@"..."];
    }
    else {
        teaser = [[[self.item.detail substringFromIndex:range.location+1] substringToIndex:70] stringByAppendingString:@"..."];
    }
    NSArray* dataToShare = @[self.item.title, teaser, [NSURL URLWithString:self.item.detailLink]];
    
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}
@end
