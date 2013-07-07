//
//  CommentTableViewCell.m
//  Pelotonia
//
//  Created by Mark Harris on 7/7/13.
//
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

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
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID]) {
        self.textLabel.text = @"this is a test";
    }
    return self;
}


@end
