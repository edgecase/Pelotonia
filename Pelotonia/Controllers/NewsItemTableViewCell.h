//
//  NewsItemTableViewCell.h
//  Pelotonia
//
//  Created by Mark Harris on 6/29/14.
//
//

#import "PRPSmartTableViewCell.h"
#import "NewsItem.h"

@interface NewsItemTableViewCell : PRPSmartTableViewCell

@property (nonatomic, strong) NewsItem *newsItem;

+ (CGFloat)calculateHeightForNewsItem:(NewsItem *)item atWidth:(CGFloat)width;

@end
