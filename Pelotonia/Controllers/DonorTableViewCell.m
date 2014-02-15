//
//  RiderTableViewCell.m
//  Pelotonia
//
//  Created by Mark Harris on 2/13/14.
//
//

#import "DonorTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"

@implementation DonorTableViewCell

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
        self.backgroundColor = PRIMARY_DARK_GRAY;
        self.textLabel.font = PELOTONIA_FONT(21);
        self.textLabel.textColor = SECONDARY_LIGHT_GRAY;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.font = PELOTONIA_FONT(18);
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = SECONDARY_GREEN;

    }
    return self;
}

/* overrides */
- (void)setDonor:(Donor *)donor
{
    self.detailTextLabel.text = donor.date;
    self.textLabel.text = [NSString stringWithFormat:@"%@  %@", donor.name, donor.amount];
}

@end
