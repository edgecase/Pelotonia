//
//  EventDetailsTableViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 6/19/14.
//
//

#import "EventDetailsTableViewController.h"
#import "Event.h"
#import "EventCategory.h"
#import "NSDate+Helper.h"
#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "UIImageExtras/UIImage+Resize.h"
#import "PelotoniaWeb.h"

@interface EventDetailsTableViewController ()

@end

@implementation EventDetailsTableViewController

@synthesize event = _event;

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
    self.navigationItem.title = self.event.title;
    self.titleLabel.text = self.event.title;
    self.titleLabel.font = PELOTONIA_FONT_BOLD(21);
    
    __weak EventDetailsTableViewController *wself = self;
    [self.titleTableViewCell.imageView setImageWithURL:[NSURL URLWithString:_event.imageLink]
                   placeholderImage:[UIImage imageNamed:@"83-calendar-gray"]
                            options:SDWebImageRefreshCached
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if (error) {
                                  NSLog(@"error setting event image: %@", [error localizedDescription]);
                              }
                              else {
                                  [wself.titleTableViewCell.imageView setImage:[image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(50, 50) interpolationQuality:kCGInterpolationDefault]];
                                  [wself.titleTableViewCell layoutSubviews];
                              }
    }];

    
    self.dateTime.font = PELOTONIA_SECONDARY_FONT(18);
    self.dateTime.enabledTextCheckingTypes = NSTextCheckingTypeDate;
    self.dateTime.text = [NSString stringWithFormat:@"%@ -> %@ to %@",
                          [self.event.startDateTime stringWithFormat:@"MMM dd, yyyy "],
                          [self.event.startDateTime stringWithFormat:@"h:mm a"],
                          [self.event.endDateTime stringWithFormat:@"h:mm a"]];
    self.dateTime.textColor = [UIColor whiteColor];
    self.dateTime.delegate = self;
    
    self.venueLabel.numberOfLines = 0;
    self.venueLabel.enabledTextCheckingTypes = NSTextCheckingTypeAddress;
    self.venueLabel.text = self.event.address;
    self.venueLabel.textColor = PRIMARY_DARK_GRAY;
    self.venueLabel.font = PELOTONIA_SECONDARY_FONT(18);
    self.venueLabel.minimumLineHeight = self.venueLabel.font.lineHeight;
    self.venueLabel.autoresizingMask =  UIViewAutoresizingFlexibleHeight;
    self.venueLabel.delegate = self;

    self.descriptionCell.textLabel.font = PELOTONIA_SECONDARY_FONT(16);

    if (self.event.eventDesc == nil) {
        [PelotoniaWeb getEventDescription:self.event onComplete:^(Event *e) {
            self.descriptionCell.textLabel.text = self.event.eventDesc;
            [self.tableView reloadData];
        } onFailure:^(NSString *errorText) {
            self.descriptionCell.textLabel.text = @"Unable to load event description";
            [self.tableView reloadData];
        }];
    }
    else {
        self.descriptionCell.textLabel.text = self.event.eventDesc;
        [self.tableView reloadData];
    }
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
    
    if (indexPath.row == 3 && self.event.eventDesc) {
        // event details path
        height = [self calculateTableRowSizeForString:self.event.eventDesc
                                          usingFont:self.descriptionCell.textLabel.font
                                           forWidth:self.tableView.bounds.size.width];
    }
    else if (indexPath.row == 2) {
        height = [self calculateTableRowSizeForString:self.event.address
                                            usingFont:self.descriptionCell.textLabel.font
                                             forWidth:self.tableView.bounds.size.width];
        height += 10.0;
    }
    else {
        height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return height;
}

// TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithAddress:(NSDictionary *)addressComponents
{
    // peel out the address from the label & open the map
    if (label == self.venueLabel) {
        NSString *mapsScheme = @"http://maps.apple.com/?q=%@";
        NSString *address = [addressComponents valueForKey:NSTextCheckingStreetKey];
        NSString *city = [addressComponents valueForKey:NSTextCheckingCityKey];
        if (city) {
            address = [address stringByAppendingString:[NSString stringWithFormat:@",%@", city]];
        }

        NSString *state = [addressComponents valueForKey:NSTextCheckingStateKey];
        if (state) {
            address = [address stringByAppendingString:[NSString stringWithFormat:@",%@", state]];
        }
        
        NSString *stringURL = [NSString stringWithFormat:mapsScheme, [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithDate:(NSDate *)date
{
    if (label == self.dateTime) {
        // create a reminder in the calendar from the date/time
        EKEventStore *store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                // create the event in their calendar
                EKEvent *newEvent = [EKEvent eventWithEventStore:store];
                newEvent.title = self.event.title;
                newEvent.startDate = self.event.startDateTime;
                newEvent.endDate = self.event.endDateTime;
                newEvent.location = self.event.address;
                
                EKEventEditViewController *evc = [[EKEventEditViewController alloc] init];
                evc.event = newEvent;
                evc.eventStore = store;
                evc.editViewDelegate = self;
                [self presentViewController:evc animated:YES completion:nil];
            }
            
        }];
        
    }
}


#pragma mark -- EKEventEditViewDelegate methods
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
