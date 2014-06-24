//
//  EventTableViewCell.m
//  Pelotonia
//
//  Created by Mark Harris on 6/18/14.
//
//

#import "EventTableViewCell.h"
#import "NSDate+Helper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageExtras/UIImage+Resize.h"


@implementation EventTableViewCell

@synthesize event = _event;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setEvent:(Event *)event {
    _event = event;
    self.textLabel.text = _event.title;
    self.textLabel.font = PELOTONIA_FONT_BOLD(21);
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [_event.startDateTime stringWithFormat:@"MMM dd h:mm a"], [_event.endDateTime stringWithFormat:@"h:mm a"]];
    self.detailTextLabel.font = PELOTONIA_SECONDARY_FONT(15);
    
    __weak EventTableViewCell *wself = self;
    
    [self.imageView setImageWithURL:[NSURL URLWithString:_event.imageLink]
                   placeholderImage:[UIImage imageNamed:@"83-calendar-gray"]
                            options:SDWebImageRefreshCached
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (error) {
            NSLog(@"error setting event image: %@", [error localizedDescription]);
        }
        else {
            [wself.imageView setImage:[image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(50, 50) interpolationQuality:kCGInterpolationDefault]];
            [wself layoutSubviews];
        }
    }];
}

@end
