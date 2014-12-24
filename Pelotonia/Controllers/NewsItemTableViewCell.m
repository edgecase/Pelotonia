//
//  NewsItemTableViewCell.m
//  Pelotonia
//
//  Created by Mark Harris on 6/29/14.
//
//

#import "NewsItemTableViewCell.h"
#import "NSDate+Helper.h"
#import "NSDate-Utilities.h"

@implementation NewsItemTableViewCell

@synthesize newsItem = _newsItem;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setNewsItem:(NewsItem *)item {
    _newsItem = item;
    
    self.textLabel.text = [NSString stringWithFormat:@"%@ | %@", [_newsItem.dateTime stringWithFormat:@"MM/dd/yy"], _newsItem.title];
    self.textLabel.font = PELOTONIA_FONT_BOLD(21);
    
    self.detailTextLabel.text = _newsItem.leader;
    self.detailTextLabel.font = PELOTONIA_SECONDARY_FONT(15);
}

+ (CGFloat)calculateHeightForNewsItem:(NewsItem *)item atWidth:(CGFloat)width
{
    CGFloat height = 0.0;
    NSString *titleString = [NSString stringWithFormat:@"%@ | %@",
                             [item.dateTime stringWithFormat:@"MM/dd/yy"], item.title];
    
    // first figure out title size
    CGSize initialSize = CGSizeMake(width, CGFLOAT_MAX);
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:titleString
                                                                         attributes:@{NSFontAttributeName:PELOTONIA_FONT_BOLD(21)}];
    CGRect rect = [attributedText boundingRectWithSize:initialSize
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               context:nil];
    height += ceilf(rect.size.height);
    
    // then add to detail size
    initialSize = CGSizeMake(width, CGFLOAT_MAX);
    attributedText = [[NSAttributedString alloc] initWithString:item.leader
                                                     attributes:@{NSFontAttributeName:PELOTONIA_FONT(15)}];
    rect = [attributedText boundingRectWithSize:initialSize
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        context:nil];
    height += ceilf(rect.size.height);
    
    // then add some buffer
    return height + 15.0;
}

@end
