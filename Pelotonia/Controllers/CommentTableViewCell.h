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

@property (strong, nonatomic) NSString *commentString;
@property (strong, nonatomic) NSString *titleString;

+ (CGFloat)getCellHeightForString:(NSString *)comment withFont:(UIFont *)font;
+ (CGFloat)getCellHeightForTitle:(NSString *)text;
+ (CGFloat)getCellHeightForCommentText:(NSString *)text;
+ (CGFloat)getTotalHeightForCellWithCommentText:(NSString *)comment andTitle:(NSString *)title;
@end
