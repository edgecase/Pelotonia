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

static CGFloat tableCellWidth = 235;

@implementation CommentTableViewCell

@synthesize titleString;
@synthesize commentString;

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
        self.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        self.textLabel.textColor = PRIMARY_DARK_GRAY;
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.font = PELOTONIA_FONT(14);
        self.detailTextLabel.textColor = SECONDARY_DARK_GREEN;
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.detailTextLabel.backgroundColor = [UIColor clearColor];

    }
    return self;
}

+ (CGFloat)getCellHeightForString:(NSString *)comment withFont:(UIFont *)font
{
    CGSize initialSize = CGSizeMake(tableCellWidth, CGFLOAT_MAX);
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:comment
                                                                         attributes:@{
                                                                                      NSFontAttributeName:font
                                                                                      }];
    CGRect rect = [attributedText boundingRectWithSize:initialSize
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
//    NSLog(@"height of string %@ is %f", comment, ceilf(rect.size.height));
    return ceilf(rect.size.height);
}

+ (CGFloat)getCellHeightForTitle:(NSString *)text
{
    return [[self class] getCellHeightForString:text withFont:[UIFont boldSystemFontOfSize:14.0]];
}

+ (CGFloat)getCellHeightForCommentText:(NSString *)text
{
    return [[self class] getCellHeightForString:text withFont:PELOTONIA_FONT(14)];
}

+ (CGFloat)getTotalHeightForCellWithCommentText:(NSString *)comment andTitle:(NSString *)title
{
    CGFloat height = [[self class] getCellHeightForCommentText:comment] + [[self class] getCellHeightForTitle:title] + 20.0;
    return height;
}


// need this for properly laying out the images, since they're funny sized
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(5,5,40,40);
    float limgW =  self.imageView.image.size.width;
    
    CGFloat commentHeight = [[self class] getCellHeightForCommentText:self.commentString];
    CGFloat titleHeight = [[self class] getCellHeightForTitle:self.titleString];
    
	CGRect newDetailTextFrame = self.detailTextLabel.frame;
    newDetailTextFrame.size.height = commentHeight;
	self.detailTextLabel.text = self.commentString;
    self.detailTextLabel.frame = newDetailTextFrame;
    
    CGRect newTitleFrame = self.textLabel.frame;
    newTitleFrame.size.height = titleHeight;
    self.textLabel.text = self.titleString;
    self.textLabel.frame = newTitleFrame;

    if(limgW > 0)
    {
        self.textLabel.frame = CGRectMake(55, self.imageView.frame.origin.y,tableCellWidth,self.textLabel.frame.size.height);
        self.detailTextLabel.frame = CGRectMake(55, CGRectGetMaxY(self.textLabel.frame)+5,tableCellWidth,self.detailTextLabel.frame.size.height);
    }

    // set the frame up well
	CGRect cellFrame = self.frame;
	cellFrame.size.height = newDetailTextFrame.size.height + newTitleFrame.size.height + 20.0;
	self.frame = cellFrame;
}

@end
