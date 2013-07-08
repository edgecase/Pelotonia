//
//  CommentTableViewCell.h
//  Pelotonia
//
//  Created by Mark Harris on 7/7/13.
//
//

#import "PRPSmartTableViewCell.h"
#import <Socialize/Socialize.h>

@interface CommentTableViewCell : PRPSmartTableViewCell

@property (strong, nonatomic) UILabel *mainLabel;
@property (strong, nonatomic) UILabel *dateLabel;

+(CGFloat)sizeForComment:(id<SZComment>)comment;

@end
