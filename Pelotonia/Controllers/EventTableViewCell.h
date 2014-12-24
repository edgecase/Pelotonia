//
//  EventTableViewCell.h
//  Pelotonia
//
//  Created by Mark Harris on 6/18/14.
//
//

#import "PRPSmartTableViewCell.h"
#import "Event.h"
#import "EventCategory.h"

@interface EventTableViewCell : PRPSmartTableViewCell

@property (nonatomic, strong) Event *event;

@end
