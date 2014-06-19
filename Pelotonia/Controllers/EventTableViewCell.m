//
//  EventTableViewCell.m
//  Pelotonia
//
//  Created by Mark Harris on 6/18/14.
//
//

#import "EventTableViewCell.h"

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
    self.detailTextLabel.text = _event.address;
}

@end
