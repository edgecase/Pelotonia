//
//  CommentTableViewCell.m
//  Pelotonia
//
//  Created by Mark Harris on 7/7/13.
//
//

#import "CommentTableViewCell.h"
#import "UIImage+Resize.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation CommentTableViewCell

@synthesize mainLabel;
@synthesize dateLabel;

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
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        self.textLabel.textColor = PRIMARY_DARK_GRAY;
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.detailTextLabel.font = PELOTONIA_FONT(14);
        self.detailTextLabel.textColor = SECONDARY_DARK_GREEN;
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return self;
}

+(CGFloat)sizeForComment:(id<SocializeComment>)comment
{
    // figure out the height of comment cells
    CGSize initialSize = CGSizeMake(300, MAXFLOAT);

    NSString *commentText = [comment text];
    CGSize sz = [commentText sizeWithFont:PELOTONIA_FONT(14) constrainedToSize:initialSize];
    CGSize szDetail = [@"User, Jan 1, 2001" sizeWithFont:[UIFont boldSystemFontOfSize:15.0] constrainedToSize:initialSize];
    
    return sz.height + szDetail.height + 20.0;
}


@end
