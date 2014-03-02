//
//  RiderTableViewCell.m
//  Pelotonia
//
//  Created by Mark Harris on 2/13/14.
//
//

#import "RiderTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"

@implementation RiderTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCellIdentifier:(NSString *)cellID
{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID])
    {
        self.textLabel.font = PELOTONIA_FONT(21);
        self.textLabel.textColor = PRIMARY_GREEN;
        self.textLabel.textColor = PRIMARY_DARK_GRAY;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.font = PELOTONIA_FONT(12);
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = SECONDARY_GREEN;

    }
    return self;
}

/* overrides */
- (void)setRider:(Rider *)rider
{
    if (rider.riderType) {
        self.detailTextLabel.text = rider.riderType;
    }
    self.textLabel.text = rider.name;
    __weak RiderTableViewCell *weakSelf = self;
    
    [self.imageView setImageWithURL:[NSURL URLWithString:rider.riderPhotoThumbUrl]
                   placeholderImage:[UIImage imageNamed:@"profile_default"]
                            options:SDWebImageRefreshCached
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if (error) {
                                  NSLog(@"error: %@", error.localizedDescription);
                              }
                              [weakSelf.imageView setImage:[image thumbnailImage:60 transparentBorder:1 cornerRadius:5 interpolationQuality:kCGInterpolationDefault]];
                              
                              [weakSelf layoutSubviews];
                          } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
}

@end
